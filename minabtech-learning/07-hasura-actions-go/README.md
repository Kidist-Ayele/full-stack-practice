# Module 07: Hasura Actions with Go Webhook Server

### Key Concepts Practiced:
- **Extending Hasura:** Using Hasura Actions to delegate custom business logic (authentication, notifications) to custom backend code.
- **Go HTTP Webhooks:** Built a standard Go `net/http` server receiving Hasura Action payloads (`ActionPayload[T]`) and returning strongly-typed JSON responses.
- **Docker-to-Host Networking:** Routed webhook traffic from the Hasura Docker container to the local host Go service (`http://host.docker.internal:3000` or `172.17.0.1`).
- **Synchronous Actions:** Executed synchronous mutations (`login`, `sendNotification`) through GraphiQL and verified immediate responses.

---

### 💡 Core Mental Models to Remember:
- **The Delegation Desk (Actions vs CRUD):** Hasura handles instant database CRUD operations out of the box, but custom business logic (validating passwords, hashing, sending SMS/emails, third-party APIs) doesn't belong in raw SQL. Actions act as a concierge that delegates these custom workflows to your external HTTP webhook.
- **The Wrapper Contract (ActionPayload):** Hasura wraps the incoming GraphQL arguments along with user session headers (`session_variables: { "x-hasura-user-id": "..." }`) into a structured JSON payload sent to your Go server.
- **Bridge to Host (Docker Networking):** A containerized Hasura cannot reach your host machine via `localhost:3000` because `localhost` points inside the container itself. Use `http://host.docker.internal:3000` (or `172.17.0.1`) so Docker escapes the bridge network into your local Go server.
- **Synchronous vs Asynchronous:** Synchronous Actions hold the HTTP request open until the Go webhook responds (ideal for `login` returning a JWT), whereas Asynchronous Actions return an action ID immediately and process in the background (ideal for heavy jobs like video processing or bulk notifications).
