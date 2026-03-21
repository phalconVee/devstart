# React + Vite + TypeScript Stack Reference

## Detection
Matches when PRD contains: React, Vite, SPA, single page app (without Next.js/Remix/Expo).

## Cursor Rules

### stack-conventions.mdc
```yaml
---
description: React + Vite + TypeScript conventions.
globs:
  - "src/**/*.tsx"
  - "src/**/*.ts"
  - "src/components/**"
  - "src/hooks/**"
  - "src/lib/**"
alwaysApply: false
---
```
Content:
- Functional components only. No class components.
- TypeScript strict mode. No `any`. Define interfaces for all props.
- Custom hooks for reusable logic. Prefix with `use`.
- Colocation: component, styles, types, tests in the same directory.
- React Router v6+ for routing (unless PRD specifies TanStack Router).
- Zustand or Jotai for client state. React Query for server state.
- Tailwind CSS for styling. No CSS-in-JS unless PRD specifies.
- Zod for form validation and API response validation.
- Barrel exports (index.ts) for component directories.
- Lazy-load routes with React.lazy() and Suspense.

### testing.mdc
```yaml
---
description: React testing patterns.
globs:
  - "src/**/*.test.ts"
  - "src/**/*.test.tsx"
  - "src/**/*.spec.ts"
  - "src/**/*.spec.tsx"
  - "tests/**"
alwaysApply: false
---
```
Content:
- Vitest + React Testing Library for unit/component tests.
- Playwright for E2E tests.
- Test user behavior, not implementation (no testing state directly).
- Mock API calls with MSW (Mock Service Worker).
- Run: `npm test` (Vitest) or `npx playwright test` (E2E).

### deployment.mdc
```yaml
---
description: Deployment config for React SPA.
globs:
  - "vite.config.*"
  - "Dockerfile"
  - "railway.*"
  - "vercel.json"
  - ".env*"
alwaysApply: false
---
```
Content:
- Build: `npm run build` outputs to `dist/`.
- Railway: static hosting via `npx serve dist -l $PORT` or nginx.
- Vercel: auto-detected as Vite project.
- API URL: use `VITE_` prefix for env vars exposed to the browser.
- For SSR/API: pair with a backend service on Railway.

## Deployment Config Files

### railway.toml (Railway static)
```toml
[build]
builder = "RAILPACK"
buildCommand = "npm ci && npm run build"

[deploy]
startCommand = "npx serve dist -l $PORT"
```

### .env.example
```
VITE_API_URL=http://localhost:3001/api
VITE_APP_NAME=YourApp
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
- Dev server: `npm run dev`
- Build: `npm run build`
- Preview build: `npm run preview`
- Run tests: `npm test`
- Deploy (Railway): `railway up`

## Recommended Community Skills
- `anthropics/skills` (React patterns) from skills.sh
- `railwayapp/railway-skills` for deployment
