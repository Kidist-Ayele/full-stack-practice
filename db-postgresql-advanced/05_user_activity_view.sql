-- View: Aggregating user activity statistics
CREATE OR REPLACE VIEW user_activity_stats AS
SELECT 
    u.id AS user_id,
    u.full_name,
    u.email,
    COUNT(DISTINCT m.team_id) AS total_teams,
    COUNT(DISTINCT t_created.id) AS tasks_created,
    COUNT(DISTINCT t_assigned.id) AS tasks_assigned,
    COUNT(DISTINCT t_assigned.id) FILTER (WHERE t_assigned.status = 'done') AS tasks_completed,
    COUNT(DISTINCT c.id) AS comments_posted,
    u.created_at AS member_since
FROM users u
LEFT JOIN memberships m ON u.id = m.user_id
LEFT JOIN tasks t_created ON u.id = t_created.creator_id
LEFT JOIN tasks t_assigned ON u.id = t_assigned.assignee_id
LEFT JOIN comments c ON u.id = c.user_id
GROUP BY u.id, u.full_name, u.email, u.created_at;

-- Query the view
SELECT * FROM user_activity_stats;
