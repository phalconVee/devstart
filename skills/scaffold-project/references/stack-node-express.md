# Node / Express / TypeScript Stack Reference

## Detection
Matches when PRD contains: Node.js, Express, Fastify, API server, REST API, TypeScript backend (without a frontend framework as primary).

## Cursor Rules

### stack-conventions.mdc
```yaml
---
description: Node/Express/TypeScript conventions.
globs:
  - "src/**/*.ts"
  - "src/**/*.js"
  - "tests/**/*.ts"
  - "prisma/**"
alwaysApply: false
---
```
Content:
- TypeScript strict mode. No `any`. Explicit return types on all functions.
- Express with explicit typing: `Request`, `Response`, `NextFunction` from express.
- Layered architecture: routes → controllers → services → repositories.
- Zod for request validation middleware. Never trust req.body/params/query directly.
- Prisma (or Drizzle) for database access. No raw SQL unless performance-critical.
- Error handling: custom AppError class, global error middleware, never unhandled rejections.
- Environment: dotenv + zod schema validation for process.env at startup.
- Use `async/await` everywhere. No callbacks. No `.then()` chains in route handlers.
- JWT + refresh tokens for auth (or as specified in PRD).
- Rate limiting on all public endpoints via express-rate-limit.

### testing.mdc
```yaml
---
description: Node/Express testing patterns.
globs:
  - "tests/**/*.ts"
  - "**/*.test.ts"
  - "**/*.spec.ts"
alwaysApply: false
---
```
Content:
- Vitest for all tests (or Jest if PRD specifies).
- Supertest for HTTP integration tests against the Express app.
- Test the API contract: status codes, response shapes, error messages.
- Use factories or fixtures for test data. Never seed production DB.
- Run: `npm test`.

### deployment.mdc
```yaml
---
description: Node/Express deployment config.
globs:
  - "Dockerfile"
  - "railway.*"
  - ".env*"
  - "prisma/**"
alwaysApply: false
---
```
Content:
- Railway: auto-detected via Nixpacks or custom Dockerfile.
- Prisma: run `npx prisma migrate deploy` as pre-deploy command.
- Start command: `node dist/index.js` (after `npm run build`).
- Use $PORT env var. Never hardcode the port.
- Health check: implement GET /health returning 200.

## Deployment Config Files

### railway.toml
```toml
[build]
builder = "RAILPACK"
buildCommand = "npm ci && npm run build && npx prisma migrate deploy"

[deploy]
startCommand = "node dist/index.js"
healthcheckPath = "/health"
healthcheckTimeout = 10
```

### Dockerfile (alternative)
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
RUN npx prisma generate

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
COPY --from=builder /app/prisma ./prisma
EXPOSE $PORT
CMD ["node", "dist/index.js"]
```

### .env.example
```
PORT=3001
NODE_ENV=production
DATABASE_URL=
JWT_SECRET=
JWT_REFRESH_SECRET=
CORS_ORIGIN=https://your-frontend.com
```

### .gitignore
```
node_modules/
dist/
.env
.env.local
*.tsbuildinfo
```

## Key Commands
- Dev server: `npm run dev` (tsx watch or nodemon)
- Build: `npm run build` (tsc)
- Run tests: `npm test`
- Generate Prisma client: `npx prisma generate`
- Run migrations: `npx prisma migrate dev`
- Deploy: `railway up`

## Recommended Community Skills
- Node.js / Express skills from skills.sh
- `railwayapp/railway-skills` for deployment
