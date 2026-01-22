-- Trigger Function to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to tables
DROP TRIGGER IF EXISTS trg_tasks_auto_updated_at ON tasks;
CREATE TRIGGER trg_tasks_auto_updated_at
BEFORE UPDATE ON tasks
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trg_users_auto_updated_at ON users;
CREATE TRIGGER trg_users_auto_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Stored Procedure to archive overdue tasks
CREATE OR REPLACE PROCEDURE archive_overdue_tasks(p_team_id UUID)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE tasks
    SET status = 'done'
    WHERE team_id = p_team_id
      AND status != 'done'
      AND due_date < CURRENT_TIMESTAMP;
END;
$$;
