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
   - Deployment config (Railway scripts, Dockerfiles, Vercel config)
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

### 2. Scaffold

In Cursor's agent or Claude Code:

```
Scaffold a new project from @PRD.md
```

Or with mockups:

```
Scaffold a project from @PRD.md — mockups are in the /mockups folder
```

### 3. Build

The scaffolded project is pre-configured. Your first prompt in the new project:

```
Read @PRD.md and @CLAUDE.md. Set up the project based on the PRD:
install dependencies, create the data model, and run the initial migration.
```

Then iterate feature by feature from your PRD.

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

- **[Railway Skills](https://github.com/railwayapp/railway-skills)** — Railway CLI deployment
- **[Laravel Specialist](https://skills.sh/jeffallan/claude-skills/laravel-specialist)** — Deep Laravel expertise
- **[Vercel Agent Skills](https://github.com/vercel-labs/agent-skills)** — Vercel deployment
- **[Engineering Workflow](https://github.com/mhattingpete/claude-skills-marketplace)** — Git automation, test fixing

## License

MIT
