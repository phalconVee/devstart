# [Project Name] — PRD

> **How to use this template:** Fill sections that matter for *this* product. Empty sections are fine to leave as placeholders or delete—keep **Mission**, **Tech Stack**, and **Features** substantive so scaffolding and agents have enough signal.

## Mission
[One sentence. What does shipped and successful look like?]

## Problem & context
- **Current state**: [What do people do today without this product? Pain, workarounds, cost.]
- **Why now**: [Trigger—regulation, scale, market shift, team capacity.]
- **Constraints**: [Time, budget, compliance, must-integrate systems, “cannot change” rules.]

## Users & stakeholders
- **Primary users**: [Who uses the product day to day? Role, context, frequency.]
- **Secondary / buyers**: [Who approves, pays, or administers—if different from primary users.]
- **Success owner**: [Who decides “we shipped the right thing”?]

## Research & validation
- **What we already know**: [Interviews, analytics, support tickets, prior experiments—bullet list with dates or links where useful.]
- **Open questions**: [What we still need to learn during or after v1.]
- **Methods** (optional): [e.g., 5 usability sessions, beta cohort of N, A/B on onboarding.]

## Voice of customer
Capture **verbatim** snippets where possible, then synthesize themes.

| Source (who / channel) | Quote or paraphrase | Theme (pain, goal, objection) |
|--------------------------|---------------------|-------------------------------|
| [e.g., PM interview, 2026-01] | “[…]” | [e.g., trust / speed / clarity] |
| | | |

- **Recurring themes**: [3–5 bullets the product must explicitly address.]
- **Non-negotiables**: [Things users said they will reject or churn over.]

## Competitive & alternatives
- **Alternatives today**: [Spreadsheets, competitor X, “do nothing,” internal tools.]
- **Differentiation**: [Why this approach wins for *our* users—not a feature laundry list unless tied to insight above.]
- **Watch-outs**: [Where competitors are strong or markets are crowded.]

## Gaps, assumptions & risks
- **Known gaps** (product / UX / data): [What v1 will not solve; honest list.]
- **Assumptions** (rank: high / medium / low confidence): [e.g., “Users will connect their bank within first session.”]
- **Risks & mitigations**: [Technical, adoption, legal—each with a one-line mitigation or “TBD”.]
- **Dependencies**: [Other teams, APIs, third-party approvals, data we don’t control.]

## Success metrics
- **North star** (optional): [One primary outcome, e.g., weekly active teams completing core job.]
- **Primary metrics**: [2–4 measurable signals tied to Mission.]
- **Guardrails**: [What must not get worse—latency, errors, support volume, etc.]
- **How we’ll measure**: [Tooling, event names, baseline if known.]

## Out of scope / non-goals
Explicitly list what **this PRD does not commit to** so scope creep is visible.

- [e.g., No native mobile app in v1]
- [e.g., No multi-tenant admin for partners]
- [e.g., No migration from LegacySystem X until phase 2]

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
- **DevStart** (optional): To scaffold without installing the Railway companion skill into the repo, add a line such as **`DevStart: skip railway skill`** or **`skip railway companion skill`** (see scaffold-project SKILL Step 1). The Railway CLI runbook in Cursor rules is still generated.

## Conventions
- [e.g., Form Requests for validation, never validate in controllers]
- [e.g., Policies for authorization]
- [e.g., Tailwind utility classes only, no custom CSS]
- [e.g., Tests for all controller/route handler methods]
- [e.g., Conventional commits: feat:, fix:, test:, docs:, chore:]
