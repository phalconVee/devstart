---
name: stack-react-native
description: >
  React Native / Expo development conventions. This skill should be used when
  working in a React Native or Expo project, building mobile screens, components,
  navigation, or native integrations. Provides Expo SDK patterns, Expo Router
  navigation, and cross-platform best practices.
---

# React Native / Expo Stack Conventions

## Architecture
- Expo managed workflow (SDK 52+). Expo Router for file-based navigation.
- App directory structure mirrors Expo Router conventions (app/ directory).
- TypeScript strict mode. No `any`.

## Components
- Functional components only. Custom hooks for shared logic.
- StyleSheet.create for all styles. No inline style objects in JSX.
- Platform-specific code: `.ios.tsx` / `.android.tsx` suffixes or `Platform.select()`.
- Use `FlatList` / `FlashList` for lists. Never `ScrollView` with `.map()` for dynamic lists.

## Navigation (Expo Router)
- File-based routing in app/ directory.
- Layouts: `_layout.tsx` for shared navigation structure.
- Typed routes with `expo-router`'s `Link` component.

## Native APIs
- `expo-image` over `Image` for performance.
- `expo-secure-store` for sensitive data.
- `expo-notifications` for push notifications.
- Check platform support before using any native module.

## State Management
- React Query / TanStack Query for server state.
- Zustand for client state.
- No Redux unless PRD explicitly requires it.

## Testing
- Jest + React Native Testing Library.
- Mock native modules in jest.setup.ts.
- Test user interactions (press, type, scroll), not implementation.
