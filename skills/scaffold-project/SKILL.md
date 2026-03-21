---
name: scaffold-project
description: >
  Scaffold a new project from a PRD. This skill should be used when the user says
  "scaffold a project", "start a new project", "bootstrap from PRD", "set up a project
  from requirements", "create project from PRD", or provides a PRD and wants a
  fully configured project folder. Generates Cursor rules, CLAUDE.md, deployment
  config, and installs relevant stack-specific skills. Supports Laravel, Next.js,
  React Native, React+Vite+TypeScript, Node/Express/TypeScript, and Django.
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

## Process

### Step 1: Analyze the PRD

Read the PRD and extract:
- **Project name**: Used for the directory name
- **Tech stack**: Detect the primary framework from the Tech Stack section
- **Database**: What DB is used (Postgres, MySQL, SQLite, MongoDB, etc.)
- **Auth method**: Breeze, NextAuth, Passport, Django auth, etc.
- **Deployment target**: Railway, Vercel, Fly, AWS, etc.
- **Data model**: All models with fields, types, relationships
- **Features list**: Each feature with routes, views, acceptance criteria
- **Conventions**: Coding standards the user defined

Map the tech stack to one of the supported stacks:
- `laravel` — PHP/Laravel detected → load `references/stack-laravel.md`
- `nextjs` — Next.js detected → load `references/stack-nextjs.md`
- `react-native` — React Native / Expo detected → load `references/stack-react-native.md`
- `react-vite` — React + Vite + TypeScript detected → load `references/stack-react-vite.md`
- `node-express` — Node/Express/TypeScript detected → load `references/stack-node-express.md`
- `django` — Python/Django detected → load `references/stack-django.md`

If unsure, ask the user which stack to use.

### Step 2: Create the Project Directory

Create the project folder with this structure:

```
<project-name>/
├── PRD.md                          # User's PRD (copied in)
├── CLAUDE.md                       # Agent context (generated)
├── AGENTS.md                       # Symlink → CLAUDE.md
├── .env.example                    # Env var template (stack-specific)
├── .gitignore                      # Stack-appropriate ignores
├── mockups/                        # User's mockups (if provided)
├── .cursor/
│   └── rules/
│       ├── project-context.mdc     # Always-on: read PRD first
│       ├── stack-conventions.mdc   # Auto-attach on source files
│       ├── deployment.mdc          # Auto-attach on deploy config
│       └── testing.mdc             # Auto-attach on test files
└── <deploy-dir>/                   # e.g., railway/, vercel.json, Dockerfile
```

### Step 3: Generate CLAUDE.md

Use this template, filled in from PRD analysis:

```markdown
# Project Context

## Quick Reference
- **PRD**: See PRD.md for full requirements
- **Stack**: [detected stack]
- **Deploy target**: [detected target]
- **Mockups**: [count] files in /mockups

## Data Model
[Paste the data model section from the PRD here verbatim — this is the
most commonly referenced section during development]

## Key Commands
[Stack-specific commands: dev server, test, build, deploy, migrate]

## Conventions
[Paste conventions from PRD here verbatim]
```

### Step 4: Generate Cursor Rules

Read the appropriate cursor rules template from `assets/cursor-rules/` for the
detected stack. Generate these .mdc files:

**project-context.mdc** (always applies):
```yaml
---
description: Project context. Always loaded for every conversation.
alwaysApply: true
---
```
Content: Instruct agent to read @PRD.md and @CLAUDE.md before any task.
If mockups/ exists, instruct agent to check mockups before building UI.

**stack-conventions.mdc** (auto-attached by glob):
Read from `references/stack-<name>.md` for the conventions content.
Set the `globs` field to match the stack's source file extensions.

**deployment.mdc** (auto-attached by glob on deploy config files):
Read from `references/stack-<name>.md` for deployment instructions.

**testing.mdc** (auto-attached by glob on test files):
Read from `references/stack-<name>.md` for testing patterns.

### Step 5: Generate Deployment Config

Read the deploy config template from `assets/deploy-configs/` for the
detected stack and deployment target. Generate the actual files.

For Railway + Laravel: `railway/init-app.sh`, `railway/run-worker.sh`, `railway/run-cron.sh`
For Railway + Node: `Dockerfile` or `railway.toml`
For Vercel + Next.js: `vercel.json`
For Railway + Django: `railway/start.sh` with gunicorn config
See the stack-specific reference for exact file contents.

### Step 6: Generate .env.example

Stack-specific env var template. Include all vars needed for the deployment
target with placeholder values and comments explaining each.

### Step 7: Initialize Git

```bash
git init
git add -A
git commit -m "chore: scaffold project from PRD via devstart"
```

### Step 8: Report to User

Print a summary:
- Project name and directory
- Detected stack
- Generated files list
- Installed skills
- Suggested first command (e.g., "open in Cursor: cursor <project>/")
- Suggested first prompt to give the agent

## Important Notes

- **SKILL.md is lean by design.** Detailed stack conventions, deployment configs,
  and cursor rule templates are in `references/` and `assets/`. Load them only
  when the stack is detected.
- **Don't over-scaffold.** Generate config and context files. Do NOT generate
  application source code — that's what the user does in Cursor after opening.
- **Mockups are optional.** If no mockups directory exists, skip all mockup
  references in generated files.
- **The PRD is sacred.** Copy it in verbatim. Never modify the user's PRD.
