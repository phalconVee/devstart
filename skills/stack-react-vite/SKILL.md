---
name: stack-react-vite
description: >
  React + Vite + TypeScript development conventions. This skill should be used
  when working in a React SPA project using Vite, creating components, hooks,
  routes, or configuring the build. Provides TypeScript-first React patterns,
  component architecture, and Vite configuration best practices.
---

# React + Vite + TypeScript Stack Conventions

## Architecture
- Vite for build tooling. React Router v6+ for routing (or TanStack Router).
- TypeScript strict mode. No `any`. Interfaces for all props.
- Functional components only. Custom hooks with `use` prefix.
- Colocation: component + styles + types + test in same directory.

## Component Patterns
- Props interfaces: `interface ButtonProps { label: string; onClick: () => void; }`
- Composition over prop drilling. Use Context sparingly.
- Lazy-load routes: `React.lazy(() => import('./pages/Dashboard'))` with `Suspense`.
- Barrel exports: `components/index.ts` re-exports all components.

## State Management
- Zustand or Jotai for client state. React Query for server state.
- No prop drilling beyond 2 levels. Use context or state library.
- MSW (Mock Service Worker) for API mocking during development.

## Styling
- Tailwind CSS. Component-scoped with utility classes.
- Shadcn/UI for pre-built components (if specified in PRD).
- Dark mode: use Tailwind's `dark:` variant.

## Testing
- Vitest + React Testing Library.
- Test user behavior: render, interact, assert.
- MSW for API mocking in tests.
- Playwright for E2E.

## Build & Deploy
- `npm run build` outputs to `dist/`.
- Use `VITE_` prefix for env vars exposed to browser.
- Analyze bundle: `npx vite-bundle-visualizer`.
