# 🐳 Full-Stack Practice: Docker & Compose Cheatsheet

A practical Docker setup demonstrating a modern multi-service backend with **PostgreSQL 16**, **Hasura GraphQL Engine**, and **pgAdmin 4**.

---

## 📄 Why `docker-compose.yml`?

Running multiple containers with raw `docker run` commands requires long, error-prone terminal commands, manual network setup, and complex startup sequencing.

**`docker-compose.yml`** solves this by defining your entire multi-container infrastructure as **declarative code**:
- **One command to start everything:** `docker compose up -d`
- **One command to stop and clean up:** `docker compose down`
- **Automatic networking:** Services discover each other by name.

---

## 🧠 Core Docker Concepts

### 1. Container vs. Image
* **Image (The Blueprint):** An immutable, read-only template containing the application code, libraries, dependencies, and OS userland (like a class or a recipe).
* **Container (The Live Instance):** A lightweight, isolated running process created from an image, with an added writable layer on top (like an instantiated object).

### 2. Dockerfile Multi-Stage Builds
Multi-stage builds use multiple `FROM` instructions in a single `Dockerfile` to optimize the final image:
* **Stage 1 (Builder):** Compiles code, pulls dev tools, builds assets (heavy).
* **Stage 2 (Runtime):** Copies *only* the compiled binary or dist files into a minimal base image (e.g., `alpine` or `scratch`).
* **Benefits:** Drastically smaller image sizes and a reduced attack surface in production.

---

## 🛠️ Key `docker-compose.yml` Building Blocks

Here is how key mechanisms work in our [`docker-compose.yml`](./docker-compose.yml):

### 3. Syntax Overview
* **`services:`** Defines the distinct containers to launch (`postgres`, `hasura`, `pgadmin`).
* **`depends_on:`** Expresses startup dependencies (Hasura waits for PostgreSQL healthcheck before launching).
* **`healthcheck:`** Runs diagnostic checks (e.g. `pg_isready`) inside the container to verify readiness.

### 4. Volume Persistence
* **Problem:** Containers are ephemeral. When a container is removed, all changes inside its filesystem are erased.
* **Solution:** **Named Volumes** (`pg_data`, `pgadmin_data`) map directories from the host's Docker storage into the container:
  ```yaml
  volumes:
    - pg_data:/var/lib/postgresql/data
  ```
  Database records survive even if containers are deleted and rebuilt.

### 5. Bridge Networks & Service Discovery
* When you run `docker compose up`, Docker automatically sets up a dedicated **user-defined bridge network**.
* **Internal DNS:** Containers can resolve each other using their service name as the hostname.
  * For example, Hasura connects to Postgres using:
    `postgres://postgres:mysecretpassword@postgres:5432/hospital_db`
    *(No need for local IP addresses!)*

### 6. Port Mapping (`HOST:CONTAINER`)
Format: `"HOST_PORT:CONTAINER_PORT"`
* **Host Port:** Exposed to your physical machine / browser.
* **Container Port:** Port the service listens on inside its private network.

| Service | Port Mapping | How to Access |
|---|---|---|
| **PostgreSQL** | `5432:5432` | `localhost:5432` (database clients) |
| **Hasura Console** | `8080:8080` | `http://localhost:8080` |
| **pgAdmin 4** | `5050:80` | `http://localhost:5050` |

### 7. Environment Variable Injection
Inject runtime configuration and credentials dynamically without baking secrets into the image:
```yaml
environment:
  POSTGRES_USER: postgres
  POSTGRES_PASSWORD: mysecretpassword
  POSTGRES_DB: hospital_db
```
*(Tip: In production environments, store sensitive values in a `.env` file and exclude it from version control).*

---

## 🚀 Quick Start

1. **Start all services:**
   ```bash
   docker compose up -d
   ```
2. **View running containers:**
   ```bash
   docker compose ps
   ```
3. **Stop all services:**
   ```bash
   docker compose down
   ```
