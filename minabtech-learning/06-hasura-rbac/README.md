# Module 06: Hasura Role-Based Access Control (RBAC)

### Key Concepts Practiced:
- **Role-Based Access Control (RBAC):** Creating custom application roles (e.g. `user`) with least-privilege permissions.
- **Row-Level Security (RLS):** Writing declarative boolean rules (`assigned_to = X-Hasura-User-Id`) to restrict row access automatically at the database query level.
- **Column-Level Security (CLS):** Limiting readable and editable columns so sensitive fields cannot be viewed or altered.
- **Dynamic Session Variables:** Injecting verified session headers (`X-Hasura-User-Id`, `X-Hasura-Role`) into permission checks.

---

### 💡 Core Mental Models to Remember:
- **Zero Trust Security:** By default, Hasura gives 0 permissions to any newly created role. If you don't explicitly configure a table permission for a role, Hasura hides that table and returns `access denied`.
- **Row-Level Security (Horizontal Cut ↔️):** Decides *which rows* a user can see or edit.
  - Rule: `{ "assigned_to": { "_eq": "X-Hasura-User-Id" } }`
  - Hasura automatically appends this condition to the underlying SQL query so users can never see other users' records.
- **Column-Level Security (Vertical Cut ↕️):** Decides *which fields* a user can see or edit.
  - A `user` can update `title`, `description`, and `status`, but cannot touch `id`, `team_id`, or `created_at`.
- **Session Variables (`X-Hasura-User-Id`, `X-Hasura-Role`):** Passed in verified JWTs or simulated via console headers. The frontend cannot tamper with these variables.
- **Console Testing Tip:** When simulating a role in the Hasura Console, keep `x-hasura-admin-secret` checked along with `x-hasura-role: user` so Hasura verifies console access while enforcing the restricted role's rules!
