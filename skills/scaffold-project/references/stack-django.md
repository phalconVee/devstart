# Django Stack Reference

## Detection
Matches when PRD contains: Django, Python web, DRF, Django REST Framework, Wagtail.

## Cursor Rules

### stack-conventions.mdc
```yaml
---
description: Django conventions for this project.
globs:
  - "**/*.py"
  - "templates/**/*.html"
  - "**/models.py"
  - "**/views.py"
  - "**/urls.py"
  - "**/serializers.py"
alwaysApply: false
---
```
Content:
- Django 5.x patterns. Use class-based views for CRUD, function views for simple logic.
- Models: explicit `__str__`, `Meta.ordering`, verbose_name. Use Django's field validators.
- Forms / Serializers for all validation. Never validate in views directly.
- Django REST Framework for API endpoints (if API project). ModelSerializer for standard CRUD.
- Permissions: use Django's permission system + custom permission classes.
- Template structure: `templates/<app_name>/` with base.html inheritance.
- Static files: Tailwind via django-tailwind or CDN. WhiteNoise for serving in production.
- Settings: split into base.py / dev.py / prod.py or use django-environ.
- Type hints on all function signatures. Use `django-stubs` for model typing.
- URL naming: `app_name:action-model` (e.g., `projects:create-project`).

### testing.mdc
```yaml
---
description: Django testing patterns.
globs:
  - "**/tests.py"
  - "**/tests/**"
  - "tests/**"
  - "**/test_*.py"
alwaysApply: false
---
```
Content:
- pytest-django for all tests. No unittest.TestCase.
- Factory Boy for model factories. Never use fixtures files.
- Test views via Django test client: self.client.get(), self.client.post().
- Test both authenticated and unauthenticated access.
- Run: `pytest` or `python manage.py test`.

### deployment.mdc
```yaml
---
description: Django deployment config.
globs:
  - "Dockerfile"
  - "railway/**"
  - "Procfile"
  - "requirements*.txt"
  - "pyproject.toml"
  - ".env*"
alwaysApply: false
---
```
Content:
- Railway: use Dockerfile or Nixpacks with gunicorn.
- Pre-deploy: `python manage.py migrate --noinput && python manage.py collectstatic --noinput`.
- ALLOWED_HOSTS must include the Railway domain.
- Use dj-database-url to parse DATABASE_URL.
- WhiteNoise for static files in production.
- Never use `DEBUG=True` in production.

## Deployment Config Files

### railway/start.sh
```bash
#!/bin/bash
set -e
python manage.py migrate --noinput
python manage.py collectstatic --noinput
gunicorn config.wsgi:application --bind 0.0.0.0:$PORT --workers 3
```

### Dockerfile
```dockerfile
FROM python:3.12-slim
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN python manage.py collectstatic --noinput

EXPOSE $PORT
CMD ["sh", "railway/start.sh"]
```

### .env.example
```
DEBUG=False
SECRET_KEY=
ALLOWED_HOSTS=.up.railway.app,localhost
DATABASE_URL=
DJANGO_SETTINGS_MODULE=config.settings.prod
```

### .gitignore
```
__pycache__/
*.py[cod]
*.egg-info/
dist/
.eggs/
*.egg
.env
db.sqlite3
staticfiles/
media/
.venv/
venv/
```

## Key Commands
- Dev server: `python manage.py runserver`
- Run tests: `pytest`
- Create app: `python manage.py startapp <name>`
- Migrations: `python manage.py makemigrations && python manage.py migrate`
- Create superuser: `python manage.py createsuperuser`
- Deploy: `railway up`

## Recommended Community Skills
- Django/Python skills from skills.sh
- `railwayapp/railway-skills` for deployment
