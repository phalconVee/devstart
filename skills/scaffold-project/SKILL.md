---
name: scaffold-project
description: >
  Scaffold a new project from a PRD. This skill should be used when the user says
  "scaffold a project", "start a new project", "bootstrap from PRD", "set up a project
  from requirements", "create project from PRD", or provides a PRD and wants a
  fully configured project folder. Generates Cursor rules, CLAUDE.md, deployment
  config, and installs relevant stack-specific skills. Supports Laravel, Next.js,
  React Native, React+Vite+TypeScript, Node/Express/TypeScript, and Django.
allowed-tools:
  - Bash
  - Read
  - Write
---

# DevStart: PRD-Driven Project Scaffolding

Scaffold a fully configured project from a PRD file, with Cursor rules, deployment
config, and agent context — ready to open in Cursor and build.

## When to Use

- User provides a PRD (as a file or inline) and wants to start building
- User says "scaffold", "bootstrap", "start a new project", "set up from PRD"
- User has a PRD.md and wants the right skills, rules, and config generated

## Inputs

1. **PRD** (required): Either a PRD.md file or inline requirements. Must include
   at minimum: project name, tech stack, and a description of features.
2. **Mockups** (optional): Figma exports, PNGs, or HTML files in a /mockups directory.

If the user provides a PRD inline rather than as a file, first write it to a
PRD.md file before proceeding.

## Standalone Script

A bash script at `scripts/scaffold.sh` can also perform this scaffolding
outside of an agent session. Usage:
```bash
./scripts/scaffold.sh [--no-railway-skill] <project-name> <path/to/PRD.md> [path/to/mockups/]
# Or: DEVSTART_SKIP_RAILWAY_SKILL=1 ./scripts/scaffold.sh myapp PRD.md
```
See **Step 8b** for skipping the Railway companion skill without a flag (PRD phrases).

## Process

### Step 1: Analyze the PRD

Read the PRD and extract:
- **Project name**: Used for the directory name
- **Tech stack**: Detect the primary framework from the Tech Stack section
- **Database**: What DB is used (Postgres, MySQL, SQLite, MongoDB, etc.)
- **Auth method**: Breeze, NextAuth, Passport, Django auth, etc.
- **Deployment target**: Railway, Vercel, Fly, AWS, EAS, etc.
- **Data model**: All models with fields, types, relationships
- **Features list**: Each feature with routes, views, acceptance criteria
- **Conventions**: Coding standards the user defined
- **Skip Railway companion skill** (optional): If true, do **not** run
  `npx skills add railwayapp/railway-skills` during Step 8b. Set when **any** of:
  - User passes **`--no-railway-skill`** or **`--skip-railway-skill`** to `scripts/scaffold.sh`
  - Environment **`DEVSTART_SKIP_RAILWAY_SKILL`** is `1`, `true`, or `yes`
  - PRD contains (case-insensitive) one of:
    - `DevStart: skip railway skill`
    - `skip railway companion skill`
    - `skip installing railway skill` / `skip install railway skill`
    - `railway companion skill: no` / `false` / `skip`
  Still generate **`deployment.mdc`** with the Railway CLI runbook; only the skill install is skipped.

**Stack detection priority order** (check top to bottom, first match wins):

1. `react-native` — PRD contains: React Native, Expo, mobile app, cross-platform mobile
2. `nextjs` — PRD contains: Next.js, NextJS, App Router, Server Components
3. `laravel` — PRD contains: Laravel, Artisan, Eloquent, Blade, Breeze, Livewire
4. `django` — PRD contains: Django, DRF, Django REST Framework
5. `node-express` — PRD contains: Express, Fastify, Node.js API/backend/server
6. `react-vite` — PRD contains: React + Vite, React SPA, or just React (without Next.js/Expo)

**Why this order matters:**
- "React Native" contains "React" — must match react-native before react-vite.
- "Next.js with React" — must match nextjs before react-vite.
- If PRD mentions both a frontend and backend stack (e.g., "React + Express"),
  detect the PRIMARY stack and note the secondary in CLAUDE.md. Ask the user
  if you should scaffold a monorepo.

**Deploy target detection** (independent of stack):
- "Vercel" in PRD → vercel
- "Railway" in PRD → railway
- "Fly" / "Fly.io" in PRD → fly
- "EAS" / "Expo Application Services" in PRD → eas
- Default: railway (unless stack is react-native → eas, or nextjs → vercel)

If unsure about either stack or deploy target, ask the user.

Load the matching reference: `references/stack-<detected-stack>.md`

If the detected stack is **react-vite**, also load
`references/design-system-shadcn-bundui.md` when generating frontend rules and
`CLAUDE.md`. It defines Bundui Cosmic (landing) and Dashboard kit references
and differentiation rules (visual branding + structural/IA).

### Step 2: Create the Project Directory

Create the project folder with this structure:

```
<project-name>/
├── PRD.md                          # User's PRD (copied in verbatim)
├── CLAUDE.md                       # Agent context (generated)
├── AGENTS.md                       # Symlink → CLAUDE.md
├── .env.example                    # Env var template (stack-specific)
├── .gitignore                      # Stack-appropriate ignores
├── .cursorignore                   # Exclude vendor/build/env from Cursor indexing
├── mockups/                        # User's mockups (if provided)
├── docs/                           # react-vite only: frontend-design-system.md (Bundui refs)
├── .cursor/
│   └── rules/
│       ├── project-context.mdc     # Always-on: read PRD first
│       ├── stack-conventions.mdc   # Auto-attach on source files
│       ├── deployment.mdc          # Auto-attach on deploy config
│       └── testing.mdc             # Auto-attach on test files
└── <deploy-dir>/                   # e.g., railway/, vercel.json, eas.json
```

### Step 3: Generate CLAUDE.md

Read the template at `assets/claude-md-template.md`. Fill in all `{{PLACEHOLDER}}`
fields with values extracted from the PRD:

- `{{STACK}}` — detected stack name
- `{{DEPLOY_TARGET}}` — detected deploy target
- `{{MOCKUP_COUNT}}` — number of files in mockups/ (0 if none)
- `{{DATA_MODEL}}` — paste the Data Model section from the PRD verbatim
- `{{KEY_COMMANDS}}` — from the stack reference's "Key Commands" section
- `{{CONVENTIONS}}` — paste the Conventions section from the PRD verbatim
- `{{DEPLOY_DIR}}` — railway/, or . for vercel.json/eas.json at root
- `{{DEPLOYMENT_NOTES}}` — brief summary of deploy architecture from reference
- `{{REPO_STRUCTURE_EXTRAS}}` — For **react-vite**: a single markdown list line
  (newline after previous bullet) `- \`docs/frontend-design-system.md\` — Bundui Cosmic + Dashboard kit references for UI work`. For all other stacks: empty (no extra line).
- `{{FRONTEND_DESIGN_SECTION}}` — For **react-vite**: paste the full contents of
  `assets/frontend-design-claude-section.md` (including the `##` heading). For
  all other stacks: empty string (remove stray blank lines before `## Deployment` if needed).

Create AGENTS.md as a symlink to CLAUDE.md for Codex/OpenCode compatibility.

### Step 3b: Copy frontend design reference (react-vite only)

If the stack is **react-vite**, create `docs/` in the project root and copy
`references/design-system-shadcn-bundui.md` to
`docs/frontend-design-system.md` verbatim. Skip this step for other stacks.

### Step 4: Generate Cursor Rules

Generate four .mdc files in `.cursor/rules/`:

**project-context.mdc** (always applies):
Copy from `assets/cursor-rules/project-context.mdc`. If no mockups directory
exists, remove the mockup-related lines from the copied file.

**stack-conventions.mdc** (auto-attached by glob):
Read the detected stack's reference file at `references/stack-<n>.md`.
Extract the `stack-conventions.mdc` section — it contains the exact YAML
frontmatter (with correct `globs` for that stack's file extensions) and
the conventions content. Generate the .mdc file from this.

**deployment.mdc** (auto-attached by glob on deploy config files):
Read the detected stack's reference file. Extract the `deployment.mdc` section
(frontmatter + stack-specific bullets). Set deploy target name in the content.
**Then append** the full contents of `assets/cursor-rules/railway-cli-runbook.md`
after a blank line. That file is the shared **Railway CLI runbook** (CLI install
through verify). It complements **project-specific** notes (e.g. Laravel
4-service layout, `railway.toml` build commands). Use these globs:
```yaml
globs:
  - "railway/**"
  - "Dockerfile"
  - "vercel.json"
  - "railway.toml"
  - "Procfile"
  - "eas.json"
  - ".env*"
```

**testing.mdc** (auto-attached by glob on test files):
Read the detected stack's reference file. Extract the `testing.mdc` section
with the correct test file globs for that stack.

### Step 5: Generate .cursorignore

Read `assets/cursorignore-templates.md` and extract the ignore patterns for
the detected stack. Write them to `.cursorignore` in the project root. This
prevents Cursor from indexing vendor dirs, build output, and env files.

### Step 6: Generate Deployment Config

Read the detected stack's reference file at `references/stack-<n>.md`.
It contains the exact file contents for each deployment config file under
the "Deployment Config Files" heading. Generate those files verbatim.

**Stack + deploy target mapping:**
- Laravel + Railway: `railway/init-app.sh`, `railway/run-worker.sh`, `railway/run-cron.sh`
- Next.js + Vercel: `vercel.json`
- Next.js + Railway: `railway.toml`
- React + Vite + Railway: `railway.toml`
- Node/Express + Railway: `railway.toml` (or `Dockerfile` — both in reference)
- Django + Railway: `railway/start.sh` (+ optional `Dockerfile`)
- React Native + EAS: `eas.json`

If the PRD specifies a deploy target not listed above, generate a minimal
config and note it in CLAUDE.md. Do NOT guess at deploy configs.

### Step 7: Generate .env.example

Read the `.env.example` content from the stack reference's "Deployment Config
Files" section. Write it to `.env.example` in the project root. Include
comments explaining each variable.

### Step 8: Generate .gitignore

Read the `.gitignore` content from the stack reference. Write it to the
project root.

### Step 8b: Install Railway companion skill (optional)

If **Step 1** determined **Skip Railway companion skill** is true, **skip this entire
step** (no `npx skills add`). Still append **## Railway companion skill** to
**CLAUDE.md** explaining it was skipped by flag, env, or PRD, and that the user may
run `npx skills add railwayapp/railway-skills --yes` manually.

Otherwise, from the **project root** (after all files exist, before `git init`), attempt:

```bash
npx skills add railwayapp/railway-skills --yes
```

Use **`--yes`** so the skills CLI does not block on an interactive agent picker.

- If the command succeeds, the scaffolded repo can use **`railwayapp/railway-skills`** for Railway CLI depth (troubleshooting, logs, edge cases).
- If `npx` or the skills CLI is unavailable, **exit silently** (do not fail the scaffold). Note in the **Step 10** user summary: install manually with `npx skills add railwayapp/railway-skills --yes`. **CLAUDE.md** should record success, manual install hint, or explicit PRD/flag/env skip.

### Step 9: Initialize Git

```bash
git init
git add -A
git commit -m "chore: scaffold project from PRD via devstart"
```

### Step 10: Report to User

Print a summary:
- Project name and path
- Detected stack and deploy target
- **Railway companion skill:** skipped by user (flag/env/PRD), auto-installed, failed (manual `npx skills add railwayapp/railway-skills --yes`), as applicable
- List of all generated files
- Suggested next step: `cursor <project-name>/`
- Suggested first prompt to give the Cursor agent:

> Read @PRD.md and @CLAUDE.md. Set up the project based on the PRD:
> install dependencies, create the data model, and run the initial
> migration. Verify everything works by running tests.

## Monorepo Handling (React Native + API)

If the stack is `react-native` AND the PRD describes a backend API, scaffold
a monorepo:

```
project/
├── apps/
│   ├── mobile/        # React Native (scaffold with react-native reference)
│   └── api/           # Backend API (scaffold with the detected backend reference)
├── packages/          # Shared types/utils (create empty with README)
├── PRD.md
├── CLAUDE.md
└── .cursor/rules/     # Rules for both stacks, scoped by glob
```

Generate cursor rules for BOTH stacks with globs scoped to their subdirectories
(e.g., `apps/mobile/**/*.tsx` and `apps/api/**/*.ts`). Generate separate deploy
configs for each app.

## Important Notes

- **SKILL.md is lean by design.** Detailed stack conventions, deployment configs,
  and cursor rule templates live in `references/` and `assets/`. Load them only
  when the stack is detected. This follows progressive disclosure.
- **React + Vite UI:** `references/design-system-shadcn-bundui.md` defines Bundui
  Cosmic + Dashboard kit usage; it is copied to `docs/frontend-design-system.md`
  in scaffolded projects.
- **Don't over-scaffold.** Generate config and context files. Do NOT generate
  application source code — that's what the user does in Cursor after opening.
- **Mockups are optional.** If no mockups directory exists, skip all mockup
  references in generated files.
- **The PRD is sacred.** Copy it in verbatim. Never modify the user's PRD.
- **Ask when ambiguous.** If the PRD mentions two frameworks or an unsupported
  deploy target, ask rather than guess.
- **Railway:** Generated `deployment.mdc` embeds the **Railway CLI runbook**
  (`assets/cursor-rules/railway-cli-runbook.md`) plus stack-specific deploy notes.
  **`railwayapp/railway-skills`** (optional; Step 8b runs `npx skills add … --yes`
  unless skipped via **flag**, **`DEVSTART_SKIP_RAILWAY_SKILL`**, or **PRD** — see Step 1)
  carries general Railway knowledge; the runbook + `railway/` / `railway.toml`
  carry **this repo’s** commands and architecture. Either layer alone is usable;
  both together is smoothest.
