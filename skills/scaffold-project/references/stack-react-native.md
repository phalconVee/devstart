# React Native Stack Reference

## Detection
Matches when PRD contains: React Native, Expo, mobile app, iOS, Android, cross-platform mobile.

## Cursor Rules

### stack-conventions.mdc
```yaml
---
description: React Native / Expo conventions for this project.
globs:
  - "app/**/*.tsx"
  - "app/**/*.ts"
  - "src/**/*.tsx"
  - "src/**/*.ts"
  - "components/**/*.tsx"
alwaysApply: false
---
```
Content:
- Expo SDK (managed workflow) unless PRD specifies bare React Native.
- Expo Router for file-based navigation (app/ directory).
- TypeScript strict mode. No `any`. Co-locate types with components.
- StyleSheet.create for all styles. No inline style objects in render.
- NativeWind (Tailwind for RN) if specified, otherwise StyleSheet.
- Use `expo-image` over `Image` for performance.
- Use `expo-secure-store` for sensitive data, `expo-async-storage` for preferences.
- Platform-specific code via `.ios.tsx` / `.android.tsx` suffixes or `Platform.select()`.
- Prefer `FlatList` over `ScrollView` for any list longer than 10 items.
- Use React Query / TanStack Query for server state management.

### testing.mdc
```yaml
---
description: React Native testing patterns.
globs:
  - "__tests__/**"
  - "**/*.test.ts"
  - "**/*.test.tsx"
alwaysApply: false
---
```
Content:
- Jest + React Native Testing Library for unit/component tests.
- Detox for E2E tests (if configured).
- Test user interactions: press, type, scroll — not implementation details.
- Mock native modules in `jest.setup.ts`.
- Run: `npm test` (Jest).

### deployment.mdc
```yaml
---
description: React Native / Expo deployment config.
globs:
  - "eas.json"
  - "app.json"
  - "app.config.*"
alwaysApply: false
---
```
Content:
- Use EAS Build for iOS and Android builds: `eas build --platform all`.
- Use EAS Submit for app store submission: `eas submit --platform all`.
- OTA updates with EAS Update: `eas update --branch production`.
- app.json / app.config.ts is the single source of app configuration.
- Never hardcode API URLs. Use environment-specific config via `eas.json` profiles.
- **Backend on Railway:** If the PRD includes an API deployed to Railway, append `assets/cursor-rules/railway-cli-runbook.md` from the scaffold-project skill to `deployment.mdc` for the **API** subproject (or shared deploy rule). Companion: `railwayapp/railway-skills` (`npx skills add railwayapp/railway-skills --yes`).

## Deployment Config Files

### eas.json
```json
{
  "cli": { "version": ">= 5.0.0" },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal"
    },
    "production": {}
  },
  "submit": {
    "production": {}
  }
}
```

### .env.example
```
# API
EXPO_PUBLIC_API_URL=http://localhost:3000/api

# Auth
EXPO_PUBLIC_AUTH_PROVIDER=

# Analytics (optional)
EXPO_PUBLIC_ANALYTICS_KEY=
```

### .gitignore
```
node_modules/
.expo/
dist/
*.jks
*.p8
*.p12
*.key
*.mobileprovision
*.orig.*
web-build/
.env
ios/
android/
```

## Key Commands
- Dev server: `npx expo start`
- Run on iOS sim: `npx expo run:ios`
- Run on Android: `npx expo run:android`
- Run tests: `npm test`
- Build (EAS): `eas build --platform all --profile preview`
- OTA update: `eas update --branch production`

## API Backend Note
React Native apps need a separate API backend. If the PRD specifies one,
also scaffold the backend using the appropriate stack reference (node-express,
laravel, django). Create a monorepo structure:
```
project/
├── apps/
│   ├── mobile/    # React Native app
│   └── api/       # Backend (Node/Laravel/Django)
└── packages/      # Shared types, utils
```

## Recommended Community Skills
- Expo-specific skills from skills.sh
- `railwayapp/railway-skills` for backend deployment
