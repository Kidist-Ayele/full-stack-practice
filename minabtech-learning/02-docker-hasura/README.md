# Docker & Hasura Multi-Container Stack

### 1. Port Mapping
| Service | Host Port | Container Port | Access URL |
|---|---|---|---|
| PostgreSQL | `5432` | `5432` | `localhost:5432` |
| Hasura Console | `8080` | `8080` | `http://localhost:8080` |
| pgAdmin 4 | `5050` | `80` | `http://localhost:5050` |

### 2. Volumes
- `pg_data`: Persists PostgreSQL database files.
- `pgadmin_data`: Persists pgAdmin configurations and server connections.

### 3. Usage Commands
```bash
docker compose up -d       # Start all services in the background
docker compose ps          # Check container status & healthchecks
docker compose logs -f     # Follow logs
docker compose down        # Stop all containers
docker compose down -v     # Stop containers and erase volume data
```

---

### 💡 Core Mental Models to Remember:
- **Image vs Container:** An Image is the frozen recipe/blueprint (read-only). A Container is the live, running cake baked from that recipe. Deleting a container never deletes the image.
- **Port Mapping (`HOST:CONTAINER`):** Outside (Laptop) : Inside (Container). `"5050:80"` means knock on laptop port 5050 to reach port 80 inside the container.
- **The Storage Locker (Volumes):** Containers have amnesia—when destroyed, internal data is wiped. Declaring named volumes (`volumes: - pg_data:/var/lib/postgresql/data`) keeps database records safe across restarts.
- **The `localhost` Trap & Bridge Network:** Inside a container, `localhost` means *that container itself*. To connect Hasura to Postgres on the same Compose network, use the service name: `postgres://...@postgres:5432/...`.
- **Healthchecks (`condition: service_healthy`):** Ensures dependent services (like Hasura) do not start until Postgres is completely ready to accept SQL queries (`pg_isready`).
