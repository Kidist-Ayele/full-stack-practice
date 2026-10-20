# GraphQL Fundamentals

### 1. GraphQL vs. REST
| Feature | REST | GraphQL |
|---|---|---|
| **Endpoints** | Multiple (`/users`, `/tasks`) | Single endpoint (`/v1/graphql`) |
| **Data Fetching** | Over-fetching or under-fetching | Fetch exact fields requested |
| **HTTP Methods** | `GET`, `POST`, `PUT`, `DELETE` | Standard `POST` for queries & mutations |

### 2. Fragments & Variables
- **Fragments**: Reusable field selections across queries (`...UserFields`).
- **Variables**: Separate dynamic values from the query string (e.g. `$teamId: uuid!`).

### 3. Executing Requests
Run the sample queries and mutations via CLI:
```bash
./curl_examples.sh
```
Or use the Hasura Console GraphiQL explorer at `http://localhost:8080/console`.

---

### 💡 Core Mental Models to Remember:
- **The À La Carte Menu (GraphQL vs REST):** REST serves fixed combos leading to over-fetching (getting 30 fields when you need 1) or under-fetching (making 4 network requests to assemble 1 screen). GraphQL uses a single endpoint (`/v1/graphql`) where the client specifies the exact fields required.
- **Operations:**
  - `Query`: Reading data (safe, never mutates state).
  - `Mutation`: Creating, updating, or deleting records.
  - `Subscription`: Real-time live data stream via WebSockets.
- **Variables (`$var: Type!`):** Never hardcode values into query strings. Use parameterized variables (marked with `$`) for security, caching, and dynamic input.
- **Fragments (`...UserFields`):** Reusable sets of fields to avoid code repetition across multiple queries.
- **Execution:** GraphQL over HTTP is simply an HTTP `POST` request with a JSON body (`{"query": "..."}`), easily executable via `curl`.
