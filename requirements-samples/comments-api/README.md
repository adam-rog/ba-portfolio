# Comments API — OpenAPI Specification

REST API specification for an article comments module, written in OpenAPI 3.0.3.

## Context

Digital media platform where readers comment under articles. The comments
module needs a documented API contract that frontend, backend, and QA teams
can build against independently — a design-first specification rather than
documentation written after the code.

## Scope

Five endpoints covering full CRUD plus listing:

| Method | Endpoint | Purpose | Success code |
|--------|----------|---------|--------------|
| GET | `/articles/{articleId}/comments` | List comments for an article (paginated) | 200 |
| POST | `/articles/{articleId}/comments` | Create a comment | 201 |
| GET | `/comments/{commentId}` | Retrieve a single comment | 200 |
| PATCH | `/comments/{commentId}` | Edit a comment (partial update) | 200 |
| DELETE | `/comments/{commentId}` | Delete a comment | 204 |

## Design decisions

- **Resource modeling** — comments are a sub-resource of articles for creation
  and listing (`/articles/{id}/comments`), but addressed directly for single-item
  operations (`/comments/{id}`) since a comment has a globally unique ID.
- **HTTP method semantics** — POST creates (returns 201 + full object), PATCH does
  partial update (only `content` in body, returns 200), DELETE returns 204 with no body.
- **Idempotency** — GET/PUT/DELETE are idempotent; POST and PATCH are not, which is
  why creation uses POST and partial edits use PATCH.
- **Request vs response shape** — the create/edit request body carries only
  client-supplied fields (`content`); server-controlled fields (`id`, `author_id`,
  `created_at`) appear only in responses.
- **Reusable schema** — the `Comment` object is defined once under
  `components/schemas` and referenced via `$ref`, following DRY.
- **Pagination** — listing uses `limit`/`offset` query parameters with defaults.

## How to view

Paste `comments-api.yaml` into [editor.swagger.io](https://editor.swagger.io)
to see the rendered interactive documentation.

## Skills demonstrated

REST API design · OpenAPI 3.0.3 · HTTP method semantics · resource modeling ·
request/response schema design · API documentation as a contract.
