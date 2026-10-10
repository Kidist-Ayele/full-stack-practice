# Linux CLI, Permissions & Port Management

### 1. File Permissions (`chmod`)
Linux permissions control Read (`r=4`), Write (`w=2`), and Execute (`x=1`):
```bash
chmod +x manage.sh        # Make script executable
chmod 600 .env             # Read/write for owner only
```

### 2. Checking Listening Ports (`lsof`)
```bash
lsof -i :5432              # Check if PostgreSQL port is in use
lsof -Pi :8080 -sTCP:LISTEN # List process listening on port 8080
kill -9 <PID>              # Terminate a process blocking a port
```

### 3. Running `manage.sh`
```bash
./manage.sh check          # Verify .env file and check all ports
./manage.sh ports          # Check port availability only
./manage.sh env            # Generate .env file
```

---

### 💡 Core Mental Models to Remember:
- **The Hotel Room (Ports & Processes):** A process (e.g. Go server, Postgres) is a hotel guest with a Process ID (`PID`). A Port (e.g. `8080`, `5432`) is the room number. If an app crashes with *"address already in use"*, ask the front desk who is in the room (`lsof -i :8080`) and evict them gracefully (`kill <PID>`) instead of pulling the power cord (`kill -9`).
- **Security Badges (Permissions):** Newly created scripts lack execution rights (`rw-`). Use `chmod +x script.sh` to stamp an executable badge. For sensitive credentials (`.env`), use `chmod 600 .env` so only the owner can read/write and outsiders have zero access.
- **Sticky Notes (Environment Variables):** `export PORT=8080` pastes a temporary note in your terminal session so programs can access it via `os.Getenv("PORT")`.
- **Search Shortcuts:** Use `grep -rn "keyword" .` to search for text inside code files, and `tail -f app.log` to follow live server logs in real time.
