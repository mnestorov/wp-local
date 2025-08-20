# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dual WordPress/Laravel local development environment using Docker. It provides containerized development for both WordPress and Laravel projects with automatic project detection, intelligent environment configuration, and streamlined workflows.

## Key Commands

### Environment Setup
```bash
# Automated setup (recommended)
cd docker && ./setup.sh <project-name>

# Manual Docker operations
docker-compose -f docker/docker-compose.wordpress.yml up -d  # WordPress
docker-compose -f docker/docker-compose.laravel.yml up -d    # Laravel

# Create new projects
./scripts/new-project-selector.sh   # Interactive
./scripts/new-laravel-project.sh    # Laravel direct
./scripts/new-wordpress-project.sh  # WordPress direct
```

### Laravel Development (example: www/karmkrag)
```bash
# Development server with queue, logs, and Vite
composer run dev

# Code quality and linting
./lint.sh check           # Full code check (PHP, JS, CSS)
./lint.sh fix            # Auto-fix all issues
composer run lint        # PHP linting with Pint
composer run lint:fix    # Fix PHP style issues
npm run lint            # Frontend linting
npm run fix             # Fix frontend issues

# Testing
./vendor/bin/pest              # Run all tests
./vendor/bin/pest --watch      # Watch mode
./vendor/bin/pest --coverage   # Coverage report
./vendor/bin/pest tests/Feature/ExampleTest.php  # Single test

# Database and queue
php artisan migrate
php artisan queue:listen --tries=1  # Required for emails
php artisan db:seed --class=AdminUserSeeder

# Frontend build
npm run dev    # Vite dev server
npm run build  # Production build
```

### WordPress Development
```bash
# WP-CLI commands (container-based)
docker exec -it php_<project> wp --allow-root user list
docker exec -it php_<project> wp --allow-root plugin list
docker exec -it php_<project> wp --allow-root core update

# Composer operations
composer install  # Install WordPress core and plugins
```

## Architecture

### Project Structure
```
wp-local/
├── docker/           # Docker configs, setup scripts, env templates
├── scripts/          # Project creation scripts
├── traefik/          # Reverse proxy configuration
└── www/              # All projects live here
    ├── karmkrag/     # Laravel magazine subscription system
    ├── smartyapp/    # WordPress project
    └── smartylaravel/# Laravel project
```

### Laravel Projects Architecture (karmkrag example)

**Modular Architecture** at `app/Modules/`:
- `Core/` - Authentication, admin panel, settings, base system
- `Subscriptions/` - Magazine subscription business logic
- `Blog/` - Content management with categories and tags
- `Shop/` - E-commerce functionality

Each module contains:
- `Http/Controllers/` - Request handling
- `Http/Livewire/` - Livewire components
- `Models/` - Eloquent models
- `Policies/` - Authorization policies
- `routes/` - Module-specific routes
- `Resources/views/` - Blade templates

**Key Technologies**:
- Laravel 12 with Livewire 3.6 for reactive components
- Pest for testing (PHPUnit wrapper with better syntax)
- Laravel Pint for PHP code style
- Vite for asset compilation
- Bootstrap 5.3 + Alpine.js for frontend

### Service Access URLs
- Projects: `http://{project-name}.test`
- phpMyAdmin: `http://phpmyadmin.test`
- MailHog: `http://mailhog.test`
- Traefik Dashboard: `http://localhost:8080`

### Database Configuration
- Root access: root/root
- Project databases auto-created with project-specific credentials
- Data persisted in `www/{project}/mysql/`

## Development Workflow

### Project Type Detection
The system automatically detects:
- **WordPress**: Presence of `wp-config.php` or `wp/wp-config.php`
- **Laravel**: Presence of `artisan` file and `composer.json`

### Laravel Concurrent Development
The `composer run dev` command runs:
1. PHP development server
2. Queue worker (critical for email/notifications)
3. Log viewer
4. Vite development server

All output is displayed concurrently for full visibility.

### Code Quality Enforcement
The `lint.sh` script provides comprehensive linting:
- PHP (Laravel Pint)
- JavaScript/TypeScript (ESLint)
- CSS/SCSS (Stylelint)
- Options: `check`, `fix`, `--php-only`, `--js-only`, `--css-only`

### Testing Strategy
- Use Pest for PHP testing (more readable than PHPUnit)
- Tests located in `tests/Feature/` and `tests/Unit/`
- Run with watch mode during development
- Ensure queue worker is running for tests involving emails

## Version Control & Releases

### Semantic Release
This repository uses automated semantic versioning with conventional commits:
- **Commit format**: `type(scope): description`
- **Interactive commits**: `npm run commit`
- **Version bumps**: Automatic based on commit types (feat → minor, fix → patch, BREAKING CHANGE → major)
- **Releases**: Automated via GitHub Actions on merge to main branch

### Commit Types
- `feat`: New feature (minor version)
- `fix`: Bug fix (patch version)
- `docs`: Documentation changes
- `chore`: Maintenance tasks
- `refactor`: Code restructuring
- `test`: Test additions/changes

## Important Notes

1. **Queue Worker Required**: For Laravel projects with email/notifications, always run `php artisan queue:listen --tries=1`
2. **Environment Files**: Docker setup uses template files (`.env.wordpress`, `.env.laravel`) with automatic variable substitution
3. **Volume Mounts**: All project files are mounted, changes reflect immediately
4. **Container Names**: Follow pattern `{service}_{project}` (e.g., `php_karmkrag`, `nginx_smartylaravel`)
5. **Traefik Routing**: Automatic SSL and routing based on project name
6. **Development Only**: This setup is optimized for local development, not production
7. **Excluded from Git**: The `www/` directory is gitignored - individual projects should have their own repositories