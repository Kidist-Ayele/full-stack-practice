-- ============================================================================
-- STEP 2: INDEXES (Speeding up queries)
-- ============================================================================
-- Why do we need indexes?
-- Without an index, Postgres must scan every row in a table (Full Table Scan).
-- With an index, Postgres uses a tree lookup to find rows instantly.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. B-Tree Indexes (The standard, default index in PostgreSQL)
-- ----------------------------------------------------------------------------
-- Best for:
--  - Foreign keys (vital for fast JOINs and fast cascading deletes)
--  - Filtering by status, date, or specific values (=, <, >, BETWEEN)

-- Index on team_id: Multi-tenant queries always filter by team_id
CREATE INDEX idx_tasks_team_id ON tasks(team_id);

-- Index on assignee_id: Fast lookup for "Show all tasks assigned to Alice"
CREATE INDEX idx_tasks_assignee_id ON tasks(assignee_id);

-- Composite B-Tree index: Filters for "team_id AND status" (e.g. active tasks)
CREATE INDEX idx_tasks_team_status ON tasks(team_id, status);

-- Index for comments belonging to a task
CREATE INDEX idx_comments_task_id ON comments(task_id);

-- ----------------------------------------------------------------------------
-- 2. GIN Index (Generalized Inverted Index)
-- ----------------------------------------------------------------------------
-- Best for:
--  - JSONB columns, arrays, and full-text search
--  - Lets you search for keys or values *inside* JSON without scanning all rows

-- Index the JSONB metadata column on tasks
CREATE INDEX idx_tasks_metadata_gin ON tasks USING gin(metadata);
