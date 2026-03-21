# Laravel Stack Reference

## Detection
Matches when PRD contains: Laravel, PHP, Blade, Artisan, Eloquent, Breeze, Livewire, Inertia.

## Cursor Rules

### stack-conventions.mdc
```yaml
---
description: Laravel conventions for this project.
globs:
  - "app/**/*.php"
  - "routes/**/*.php"
  - "resources/views/**/*.blade.php"
  - "tests/**/*.php"
  - "database/**/*.php"
  - "config/**/*.php"
alwaysApply: false
---
```
Content:
- Use Form Requests for all validation. Never validate in controllers.
- Use Policies for authorization. Register in AuthServiceProvider.
- Eloquent scopes over raw queries. Never use DB:: facade for CRUD.
- Resource controllers: `php artisan make:controller XController --resource --model=X`
- Blade components with Tailwind utility classes. No custom CSS files.
- Status fields use PHP 8.1+ backed enums, not string constants.
- Route model binding everywhere. No manual `find()` calls in controllers.
- Use `php artisan make:` commands to generate boilerplate — don't write stubs manually.

### testing.mdc
```yaml
---
description: Laravel testing patterns.
globs:
  - "tests/**/*.php"
alwaysApply: false
---
```
Content:
- Pest for all tests. No PHPUnit test classes.
- Feature tests for every controller method.
- Use factories for test data. Never hardcode IDs.
- Name tests: `it('prevents unauthorized access to edit', ...)`
- Test both happy path and edge cases (auth, validation, ownership).
- Run `php artisan test` after every feature.

### deployment.mdc (Railway)
```yaml
---
description: Railway deployment config for Laravel.
globs:
  - "railway/**"
  - ".env*"
  - "Dockerfile"
alwaysApply: false
---
```
Content:
- Deployment target: Railway.
- 4-service architecture: App + Worker + Cron + Postgres.
- App: Pre-deploy runs railway/init-app.sh (migrations + cache).
- Worker: Start command runs railway/run-worker.sh.
- Cron: Start command runs railway/run-cron.sh.
- NEVER commit .env. Use .env.example as template.
- LOG_CHANNEL=stderr (Railway has ephemeral filesystem).
- Railway does NOT support docker-compose.

## Deployment Config Files

### railway/init-app.sh
```bash
#!/bin/bash
set -e
php artisan migrate --force
php artisan optimize:clear
php artisan config:cache
php artisan event:cache
php artisan route:cache
php artisan view:cache
```

### railway/run-worker.sh
```bash
#!/bin/bash
php artisan queue:work --sleep=3 --tries=3 --max-time=3600
```

### railway/run-cron.sh
```bash
#!/bin/bash
while [ true ]; do
    php artisan schedule:run --verbose --no-interaction &
    sleep 60
done
```

### .env.example
```
APP_NAME=YourApp
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://your-app.up.railway.app

DB_CONNECTION=pgsql
DB_URL=

QUEUE_CONNECTION=database
LOG_CHANNEL=stderr
SESSION_DRIVER=database
CACHE_STORE=database
```

### .gitignore
```
/node_modules
/public/build
/public/hot
/public/storage
/storage/*.key
/vendor
.env
.env.backup
.env.production
.phpunit.result.cache
Homestead.json
Homestead.yaml
auth.json
npm-debug.log
yarn-error.log
/.fleet
/.idea
/.vscode
```

## Key Commands
- Dev server: `php artisan serve` (+ `npm run dev` for Vite)
- Run tests: `php artisan test`
- Create model: `php artisan make:model X -mfsc` (migration, factory, seeder, controller)
- Run migrations: `php artisan migrate`
- Fresh seed: `php artisan migrate:fresh --seed`
- Deploy: `railway up`

## Recommended Community Skills
- `jeffallan/claude-skills/laravel-specialist` from skills.sh
- `laravel/agent-skills` (laravel-simplifier) via Claude Code plugin marketplace
- `railwayapp/railway-skills` (use-railway) via skills.sh or Claude Code plugin
