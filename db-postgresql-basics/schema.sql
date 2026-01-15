-- ============================================================================
-- Multi-Tenant Task Management Database Schema
-- Database: PostgreSQL 14+
-- ============================================================================

-- Enable pgcrypto if needed (in Postgres 13+, gen_random_uuid() is built-in)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ----------------------------------------------------------------------------
-- 1. Helper Function & Trigger for Auto-Updating `updated_at`
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_timestamp_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- 2. DDL: Entities & Tables
-- ----------------------------------------------------------------------------

-- USERS Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_timestamp_column();

-- TEAMS Table (Tenants)
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_teams_updated_at
BEFORE UPDATE ON teams
FOR EACH ROW
EXECUTE FUNCTION update_timestamp_column();

-- MEMBERSHIPS Table (Many-to-Many between Users and Teams with Roles)
CREATE TABLE memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL DEFAULT 'member',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Prevent duplicate membership within the same team
    CONSTRAINT uq_team_user UNIQUE (team_id, user_id),
    -- Role validation constraint
    CONSTRAINT check_valid_role CHECK (role IN ('owner', 'admin', 'member', 'guest'))
);

-- TASKS Table (Scoped to a Tenant/Team)
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    creator_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    assignee_id UUID REFERENCES users(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(30) NOT NULL DEFAULT 'todo',
    priority VARCHAR(20) NOT NULL DEFAULT 'medium',
    due_date TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Status & Priority constraints
    CONSTRAINT check_task_status CHECK (status IN ('todo', 'in_progress', 'in_review', 'done', 'archived')),
    CONSTRAINT check_task_priority CHECK (priority IN ('low', 'medium', 'high', 'urgent'))
);

CREATE TRIGGER trg_tasks_updated_at
BEFORE UPDATE ON tasks
FOR EACH ROW
EXECUTE FUNCTION update_timestamp_column();

-- COMMENTS Table (One-to-Many: Task -> Comments)
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_comment_not_empty CHECK (length(trim(content)) > 0)
);

CREATE TRIGGER trg_comments_updated_at
BEFORE UPDATE ON comments
FOR EACH ROW
EXECUTE FUNCTION update_timestamp_column();

-- TAGS Table (Scoped to Team/Tenant)
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    color_hex VARCHAR(7) DEFAULT '#6B7280',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Tag names must be unique within a team
    CONSTRAINT uq_team_tag_name UNIQUE (team_id, name),
    CONSTRAINT check_hex_color CHECK (color_hex ~* '^#[0-9A-Fa-f]{6}$')
);

-- TASK_TAGS Table (Many-to-Many Junction Table between Tasks and Tags)
CREATE TABLE task_tags (
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (task_id, tag_id)
);

-- ----------------------------------------------------------------------------
-- 3. Indexes (B-Tree and GIN)
-- ----------------------------------------------------------------------------

-- B-Tree Indexes on Foreign Keys (Crucial for JOIN performance & Cascade Deletions)
CREATE INDEX idx_memberships_user_id ON memberships(user_id);
CREATE INDEX idx_tasks_team_id ON tasks(team_id);
CREATE INDEX idx_tasks_assignee_id ON tasks(assignee_id);
CREATE INDEX idx_tasks_status ON tasks(team_id, status);
CREATE INDEX idx_comments_task_id ON comments(task_id);
CREATE INDEX idx_task_tags_tag_id ON task_tags(tag_id);

-- B-Tree Index for range / ordering queries
CREATE INDEX idx_tasks_due_date ON tasks(team_id, due_date) WHERE due_date IS NOT NULL;

-- GIN Index for JSONB metadata querying
CREATE INDEX idx_tasks_metadata_gin ON tasks USING gin(metadata);

-- ----------------------------------------------------------------------------
-- 4. DML: Seed Data Demonstration
-- ----------------------------------------------------------------------------

-- Insert Users
INSERT INTO users (id, email, full_name) VALUES
    ('11111111-1111-4111-8111-111111111111', 'alice@company.com', 'Alice Smith'),
    ('22222222-2222-4222-8222-222222222222', 'bob@company.com', 'Bob Johnson'),
    ('33333333-3333-4333-8333-333333333333', 'carol@partner.com', 'Carol Williams');

-- Insert Teams (Tenants)
INSERT INTO teams (id, name, slug) VALUES
    ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Engineering Core', 'engineering-core'),
    ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'Marketing Launch', 'marketing-launch');

-- Insert Memberships
INSERT INTO memberships (team_id, user_id, role) VALUES
    ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '11111111-1111-4111-8111-111111111111', 'owner'),
    ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '22222222-2222-4222-8222-222222222222', 'member'),
    ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', '22222222-2222-4222-8222-222222222222', 'admin');

-- Insert Tags
INSERT INTO tags (id, team_id, name, color_hex) VALUES
    ('77777777-7777-4777-8777-777777777777', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'backend', '#3B82F6'),
    ('88888888-8888-4888-8888-888888888888', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'bug', '#EF4444');

-- Insert Tasks
INSERT INTO tasks (id, team_id, creator_id, assignee_id, title, status, priority, metadata) VALUES
    (
        '99999999-9999-4999-8999-999999999999',
        'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        '11111111-1111-4111-8111-111111111111',
        '22222222-2222-4222-8222-222222222222',
        'Set up database migrations',
        'in_progress',
        'high',
        '{"estimated_hours": 4, "device": "cloud"}'::jsonb
    );

-- Insert Task-Tag Associations
INSERT INTO task_tags (task_id, tag_id) VALUES
    ('99999999-9999-4999-8999-999999999999', '77777777-7777-4777-8777-777777777777');

-- Insert Comment
INSERT INTO comments (task_id, user_id, content) VALUES
    ('99999999-9999-4999-8999-999999999999', '11111111-1111-4111-8111-111111111111', 'Initial schema drafted. Ready for review.');

-- ----------------------------------------------------------------------------
-- 5. Example Queries (DML)
-- ----------------------------------------------------------------------------

-- Multi-Tenant Isolation Query: Get all tasks for Engineering team with tags and assignee
-- SELECT 
--     t.id AS task_id,
--     t.title,
--     t.status,
--     u.full_name AS assignee,
--     COALESCE(array_agg(tg.name) FILTER (WHERE tg.name IS NOT NULL), '{}') AS tags
-- FROM tasks t
-- LEFT JOIN users u ON t.assignee_id = u.id
-- LEFT JOIN task_tags tt ON t.id = tt.task_id
-- LEFT JOIN tags tg ON tt.tag_id = tg.id
-- WHERE t.team_id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'
-- GROUP BY t.id, t.title, t.status, u.full_name;
