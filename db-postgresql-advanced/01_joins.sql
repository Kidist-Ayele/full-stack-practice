-- INNER JOIN
SELECT 
    t.id AS task_id,
    t.title AS task_title,
    t.status,
    u.full_name AS assignee_name,
    u.email AS assignee_email
FROM tasks t
INNER JOIN users u ON t.assignee_id = u.id;

-- LEFT JOIN
SELECT 
    t.id AS task_id,
    t.title AS task_title,
    t.status,
    COALESCE(u.full_name, 'Unassigned') AS assignee_name
FROM tasks t
LEFT JOIN users u ON t.assignee_id = u.id;

-- RIGHT JOIN
SELECT 
    u.full_name,
    u.email,
    t.title AS assigned_task_title
FROM tasks t
RIGHT JOIN users u ON t.assignee_id = u.id;

-- FULL OUTER JOIN
SELECT 
    COALESCE(t.title, '[No Task]') AS task_title,
    COALESCE(u.full_name, '[No Assignee]') AS user_name
FROM tasks t
FULL OUTER JOIN users u ON t.assignee_id = u.id;

-- Multi-Table JOIN
SELECT 
    tm.name AS team_name,
    t.title AS task_title,
    COALESCE(u.full_name, 'Unassigned') AS assignee,
    tg.name AS tag_name
FROM tasks t
JOIN teams tm ON t.team_id = tm.id
LEFT JOIN users u ON t.assignee_id = u.id
LEFT JOIN task_tags tt ON t.id = tt.task_id
LEFT JOIN tags tg ON tt.tag_id = tg.id;
