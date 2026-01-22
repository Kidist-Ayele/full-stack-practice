# 🚀 PostgreSQL Queries, Triggers & Views

A beginner-friendly guide to intermediate and advanced PostgreSQL concepts, including **SQL JOINs**, **Aggregations**, **JSONB querying**, and the mini-project: **Auto-updating Timestamp Trigger & User Activity Statistics View**.

All examples build upon our multi-tenant task management database.

---

## 📂 Folder Overview

This module is split into **5 focused, step-by-step files**:

| File | Core Concepts Covered |
|---|---|
| 📄 [`01_joins.sql`](./01_joins.sql) | `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL OUTER JOIN`, Multi-table JOINs |
| 📄 [`02_group_by_aggregations.sql`](./02_group_by_aggregations.sql) | `GROUP BY`, `COUNT()`, `ARRAY_AGG()`, `FILTER (WHERE ...)`, `HAVING` |
| 📄 [`03_jsonb_queries.sql`](./03_jsonb_queries.sql) | JSONB operators (`->`, `->>`, `@>`, `?`, `jsonb_set`) |
| 📄 [`04_triggers_and_procedures.sql`](./04_triggers_and_procedures.sql) | **Mini-Project:** PL/pgSQL trigger function for `updated_at`, Stored Procedures |
| 📄 [`05_user_activity_view.sql`](./05_user_activity_view.sql) | **Mini-Project:** SQL VIEW aggregating user activity statistics |

---

## 🧩 Core Concepts Made Simple

### 1. SQL JOINs Visualized

```
    INNER JOIN              LEFT JOIN              FULL OUTER JOIN
  ┌─────┬─────┐           ┌─────┬─────┐           ┌─────┬─────┐
  │     │ █   │           │█████│ █   │           │█████│█████│
  │  A  │███B │           │██ A │███B │           │██ A │███B │
  │     │ █   │           │█████│ █   │           │█████│█████│
  └─────┴─────┘           └─────┴─────┘           └─────┴─────┘
Only matching rows       All from A + matching   All rows from both,
from both tables         from B (NULL if none)   unmatched filled with NULL
```

* **`INNER JOIN`**: Tasks that have an assigned user (tasks without assignees are excluded).
* **`LEFT JOIN`**: All tasks, showing assignee name if present, or `NULL` if unassigned.
* **`FULL OUTER JOIN`**: Shows all tasks and all users, even if they have no connection.

---

### 2. GROUP BY & PostgreSQL Aggregations

* **`GROUP BY`**: Collapses multiple rows with the same key into a single summary row.
* **`FILTER (WHERE ...)`**: Powerful PostgreSQL feature that counts conditionally inside an aggregation:
  ```sql
  COUNT(t.id) FILTER (WHERE t.status = 'done') AS completed_tasks
  ```
* **`ARRAY_AGG()`**: Groups related rows into a PostgreSQL array (e.g. `['backend', 'urgent']` tags on a task).
* **`HAVING`**: Like a `WHERE` clause, but runs *after* grouping (e.g. `HAVING COUNT(tasks.id) > 5`).

---

### 3. JSONB Columns & Operators

Unlike plain text `JSON`, `JSONB` decomposes JSON into binary for fast indexing and querying:

| Operator | Meaning | Example | Output |
|---|---|---|---|
| **`->`** | Get JSON object | `metadata -> 'estimated_hours'` | `3` (JSON) |
| **`->>`** | Get text | `metadata ->> 'environment'` | `'docker'` (Text) |
| **`@>`** | Contains key/value? | `metadata @> '{"environment": "docker"}'` | `true/false` |
| **`?`** | Key exists? | `metadata ? 'estimated_hours'` | `true/false` |
| **`||`** | Merge/update JSON | `metadata || '{"sprint": 1}'::jsonb` | Merged JSONB |

---

### 4. Database Triggers (PL/pgSQL)

A **Trigger** is an automatic callback that fires before or after an `INSERT`, `UPDATE`, or `DELETE`.

#### The `updated_at` Trigger:
```sql
-- 1. Create reusable trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Hook it to a table
CREATE TRIGGER trg_tasks_auto_updated_at
BEFORE UPDATE ON tasks
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```
Now, whenever an application or query runs `UPDATE tasks SET status = 'done'`, PostgreSQL automatically updates `updated_at` to the exact current timestamp.

---

### 5. Stored Procedures vs. Functions

* **Function (`CREATE FUNCTION`)**: Computes and returns a value. Cannot commit transactions.
* **Procedure (`CREATE PROCEDURE`)**: Executes batch workflows or operations; can manage transactions (`COMMIT` / `ROLLBACK`). Called with `CALL my_procedure()`.

---

### 6. SQL VIEW: User Activity Statistics

A **View** is a saved query that looks and acts just like a regular table, without duplicating data on disk:

```sql
CREATE OR REPLACE VIEW user_activity_stats AS
SELECT 
    u.id AS user_id,
    u.full_name,
    u.email,
    COUNT(DISTINCT m.team_id) AS total_teams,
    COUNT(DISTINCT t_created.id) AS tasks_created,
    COUNT(DISTINCT t_assigned.id) AS tasks_assigned,
    COUNT(DISTINCT t_assigned.id) FILTER (WHERE t_assigned.status = 'done') AS tasks_completed,
    COUNT(DISTINCT c.id) AS comments_posted
FROM users u
LEFT JOIN memberships m ON u.id = m.user_id
LEFT JOIN tasks t_created ON u.id = t_created.creator_id
LEFT JOIN tasks t_assigned ON u.id = t_assigned.assignee_id
LEFT JOIN comments c ON u.id = c.user_id
GROUP BY u.id, u.full_name, u.email;
```

**Querying the View:**
```sql
SELECT * FROM user_activity_stats WHERE tasks_assigned > 0;
```

---

## 🧪 How to Run These Files

Run them against your PostgreSQL database in the Docker container:

```bash
# 1. Test JOINs
docker exec -i postgres_db psql -U postgres -d hospital_db < db-postgresql-advanced/01_joins.sql

# 2. Test Aggregations
docker exec -i postgres_db psql -U postgres -d hospital_db < db-postgresql-advanced/02_group_by_aggregations.sql

# 3. Test JSONB Queries
docker exec -i postgres_db psql -U postgres -d hospital_db < db-postgresql-advanced/03_jsonb_queries.sql

# 4. Install the Trigger & Procedure
docker exec -i postgres_db psql -U postgres -d hospital_db < db-postgresql-advanced/04_triggers_and_procedures.sql

# 5. Create & Query the User Activity Statistics View
docker exec -i postgres_db psql -U postgres -d hospital_db < db-postgresql-advanced/05_user_activity_view.sql
```
