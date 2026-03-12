# WordPress, Laravel & Next.js Local Development Environment

[![Last Update](https://img.shields.io/github/last-commit/mnestorov/wp-local/main.svg?label=last%20update)](https://github.com/mnestorov/wp-local/commits/main)
[![Version](https://img.shields.io/github/v/release/mnestorov/wp-local?label=version)](https://github.com/mnestorov/wp-local/releases)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue)](https://www.docker.com/)

A complete Docker-based local development environment supporting **WordPress**, **Laravel**, and **Next.js** projects with automatic project setup, intelligent project detection, and streamlined development workflows.

## 📰 Latest Updates

### Version Updates (October 2025)

- **Traefik**: Upgraded to v3.5 (latest stable release)
- **phpMyAdmin**: Updated to latest version for improved security
- **Adminer**: Updated to latest version for better performance
- **PHP**: Already using 8.4 (latest stable) in all Docker images
- **Composer**: Using version 2.8 for better dependency management
- **MariaDB**: Continues with 11.6 LTS for stability
- **Redis**: Using 7.4 Alpine for minimal footprint
- **Elasticsearch/Kibana**: 7.17.25 with full security features enabled

## 🛠️ Tools & Technologies

### Core Technologies

- **Docker** - Containerization platform for consistent development environments
- **Docker Compose** - Multi-container Docker applications
- **Traefik v3.5** - Modern reverse proxy and load balancer for automatic routing (latest stable)
- **MariaDB 11.6** - Latest LTS database server (MySQL-compatible)
- **PHP 8.4** - Latest PHP version with improved performance and features
- **Nginx** - Web server (for Laravel projects)
- **Apache** - Web server (for WordPress projects)

### Development Tools

- **Composer 2.8** - PHP dependency management
- **GitHub Authentication** - For private repository access
- **Mailpit** - Modern email testing and development tool
- **phpMyAdmin** - Database administration interface (latest version)
- **Adminer** - Lightweight database administration tool (latest version)
- **Elasticsearch 7.17.25** - Search and analytics engine with security enabled
- **Kibana 7.17.25** - Elasticsearch data visualization with authentication
- **WP-CLI** - Command-line interface for WordPress
- **Redis 7.4** - In-memory data structure store (for Laravel projects)

### Supported Frameworks

- **WordPress** - Latest stable version (6.5+) with WP-CLI integration
- **Laravel** - Modern PHP framework with full feature support
- **Next.js** - React framework with PostgreSQL and Prisma ORM support

### System Requirements

- **Docker Desktop** - For Windows/macOS users
- **Docker Engine** - For Linux users
- **Bash Shell** - For script execution
- **Git** - Version control (optional but recommended)
- **Ruby 3.4+** - For DIP (Docker Interaction Process) support (optional but recommended)

## 🚀 Quick Start

### Automated Setup (Recommended)

The setup script automatically detects your project type and configures the environment. It also generates a `dip.yml` file for simplified Docker commands.

```bash
cd wp-local/docker
./setup.sh <project-name>
```

**Examples:**

```bash
# For WordPress project
./setup.sh smartyapp

# For Laravel project
./setup.sh smartylaravel

# For Next.js project
./setup.sh smartynext
```

**What the setup script does:**

- Detects project type (WordPress, Laravel, or Next.js)
- Configures environment variables
- **Auto-generates dip.yml** with project-specific settings
- Starts Docker containers
- Sets up database and dependencies

### Using DIP - Simplified Docker Commands (Recommended)

DIP (Docker Interaction Process) provides a simplified interface for Docker operations. Navigate to your project directory first:

```bash
# Navigate to your project
cd www/<project-name>

# Common commands
dip up          # Start all services
dip down        # Stop all services
dip logs        # View logs
dip restart     # Restart services
dip clean       # Stop and remove volumes
```

**WordPress-specific:**

```bash
dip wp plugin list  # Run WP-CLI commands
dip shell           # Access PHP container
dip db              # Access database CLI
```

**Laravel-specific:**

```bash
dip artisan migrate # Run Artisan commands
dip composer install # Run Composer
dip npm install     # Run NPM commands
dip test            # Run tests
```

**Next.js-specific:**

```bash
dip npm run build   # Production build
dip prisma          # Run Prisma commands
dip migrate         # Run Prisma migrations
dip seed            # Run seeders
dip db              # Access PostgreSQL CLI
dip lint            # Run ESLint
```

### Manual Setup

If you prefer manual control:

```bash
cd wp-local/docker

# For WordPress
docker-compose -f docker-compose.wordpress.yml up -d

# For Laravel
docker-compose -f docker-compose.laravel.yml up -d

# For Next.js
docker-compose -f docker-compose.nextjs.yml up -d
```

## 🔧 DIP Installation (Optional but Recommended)

DIP (Docker Interaction Process) simplifies Docker commands and provides a cleaner workflow.

### Installing DIP

**macOS:**

```bash
# Install Ruby 3.4+ via Homebrew (if not already installed)
brew install ruby

# Add Ruby to your PATH in ~/.zshrc or ~/.bash_profile
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"

# Reload shell
source ~/.zshrc  # or source ~/.bash_profile

# Install DIP gem
gem install dip

# Verify installation
dip version
```

**Linux:**

```bash
# Install Ruby 3.4+ via package manager
# Ubuntu/Debian:
sudo apt-get install ruby-full

# Fedora/RHEL:
sudo dnf install ruby

# Install DIP gem
gem install dip

# Verify installation
dip version
```

### DIP Configuration

**Automatic Generation**: When you create a new project using the setup scripts, a `dip.yml` file is automatically generated in your project directory with the correct configuration for your project type (WordPress, Laravel, or Next.js).

The auto-generated `dip.yml` file includes:

- Project-specific environment variables (database credentials, domain, etc.)
- Pre-configured commands for common tasks (up, down, logs, etc.)
- Framework-specific commands (WP-CLI for WordPress, Artisan for Laravel, Prisma for Next.js)
- Container access commands (shell, database CLI, etc.)

**Example projects with dip.yml:**

- [www/smartyapp/dip.yml](www/smartyapp/dip.yml) - WordPress configuration
- [www/smartylaravel/dip.yml](www/smartylaravel/dip.yml) - Laravel configuration
- [www/smartynext/dip.yml](www/smartynext/dip.yml) - Next.js configuration

**Manual creation**: If you need to create a `dip.yml` file manually, templates are available at:

- [docker/templates/dip.wordpress.yml](docker/templates/dip.wordpress.yml) - WordPress template
- [docker/templates/dip.laravel.yml](docker/templates/dip.laravel.yml) - Laravel template
- [docker/templates/dip.nextjs.yml](docker/templates/dip.nextjs.yml) - Next.js template

### Using DIP

Navigate to your project directory and use simple commands:

```bash
cd www/your-project
dip ls          # List all available commands
dip up          # Start services
dip down        # Stop services
```

## 🔧 Environment Configuration System

### Environment Files

The setup uses separate environment templates for different project types:

```text
docker/
├── .env                        # Auto-generated by setup.sh
├── .env.wordpress             # WordPress environment template
├── .env.laravel               # Laravel environment template
├── .env.nextjs                # Next.js environment template
├── docker-compose.wordpress.yml
├── docker-compose.laravel.yml
├── docker-compose.nextjs.yml
├── Dockerfile.wordpress
├── Dockerfile.laravel
└── setup.sh                   # Automated setup script
```

### What are .env Files?

Environment files (`.env`) contain configuration variables that customize your Docker environment:

- **Project-specific settings** - APP_ID, PROJECT_DOMAIN, database credentials
- **Version control** - PHP version, MariaDB version, phpMyAdmin version
- **Authentication** - GitHub token for private repository access
- **Database configuration** - Database name, user, password

### How It Works

1. **Template Selection**: Setup script detects project type (WordPress/Laravel/Next.js)
2. **Environment Generation**: Copies appropriate template (`.env.wordpress`, `.env.laravel`, or `.env.nextjs`)
3. **Variable Substitution**: Replaces placeholders with your project name
4. **Container Launch**: Uses the generated `.env` file for Docker configuration

### Environment Variables Explained

| Variable | Purpose | Example |
|----------|---------|---------|
| `APP_ID` | Project identifier | `smartyapp` |
| `PROJECT_DOMAIN` | Local domain | `smartyapp.test` |
| `DB_NAME` | Database name | `smartyapp` |
| `DB_USER` | Database user | `smartyapp` |
| `DB_PASSWORD` | Database password | `smartyapp` |
| `PHP_VERSION` | PHP Docker image version | `8.4-apache` |
| `MARIADB_VERSION` | MariaDB version | `11.6` |
| `GITHUB_AUTH_TOKEN` | GitHub authentication | `ghp_xyz123...` |

## 📁 Project Structure

```text
wp-local/
├── docker/
│   ├── .env                          # Auto-generated environment
│   ├── .env.wordpress               # WordPress template
│   ├── .env.laravel                 # Laravel template
│   ├── .env.nextjs                  # Next.js template
│   ├── docker-compose.wordpress.yml # WordPress services
│   ├── docker-compose.laravel.yml   # Laravel services
│   ├── docker-compose.nextjs.yml    # Next.js services
│   ├── Dockerfile.wordpress         # WordPress container
│   ├── Dockerfile.laravel           # Laravel container
│   ├── setup.sh                     # Automated setup script
│   ├── nginx.conf                   # Nginx configuration
│   ├── default.conf                 # Default site configuration
│   ├── supervisord.conf             # Process management
│   └── templates/
│       ├── dip.wordpress.yml        # WordPress DIP template
│       ├── dip.laravel.yml          # Laravel DIP template
│       └── dip.nextjs.yml           # Next.js DIP template
├── www/
│   ├── smartyapp/                   # WordPress project
│   │   ├── wp/                      # WordPress core files
│   │   ├── mysql/                   # Database files
│   │   ├── elasticsearch/           # Search index data
│   │   └── composer.json            # WordPress dependencies
│   ├── smartylaravel/               # Laravel project
│   │   ├── app/                     # Laravel application
│   │   ├── public/                  # Public web directory
│   │   ├── mysql/                   # Database files
│   │   ├── redis/                   # Redis data
│   │   ├── elasticsearch/           # Search index data
│   │   └── composer.json            # Laravel dependencies
│   └── smartynext/                    # Next.js project (symlink)
│       ├── src/                     # Application source
│       ├── prisma/                  # Prisma schema & migrations
│       ├── pgdata/                  # PostgreSQL data
│       └── package.json             # Node.js dependencies
└── README.md                        # This documentation
```

## 🎯 Project Detection

The setup script automatically detects your project type:

### WordPress Detection

- Looks for `wp-config.php` or `wp/wp-config.php`
- Uses `docker-compose.wordpress.yml`
- Mounts `../www/{project}/wp:/var/www/html`

### Laravel Detection

- Looks for `artisan` file and `composer.json`
- Uses `docker-compose.laravel.yml`
- Mounts `../www/{project}:/var/www/html`

### Next.js Detection

- Looks for `next.config.ts`, `next.config.js`, or `next.config.mjs`
- Uses `docker-compose.nextjs.yml`
- Mounts `../www/{project}:/var/www/html`
- Uses PostgreSQL 16 instead of MariaDB
- Runs `npm install`, `prisma generate`, and `npm run dev` on startup

## 🐳 Available Services

| Service | WordPress URL | Laravel URL | Next.js URL | Description |
|---------|---------------|-------------|-------------|-------------|
| Your Site | `https://smartyapp.test` | `https://smartylaravel.test` | `https://smartynext.test` | Your application |
| phpMyAdmin | `https://phpmyadmin.test` | `https://phpmyadmin.test` | N/A | Database management (full-featured) |
| Adminer | `https://adminer.test` | `https://adminer.test` | `https://adminer.test` | Database management (lightweight) |
| Mailpit | `https://mailpit.test` | `https://mailpit.test` | `https://mailpit.test` | Email testing and debugging |
| Kibana | `https://kibana-smartyapp.test` | `https://kibana-smartylaravel.test` | N/A | Elasticsearch visualization |
| Elasticsearch | `http://localhost:9201` | `http://localhost:9200` | N/A | Search and analytics API |
| Traefik Dashboard | `http://localhost:8080` | `http://localhost:8080` | `http://localhost:8080` | Proxy management |

## 🔧 Setup Script Usage

### Basic Usage

```bash
# From wp-local/docker/ directory
./setup.sh <project-name>
```

### What the Script Does

1. **Project Detection**: Automatically detects WordPress, Laravel, or Next.js
2. **Environment Setup**: Copies and configures appropriate `.env` file
3. **Variable Substitution**: Updates project-specific variables
4. **Container Management**: Stops existing containers and starts new ones
5. **Dependency Installation**: Installs Composer dependencies (Laravel) or npm packages (Next.js)
6. **Framework Setup**: Runs key generation and migrations (Laravel), or Prisma migrations and seeders (Next.js)

### Script Output

```bash
# From wp-local/docker/ directory
./setup.sh smartylaravel
ℹ️  Setting up Docker environment for project: smartylaravel
✅ Detected Laravel project
✅ Using Laravel environment configuration
✅ Environment configured for smartylaravel (laravel)
🚀 Project started successfully!
ℹ️  Project URL: http://smartylaravel.test
ℹ️  phpMyAdmin: http://phpmyadmin.test
ℹ️  Installing Laravel dependencies...
```

## 🔄 Manual Docker Commands

### DIP vs Traditional Commands

**With DIP (from project directory):**

```bash
cd www/your-project
dip up              # Start services
dip down            # Stop services
dip logs            # View logs
dip restart         # Restart services
```

**Traditional Docker Compose (from docker directory):**

```bash
cd wp-local/docker
docker-compose -f docker-compose.wordpress.yml up -d
docker-compose -f docker-compose.wordpress.yml down
docker-compose -f docker-compose.wordpress.yml logs -f
docker-compose -f docker-compose.wordpress.yml restart
```

### Clearing All Containers (Important!)

Before switching between WordPress and Laravel, always clear all containers to avoid conflicts:

```bash
# From any directory
# Stop all running containers
docker stop $(docker ps -q)

# Remove all containers
docker rm $(docker ps -a -q)

# Remove all networks (optional)
docker network prune -f

# Remove all volumes (optional - this will delete databases!)
docker volume prune -f

# Complete cleanup (removes images, containers, networks, volumes)
docker system prune -a -f --volumes
```

### WordPress Projects

```bash
# From wp-local/docker/ directory
# Start WordPress environment
docker-compose -f docker-compose.wordpress.yml up -d

# Stop WordPress environment
docker-compose -f docker-compose.wordpress.yml down

# Stop WordPress with volume removal
docker-compose -f docker-compose.wordpress.yml down -v

# Rebuild WordPress containers
docker-compose -f docker-compose.wordpress.yml up --build -d

# View WordPress logs
docker-compose -f docker-compose.wordpress.yml logs -f
```

### Laravel Projects

```bash
# From wp-local/docker/ directory
# Start Laravel environment
docker-compose -f docker-compose.laravel.yml up -d

# Stop Laravel environment
docker-compose -f docker-compose.laravel.yml down

# Stop Laravel with volume removal
docker-compose -f docker-compose.laravel.yml down -v

# Rebuild Laravel containers
docker-compose -f docker-compose.laravel.yml up --build -d

# View Laravel logs
docker-compose -f docker-compose.laravel.yml logs -f
```

### Next.js Projects

```bash
# From wp-local/docker/ directory
# Start Next.js environment
docker-compose -f docker-compose.nextjs.yml up -d

# Stop Next.js environment
docker-compose -f docker-compose.nextjs.yml down

# Stop Next.js with volume removal
docker-compose -f docker-compose.nextjs.yml down -v

# View Next.js logs
docker-compose -f docker-compose.nextjs.yml logs -f
```

### Switching Between Projects

When switching between WordPress, Laravel, and Next.js:

```bash
# Method 1: Stop specific project first
# From wp-local/docker/ directory
docker-compose -f docker-compose.wordpress.yml down
docker-compose -f docker-compose.laravel.yml up -d

# Method 2: Use the setup script (recommended)
# From wp-local/docker/ directory
./setup.sh smartylaravel  # Automatically stops WordPress and starts Laravel

# Method 3: Complete cleanup (if having issues)
# From any directory
docker stop $(docker ps -q)
docker rm $(docker ps -a -q)
# From wp-local/docker/ directory
./setup.sh smartylaravel
```

### Laravel-Specific Commands

**With DIP (from project directory):**

```bash
cd www/smartylaravel
dip shell           # Access Laravel container
dip artisan migrate # Run migrations
dip tinker          # Open Tinker
dip composer install # Install dependencies
dip npm install     # Install frontend dependencies
dip test            # Run tests
dip queue           # Start queue worker
```

**Traditional Docker Commands:**

```bash
# From any directory
# Access Laravel container
docker exec -it laravel_smartylaravel bash

# Run Laravel commands
docker exec -it laravel_smartylaravel php artisan migrate
docker exec -it laravel_smartylaravel php artisan tinker
docker exec -it laravel_smartylaravel composer install
```

### Next.js-Specific Commands

**With DIP (from project directory):**

```bash
cd www/smartynext
dip shell           # Access app container shell
dip npm run build   # Production build
dip prisma          # Run Prisma CLI
dip migrate         # Run Prisma migrations
dip seed            # Run admin seeder
dip lint            # Run ESLint
dip db              # Access PostgreSQL CLI
```

**Traditional Docker Commands:**

```bash
# From any directory
# Access Next.js container
docker exec -it app_smartynext sh

# Run Next.js commands
docker exec -it app_smartynext npx prisma migrate dev --config prisma.config.ts
docker exec -it app_smartynext npm run build
docker exec -it app_smartynext npx tsx scripts/seeders/seed-admin.ts

# Access PostgreSQL
docker exec -it db_smartynext psql -U smartynext -d smartynext
```

### WordPress-Specific Commands

**With DIP (from project directory):**

```bash
cd www/smartyapp
dip shell               # Access PHP container
dip wp user list        # List WordPress users
dip wp plugin list      # List plugins
dip wp core update      # Update WordPress core
dip composer install    # Install dependencies
dip db                  # Access database CLI
```

**Traditional Docker Commands:**

```bash
# From any directory
# Access WordPress container
docker exec -it php_smartyapp bash

# Run WP-CLI commands
docker exec -it php_smartyapp wp --allow-root user list
docker exec -it php_smartyapp wp --allow-root plugin list
```

## 🔧 Environment Customization

### Creating Custom Environment Files

You can create project-specific environment files:

```bash
# From wp-local/docker/ directory
# Copy template
cp .env.laravel .env.myproject

# Edit variables
nano .env.myproject

# Use custom environment
cp .env.myproject .env
docker-compose -f docker-compose.laravel.yml up -d
```

### Adding New Variables

Add variables to your environment template:

```bash
# From wp-local/docker/ directory
# Edit .env.laravel file
nano .env.laravel

# Add these variables:
APP_DEBUG=true
APP_ENV=local
MAIL_DRIVER=smtp
```

## 🛠️ Container Architecture

### WordPress Container (docker-php)

- **Base**: `php:8.4-apache`
- **Services**: Apache, PHP, WP-CLI
- **Volumes**: WordPress files, database, uploads, elasticsearch data
- **Networking**: Traefik routing

### Laravel Container (docker-laravel)

- **Base**: `php:8.4-fpm`
- **Services**: Nginx, PHP-FPM, Supervisor
- **Volumes**: Laravel application, database, storage, elasticsearch data
- **Networking**: Traefik routing, Redis connection

### Next.js Container (node)

- **Base**: `node:22-alpine`
- **Services**: Next.js dev server (port 3000)
- **Database**: PostgreSQL 16 Alpine
- **Volumes**: Application files, node_modules (named volume), PostgreSQL data
- **Networking**: Traefik routing with HTTPS

### Shared Services

- **MariaDB 11.6**: Database server (WordPress/Laravel)
- **Redis 7.4**: Caching and sessions (Laravel)
- **Traefik v3.5**: Reverse proxy and SSL termination (latest stable)
- **phpMyAdmin latest**: Full-featured database management interface
- **Adminer latest**: Lightweight database administration tool
- **Mailpit latest**: Modern email testing and debugging
- **Elasticsearch 7.17.25**: Search and analytics engine with security enabled
- **Kibana 7.17.25**: Data visualization and monitoring with authentication

## 🔍 Troubleshooting

### Common Issues

1. **Containers from previous project still running:**

   ```bash
   # From any directory
   # Check what containers are running
   docker ps
   
   # Stop all containers
   docker stop $(docker ps -q)
   
   # Remove all containers
   docker rm $(docker ps -a -q)
   
   # From wp-local/docker/ directory
   # Then start your new project
   ./setup.sh project-name
   ```

2. **Port conflicts:**

   ```bash
   # From any directory
   # Check what's using port 80
   sudo lsof -i :80
   
   # Stop conflicting services
   sudo service apache2 stop
   sudo service nginx stop
   ```

3. **Permission issues:**

   ```bash
   # From wp-local/ directory
   # Fix file permissions
   sudo chown -R $USER:$USER www/
   
   # From any directory
   # Laravel storage permissions
   docker exec -it laravel_{project-name} chmod -R 755 storage/
   ```

4. **Database connection errors:**

   ```bash
   # From wp-local/docker/ directory
   # Reset environment
   docker-compose down -v
   ./setup.sh project-name
   ```

5. **Container build failures:**

   ```bash
   # From any directory
   # Clean Docker cache
   docker system prune -a
   
   # From wp-local/docker/ directory
   # Rebuild without cache
   docker-compose up --build --no-cache
   ```

6. **WordPress containers still active when trying to start Laravel:**

   ```bash
   # From wp-local/docker/ directory
   # Quick fix
   docker-compose -f docker-compose.wordpress.yml down
   docker-compose -f docker-compose.laravel.yml up -d
   
   # Or use setup script (recommended)
   ./setup.sh smartylaravel
   ```

7. **Database user doesn't exist error (Laravel):**

   ```bash
   # From any directory
   # If you get "Access denied for user 'projectname'" error
   docker exec db_{project-name} mysql -u root -proot -e "CREATE USER 'projectname'@'%' IDENTIFIED BY 'projectname';"
   docker exec db_{project-name} mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS projectname;"
   docker exec db_{project-name} mysql -u root -proot -e "GRANT ALL PRIVILEGES ON projectname.* TO 'projectname'@'%';"
   docker exec db_{project-name} mysql -u root -proot -e "FLUSH PRIVILEGES;"
   
   # Then run migrations
   docker exec laravel_{project-name} php artisan migrate --no-interaction
   ```

### Debug Commands

```bash
# From any directory
# Check container status
docker ps

# View container logs
docker logs container_name

# Check environment variables
docker exec -it container_name env

# Test database connection
docker exec -it db_{project-name} mysql -u root -p

# Check file permissions
docker exec -it container_name ls -la /var/www/html
```

## 🔍 Database Administration Tools

### phpMyAdmin vs Adminer

Both tools are available for database management:

**phpMyAdmin** (`http://phpmyadmin.test`):

- Full-featured database administration
- WordPress-friendly interface
- Comprehensive import/export tools
- Plugin ecosystem

**Adminer** (`http://adminer.test`):

- Lightweight and fast
- Clean, modern interface
- Supports multiple database types
- Better performance for large datasets

### Using Adminer

```bash
# Access Adminer at http://adminer.test
# Login credentials:
# Server: db
# Username: root
# Password: root
# Database: [your-project-name]
```

## 🔍 Search & Analytics with Elasticsearch

### Elasticsearch Integration

#### Initial Elasticsearch Setup

```bash
# Check Elasticsearch cluster health (with authentication)
curl -u elastic:changeme http://localhost:9200/_cluster/health?pretty

# Check cluster status (quick view)
curl -u elastic:changeme http://localhost:9200/_cat/health

# View all indices
curl -u elastic:changeme http://localhost:9200/_cat/indices
```

**Security Enabled**: Elasticsearch 7.17.25 with authentication enabled for Fleet and Agent integrations.
**Default Credentials**: Username: `elastic`, Password: `changeme`

#### Laravel

```bash
# Install Laravel Scout for Elasticsearch
docker exec -it laravel_{project-name} composer require laravel/scout
docker exec -it laravel_{project-name} composer require matchish/laravel-scout-elasticsearch

# Configure in your Laravel .env
SCOUT_DRIVER=elasticsearch
ELASTICSEARCH_HOST=elasticsearch:9200
ELASTICSEARCH_USERNAME=elastic
ELASTICSEARCH_PASSWORD=changeme

# Create and sync searchable models
docker exec -it laravel_{project-name} php artisan scout:import "App\Models\Post"
```

#### WordPress

```bash
# Install ElasticPress plugin
docker exec -it php_{project-name} wp --allow-root plugin install elasticpress --activate

# Configure Elasticsearch endpoint in WordPress admin:
# Settings > ElasticPress > Settings
# Host: http://elasticsearch:9200
# Username: elastic
# Password: changeme

# Index content via WP-CLI
docker exec -it php_{project-name} wp --allow-root elasticpress index --setup
```

### Kibana Dashboards

Access Kibana at `http://kibana-{project-name}.test` to:

- Monitor search performance
- Create data visualizations
- Analyze user search patterns
- Track application metrics

#### Kibana Setup & Access

```bash
# Access Kibana with authentication
# URL: http://kibana-{project-name}.test
# Username: elastic
# Password: changeme

# View Kibana logs for debugging
docker logs kibana_{project-name}

# Check Elasticsearch connection from Kibana container
docker exec -it kibana_{project-name} curl -u elastic:changeme http://elasticsearch:9200/_cluster/health
```

#### Security Features Enabled

- **Authentication Required**: Login with username `elastic` and password `changeme`
- **Fleet Management**: Now available for Elastic Agent integrations
- **API Keys**: Enabled for agent authentication (`xpack.security.authc.api_key.enabled=true`)
- **Full Security**: All Elasticsearch security features are active

### Elasticsearch Management

```bash
# Check Elasticsearch status
curl http://localhost:9200/_cluster/health

# View all indices
curl http://localhost:9200/_cat/indices

# Search data directly
curl -X GET "localhost:9200/your_index/_search?pretty"
```

## 📊 Performance Optimization

### Laravel Performance

```bash
# From any directory
# Optimize Laravel
docker exec -it laravel_{project-name} php artisan optimize
docker exec -it laravel_{project-name} php artisan config:cache
docker exec -it laravel_{project-name} php artisan route:cache
docker exec -it laravel_{project-name} php artisan view:cache
```

### WordPress Performance

```bash
# From any directory
# Enable object caching
docker exec -it php_{project-name} wp --allow-root plugin install redis-cache --activate

# Install Elasticsearch plugin for enhanced search
docker exec -it php_{project-name} wp --allow-root plugin install elasticpress --activate

# Optimize database
docker exec -it php_{project-name} wp --allow-root db optimize
```

## 📧 Email Testing with Mailpit

### Using Mailpit

Mailpit replaces MailHog and provides modern email testing:

**Access**: `http://mailpit.test`

**Features**:

- Modern web interface
- Real-time email capture
- HTML email rendering
- Attachment handling
- Email search and filtering

**Laravel Configuration**:

```bash
# Already configured in docker-compose
MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
```

**Next.js Configuration**:

```bash
# Already configured in docker-compose
SMTP_HOST=mailpit
SMTP_PORT=1025
SMTP_SECURE=false
```

**WordPress Configuration**:

- Install SMTP plugin or configure in wp-config.php
- SMTP Server: mailpit
- Port: 1025
- No authentication required

**Testing Emails**:

```bash
# Laravel - send test email
docker exec -it laravel_{project-name} php artisan tinker
# In tinker: Mail::raw('Test email', function($msg) { $msg->to('test@example.com')->subject('Test'); });

# WordPress - use WP-CLI
docker exec -it php_{project-name} wp --allow-root eval "wp_mail('test@example.com', 'Test Subject', 'Test message');"
```

## 🔐 Security Best Practices

### Production Considerations

- **Environment Files**: Never commit `.env` files to version control
- **Database Credentials**: Use strong passwords in production
- **GitHub Tokens**: Use minimal required permissions
- **Container Security**: Regularly update base images

### Development Security

- **Local Only**: This setup is for local development only
- **Firewall**: Ensure Docker ports aren't exposed externally
- **Backup**: Regularly backup your project files and databases

## 🎯 Advanced Usage

### Multi-Project Setup

**Directory:** `wp-local/docker/`

```bash
# Project 1 (WordPress)
./setup.sh myblog
# Visit: https://myblog.test

# Project 2 (Laravel)
./setup.sh myapi
# Visit: https://myapi.test

# Project 3 (Next.js)
./setup.sh smartynext
# Visit: https://smartynext.test

# Note: Stop one project before starting another to avoid
# container name conflicts (mailpit, traefik, adminer)
```

### Custom Domain Configuration

**Directory:** `any`

Add custom domains to `/etc/hosts`:

```bash
# Edit hosts file
sudo nano /etc/hosts

# Add entries
127.0.0.1 custom-domain.test
127.0.0.1 another-project.test
```

### SSL Configuration

Traefik can be configured for SSL:

```yaml
# In docker-compose files
labels:
  - "traefik.http.routers.project.tls=true"
  - "traefik.http.routers.project.rule=Host(`project.test`)"
```

## 📝 Tips and Best Practices

### Development Workflow

1. **Use the setup script** for consistent environments
2. **Backup databases** before major changes
3. **Use version control** for your application code
4. **Test migrations** before applying to production
5. **Monitor container logs** for debugging

### Code Organization

```bash
# WordPress
www/project/wp/                    # WordPress core (don't edit)
www/project/wp/wp-content/themes/  # Custom themes
www/project/wp/wp-content/plugins/ # Custom plugins

# Laravel
www/project/app/                   # Application logic
www/project/resources/             # Views and assets
www/project/database/migrations/   # Database migrations
```

## 🔄 Updates and Maintenance

### Updating WordPress

```bash
# From any directory
# Update WordPress core
docker exec -it php_{project-name} wp --allow-root core update

# Update plugins
docker exec -it php_{project-name} wp --allow-root plugin update --all

# Update themes
docker exec -it php_{project-name} wp --allow-root theme update --all
```

### Updating Laravel

```bash
# From any directory
# Update dependencies
docker exec -it laravel_{project-name} composer update

# Run migrations
docker exec -it laravel_{project-name} php artisan migrate

# Clear caches
docker exec -it laravel_{project-name} php artisan cache:clear
```

### Updating Docker Images

```bash
# From wp-local/docker/ directory
# Pull latest images
docker-compose pull

# Rebuild containers
docker-compose up --build -d
```

---

## 📋 Versioning & Releases

This project follows [Semantic Versioning](https://semver.org/) and uses automated releases via [semantic-release](https://github.com/semantic-release/semantic-release).

### Version Format

- **Major** (X.0.0): Breaking changes
- **Minor** (0.X.0): New features, backwards compatible
- **Patch** (0.0.X): Bug fixes, backwards compatible

### Automated Releases

Releases are automatically created when changes are pushed to the `main` branch. The version number is determined by analyzing commit messages following the [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Commit Message Format

```bash
# Features (minor version bump)
feat(docker): add Redis service for caching

# Bug fixes (patch version bump)
fix: resolve MySQL connection timeout

# Breaking changes (major version bump)
feat(docker)!: upgrade to PHP 8.4
```

For more details, see [CONTRIBUTING.md](CONTRIBUTING.md).

---

## 🤝 Contributing

We welcome contributions! Please follow our commit message conventions to ensure proper versioning:

1. Use conventional commits format: `type(scope): description`
2. Run `npm run commit` for an interactive commit experience
3. Create feature branches and submit pull requests
4. Automated tests and releases run on merge to main

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## 📖 DIP Quick Reference

### Common Commands (All Projects)

| Command | Description |
|---------|-------------|
| `dip ls` | List all available commands |
| `dip up` | Start all services |
| `dip down` | Stop all services |
| `dip restart` | Restart all services |
| `dip logs` | View service logs |
| `dip clean` | Stop and remove volumes |

### WordPress Commands

| Command | Description |
|---------|-------------|
| `dip wp <command>` | Run WP-CLI commands |
| `dip shell` | Access PHP container shell |
| `dip db` | Access database CLI |
| `dip composer <command>` | Run Composer commands |
| `dip status` | Check WordPress installation status |

**Examples:**

```bash
dip wp plugin list
dip wp user create john john@example.com --role=editor
dip wp db export backup.sql
```

### Laravel Commands

| Command | Description |
|---------|-------------|
| `dip artisan <command>` | Run Artisan commands |
| `dip shell` | Access Laravel container shell |
| `dip composer <command>` | Run Composer commands |
| `dip npm <command>` | Run NPM commands |
| `dip test` | Run Pest tests |
| `dip migrate` | Run database migrations |
| `dip queue` | Start queue worker |
| `dip tinker` | Open Laravel Tinker |
| `dip db` | Access database CLI |
| `dip redis` | Access Redis CLI |

**Examples:**

```bash
dip artisan make:model Post
dip composer require laravel/sanctum
dip npm run dev
dip test --filter UserTest
```

### Next.js Commands

| Command | Description |
|---------|-------------|
| `dip shell` | Access app container shell |
| `dip npm <command>` | Run NPM commands |
| `dip npx <command>` | Run npx commands |
| `dip prisma <command>` | Run Prisma CLI |
| `dip migrate` | Run Prisma migrations |
| `dip seed` | Run seeders |
| `dip build` | Run production build |
| `dip lint` | Run ESLint |
| `dip db` | Access PostgreSQL CLI |

**Examples:**

```bash
dip prisma studio
dip npm install stripe
dip npx tsx scripts/seeders/seed-articles.ts
dip db
```

---

🚀 **Happy Development!**

*This environment supports WordPress, Laravel, and Next.js development with automatic project detection, intelligent environment configuration, and streamlined workflows for modern web development.*
