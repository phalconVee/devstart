### Railway CLI deploy runbook

Use this when the deploy target is **Railway** (or when adding a Railway service). **DevStart** provides project-specific files (`railway.toml`, `railway/*.sh`, `.env.example`); this runbook is the **CLI sequence**. For deeper CLI behavior, errors, and log patterns, use the **`railwayapp/railway-skills`** companion skill if installed (`npx skills add railwayapp/railway-skills --yes`).

1. **Install CLI** — [Railway CLI](https://docs.railway.com/develop/cli): e.g. `npm i -g @railway/cli` or the install method from current Railway docs. Confirm with `railway --version`.
2. **Login** — `railway login` (browser/device flow). Never paste tokens into the repo.
3. **Project** — New: `railway init` and follow prompts. Existing: `railway link` and select the project/environment.
4. **Provision Postgres** (if the PRD needs a DB) — Railway dashboard: **New** → **Database** → **PostgreSQL**, or use the CLI flow documented for your Railway version. Note the service that exposes `DATABASE_URL` (or reference variables from the DB service into the app service).
5. **Align variables** — Match `.env.example`: `railway variables set KEY=value` (or dashboard **Variables**). Set secrets only in Railway, not in git. For Laravel **4-service** setups (web + worker + cron + Postgres), configure variables per service; reference shared DB URL from the Postgres plugin/service as needed.
6. **Configure services** — In dashboard or CLI: set **Root Directory** (if monorepo), **Build** and **Start** commands to match this repo’s `railway.toml` and `railway/*.sh` (see **CLAUDE.md**). Add **worker** and **cron** as separate services pointing at the same repo with different start commands where applicable.
7. **Deploy** — From the linked directory: `railway up` (or connect GitHub and push to the tracked branch for automatic deploys).
8. **Domain** — Dashboard **Settings** → **Networking** → generate public URL, or `railway domain` per CLI help for your version.
9. **Verify** — `railway logs` (or dashboard logs), open the URL, hit a health route if defined, and run a quick smoke test (auth, DB read) per the PRD.
10. **Iterate** — On build failure, inspect build logs; on runtime 5xx, check `railway logs` and variable parity with `.env.example`. Use **`railwayapp/railway-skills`** for advanced troubleshooting when installed.
