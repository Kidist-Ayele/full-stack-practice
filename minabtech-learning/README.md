# Full-Stack & DevOps Practice

This repository contains hands-on mini-projects covering the modern backend, database, and DevOps stack (Linux, Docker, PostgreSQL, Hasura, and GraphQL) aligned with production standards.

## Modules Completed
- **[01-linux-bash](./01-linux-bash)**: Bash CLI, permissions (`chmod`/`chown`), process management (`lsof`, `kill`), environment variables.
- **[02-docker-hasura](./02-docker-hasura)**: Multi-container orchestration (`docker-compose`), bridge networking, volume persistence, and healthchecks for PostgreSQL 16 + Hasura Engine + pgAdmin 4.
- **[03-postgres-schema](./03-postgres-schema)**: Relational schema design for a multi-tenant task management app (UUID v4, foreign keys, `ON DELETE CASCADE`, constraints, PL/pgSQL triggers, and SQL Views).
- **[04-graphql-basics](./04-graphql-basics)**: Schema Definition Language, parameterized mutations, reusable fragments, and manual cURL API execution against Hasura.
- **[05-hasura-relationships](./05-hasura-relationships)**: Tracking tables, bidirectional object & array relationships, and nested GraphQL query compilation.
- **[06-hasura-rbac](./06-hasura-rbac)**: Role-Based Access Control, Row-Level Security (RLS), Column-Level Security (CLS), and session variables (`X-Hasura-User-Id`).
- **[07-hasura-actions-go](./07-hasura-actions-go)**: Extending Hasura with custom business logic, Go HTTP webhook servers, Docker-to-host networking, and synchronous mutations.
- **[08-go-cli-modular](./08-go-cli-modular)**: Modular Go architecture, domain structs & enums, custom error types (`errors.As`), interface decoupling, thread-safe memory repo, and unit tests.
- **[09-go-concurrency-workerpool](./09-go-concurrency-workerpool)**: Concurrent worker pools, directional channels, graceful timeout cancellation with `context.WithTimeout`, and `sync.WaitGroup` coordination.
