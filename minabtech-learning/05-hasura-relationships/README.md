# Module 05: Hasura Tracking & Bidirectional Relationships

### Key Concepts Practiced:
- **Tracking Tables:** Exposing PostgreSQL tables through Hasura GraphQL Engine.
- **Object Relationships (Many-to-One):** Navigating from a child record (`article`) to its single parent (`author`).
- **Array Relationships (One-to-Many):** Navigating from a parent record (`author`) to its nested array of children (`articles`).
- **Nested Querying:** Fetching relational data across multiple tables in a single GraphQL network round-trip without manual SQL JOINs.

---

### 💡 Core Mental Models to Remember:
- **Tracking (Opening the Curtain):** PostgreSQL tables exist in the database, but Hasura won't expose them until you "track" them. Tracking is like flipping a switch that generates automatic GraphQL Queries, Mutations, and Subscriptions for that table.
- **Object Relationships (Looking Up):** A child looking up to its single parent (Many-to-One / One-to-One). An article has *one* author (`article.author`).
- **Array Relationships (Looking Down):** A parent looking down at its list of children (One-to-Many). An author has *many* articles (`author.articles`).
- **Single-Shot SQL Compilation:** In REST, fetching an author and their 10 articles often causes an $N+1$ query problem (1 query for author + 10 queries for articles). Hasura solves this by compiling nested GraphQL queries into a *single, ultra-optimized SQL query* using PostgreSQL JSON aggregations (`json_build_object`, `json_agg`).
