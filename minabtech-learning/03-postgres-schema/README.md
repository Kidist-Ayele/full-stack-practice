# PostgreSQL Multi-Tenant Schema & Analytics

### 1. Entity Relationship (ERD)
```
users (1) ──────────< memberships >────────── (1) teams (Tenants)
  │                                                  │
  │ (creator/assignee)                               │ (tenant boundary)
  ▼                                                  ▼
tasks (1) ──────────< task_tags >────────── (1) tags
  │
  ▼ (1:N)
comments
```

### 2. Referential Deletions
- `CASCADE`: Deleting a `team` removes all associated `tasks`, `tags`, and `memberships`.
- `SET NULL`: Deleting a user clears `tasks.assignee_id` without deleting the task.
- `RESTRICT`: Prevents deleting a user who is recorded as `tasks.creator_id`.

### 3. Triggers & Views
- `set_updated_at_timestamp()`: Automatically modifies `updated_at = NOW()` before row updates.
- `user_activity_stats`: Virtual view summarizing user task assignments, completions, and comment counts.

---

### 💡 Core Mental Models to Remember:
- **DDL vs DML:** DDL builds the shelves (`CREATE`, `ALTER TABLE`), while DML puts items on the shelves (`INSERT`, `SELECT`, `UPDATE`).
- **UUID v4 vs Sequential IDs:** Serial IDs (`1, 2, 3...`) can be easily guessed by attackers (`/api/user/4`). UUIDs are 36-character unguessable strings generated via `uuid_generate_v4()`.
- **Constraints:** `UNIQUE` prevents duplicates (emails, team slugs). `CHECK` enforces business rules (e.g., `CHECK (status IN ('todo', 'done'))`).
- **`ON DELETE CASCADE` vs `SET NULL`:**
  - `CASCADE` (Domino effect): If a `Team` is deleted, delete all its child tasks automatically.
  - `SET NULL` (Eraser): If a `User` is deleted, do not delete the task! Just erase the author's name (`assigned_to = NULL`) so work isn't lost.
- **Triggers (The Motion Detector):** A PL/pgSQL function triggered `BEFORE UPDATE` on `tasks` automatically stamps `NEW.updated_at = NOW();` without relying on clients.
- **Views & JOINs:** `LEFT JOIN` keeps all left-side rows even if they have 0 tasks/comments. A `VIEW` saves complex joins and aggregations (`COUNT`, `GROUP BY`) into a reusable virtual table.
