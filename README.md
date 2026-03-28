# DevStart

**PRD in → Scaffolded project out → Open in Cursor → Build.**

DevStart is an agent skill for Cursor and Claude Code that scaffolds fully configured projects from a PRD. You provide the requirements, it generates the project structure, Cursor rules, deployment config, and agent context — ready to open and start building.

No orchestration layers. No dashboards. Just you and your editor.

## What It Does

1. You write a PRD (product requirements document)
2. You tell the agent: "Scaffold a project from my PRD"
3. DevStart detects your tech stack and generates:
   - `.cursor/rules/*.mdc` — auto-attached rules for your stack
   - `CLAUDE.md` — project context for the agent
   - Deployment config (Railway scripts, Dockerfiles, Vercel config) and a **Railway CLI runbook** inside `deployment.mdc`
   - Optional: `npx skills add railwayapp/railway-skills --yes` during scaffold (companion Railway CLI skill; `--yes` avoids interactive prompts). **Opt out** with `scaffold.sh --no-railway-skill`, `DEVSTART_SKIP_RAILWAY_SKILL=1`, or PRD lines like `DevStart: skip railway skill` (runbook in `deployment.mdc` is still included).
   - `.env.example` with all required variables
   - `.gitignore` appropriate for your stack
4. You open the folder in Cursor and start building

## Supported Stacks

| Stack | Detection Keywords | Deployment Target |
|-------|-------------------|-------------------|
| **Laravel** | Laravel, PHP, Blade, Eloquent, Breeze | Railway |
| **Next.js** | Next.js, App Router, Server Components | Vercel / Railway |
| **React Native** | React Native, Expo, mobile | EAS Build |
| **React + Vite** | React, Vite, SPA | Railway / Vercel |
| **Node/Express** | Express, Fastify, REST API, TypeScript backend | Railway |
| **Django** | Django, DRF, Python web | Railway |

## Installation

### Cursor

Copy the `skills/` directory into your project's `.cursor/skills/`, or install globally:

```bash
# Clone and symlink
git clone https://github.com/phalconVee/devstart.git ~/devstart
ln -s ~/devstart/skills/* ~/.cursor/skills/
```

### Claude Code (Plugin Marketplace)

```
/plugin marketplace add phalconVee/devstart
/plugin install devstart@devstart
```

### Codex / OpenCode

```bash
npx skills add phalconVee/devstart
```

## Usage

### 1. Write a PRD

Use the included template (`skills/scaffold-project/assets/prd-template.md`) or write your own. At minimum, include: project name, tech stack, data model, and features.

### 2. Invoke the scaffold skill

Use any of the patterns below (Cursor, Claude Code, or the shell script). The agent follows `skills/scaffold-project/SKILL.md`; the script mirrors the same flow.

### 3. Build in the new folder

Open the generated directory and continue with your stack (install deps, migrations, tests).

---

### Examples (once the skill is installed)

**Cursor or Claude Code — PRD file in the repo**

```
Scaffold a new project from @PRD.md. Use the devstart scaffold-project skill.
```

```
Bootstrap from this PRD: @docs/PRD.md — project name should be "invoice-app".
```

```
I have @requirements/PRD.md ready. Set up a new project folder with Cursor rules and deploy config for the stack described there.
```

**With mockups**

```
Scaffold a project from @PRD.md. Design reference files are in ./mockups — include them in the scaffolded project.
```

**Inline requirements (no PRD file yet)**

```
Scaffold a new Laravel + Railway project. First write PRD.md from this description: [paste product brief]. Then run the full scaffold from that PRD.
```

```
Create PRD.md for a React + Vite SPA with Postgres API on Railway, then scaffold the project using DevStart.
```

**Name and location explicit**

```
Use scaffold-project to create ~/Projects/bookmarks-app/ from @PRD.md. Do not modify the PRD text — copy it verbatim.
```

**Skip Railway companion skill (PRD-driven)**

Add a line to your PRD such as `DevStart: skip railway skill` (see the PRD template), then:

```
Scaffold from @PRD.md
```

The agent reads the PRD and skips `npx skills add` for Railway skills while still generating `deployment.mdc` with the CLI runbook.

**Bash script (no agent)**

From the DevStart repo (or with `SKILL_ROOT` pointing at `skills/scaffold-project`):

```bash
./skills/scaffold-project/scripts/scaffold.sh my-saas ./PRD.md
./skills/scaffold-project/scripts/scaffold.sh my-saas ./PRD.md ./mockups/
```

Skip installing `railwayapp/railway-skills` into the new repo:

```bash
./skills/scaffold-project/scripts/scaffold.sh --no-railway-skill my-saas ./PRD.md
DEVSTART_SKIP_RAILWAY_SKILL=1 ./skills/scaffold-project/scripts/scaffold.sh my-saas ./PRD.md
```

**First prompt inside the scaffolded project**

```
Read @PRD.md and @CLAUDE.md. Install dependencies, create the data model from the PRD, run migrations, and verify with the test command from CLAUDE.md.
```

```
Open @PRD.md Feature 1. Implement it end-to-end and satisfy the acceptance criteria.
```

**Codex / OpenCode (skills already added via `npx skills add phalconVee/devstart`)**

Use the same natural-language scaffolds as above; reference your PRD path and ask to use the **scaffold-project** skill so the agent loads `SKILL.md`.

## Project Structure

```
devstart/
├── .claude-plugin/
│   └── plugin.json              # Claude Code plugin manifest
├── skills/
│   ├── scaffold-project/        # Main skill: PRD → scaffolded project
│   │   ├── SKILL.md             # Orchestrator instructions
│   │   ├── references/          # Stack-specific conventions & config
│   │   │   ├── stack-laravel.md
│   │   │   ├── stack-nextjs.md
│   │   │   ├── stack-react-native.md
│   │   │   ├── stack-react-vite.md
│   │   │   ├── stack-node-express.md
│   │   │   └── stack-django.md
│   │   └── assets/
│   │       └── prd-template.md  # PRD template to copy
│   ├── stack-laravel/           # Laravel conventions skill
│   │   └── SKILL.md
│   ├── stack-nextjs/            # Next.js conventions skill
│   │   └── SKILL.md
│   ├── stack-react-native/      # React Native conventions skill
│   │   └── SKILL.md
│   ├── stack-react-vite/        # React + Vite conventions skill
│   │   └── SKILL.md
│   ├── stack-node-express/      # Node/Express conventions skill
│   │   └── SKILL.md
│   └── stack-django/            # Django conventions skill
│       └── SKILL.md
├── LICENSE
└── README.md
```

## How It Works

DevStart uses two types of skills:

**scaffold-project** (task skill): Runs once per project. Reads your PRD, detects the stack, generates all config files. You invoke it explicitly.

**stack-\*** (reference skills): Loaded automatically when working in a project of that stack. They teach the agent your framework's conventions, testing patterns, and deployment procedures. These persist across your entire development session.

## Extending

### Adding a new stack

1. Create `skills/scaffold-project/references/stack-yourstack.md` with conventions, cursor rules, deploy config, and key commands
2. Create `skills/stack-yourstack/SKILL.md` with development conventions
3. Add detection keywords to the scaffold-project SKILL.md
4. Update plugin.json to include the new skill

### Customizing for your team

Fork this repo and modify:
- Stack conventions in the reference files (add your team's patterns)
- Deployment config templates (swap Railway for your infra)
- PRD template (add fields specific to your org)

## Recommended Companion Skills

These pair well with DevStart:

- **[Railway Skills](https://github.com/railwayapp/railway-skills)** — Railway CLI deployment (DevStart attempts `npx skills add railwayapp/railway-skills --yes` when scaffolding; `deployment.mdc` also embeds a full CLI runbook)
- **[Laravel Specialist](https://skills.sh/jeffallan/claude-skills/laravel-specialist)** — Deep Laravel expertise
- **[Vercel Agent Skills](https://github.com/vercel-labs/agent-skills)** — Vercel deployment
- **[Engineering Workflow](https://github.com/mhattingpete/claude-skills-marketplace)** — Git automation, test fixing

## License

MIT
