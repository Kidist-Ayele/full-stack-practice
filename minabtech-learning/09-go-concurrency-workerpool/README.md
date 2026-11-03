# Module 09: Go Concurrency — Worker Pool with Context Cancellation

### Architectural Patterns Practiced:
- **Worker Pool Pattern:** Dispatched a fixed number of concurrent workers reading from a buffered `jobs` channel to prevent resource exhaustion.
- **Directional Channels:** Enforced type safety using send-only (`chan<-`) and receive-only (`<-chan`) channels.
- **Graceful Cancellation (`context.WithTimeout`):** Controlled job deadlines using `ctx.Done()` within `select` blocks to guarantee zero goroutine leaks on timeout.
- **Synchronization (`sync.WaitGroup`):** Coordinated worker lifecycle and channel closure using `wg.Add`, `wg.Done`, and `wg.Wait`.

---

### 💡 Core Mental Models to Remember:
- **The Factory Assembly Line (Worker Pool):** Spawning unbounded goroutines (`go func()`) under heavy load can exhaust memory and crash servers. A worker pool employs a fixed team of workers (e.g. 3 workers) picking jobs off a shared conveyor belt (`buffered channel`), ensuring controlled concurrency.
- **One-Way Street Signs (Directional Channels):** Channels can be restricted by direction: `chan<- T` (send-only) and `<-chan T` (receive-only). The compiler prevents workers from accidentally closing channels or reading from output sinks.
- **The Emergency Brake (`context.Context`):** `context.WithTimeout` broadcasts a cancellation signal downstream. When time expires or cancellation is triggered, `ctx.Done()` unblocks across all goroutines, preventing dangling or leaked background operations.
- **The Roll Call (`sync.WaitGroup`):** Like a tour guide counting passengers before the bus departs, `wg.Add(n)` registers workers, `wg.Done()` checks each in when finished, and `wg.Wait()` guarantees the main process doesn't exit prematurely.
