---
name: stack-laravel
description: >
  Laravel development conventions and patterns. This skill should be used when
  working in a Laravel project, editing PHP files, creating controllers, models,
  migrations, Blade views, or Pest tests. Provides Laravel 11 best practices,
  Eloquent patterns, Form Request validation, Policy authorization, and Pest testing.
---

# Laravel Stack Conventions

## Architecture
- Resource controllers with route model binding for all CRUD.
- Form Requests for validation. Never validate in controllers.
- Policies for authorization. Always authorize in controller methods.
- Eloquent scopes for reusable query logic. No raw DB:: queries for CRUD.
- PHP 8.1+ backed enums for status fields and other finite value sets.

## File Generation
Always use Artisan to generate files:
- `php artisan make:model X -mfsc` (model + migration + factory + seeder + controller)
- `php artisan make:request StoreXRequest` / `UpdateXRequest`
- `php artisan make:policy XPolicy --model=X`
- `php artisan make:test XTest` (Pest feature test)

## Blade + Tailwind
- Use Blade components (`<x-app-layout>`, `<x-slot>`). No `@extends` / `@section`.
- Tailwind utility classes only. No custom CSS files.
- Use `@vite` directive for asset loading.

## Testing (Pest)
- Feature tests for every controller action.
- Factory states for different data scenarios.
- `actingAs($user)` for authenticated tests.
- Assert response status, redirect, view, session errors.
- Run: `php artisan test`

## Database
- Migrations: always include `down()` method.
- Factories: define realistic defaults. Use `fake()` helper.
- Seeders: call from DatabaseSeeder. Idempotent where possible.

## Common Patterns
```php
// Controller with authorization
public function update(UpdateProjectRequest $request, Project $project)
{
    $this->authorize('update', $project);
    $project->update($request->validated());
    return redirect()->route('projects.show', $project);
}

// Pest test
it('allows owner to update project', function () {
    $user = User::factory()->create();
    $project = Project::factory()->for($user)->create();

    actingAs($user)
        ->put(route('projects.update', $project), ['name' => 'Updated'])
        ->assertRedirect(route('projects.show', $project));

    expect($project->fresh()->name)->toBe('Updated');
});
```
