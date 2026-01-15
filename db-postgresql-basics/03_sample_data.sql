-- ============================================================================
-- STEP 3: SAMPLE DATA (DML: Data Manipulation Language)
-- ============================================================================
-- DML is used to INSERT, UPDATE, DELETE, and query actual data.
-- Here we populate our multi-tenant schema with realistic data.
-- ============================================================================

-- 1. Insert Users
INSERT INTO users (id, email, full_name) VALUES
    ('11111111-1111-4111-8111-111111111111', 'alice@company.com', 'Alice Smith'),
    ('22222222-2222-4222-8222-222222222222', 'bob@company.com', 'Bob Johnson'),
    ('33333333-3333-4333-8333-333333333333', 'carol@company.com', 'Carol Williams');

-- 2. Insert Teams (Two separate tenants)
INSERT INTO teams (id, name, slug) VALUES
    ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Engineering Team', 'engineering'),
    ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'Marketing Team', 'marketing');

-- 3. Insert Memberships (Connecting Users to Teams)
INSERT INTO memberships (team_id, user_id, role) VALUES
    ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '11111111-1111-4111-8111-111111111111', 'owner'),
    ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '22222222-2222-4222-8222-222222222222', 'member'),
    ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', '33333333-3333-4333-8333-333333333333', 'owner');

-- 4. Insert Tags for Engineering Team
INSERT INTO tags (id, team_id, name, color_hex) VALUES
    ('77777777-7777-4777-8777-777777777777', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'backend', '#3B82F6'),
    ('88888888-8888-4888-8888-888888888888', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'urgent', '#EF4444');

-- 5. Insert Tasks for Engineering Team
INSERT INTO tasks (id, team_id, creator_id, assignee_id, title, description, status, priority, metadata) VALUES
    (
        '99999999-9999-4999-8999-999999999999',
        'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        '11111111-1111-4111-8111-111111111111',
        '22222222-2222-4222-8222-222222222222',
        'Set up PostgreSQL Schema',
        'Design tables with UUIDs, foreign keys, and indexes.',
        'in_progress',
        'high',
        '{"estimated_hours": 3, "environment": "docker"}'::jsonb
    );

-- 6. Attach Tags to Task (Many-to-Many junction table)
INSERT INTO task_tags (task_id, tag_id) VALUES
    ('99999999-9999-4999-8999-999999999999', '77777777-7777-4777-8777-777777777777'),
    ('99999999-9999-4999-8999-999999999999', '88888888-8888-4888-8888-888888888888');

-- 7. Add Comments to the Task (One-to-Many)
INSERT INTO comments (task_id, user_id, content) VALUES
    ('99999999-9999-4999-8999-999999999999', '11111111-1111-4111-8111-111111111111', 'Schema files are organized and ready!');
