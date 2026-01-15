-- ============================================================================
-- STEP 4: COMMON QUERIES (DML Practice)
-- ============================================================================
-- Practice running these SELECT and UPDATE queries to see how relational
-- databases work in real full-stack applications.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Tenant Isolation Query
-- "Get all tasks that belong to the Engineering Team"
-- In multi-tenant systems, we ALWAYS filter by team_id to keep tenant data isolated.
-- ----------------------------------------------------------------------------
SELECT 
    id, 
    title, 
    status, 
    priority 
FROM tasks 
WHERE team_id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';


-- ----------------------------------------------------------------------------
-- 2. One-to-Many JOIN Query
-- "Get a task along with its assignee name and all comments"
-- ----------------------------------------------------------------------------
SELECT 
    t.title AS task_title,
    t.status,
    u.full_name AS assigned_to,
    c.content AS comment_text,
    c.created_at AS commented_at
FROM tasks t
LEFT JOIN users u ON t.assignee_id = u.id
LEFT JOIN comments c ON t.id = c.task_id
WHERE t.id = '99999999-9999-4999-8999-999999999999';


-- ----------------------------------------------------------------------------
-- 3. Many-to-Many JOIN Query
-- "Get a task along with all its tags"
-- We join tasks -> task_tags -> tags
-- ----------------------------------------------------------------------------
SELECT 
    t.title,
    tg.name AS tag_name,
    tg.color_hex
FROM tasks t
JOIN task_tags tt ON t.id = tt.task_id
JOIN tags tg ON tt.tag_id = tg.id
WHERE t.id = '99999999-9999-4999-8999-999999999999';


-- ----------------------------------------------------------------------------
-- 4. Querying Inside JSONB (Leveraging GIN Index)
-- "Find tasks that have the environment set to 'docker' inside their metadata"
-- ----------------------------------------------------------------------------
SELECT 
    title, 
    metadata 
FROM tasks 
WHERE metadata @> '{"environment": "docker"}';


-- ----------------------------------------------------------------------------
-- 5. UPDATE Query (Updating task status and timestamp)
-- ----------------------------------------------------------------------------
UPDATE tasks 
SET status = 'done', 
    updated_at = CURRENT_TIMESTAMP 
WHERE id = '99999999-9999-4999-8999-999999999999';
