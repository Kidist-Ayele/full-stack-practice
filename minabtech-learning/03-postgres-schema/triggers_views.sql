-- 1. Trigger Function to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION set_updated_at_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_update_tasks_timestamp
BEFORE UPDATE ON tasks
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_timestamp();
-- 2. View aggregating user activity statistics
CREATE OR REPLACE VIEW user_activity_stats AS
SELECT 
    u.id AS user_id,
    u.full_name,
    u.email,
    COUNT(DISTINCT t.id) AS total_tasks,
    COUNT(DISTINCT t.id) FILTER (WHERE t.status = 'done') AS completed_tasks,
    COUNT(DISTINCT c.id) AS total_comments
FROM users u
LEFT JOIN tasks t ON u.id = t.assigned_to
LEFT JOIN comments c ON u.id = c.user_id
GROUP BY u.id, u.full_name, u.email;
