# Module 08: Modular Go CLI with Structs, Interfaces & Custom Errors

### Architectural Concepts Implemented:
- **Domain Structs & Enums:** Defined typed models (`Task`, `TaskStatus`) using Go types.
- **Custom Error Types:** Implemented `TaskNotFoundError` and `ValidationError` satisfying the `error` interface, verifiable with `errors.As`.
- **Interface Decoupling:** `TaskRepository` interface abstracts data access, backed by a thread-safe `InMemoryTaskRepo` with `sync.RWMutex`.
- **Automated Unit Testing:** Standard `go test` suite covering data persistence, retrieval, validation, and error assertions.

---

### 💡 Core Mental Models to Remember:
- **The Electrical Plug & Socket (Interfaces):** Go interfaces are contracts of behavior (`Save`, `FindByID`, `FindAll`). High-level code depends on the socket (`TaskRepository`), not the concrete appliance (`InMemoryTaskRepo`). Tomorrow you can plug in a `PostgresTaskRepo` without altering a single line of business logic.
- **Error Fingerprinting (Custom Error Structs):** Returning plain `errors.New("not found")` forces fragile string parsing. Implementing custom structs with an `Error() string` method allows callers to use `errors.As(err, &target)` to inspect exact error properties (e.g., `target.TaskID`, `target.Field`).
- **The Library Reading Room (`sync.RWMutex`):** Multiple readers can read books simultaneously (`RLock` / `RUnlock`) without blocking one another. But when an author writes a new book (`Lock` / `Unlock`), all access is blocked exclusively until the write completes—preventing race conditions in memory.
- **Separation of Concerns (Domain vs Infrastructure):** Keep domain entities pure (`domain/task.go`) with no knowledge of databases, JSON parsing, or network protocols. Storage and presentation adapt to the domain, never the other way around.
