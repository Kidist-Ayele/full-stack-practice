-- Group by status
SELECT 
    status,
    COUNT(*) AS total_tasks
FROM tasks
GROUP BY status
ORDER BY total_tasks DESC;

-- Aggregations per team
SELECT 
    tm.name AS team_name,
    COUNT(t.id) AS total_tasks,
    MIN(t.created_at) AS first_task_created_at,
    MAX(t.created_at) AS latest_task_created_at
FROM teams tm
LEFT JOIN tasks t ON tm.id = t.team_id
GROUP BY tm.id, tm.name;

-- Conditional counts with FILTER
SELECT 
    tm.name AS team_name,
    COUNT(t.id) AS total_tasks,
    COUNT(t.id) FILTER (WHERE t.status = 'todo') AS todo_count,
    COUNT(t.id) FILTER (WHERE t.status = 'in_progress') AS in_progress_count,
    COUNT(t.id) FILTER (WHERE t.status = 'done') AS completed_count
FROM teams tm
LEFT JOIN tasks t ON tm.id = t.team_id
GROUP BY tm.id, tm.name;

-- Aggregate tags into an array
SELECT 
    t.id AS task_id,
    t.title,
    COALESCE(ARRAY_AGG(tg.name) FILTER (WHERE tg.name IS NOT NULL), '{}') AS tag_list
FROM tasks t
LEFT JOIN task_tags tt ON t.id = tt.task_id
LEFT JOIN tags tg ON tt.tag_id = tg.id
GROUP BY t.id, t.title;

-- Filter groups using HAVING
SELECT 
    tm.name AS team_name,
    COUNT(t.id) AS task_count
FROM teams tm
JOIN tasks t ON tm.id = t.team_id
GROUP BY tm.id, tm.name
HAVING COUNT(t.id) >= 2;
