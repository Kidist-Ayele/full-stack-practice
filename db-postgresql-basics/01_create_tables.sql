-- ============================================================================
-- STEP 1: TABLES & RELATIONSHIPS (DDL)
-- ============================================================================
-- This file defines the core tables for a Multi-Tenant Task Management App.
--
-- Concepts demonstrated:
-- 1. UUID v4 as IDs (gen_random_uuid())
-- 2. Primary Keys (PRIMARY KEY) & Foreign Keys (REFERENCES ... ON DELETE)
-- 3. Constraints (UNIQUE, CHECK, NOT NULL)
-- 4. One-to-Many & Many-to-Many relationships
-- 5. created_at & updated_at timestamps
-- ============================================================================

-- Enable UUID generator function (built-in in PostgreSQL 13+)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ----------------------------------------------------------------------------
-- 1. USERS (Application users)
-- ----------------------------------------------------------------------------
CREATE TABLE users (
    -- UUID v4: Random, secure, non-guessable primary key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- UNIQUE constraint: No two users can register with the same email
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    
    -- Timestamps to record when the account was created and last updated
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- 2. TEAMS (The Tenant Boundary)
-- In a multi-tenant app, a "Team" (or organization) owns the data.
-- ----------------------------------------------------------------------------
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    
    -- URL-friendly unique slug (e.g. 'engineering-team')
    slug VARCHAR(100) NOT NULL UNIQUE,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- 3. MEMBERSHIPS (Junction Table: Users <-> Teams)
-- A user can belong to multiple teams, and a team has many users.
-- ----------------------------------------------------------------------------
CREATE TABLE memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Foreign Keys: If team or user is deleted, remove their membership (CASCADE)
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- CHECK constraint: Only allow specific roles
    role VARCHAR(20) NOT NULL DEFAULT 'member' 
        CHECK (role IN ('owner', 'admin', 'member')),
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Composite UNIQUE constraint: Prevents adding the same user twice to the same team
    CONSTRAINT uq_team_user UNIQUE (team_id, user_id)
);

-- ----------------------------------------------------------------------------
-- 4. TASKS (Owned by a Team / Tenant)
-- ----------------------------------------------------------------------------
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Multi-tenant isolation: every task strictly belongs to a specific team
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    
    -- RESTRICT: Prevent deleting a user if they created active tasks
    creator_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    
    -- SET NULL: If assignee is deleted, task stays but assignee becomes empty
    assignee_id UUID REFERENCES users(id) ON DELETE SET NULL,
    
    title VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- CHECK constraints: Limit valid values
    status VARCHAR(30) NOT NULL DEFAULT 'todo' 
        CHECK (status IN ('todo', 'in_progress', 'done')),
        
    priority VARCHAR(20) NOT NULL DEFAULT 'medium' 
        CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    
    due_date TIMESTAMPTZ,
    
    -- JSONB: Allows flexible extra properties (e.g. {"estimated_hours": 3})
    metadata JSONB DEFAULT '{}'::jsonb,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- 5. COMMENTS (One-to-Many: One Task has Many Comments)
-- ----------------------------------------------------------------------------
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- When a task is deleted, automatically delete its comments (CASCADE)
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- 6. TAGS (Labels scoped to a Team)
-- ----------------------------------------------------------------------------
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    
    name VARCHAR(50) NOT NULL,
    color_hex VARCHAR(7) DEFAULT '#3B82F6',
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Tag names must be unique within a team
    CONSTRAINT uq_team_tag UNIQUE (team_id, name)
);

-- ----------------------------------------------------------------------------
-- 7. TASK_TAGS (Many-to-Many: Tasks <-> Tags)
-- A task can have multiple tags, and a tag can belong to multiple tasks.
-- ----------------------------------------------------------------------------
CREATE TABLE task_tags (
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    
    -- Composite Primary Key: Guarantees no duplicate tag on the same task
    PRIMARY KEY (task_id, tag_id)
);
