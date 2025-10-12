# Contributing to WP-Local

## Commit Message Conventions

This project uses [Conventional Commits](https://www.conventionalcommits.org/) and [Semantic Versioning](https://semver.org/).

### Commit Message Format

Each commit message consists of a **header**, a **body** (optional), and a **footer** (optional).

```text
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: A new feature (minor version bump)
- **fix**: A bug fix (patch version bump)
- **docs**: Documentation only changes
- **style**: Changes that don't affect code meaning (formatting, missing semicolons, etc.)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Performance improvement
- **test**: Adding missing tests or correcting existing tests
- **chore**: Changes to build process, auxiliary tools, or maintenance tasks
- **ci**: CI configuration changes
- **build**: Build system or external dependency changes

### Scope (Optional)

The scope could be:

- `docker`: Docker configuration changes
- `wordpress`: WordPress-specific changes
- `laravel`: Laravel-specific changes
- `traefik`: Traefik configuration
- `scripts`: Shell scripts or automation
- `docs`: Documentation

### Examples

```bash
# Feature with scope
feat(docker): add Redis service for Laravel caching

# Bug fix
fix: resolve MySQL connection timeout in docker-compose

# Breaking change (major version bump)
feat(docker)!: upgrade to PHP 8.3

BREAKING CHANGE: PHP 8.3 requires updating all WordPress plugins

# Documentation
docs: update README with new environment variables

# Chore
chore: update npm dependencies
```

### Using Commitizen

For an interactive commit experience:

```bash
npm run commit
```

This will guide you through creating a properly formatted commit message.

## Development Workflow

1. **Create a feature branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow existing code patterns
   - Update documentation if needed
   - Test your changes

3. **Commit using conventional commits**

   ```bash
   npm run commit
   # or
   git commit -m "feat(docker): add new service"
   ```

4. **Push and create a Pull Request**

   ```bash
   git push origin feature/your-feature-name
   ```

5. **Automated Release**
   - When PR is merged to `main`, semantic-release automatically:
     - Analyzes commits
     - Determines version bump
     - Updates CHANGELOG.md
     - Creates GitHub release
     - Tags the release

## Version Bumping Rules

- `fix:` commits → Patch release (1.0.0 → 1.0.1)
- `feat:` commits → Minor release (1.0.0 → 1.1.0)
- `BREAKING CHANGE:` in footer → Major release (1.0.0 → 2.0.0)
- `!` after type → Major release (1.0.0 → 2.0.0)

## Pre-release Branches

- `develop` branch: Creates pre-release versions (e.g., 1.1.0-develop.1)
- `beta` branch: Creates beta versions (e.g., 1.1.0-beta.1)
- `main` branch: Creates stable releases
