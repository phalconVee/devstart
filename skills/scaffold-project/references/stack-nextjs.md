# Next.js Stack Reference

## Detection
Matches when PRD contains: Next.js, NextJS, App Router, Pages Router, Server Components, Vercel.

## Cursor Rules

### stack-conventions.mdc
```yaml
---
description: Next.js conventions for this project.
globs:
  - "app/**/*.tsx"
  - "app/**/*.ts"
  - "src/**/*.tsx"
  - "src/**/*.ts"
  - "components/**/*.tsx"
  - "lib/**/*.ts"
alwaysApply: false
---
```
Content:
- App Router by default. Use `app/` directory with layout.tsx, page.tsx, loading.tsx, error.tsx.
- Server Components by default. Add 'use client' only when needed (useState, useEffect, event handlers, browser APIs).
- Server Actions for mutations. Prefer over API routes for form submissions.
- TypeScript strict mode. No `any`. Define types in `types/` or co-located `.types.ts` files.
- Tailwind CSS for styling. No CSS modules unless explicitly required.
- Use `next/image` for all images. Never use raw `<img>` tags.
- Use `next/link` for all internal navigation. Never use `<a>` for internal links.
- Zod for runtime validation of form data and API inputs.
- Metadata API for SEO: export metadata objects or generateMetadata functions.

### testing.mdc
```yaml
---
description: Next.js testing patterns.
globs:
  - "__tests__/**"
  - "**/*.test.ts"
  - "**/*.test.tsx"
  - "**/*.spec.ts"
  - "**/*.spec.tsx"
alwaysApply: false
---
```
Content:
- Vitest + React Testing Library for unit/component tests.
- Playwright for E2E tests.
- Test server components by testing their output, not with RTL.
- Test client components with RTL: render, user events, assertions.
- Run: `npm test` (Vitest) or `npx playwright test` (E2E).

### deployment.mdc (Vercel)
```yaml
---
description: Deployment config for Next.js on Vercel or Railway.
globs:
  - "vercel.json"
  - "next.config.*"
  - ".env*"
alwaysApply: false
---
```
Content:
- Default target: Vercel (zero-config deploy for Next.js).
- Alternative: Railway with Nixpacks auto-detection.
- Env vars: set in Vercel dashboard or `railway variables`.
- Use `NEXT_PUBLIC_` prefix for client-side env vars.
- Never expose server secrets with NEXT_PUBLIC_ prefix.
- **Cursor rule body:** After the bullets above, append the full contents of `assets/cursor-rules/railway-cli-runbook.md` from the scaffold-project skill (use when deploying to Railway; Vercel flows stay dashboard/CLI as usual). Companion: `railwayapp/railway-skills` (`npx skills add railwayapp/railway-skills --yes`).

## Deployment Config Files

### vercel.json (if Vercel)
```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "framework": "nextjs"
}
```

### Railway alternative: railway.toml
```toml
[build]
builder = "RAILPACK"
buildCommand = "npm ci && npm run build"

[deploy]
startCommand = "npm start"
```

### .env.example
```
# App
NEXT_PUBLIC_APP_URL=http://localhost:3000

# Database (if using Prisma/Drizzle)
DATABASE_URL=

# Auth (if using NextAuth)
NEXTAUTH_SECRET=
NEXTAUTH_URL=http://localhost:3000
```

### .gitignore
```
node_modules/
.next/
out/
.env
.env.local
.env.production
.vercel
*.tsbuildinfo
next-env.d.ts
```

## Key Commands
- Dev server: `npm run dev`
- Build: `npm run build`
- Run tests: `npm test`
- E2E tests: `npx playwright test`
- Deploy (Vercel): `vercel` or push to linked GitHub repo
- Deploy (Railway): `railway up`

## Recommended Community Skills
- `vercel-labs/agent-skills` from skills.sh
- `railwayapp/railway-skills` if deploying to Railway
