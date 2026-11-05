# Module 10: Clean REST API in Go 1.22 (Standard Library Only)

### Architectural Features:
- **Zero Third-Party Routers:** Built entirely using Go 1.22 standard library `net/http` enhanced routing (`POST /books`, `GET /books/{id}`).
- **Path Value Parameters:** Used native `r.PathValue("id")` for dynamic route extraction.
- **Layered Clean Architecture:**
  - `models/`: Domain structs with JSON serialization tags.
  - `repository/`: Thread-safe in-memory data store with `sync.RWMutex`.
  - `service/`: Business validation logic (price, empty title/author guards).
  - `controllers/`: HTTP request parsing and response encoding.
- **Middleware Chaining:** Implemented custom Logging middleware and CORS preflight (`OPTIONS`) handling.

---

### 💡 Core Mental Models to Remember:
- **The Restaurant Kitchen (Clean Layered Architecture):**
  - **Controller (The Waiter):** Greets customers (HTTP requests), accepts orders (JSON body), delivers prepared food (JSON responses). Contains zero cooking logic.
  - **Service (The Chef):** Validates the recipe (price > 0, required titles/authors) and orchestrates business rules.
  - **Repository (The Pantry Keeper):** Stores and retrieves ingredients (data persistence with `sync.RWMutex`), having no clue about HTTP or JSON.
- **The Tollbooth Gates (Middleware Pipeline):** Middleware wraps the router like concentric onion layers (`loggingMiddleware(corsMiddleware(mux))`). Every request must pass security inspection and timing before entering, and responses pass back through on exit.
- **Native Routing in Go 1.22:** Prior to Go 1.22, developers needed external routers (Gorilla Mux, Chi) just to match methods or extract path parameters. Go 1.22 standard library `http.NewServeMux()` natively parses `"GET /books/{id}"` and `r.PathValue("id")` with zero dependencies.
- **Reader-Writer Storage Locking (`sync.RWMutex`):** Multiple simultaneous readers can browse the bookstore inventory (`RLock`), but updates or additions acquire an exclusive lock (`Lock`)—guaranteeing thread safety without stalling concurrent read performance.
