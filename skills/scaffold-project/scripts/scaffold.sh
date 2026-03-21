#!/bin/bash
# DevStart Scaffold Script
# Standalone version of the scaffold-project skill.
# Usage: ./scaffold.sh <project-name> <path/to/PRD.md> [path/to/mockups/]
#
# This script does the same thing the skill does inside Cursor/Claude Code,
# but can be run directly from a terminal. Useful for CI, quick bootstrapping,
# or when you want to scaffold before opening an editor.

set -euo pipefail

PROJECT_NAME="${1:?Usage: scaffold.sh <project-name> <path/to/PRD.md> [path/to/mockups/]}"
PRD_PATH="${2:?Usage: scaffold.sh <project-name> <path/to/PRD.md> [path/to/mockups/]}"
MOCKUPS_PATH="${3:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(dirname "$SCRIPT_DIR")"

# ── Validate ──
if [ ! -f "$PRD_PATH" ]; then
  echo "Error: PRD not found at $PRD_PATH"
  exit 1
fi

if [ -d "$PROJECT_NAME" ]; then
  echo "Error: Directory $PROJECT_NAME already exists"
  exit 1
fi

# ── Detect stack ──
detect_stack() {
  local prd
  prd=$(cat "$PRD_PATH" | tr '[:upper:]' '[:lower:]')

  # Priority order matters: more specific matches first
  if echo "$prd" | grep -qE 'react.native|expo|mobile.app'; then
    echo "react-native"
  elif echo "$prd" | grep -qE 'next\.?js|app.router|server.components'; then
    echo "nextjs"
  elif echo "$prd" | grep -qE 'laravel|artisan|eloquent|blade|breeze|livewire'; then
    echo "laravel"
  elif echo "$prd" | grep -qE 'django|drf|django.rest'; then
    echo "django"
  elif echo "$prd" | grep -qE 'express|fastify|node\.?js.*(api|backend|server)'; then
    echo "node-express"
  elif echo "$prd" | grep -qE 'react.*vite|vite.*react|react.*spa'; then
    echo "react-vite"
  elif echo "$prd" | grep -qE 'react'; then
    echo "react-vite"
  else
    echo "generic"
  fi
}

STACK=$(detect_stack)
echo "Detected stack: $STACK"

if [ "$STACK" = "generic" ]; then
  echo "Warning: Could not detect a specific stack from the PRD."
  echo "Scaffolding with minimal config. You may want to add stack-specific rules manually."
fi

# ── Detect deploy target ──
detect_deploy() {
  local prd
  prd=$(cat "$PRD_PATH" | tr '[:upper:]' '[:lower:]')

  if echo "$prd" | grep -qE 'vercel'; then echo "vercel"
  elif echo "$prd" | grep -qE 'railway'; then echo "railway"
  elif echo "$prd" | grep -qE 'fly\.io|flyctl'; then echo "fly"
  elif echo "$prd" | grep -qE 'eas.build|expo.application.services'; then echo "eas"
  else echo "railway"  # Default
  fi
}

DEPLOY_TARGET=$(detect_deploy)
echo "Detected deploy target: $DEPLOY_TARGET"

# ── Create structure ──
echo "Creating project: $PROJECT_NAME"
mkdir -p "$PROJECT_NAME"/{.cursor/rules,mockups}

# Copy PRD
cp "$PRD_PATH" "$PROJECT_NAME/PRD.md"

# Copy mockups if provided
MOCKUP_COUNT=0
if [ -n "$MOCKUPS_PATH" ] && [ -d "$MOCKUPS_PATH" ]; then
  cp -r "$MOCKUPS_PATH"/* "$PROJECT_NAME/mockups/" 2>/dev/null || true
  MOCKUP_COUNT=$(ls "$PROJECT_NAME/mockups/" 2>/dev/null | wc -l | tr -d ' ')
  echo "Copied $MOCKUP_COUNT mockup files"
fi

cd "$PROJECT_NAME"

# ── Generate project-context.mdc ──
cp "$SKILL_ROOT/assets/cursor-rules/project-context.mdc" .cursor/rules/project-context.mdc

# If no mockups, remove the mockup reference from the rule
if [ "$MOCKUP_COUNT" -eq 0 ]; then
  sed -i '/mockup/Id' .cursor/rules/project-context.mdc 2>/dev/null || true
fi

# ── Load stack reference and generate stack-specific files ──
STACK_REF="$SKILL_ROOT/references/stack-${STACK}.md"

if [ -f "$STACK_REF" ]; then
  # Extract cursor rule globs and content from the reference file
  # (The agent does this intelligently; the script does a simpler version)

  case $STACK in
    laravel)
      GLOBS='  - "app/**/*.php"\n  - "routes/**/*.php"\n  - "resources/views/**/*.blade.php"\n  - "tests/**/*.php"\n  - "database/**/*.php"'
      TEST_GLOBS='  - "tests/**/*.php"'
      CURSORIGNORE="vendor/\nnode_modules/\n.env\nstorage/logs/\npublic/build/\nbootstrap/cache/"
      KEY_COMMANDS="- Dev: php artisan serve (+ npm run dev)\n- Test: php artisan test\n- Migrate: php artisan migrate\n- Model: php artisan make:model X -mfsc\n- Deploy: railway up"
      DEPLOY_DIR="railway"
      ;;
    nextjs)
      GLOBS='  - "app/**/*.tsx"\n  - "app/**/*.ts"\n  - "src/**/*.tsx"\n  - "components/**/*.tsx"\n  - "lib/**/*.ts"'
      TEST_GLOBS='  - "__tests__/**"\n  - "**/*.test.tsx"\n  - "**/*.test.ts"'
      CURSORIGNORE="node_modules/\n.next/\nout/\n.env\n.env.local\n.vercel/"
      KEY_COMMANDS="- Dev: npm run dev\n- Build: npm run build\n- Test: npm test\n- E2E: npx playwright test\n- Deploy: vercel (or railway up)"
      DEPLOY_DIR="."
      ;;
    react-native)
      GLOBS='  - "app/**/*.tsx"\n  - "src/**/*.tsx"\n  - "components/**/*.tsx"'
      TEST_GLOBS='  - "__tests__/**"\n  - "**/*.test.tsx"'
      CURSORIGNORE="node_modules/\n.expo/\nios/\nandroid/\ndist/\n.env"
      KEY_COMMANDS="- Dev: npx expo start\n- iOS: npx expo run:ios\n- Android: npx expo run:android\n- Test: npm test\n- Build: eas build --platform all"
      DEPLOY_DIR="."
      ;;
    react-vite)
      GLOBS='  - "src/**/*.tsx"\n  - "src/**/*.ts"\n  - "src/components/**"'
      TEST_GLOBS='  - "src/**/*.test.tsx"\n  - "src/**/*.test.ts"\n  - "tests/**"'
      CURSORIGNORE="node_modules/\ndist/\n.env\n.env.local"
      KEY_COMMANDS="- Dev: npm run dev\n- Build: npm run build\n- Test: npm test\n- Deploy: railway up"
      DEPLOY_DIR="."
      ;;
    node-express)
      GLOBS='  - "src/**/*.ts"\n  - "src/**/*.js"\n  - "prisma/**"'
      TEST_GLOBS='  - "tests/**/*.ts"\n  - "**/*.test.ts"\n  - "**/*.spec.ts"'
      CURSORIGNORE="node_modules/\ndist/\n.env\n.env.local"
      KEY_COMMANDS="- Dev: npm run dev\n- Build: npm run build\n- Test: npm test\n- Migrate: npx prisma migrate dev\n- Deploy: railway up"
      DEPLOY_DIR="."
      ;;
    django)
      GLOBS='  - "**/*.py"\n  - "templates/**/*.html"'
      TEST_GLOBS='  - "**/tests.py"\n  - "**/test_*.py"\n  - "tests/**"'
      CURSORIGNORE="__pycache__/\n*.pyc\n.env\ndb.sqlite3\nstaticfiles/\nmedia/\n.venv/\nvenv/"
      KEY_COMMANDS="- Dev: python manage.py runserver\n- Test: pytest\n- Migrate: python manage.py makemigrations && python manage.py migrate\n- Deploy: railway up"
      DEPLOY_DIR="railway"
      ;;
    *)
      GLOBS='  - "src/**"'
      TEST_GLOBS='  - "tests/**"\n  - "**/*.test.*"'
      CURSORIGNORE="node_modules/\ndist/\n.env"
      KEY_COMMANDS="- Dev: npm run dev\n- Test: npm test\n- Deploy: railway up"
      DEPLOY_DIR="."
      ;;
  esac

  # Generate stack-conventions.mdc
  cat > .cursor/rules/stack-conventions.mdc << RULE
---
description: Stack conventions for this ${STACK} project. Auto-attached on source files.
globs:
$(echo -e "$GLOBS")
alwaysApply: false
---
See @CLAUDE.md for project conventions and key commands.
Follow the conventions listed in @PRD.md under the Conventions section.
RULE

  # Generate testing.mdc
  cat > .cursor/rules/testing.mdc << RULE
---
description: Testing patterns for this project. Auto-attached on test files.
globs:
$(echo -e "$TEST_GLOBS")
alwaysApply: false
---
- Write tests for every feature and controller/handler method.
- Test both happy path and edge cases (auth, validation, ownership).
- Use factories or fixtures for test data. Never hardcode IDs.
- Run the test suite after every change. See CLAUDE.md for the test command.
RULE

  # Generate deployment.mdc
  cat > .cursor/rules/deployment.mdc << RULE
---
description: Deployment config for ${DEPLOY_TARGET}. Auto-attached on deploy files.
globs:
  - "railway/**"
  - "Dockerfile"
  - "docker-compose.yml"
  - "vercel.json"
  - "railway.toml"
  - "Procfile"
  - "eas.json"
  - ".env*"
alwaysApply: false
---
Deploy target: ${DEPLOY_TARGET}.
NEVER commit .env files. Use .env.example as the template.
All secrets go in the deployment platform's dashboard, not in code.
See CLAUDE.md and the deploy reference files for exact steps.
RULE

  # Generate .cursorignore
  echo -e "$CURSORIGNORE" > .cursorignore

else
  echo "Warning: No stack reference found for '$STACK'. Generating minimal config."
  KEY_COMMANDS="- Dev: (see your framework docs)\n- Test: (see your framework docs)"
  DEPLOY_DIR="."
fi

# ── Extract data model from PRD ──
# Simple extraction: grab everything between "## Data Model" and the next "##"
DATA_MODEL=$(sed -n '/^## Data Model/,/^## /{/^## Data Model/d;/^## /d;p;}' PRD.md)
if [ -z "$DATA_MODEL" ]; then
  DATA_MODEL="(See PRD.md — Data Model section)"
fi

# ── Extract conventions from PRD ──
CONVENTIONS=$(sed -n '/^## Conventions/,/^## /{/^## Conventions/d;/^## /d;p;}' PRD.md)
if [ -z "$CONVENTIONS" ]; then
  CONVENTIONS="(See PRD.md — Conventions section)"
fi

# ── Generate CLAUDE.md ──
cat > CLAUDE.md << EOF
# Project Context

## Quick Reference
- **PRD**: See PRD.md for full requirements, data model, and features
- **Stack**: ${STACK}
- **Deploy target**: ${DEPLOY_TARGET}
- **Mockups**: ${MOCKUP_COUNT} files in /mockups

## Data Model
${DATA_MODEL}

## Key Commands
$(echo -e "$KEY_COMMANDS")

## Repo Structure
- \`PRD.md\` — Product requirements (read FIRST for any task)
- \`CLAUDE.md\` — This file. Project context for AI agents.
- \`AGENTS.md\` — Symlink to CLAUDE.md (Codex/OpenCode compatibility)
- \`mockups/\` — Figma exports or HTML mockups (if provided)
- \`.cursor/rules/\` — Cursor rules (auto-generated, edit as needed)
- \`.cursorignore\` — Files excluded from Cursor indexing
- \`${DEPLOY_DIR}/\` — Deployment scripts and config

## Conventions
${CONVENTIONS}
EOF

# Symlink for Codex/OpenCode compatibility
ln -sf CLAUDE.md AGENTS.md

# ── Generate deploy config from reference ──
if [ -f "$STACK_REF" ]; then
  case "${STACK}-${DEPLOY_TARGET}" in
    laravel-railway)
      mkdir -p railway
      cat > railway/init-app.sh << 'DEPLOY'
#!/bin/bash
set -e
php artisan migrate --force
php artisan optimize:clear
php artisan config:cache
php artisan event:cache
php artisan route:cache
php artisan view:cache
DEPLOY
      cat > railway/run-worker.sh << 'DEPLOY'
#!/bin/bash
php artisan queue:work --sleep=3 --tries=3 --max-time=3600
DEPLOY
      cat > railway/run-cron.sh << 'DEPLOY'
#!/bin/bash
while [ true ]; do
    php artisan schedule:run --verbose --no-interaction &
    sleep 60
done
DEPLOY
      chmod +x railway/*.sh
      cat > .env.example << 'ENV'
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
ENV
      ;;
    nextjs-vercel)
      cat > vercel.json << 'DEPLOY'
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "framework": "nextjs"
}
DEPLOY
      cat > .env.example << 'ENV'
NEXT_PUBLIC_APP_URL=http://localhost:3000
DATABASE_URL=
NEXTAUTH_SECRET=
NEXTAUTH_URL=http://localhost:3000
ENV
      ;;
    nextjs-railway)
      cat > railway.toml << 'DEPLOY'
[build]
builder = "RAILPACK"
buildCommand = "npm ci && npm run build"

[deploy]
startCommand = "npm start"
DEPLOY
      cat > .env.example << 'ENV'
NEXT_PUBLIC_APP_URL=https://your-app.up.railway.app
DATABASE_URL=
NEXTAUTH_SECRET=
ENV
      ;;
    react-vite-railway)
      cat > railway.toml << 'DEPLOY'
[build]
builder = "RAILPACK"
buildCommand = "npm ci && npm run build"

[deploy]
startCommand = "npx serve dist -l $PORT"
DEPLOY
      cat > .env.example << 'ENV'
VITE_API_URL=http://localhost:3001/api
VITE_APP_NAME=YourApp
ENV
      ;;
    node-express-railway)
      cat > railway.toml << 'DEPLOY'
[build]
builder = "RAILPACK"
buildCommand = "npm ci && npm run build && npx prisma migrate deploy"

[deploy]
startCommand = "node dist/index.js"
healthcheckPath = "/health"
healthcheckTimeout = 10
DEPLOY
      cat > .env.example << 'ENV'
PORT=3001
NODE_ENV=production
DATABASE_URL=
JWT_SECRET=
JWT_REFRESH_SECRET=
CORS_ORIGIN=https://your-frontend.com
ENV
      ;;
    django-railway)
      mkdir -p railway
      cat > railway/start.sh << 'DEPLOY'
#!/bin/bash
set -e
python manage.py migrate --noinput
python manage.py collectstatic --noinput
gunicorn config.wsgi:application --bind 0.0.0.0:$PORT --workers 3
DEPLOY
      chmod +x railway/start.sh
      cat > .env.example << 'ENV'
DEBUG=False
SECRET_KEY=
ALLOWED_HOSTS=.up.railway.app,localhost
DATABASE_URL=
DJANGO_SETTINGS_MODULE=config.settings.prod
ENV
      ;;
    react-native-eas)
      cat > eas.json << 'DEPLOY'
{
  "cli": { "version": ">= 5.0.0" },
  "build": {
    "development": { "developmentClient": true, "distribution": "internal" },
    "preview": { "distribution": "internal" },
    "production": {}
  },
  "submit": { "production": {} }
}
DEPLOY
      cat > .env.example << 'ENV'
EXPO_PUBLIC_API_URL=http://localhost:3001/api
EXPO_PUBLIC_AUTH_PROVIDER=
ENV
      ;;
    *)
      # Fallback: minimal .env.example
      if [ ! -f .env.example ]; then
        cat > .env.example << 'ENV'
# Add your environment variables here
# See PRD.md Deployment section for required vars
ENV
      fi
      ;;
  esac
fi

# ── Generate .gitignore ──
if [ ! -f .gitignore ]; then
  cat > .gitignore << 'GIT'
node_modules/
dist/
.env
.env.local
*.log
GIT
fi

# Add stack-specific entries
case $STACK in
  laravel)
    cat >> .gitignore << 'GIT'
/vendor
/public/build
/public/hot
/public/storage
/storage/*.key
.phpunit.result.cache
auth.json
GIT
    ;;
  nextjs)
    cat >> .gitignore << 'GIT'
.next/
out/
.vercel
next-env.d.ts
GIT
    ;;
  react-native)
    cat >> .gitignore << 'GIT'
.expo/
ios/
android/
web-build/
*.jks
*.p8
*.p12
*.key
*.mobileprovision
GIT
    ;;
  django)
    cat >> .gitignore << 'GIT'
__pycache__/
*.py[cod]
*.egg-info/
db.sqlite3
staticfiles/
media/
.venv/
venv/
GIT
    ;;
esac

# ── Init git ──
git init -q
git add -A
git commit -q -m "chore: scaffold project from PRD via devstart"

# ── Summary ──
echo ""
echo "========================================="
echo "  DevStart: Project Scaffolded"
echo "========================================="
echo ""
echo "  Project:  $PROJECT_NAME"
echo "  Stack:    $STACK"
echo "  Deploy:   $DEPLOY_TARGET"
echo "  Mockups:  $MOCKUP_COUNT files"
echo ""
echo "  Generated files:"
find . -not -path './.git/*' -not -path './.git' -type f | sort | sed 's/^/    /'
echo ""
echo "  Next steps:"
echo "    1. Open in Cursor:"
echo "       cursor $(pwd)/"
echo ""
echo "    2. First prompt to the agent:"
echo "       Read @PRD.md and @CLAUDE.md. Set up the project:"
echo "       install dependencies, create the data model from the PRD,"
echo "       and run the initial migration. Verify with a test."
echo ""
echo "========================================="
