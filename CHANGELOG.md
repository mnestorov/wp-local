# Changelog

All notable changes to the WP-Local Docker environment will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

# 1.0.0 (2025-08-20)


### Bug Fixes

* **ci:** resolve semantic-release commit hook conflicts ([aebe250](https://github.com/mnestorov/wp-local/commit/aebe250d047c8b7838d0ecc6a2401a803d308661))


### Features

* **ci:** add semantic-release with conventional commits ([eebe548](https://github.com/mnestorov/wp-local/commit/eebe548f2e9fe7e1a0af2516d288a0f158c3aca0))
* **ci:** update PR check workflow to enhance semantic-release preview ([40206e3](https://github.com/mnestorov/wp-local/commit/40206e30e6dba625468206bc5c614688e02f1ee9))
* enhance Docker configuration for large file uploads ([ffbdaf2](https://github.com/mnestorov/wp-local/commit/ffbdaf240d193123be07acbe7891e048bad4c2e8))
* transform WordPress environment into dual WordPress/Laravel development platform ([5ce4e90](https://github.com/mnestorov/wp-local/commit/5ce4e900d29162fda61649a8379ceb547b77c618))
* update Docker Compose configuration to expose MySQL and MailHog ports ([5f68635](https://github.com/mnestorov/wp-local/commit/5f68635d814aae68304700a8335c1697840cca5d))

## [Unreleased]

### Added
- Semantic release automation with conventional commits
- GitHub Actions workflow for automated releases
- Commitlint for enforcing commit message conventions
- Husky git hooks for pre-commit validation

### Changed
- Enhanced Docker configuration for large file uploads
- Exposed MySQL and MailHog ports in Docker Compose configuration

### Previous Features
- Dual WordPress/Laravel development environment
- Automatic project type detection
- Traefik reverse proxy integration
- phpMyAdmin and MailHog services
- Interactive project creation scripts
- WordPress coding standards and best practices guidelines
