---
name: stack-node-express
description: >
  Node.js / Express / TypeScript backend conventions. This skill should be used
  when building REST APIs, middleware, database integrations, or backend services
  with Express and TypeScript. Provides layered architecture patterns, Zod
  validation, Prisma ORM, and authentication best practices.
---

# Node / Express / TypeScript Stack Conventions

## Architecture
- Layered: routes → controllers → services → repositories.
- TypeScript strict mode. Explicit return types on all exported functions.
- Express with typed handlers: `Request`, `Response`, `NextFunction`.
- Dependency injection via constructor params, not global singletons.

## Validation & Error Handling
- Zod schemas for all request validation (body, params, query).
- Validation middleware: parse with Zod, throw on failure.
- Custom `AppError` class extending Error with statusCode.
- Global error handler middleware as last app.use().
- Never let unhandled promise rejections crash the server.

## Database (Prisma)
- Prisma for all database access. Schema in `prisma/schema.prisma`.
- `npx prisma migrate dev` for development migrations.
- `npx prisma migrate deploy` for production (no interactive prompts).
- Never use raw SQL unless Prisma can't express the query.

## Auth
- JWT access + refresh token pattern (or as PRD specifies).
- Auth middleware extracts and verifies token.
- Role-based access via permission middleware.
- Passwords: bcrypt with salt rounds >= 12.

## Testing
- Vitest + Supertest for integration tests.
- Test the HTTP contract: request → status code + response body.
- Factory functions for test data creation.
- Isolated test database or in-memory SQLite.

## Common Patterns
```typescript
// Validated route
router.post('/projects', validate(createProjectSchema), async (req, res) => {
  const project = await projectService.create(req.body, req.user.id);
  res.status(201).json(project);
});

// Zod schema
const createProjectSchema = z.object({
  body: z.object({
    name: z.string().min(1).max(255),
    description: z.string().optional(),
    status: z.enum(['planning', 'active', 'completed']).default('planning'),
  }),
});
```
