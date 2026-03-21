---
name: stack-django
description: >
  Django development conventions and patterns. This skill should be used when
  working in a Django project, creating models, views, serializers, templates,
  or tests. Provides Django 5.x best practices, DRF patterns, class-based views,
  and pytest-django testing conventions.
---

# Django Stack Conventions

## Architecture
- Django 5.x. Class-based views for CRUD (CreateView, UpdateView, etc.).
- Function-based views for simple or custom logic.
- Django REST Framework for API projects. ModelSerializer + ViewSets.
- Settings split: `config/settings/{base,dev,prod}.py` or django-environ.

## Models
- Explicit `__str__`, `Meta.ordering`, `verbose_name`.
- Field validators on the model. Custom `clean()` for cross-field validation.
- Use `related_name` on all ForeignKey / ManyToMany fields.
- Abstract base models for shared fields (timestamps, soft delete).

## Validation
- Django Forms for template-based views. Clean methods for custom validation.
- DRF Serializers for API views. Never validate in views directly.
- Permissions: Django's built-in permission system + custom permission classes.

## Templates
- Base template inheritance: `base.html` → `app/base.html` → `app/page.html`.
- Template tags and filters for reusable logic. No complex Python in templates.
- Tailwind CSS via django-tailwind package or CDN.

## Testing
- pytest-django. No `unittest.TestCase`.
- Factory Boy for model factories. No fixtures.
- Test views via `client.get()`, `client.post()`.
- Test both 200 and 403/404 responses.
- Run: `pytest`.

## Common Patterns
```python
# Class-based view with permission
class ProjectUpdateView(LoginRequiredMixin, UserPassesTestMixin, UpdateView):
    model = Project
    form_class = ProjectForm
    template_name = 'projects/edit.html'

    def test_func(self):
        return self.get_object().owner == self.request.user

# pytest test
def test_owner_can_update_project(client, user_factory, project_factory):
    user = user_factory()
    project = project_factory(owner=user)
    client.force_login(user)
    response = client.post(
        reverse('projects:update', args=[project.pk]),
        {'name': 'Updated'}
    )
    assert response.status_code == 302
    project.refresh_from_db()
    assert project.name == 'Updated'
```
