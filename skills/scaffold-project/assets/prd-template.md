# [Project Name] — PRD

## Mission
[One sentence. What does shipped and successful look like?]

## Tech Stack
- Language/Framework: [e.g., PHP 8.3 / Laravel 11]
- Frontend: [e.g., Blade + Tailwind CSS 3, or React + Vite + TypeScript]
- Database: [e.g., SQLite (dev), Postgres (prod)]
- Testing: [e.g., Pest, Vitest, pytest]
- Auth: [e.g., Laravel Breeze, NextAuth, JWT, Django auth]
- Deployment: [e.g., Railway, Vercel, EAS]

## Data Model
[List every model with fields, types, defaults, and relationships.]

Example:
```
Project: id, user_id (FK->users), name (string 255, required),
  description (text, nullable), status (enum: planning|active|completed,
  default: planning), due_date (date, nullable), timestamps

User: (default auth user model)
```

## Features

### Feature 1: [Name]
- **What**: [Description]
- **Routes**: [e.g., GET /projects, POST /projects]
- **Views/Screens**: [e.g., projects/index.blade.php, ProjectList.tsx]
- **Acceptance criteria**:
  - [Specific, testable criterion]
  - [Another criterion]

### Feature 2: [Name]
[Same structure]

## Pages / Screens

### Landing Page (/)
- Hero section with tagline and CTA
- Features section
- Footer

### Dashboard (/dashboard)
- Summary stats cards
- Recent items list

[Add more pages/screens as needed]

## Deployment
- **Target**: [Railway / Vercel / EAS / etc.]
- **Services**: [e.g., App + Worker + Cron + Postgres]
- **Key env vars**: [List them with descriptions]

## Conventions
- [e.g., Form Requests for validation, never validate in controllers]
- [e.g., Policies for authorization]
- [e.g., Tailwind utility classes only, no custom CSS]
- [e.g., Tests for all controller/route handler methods]
- [e.g., Conventional commits: feat:, fix:, test:, docs:, chore:]
