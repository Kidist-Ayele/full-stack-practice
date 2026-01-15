# 🐘 PostgreSQL Basics: Relational Schema & Multi-Tenant Design

A practical guide to essential PostgreSQL relational database concepts, featuring a complete schema for a **Multi-Tenant Task Management Application** (Users, Teams, Memberships, Tasks, Comments, and Tags).

---

## 🏗️ Multi-Tenant Architecture Overview

In a **multi-tenant** SaaS application, multiple organizations (Teams) share the same database while keeping their data strictly isolated.

```
       ┌────────────────────────┐
       │         users          │
       └───────────┬────────────┘
                   │
           (1:N)   │   (M:N via memberships)
                   ▼
       ┌────────────────────────┐
       │         teams          │  ◄── (The Tenant Boundary)
       └───────────┬────────────┘
                   │
         ┌─────────┴─────────┐
         │ (1:N)             │ (1:N)
         ▼                   ▼
┌─────────────────┐ ┌─────────────────┐
│      tasks      │ │      tags       │
└────────┬────────┘ └────────┬────────┘
         │                   │
   (1:N) │             (M:N) │ via task_tags
         ▼                   ▼
┌─────────────────┐ ┌─────────────────┐
│    comments     │ │    task_tags    │
└─────────────────┘ └─────────────────┘
```

---

## 🔑 Core Concepts & Design Principles

### 1. DDL vs. DML
* **DDL (Data Definition Language):** Defines or modifies the database structure.
  * Keywords: `CREATE`, `ALTER`, `DROP`, `TRUNCATE`.
  * *Example:* `CREATE TABLE tasks (...)` in [`schema.sql`](./schema.sql).
* **DML (Data Manipulation Language):** Queries and modifies the data itself.
  * Keywords: `SELECT`, `INSERT`, `UPDATE`, `DELETE`.
  * *Example:* `INSERT INTO tasks (title, status) VALUES ('Setup DB', 'in_progress');`.

---

### 2. UUID v4 as Primary Keys
Instead of sequential integer IDs (`SERIAL` / `BIGINT`):
```sql
id UUID PRIMARY KEY DEFAULT gen_random_uuid()
```
* **Why UUID v4?**
  * **Security & Non-Enumerable:** Sequential IDs reveal business volume (e.g. `GET /tasks/100` tells attackers there are ~100 tasks).
  * **Distributed Creation:** Client apps or microservices can generate unique IDs offline before inserting without database collisions.
  * **Seamless Merging:** Sharding and multi-region database replication without ID collision headaches.

---

### 3. Primary & Foreign Keys (Referential Actions)
Foreign keys enforce data integrity across tables with specific deletion behaviors:

| Action | Behavior | Where We Used It |
|---|---|---|
| **`ON DELETE CASCADE`** | Automatically deletes child records when parent is deleted. | `comments` deleted when parent `task` is removed; `task_tags` deleted when `task` or `tag` is removed. |
| **`ON DELETE SET NULL`** | Preserves child records but clears the reference. | If an assigned user is deleted, `tasks.assignee_id` becomes `NULL` (task remains intact). |
| **`ON DELETE RESTRICT`** | Blocks deletion if related records exist. | Prevents deleting a user who originally created active `tasks`. |

---

### 4. Constraints (`CHECK`, `UNIQUE`, `NOT NULL`)
Constraints prevent corrupt or invalid data from ever entering your database:

* **`UNIQUE`:**
  * Single column: `email VARCHAR(255) UNIQUE`
  * Composite unique: `CONSTRAINT uq_team_user UNIQUE (team_id, user_id)` (prevents adding the same user twice to the same team).
* **`CHECK`:**
  * Validating state machines:
    ```sql
    CONSTRAINT check_task_status CHECK (status IN ('todo', 'in_progress', 'in_review', 'done', 'archived'))
    ```
  * Enforcing email regex or hex colors:
    ```sql
    CONSTRAINT check_hex_color CHECK (color_hex ~* '^#[0-9A-Fa-f]{6}$')
    ```

---

### 5. Table Relationships: 1:N vs. M:N

#### One-to-Many (1:N)
A single record in Table A owns multiple records in Table B.
* **Example:** `tasks` $\rightarrow$ `comments`.
* **Design:** Add a Foreign Key column `task_id` in the `comments` table.

#### Many-to-Many (M:N)
A record in Table A can relate to multiple records in Table B, and vice-versa.
* **Example:** `tasks` $\leftrightarrow$ `tags` (a task can have many tags; a tag can be applied to many tasks).
* **Design:** Use an associative/junction table `task_tags` with a composite primary key:
  ```sql
  CREATE TABLE task_tags (
      task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
      tag_id  UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
      assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (task_id, tag_id)
  );
  ```

---

### 6. Indexing: B-Tree vs. GIN

Indexes speed up queries from slow full-table scans ($O(N)$) to fast lookups ($O(\log N)$).

#### B-Tree Index (Default)
Best for scalar values, equality (`=`), comparisons (`<`, `>`, `<=`), ranges (`BETWEEN`), and sorting (`ORDER BY`).
```sql
-- Fast tenant lookups and filtering
CREATE INDEX idx_tasks_team_id ON tasks(team_id);
CREATE INDEX idx_tasks_status ON tasks(team_id, status);
```

#### GIN (Generalized Inverted Index)
Best for composite items where you want to query inside values (JSONB documents, text arrays, full-text search).
```sql
-- Enables fast search inside task metadata (e.g. metadata @> '{"device": "cloud"}')
CREATE INDEX idx_tasks_metadata_gin ON tasks USING gin(metadata);
```

---

### 7. Automatic `created_at` & `updated_at`

PostgreSQL does not update timestamps on row changes automatically. We solve this elegantly using a reusable function and trigger:

```sql
-- 1. Reusable trigger function
CREATE OR REPLACE FUNCTION update_timestamp_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Attach trigger to any table
CREATE TRIGGER trg_tasks_updated_at
BEFORE UPDATE ON tasks
FOR EACH ROW
EXECUTE FUNCTION update_timestamp_column();
```
Now every `UPDATE tasks SET status = 'done' WHERE id = ...;` automatically updates `updated_at` without manual app logic.

---

## 🧪 Testing the Schema

You can execute the entire schema and seed data directly in your PostgreSQL database:

```bash
# Connect to your local Postgres container from docker-practice
docker exec -i postgres_db psql -U postgres -d hospital_db < db-postgresql-basics/schema.sql
```

Query tasks with their tags and assignee for a specific tenant:
```sql
SELECT 
    t.id AS task_id,
    t.title,
    t.status,
    u.full_name AS assignee,
    COALESCE(array_agg(tg.name) FILTER (WHERE tg.name IS NOT NULL), '{}') AS tags
FROM tasks t
LEFT JOIN users u ON t.assignee_id = u.id
LEFT JOIN task_tags tt ON t.id = tt.task_id
LEFT JOIN tags tg ON tt.tag_id = tg.id
WHERE t.team_id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'
GROUP BY t.id, t.title, t.status, u.full_name;
```
