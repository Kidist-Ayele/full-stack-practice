#!/bin/bash
# Example manual GraphQL query via cURL
curl -X POST http://localhost:8080/v1/graphql \
  -H "Content-Type: application/json" \
  -H "x-hasura-admin-secret: myadminsecretkey" \
  -d '{"query": "query { users { id full_name email } }"}'
