# WordPress Local Development Environment

A complete Docker-based WordPress local development environment with automatic project setup, WP-CLI integration, and convenient aliases.

## 🚀 Quick Start

1. **Create a new project:**
   ```bash
   cd wp-local
   ./scripts/new-project.sh
   ```

2. **Enter your project name** when prompted (e.g., `myproject`)

3. **Visit your site:** `http://myproject.test`

## 🔧 Multi-Project Setup

This environment supports **multiple WordPress projects** simultaneously:

- **Shared `.env` file** - Contains common settings (PHP version, MariaDB version, GitHub token)
- **Project-specific aliases** - Each project gets its own set of aliases
- **Isolated databases** - Each project has its own database and file system
- **No conflicts** - Projects don't interfere with each other

**Example:**
```bash
# Create first project
./scripts/new-project.sh  # Enter: myblog
# Creates aliases: wpup-myblog, wpcli-myblog, etc.

# Create second project  
./scripts/new-project.sh  # Enter: ecommerce
# Creates aliases: wpup-ecommerce, wpcli-ecommerce, etc.

# Both projects can run simultaneously
wpup-myblog
wpup-ecommerce
```

## 📁 Project Structure

```
wp-local/
├── docker/
│   ├── docker-compose.yml    # Docker services configuration
│   ├── Dockerfile           # PHP + Apache + WP-CLI image
│   └── .env                 # Environment variables (auto-generated)
├── scripts/
│   └── new-project.sh       # Project creation script
├── traefik/
│   └── traefik.yml          # Reverse proxy configuration
├── www/
│   └── [project-name]/      # WordPress installation
└── README.md               # This file
```

## 🐳 Available Services

| Service | URL | Description |
|---------|-----|-------------|
| WordPress Site | `http://[project].test` | Your WordPress installation |
| Traefik Dashboard | `http://localhost:8080` | Reverse proxy management |
| phpMyAdmin | `http://phpmyadmin.test` | Database management |
| MailHog | `http://mailhog.test` | Email testing |

## ⚡ Available Aliases

After running the setup script, you'll have project-specific aliases available. Replace `[project]` with your actual project name.

### Docker Management Aliases

```bash
# Start containers
wpup-[project]

# Stop containers
wpdown-[project]

# View logs
wplogs-[project]

# Restart containers
wprestart-[project]

# Stop and remove everything (volumes included)
wpclean-[project]

# Clean up all Docker resources
wpprune-[project]
```

### WP-CLI Aliases

```bash
# Run any WP-CLI command
wpcli-[project] <command>

# Show WP-CLI information
wpinfo-[project]

# Check if WordPress is installed
wpstatus-[project]

# Install WordPress automatically
wpinstall-[project]

# Database management
wpdb-[project] <command>
```

**Note:** All WP-CLI commands include `--allow-root` flag to prevent paging issues in Docker containers.

## 🔧 WP-CLI Examples

```bash
# List users
wpcli-[project] user list

# List plugins
wpcli-[project] plugin list

# List themes
wpcli-[project] theme list

# Check WordPress version
wpcli-[project] core version

# Install a plugin
wpcli-[project] plugin install woocommerce --activate

# Update WordPress core
wpcli-[project] core update

# Export database
wpcli-[project] db export backup.sql

# Import database
wpcli-[project] db import backup.sql

# Search and replace in database
wpcli-[project] search-replace 'old-domain.com' 'new-domain.com'
```

## 🛠️ Manual Commands

If you need to run commands manually:

```bash
# Navigate to docker directory
cd wp-local/docker

# Export DB variables (replace with your project name)
export DB_NAME="[prefix]_[project]"
export DB_USER="[project]_user"
export DB_PASSWORD="[project]_pass"
export APP_ID="[project]"
export PROJECT_DOMAIN="[project].test"

# Run docker compose
docker compose up -d

# Access WP-CLI directly
docker exec -it php_[project] wp --allow-root
```

## 🔍 Troubleshooting

### Common Issues

1. **Port 80 already in use:**
   ```bash
   sudo lsof -i :80
   # Stop the conflicting service
   ```

2. **Database connection errors:**
   ```bash
   wpclean-[project]
   wpup-[project]
   ```

3. **WP-CLI permission errors:**
   - All commands include `--allow-root` flag
   - If you see permission warnings, they're safe to ignore in Docker

4. **Composer installation fails:**
   - Check your GitHub token in `docker/.env`
   - The token is automatically reused for all projects
   - Ensure you have access to private repositories
   - Try running the script again
   - The script will continue even if some plugins fail to install

5. **Domain not resolving:**
   ```bash
   # Check if domain is in /etc/hosts
   cat /etc/hosts | grep [project].test
   ```

### Debug Commands

```bash
# Check container status
docker compose ps

# View container logs
docker compose logs [service]

# Access container shell
docker exec -it php_[project] bash

# Check WordPress installation
wpcli-[project] core is-installed
```

## 📦 Included Plugins

Every new project automatically includes:

- **Query Monitor** - Performance and debugging
- **WP Crontrol** - Cron job management
- **Smarty Change Admin Colors** - Custom admin theme

## 🔐 Security Notes

- Database credentials are generated dynamically and not stored in files
- WP-CLI runs with `--allow-root` flag in Docker containers (safe for local development)
- Each project has isolated database and file system
- **GitHub token is shared** across all projects (stored in `.env` file)
- **GitHub token is automatically reused** - you only need to enter it once

## 🎯 Project Examples

### Example: Creating "myblog" project

```bash
cd wp-local
./scripts/new-project.sh
# Enter: myblog

# Available aliases:
wpup-myblog
wpdown-myblog
wpcli-myblog user list
wpstatus-myblog
```

### Example: Creating "ecommerce" project

```bash
cd wp-local
./scripts/new-project.sh
# Enter: ecommerce

# Available aliases:
wpup-ecommerce
wpdown-ecommerce
wpcli-ecommerce plugin install woocommerce --activate
```

## 📝 Notes

- **WordPress Admin:** `http://[project].test/wp-admin`
- **Default Admin:** `admin` / `admin123` (if using wpinstall alias)
- **Database Name:** `[prefix]_[project]` (e.g., `my_myblog`)
- **Debug Log:** `www/[project]/wp/wp-content/debug.log`

## 🔄 Updates

To update the Docker image with new features:

```bash
cd wp-local/docker
docker compose build --no-cache
```

---

**Happy WordPress Development! 🚀** 