---
name: stack-nextjs
description: >
  Next.js development conventions and patterns. This skill should be used when
  working in a Next.js project, editing TSX/TS files in the app/ directory, creating
  pages, layouts, server components, server actions, or API routes. Provides App
  Router best practices, Server Components patterns, and TypeScript conventions.
---

# Next.js Stack Conventions

## Architecture
- App Router (app/ directory). File conventions: page.tsx, layout.tsx, loading.tsx, error.tsx, not-found.tsx.
- Server Components by default. Add 'use client' ONLY for interactivity (useState, useEffect, event handlers, browser APIs).
- Server Actions for form mutations. Prefer over API routes for data writes.
- Parallel routes and intercepting routes for complex layouts.

## TypeScript
- Strict mode. No `any`. Explicit interfaces for all props and data shapes.
- Co-locate types: `component.types.ts` next to `component.tsx`.
- Use Zod for runtime validation of form data and external API responses.

## Data Fetching
- Fetch in Server Components directly (no useEffect for data loading).
- Use `cache()` and `revalidatePath()` / `revalidateTag()` for caching.
- React Query for client-side server state (polling, optimistic updates).

## Styling
- Tailwind CSS. No CSS modules unless explicitly required.
- `next/image` for all images. `next/link` for all internal links.
- `next/font` for font loading. No external font CDN links.

## Testing
- Vitest + React Testing Library for components.
- Test server components by testing their rendered output.
- Playwright for E2E.

## Common Patterns
```tsx
// Server Component with data fetching
async function ProjectList() {
  const projects = await db.project.findMany();
  return <ul>{projects.map(p => <li key={p.id}>{p.name}</li>)}</ul>;
}

// Server Action
'use server'
async function createProject(formData: FormData) {
  const data = createProjectSchema.parse(Object.fromEntries(formData));
  await db.project.create({ data });
  revalidatePath('/projects');
}
```
