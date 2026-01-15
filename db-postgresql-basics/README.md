# 🐘 PostgreSQL Basics: Beginner's Guide & Schema Design

Welcome to PostgreSQL basics! This guide breaks down relational database concepts step-by-step using a real-world mini-project: **A Multi-Tenant Task Management App** (Users, Teams, Memberships, Tasks, Comments, and Tags).

Instead of putting all code in one big file, this project is split into **4 bite-sized, easy-to-read files**:

| File | What it teaches |
|---|---|
| 📄 [`01_create_tables.sql`](./01_create_tables.sql) | DDL, Tables, UUIDs, Primary & Foreign Keys, Constraints |
| 📄 [`02_indexes.sql`](./02_indexes.sql) | B-Tree & GIN Indexes (Making queries fast) |
| 📄 [`03_sample_data.sql`](./03_sample_data.sql) | DML (`INSERT INTO`) with sample multi-tenant data |
| 📄 [`04_queries.sql`](./04_queries.sql) | Practical `SELECT` & `UPDATE` queries with JOINs |

---

## 🗺️ Visual Architecture (The Big Picture)

A **multi-tenant** app means multiple organizations (Teams) share one database, but each team only sees their own data.

```
       ┌────────────────────────┐
       │         users          │
       └───────────┬────────────┘
                   │
           (1:N)   │   (M:N via memberships)
                   ▼
       ┌────────────────────────┐
       │         teams          │  ◄── Tenant Boundary
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

## 💡 Key Concepts Explained Simply

### 1. DDL vs. DML
* **DDL (Data Definition Language):** Building the structure (the blueprint).
  * Commands: `CREATE TABLE`, `ALTER TABLE`, `DROP TABLE`.
  * *See:* [`01_create_tables.sql`](./01_create_tables.sql).
* **DML (Data Manipulation Language):** Working with the rows inside the tables.
  * Commands: `SELECT`, `INSERT`, `UPDATE`, `DELETE`.
  * *See:* [`03_sample_data.sql`](./03_sample_data.sql) & [`04_queries.sql`](./04_queries.sql).

---

### 2. UUID v4 as IDs
Instead of regular auto-incrementing numbers (`1, 2, 3...`), we use:
```sql
id UUID PRIMARY KEY DEFAULT gen_random_uuid()
```
* **Why?** Numbers are easily guessable (someone can try `/tasks/1`, `/tasks/2`). UUIDs are long random strings (`11111111-1111-4111-8111-111111111111`) that are secure and globally unique.

---

### 3. Primary Keys & Foreign Keys
* **Primary Key (`PRIMARY KEY`):** The unique identifier for each row in a table.
* **Foreign Key (`REFERENCES ...`):** Connects a row in one table to a row in another table.
  * **`ON DELETE CASCADE`:** If the parent is deleted, automatically delete the children. (e.g. deleting a task deletes its comments).
  * **`ON DELETE SET NULL`:** If the parent is deleted, keep the record but set the link to empty. (e.g. if an assigned user deletes their account, the task remains with no assignee).
  * **`ON DELETE RESTRICT`:** Block deletion if connected records exist. (e.g. you cannot delete a user if they created active tasks).

---

### 4. Constraints (`NOT NULL`, `UNIQUE`, `CHECK`)
Constraints act as rules to keep your data clean:
* **`NOT NULL`:** Column must have a value (e.g. title cannot be empty).
* **`UNIQUE`:** No duplicates allowed (e.g. `email` or composite `UNIQUE(team_id, user_id)`).
* **`CHECK`:** Restricts values to a specific list or condition:
  ```sql
  CHECK (status IN ('todo', 'in_progress', 'done'))
  CHECK (role IN ('owner', 'admin', 'member'))
  ```

---

### 5. Table Relationships: 1:N vs. M:N

#### One-to-Many (1:N)
* **Real world:** One task has many comments.
* **Design:** Add a single foreign key `task_id` inside the `comments` table.

#### Many-to-Many (M:N)
* **Real world:** One task has many tags, and one tag can be used on many tasks.
* **Design:** We use a **junction table** (`task_tags`) containing two foreign keys:
  ```sql
  CREATE TABLE task_tags (
      task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
      tag_id  UUID REFERENCES tags(id) ON DELETE CASCADE,
      PRIMARY KEY (task_id, tag_id)
  );
  ```

---

### 6. Indexing: B-Tree vs. GIN

Without an index, searching for a task requires checking every single row (slow). Indexes make lookups instant:

* **B-Tree Index (Default):** Great for numbers, text, dates, and foreign keys (`WHERE team_id = ...` or `ORDER BY due_date`).
  ```sql
  CREATE INDEX idx_tasks_team_id ON tasks(team_id);
  ```
* **GIN Index (Generalized Inverted Index):** Great for querying *inside* JSON or arrays.
  ```sql
  CREATE INDEX idx_tasks_metadata_gin ON tasks USING gin(metadata);
  ```

---

### 7. Timestamps (`created_at`, `updated_at`)
Every table includes:
* `created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP`: Automatically saves the exact creation time.
* `updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP`: Tracks when the row was last modified.

---

## 🧪 How to Run These Files

Using the PostgreSQL database running in your `docker-practice` container:

```bash
# 1. Create tables
docker exec -i postgres_db psql -U postgres -d hospital_db < db-postgresql-basics/01_create_tables.sql

# 2. Add indexes
docker exec -i postgres_db psql -U postgres -d hospital_db < db-postgresql-basics/02_indexes.sql

# 3. Insert sample data
docker exec -i postgres_db psql -U postgres -d hospital_db < db-postgresql-basics/03_sample_data.sql

# 4. Test queries
docker exec -i postgres_db psql -U postgres -d hospital_db < db-postgresql-basics/04_queries.sql
```
