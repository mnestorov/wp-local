#!/usr/bin/env bash
set -e

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 1  •  Project name
# ──────────────────────────────────────────────────────────────────────────────
mkdir -p www
read -rp "Enter project name (APP_ID): " APP_ID
[ -z "$APP_ID" ] && { echo "❌  Project name cannot be empty."; exit 1; }

PROJECT_DOMAIN="${APP_ID}.test"
PROJECT_DIR="www/${APP_ID}"

# Generate simple credentials on-the-fly (not stored anywhere)
DB_NAME=$(echo ${APP_ID} | cut -c1-2)_${APP_ID}
DB_USER=${APP_ID}_user
DB_PASSWORD=${APP_ID}_pass

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 2  •  .env
# ──────────────────────────────────────────────────────────────────────────────
# Create .env file only if it doesn't exist (to avoid overwriting existing projects)
if [ ! -f ../docker/.env ]; then
    echo "🧪  Creating .env file for shared settings"
    mkdir -p ../docker
    cat > ../docker/.env <<ENV
PHP_VERSION=8.3-fpm
MARIADB_VERSION=10.11
PHPMYADMIN_VERSION=5.2

APP_ID=${APP_ID}
PROJECT_DOMAIN=${PROJECT_DOMAIN}
ENV
else
    echo "✅  .env file already exists (shared across projects)"
fi

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 3  •  Laravel Installation
# ──────────────────────────────────────────────────────────────────────────────
echo "📦  Installing Laravel..."
echo "   This will create a fresh Laravel installation in $PROJECT_DIR"

# Create project directory
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Install Laravel using Composer
echo "🚀  Running composer create-project laravel/laravel ."
composer create-project laravel/laravel . --prefer-dist --no-interaction

# Create additional directories
mkdir -p mysql redis

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 4  •  Laravel Configuration
# ──────────────────────────────────────────────────────────────────────────────
echo "⚙️  Configuring Laravel environment..."

# Create Laravel .env file
cat > .env <<LARAVEL_ENV
APP_NAME="${APP_ID}"
APP_ENV=local
APP_KEY=base64:$(openssl rand -base64 32)
APP_DEBUG=true
APP_URL=http://${PROJECT_DOMAIN}

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=${DB_NAME}
DB_USERNAME=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}

BROADCAST_DRIVER=log
CACHE_DRIVER=redis
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=redis
SESSION_LIFETIME=120

REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS=noreply@${PROJECT_DOMAIN}
MAIL_FROM_NAME="\${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=mt1

VITE_PUSHER_APP_KEY="\${PUSHER_APP_KEY}"
VITE_PUSHER_HOST="\${PUSHER_HOST}"
VITE_PUSHER_PORT="\${PUSHER_PORT}"
VITE_PUSHER_SCHEME="\${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="\${PUSHER_APP_CLUSTER}"
LARAVEL_ENV

# Go back to main directory
cd ..

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 5  •  /etc/hosts
# ──────────────────────────────────────────────────────────────────────────────
echo "📌  Updating /etc/hosts"
for d in "$PROJECT_DOMAIN" phpmyadmin.test adminer.test mailpit.test "kibana-$APP_ID.test"; do
  sudo grep -q "$d" /etc/hosts || echo "127.0.0.1 $d" | sudo tee -a /etc/hosts
done

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 6  •  Docker up
# ──────────────────────────────────────────────────────────────────────────────
echo "🧹  Cleaning up any existing containers/volumes for this project"
(cd ../docker && docker compose -f docker-compose.laravel.yml --env-file .env down -v 2>/dev/null || true)

echo "🚀  docker compose up …"

# Export environment variables for docker compose (not stored in any file)
export DB_NAME="$DB_NAME"
export DB_USER="$DB_USER"
export DB_PASSWORD="$DB_PASSWORD"
export APP_ID="$APP_ID"
export PROJECT_DOMAIN="$PROJECT_DOMAIN"

# Run docker compose with exported environment variables
(cd ../docker && docker compose -f docker-compose.laravel.yml up -d)

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 7  •  Laravel Setup
# ──────────────────────────────────────────────────────────────────────────────
echo "🔧  Setting up Laravel..."

# Wait for containers to be ready
sleep 10

# Install dependencies and setup Laravel
echo "📦  Installing Laravel dependencies..."
docker exec laravel_${APP_ID} composer install --no-interaction --optimize-autoloader

echo "🔐  Generating application key..."
docker exec laravel_${APP_ID} php artisan key:generate --no-interaction

echo "🗄️  Running database migrations..."
docker exec laravel_${APP_ID} php artisan migrate --no-interaction

echo "🔗  Creating storage link..."
docker exec laravel_${APP_ID} php artisan storage:link

echo "🧹  Optimizing Laravel..."
docker exec laravel_${APP_ID} php artisan config:cache
docker exec laravel_${APP_ID} php artisan route:cache
docker exec laravel_${APP_ID} php artisan view:cache

echo "✅  Done.  Visit → http://${PROJECT_DOMAIN}"

echo ""
echo "🐳  Docker Management Commands:"
echo "   • Start containers:   cd docker && docker compose -f docker-compose.laravel.yml --env-file .env up -d"
echo "   • Stop containers:    cd docker && docker compose -f docker-compose.laravel.yml --env-file .env down"
echo "   • View logs:          cd docker && docker compose -f docker-compose.laravel.yml --env-file .env logs -f"
echo "   • Restart containers: cd docker && docker compose -f docker-compose.laravel.yml --env-file .env restart"
echo "   • Remove everything:  cd docker && docker compose -f docker-compose.laravel.yml --env-file .env down -v"

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 8  •  Setup Shell Aliases
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "⚡  Setting up shell aliases..."

# Detect shell config file
SHELL_CONFIG=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_CONFIG="$HOME/.bash_profile"
else
    # Create shell config file based on current shell
    if [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_CONFIG="$HOME/.zshrc"
        touch "$SHELL_CONFIG"
        echo "✅  Created $SHELL_CONFIG"
    elif [[ "$SHELL" == *"bash"* ]]; then
        SHELL_CONFIG="$HOME/.bashrc"
        touch "$SHELL_CONFIG"
        echo "✅  Created $SHELL_CONFIG"
    else
        echo "⚠️  Unsupported shell: $SHELL"
        echo "   Please manually create .zshrc or .bashrc and add the aliases"
    fi
fi

if [ -n "$SHELL_CONFIG" ]; then
    # Check if aliases already exist
    if ! grep -q "alias laravelup.*${APP_ID}" "$SHELL_CONFIG"; then
        # Add aliases with project-specific comments
        cat >> "$SHELL_CONFIG" <<ALIASES

# Laravel Docker aliases for ${APP_ID} project
alias laravelup-${APP_ID}='cd ${PWD}/docker && export DB_NAME="$(echo ${APP_ID} | cut -c1-2)_${APP_ID}" && export DB_USER="${APP_ID}_user" && export DB_PASSWORD="${APP_ID}_pass" && export APP_ID="${APP_ID}" && export PROJECT_DOMAIN="${APP_ID}.test" && docker compose -f docker-compose.laravel.yml up -d'
alias laraveldown-${APP_ID}='cd ${PWD}/docker && export DB_NAME="$(echo ${APP_ID} | cut -c1-2)_${APP_ID}" && export DB_USER="${APP_ID}_user" && export DB_PASSWORD="${APP_ID}_pass" && export APP_ID="${APP_ID}" && export PROJECT_DOMAIN="${APP_ID}.test" && docker compose -f docker-compose.laravel.yml down'
alias laravellogs-${APP_ID}='cd ${PWD}/docker && export DB_NAME="$(echo ${APP_ID} | cut -c1-2)_${APP_ID}" && export DB_USER="${APP_ID}_user" && export DB_PASSWORD="${APP_ID}_pass" && export APP_ID="${APP_ID}" && export PROJECT_DOMAIN="${APP_ID}.test" && docker compose -f docker-compose.laravel.yml logs -f'
alias laravelrestart-${APP_ID}='cd ${PWD}/docker && export DB_NAME="$(echo ${APP_ID} | cut -c1-2)_${APP_ID}" && export DB_USER="${APP_ID}_user" && export DB_PASSWORD="${APP_ID}_pass" && export APP_ID="${APP_ID}" && export PROJECT_DOMAIN="${APP_ID}.test" && docker compose -f docker-compose.laravel.yml restart'
alias laravelclean-${APP_ID}='cd ${PWD}/docker && export DB_NAME="$(echo ${APP_ID} | cut -c1-2)_${APP_ID}" && export DB_USER="${APP_ID}_user" && export DB_PASSWORD="${APP_ID}_pass" && export APP_ID="${APP_ID}" && export PROJECT_DOMAIN="${APP_ID}.test" && docker compose -f docker-compose.laravel.yml down -v'

# Laravel Artisan aliases for ${APP_ID} project
alias artisan-${APP_ID}='docker exec -it laravel_${APP_ID} php artisan'
alias laravelshell-${APP_ID}='docker exec -it laravel_${APP_ID} bash'
alias laravelcomposer-${APP_ID}='docker exec -it laravel_${APP_ID} composer'
alias laravelnpm-${APP_ID}='docker exec -it laravel_${APP_ID} npm'
alias laraveltest-${APP_ID}='docker exec -it laravel_${APP_ID} php artisan test'
alias laravelmigrate-${APP_ID}='docker exec -it laravel_${APP_ID} php artisan migrate'
alias laravelqueue-${APP_ID}='docker exec -it laravel_${APP_ID} php artisan queue:work'

ALIASES
        echo "✅  Aliases added to $SHELL_CONFIG"
        echo "   • Use: laravelup-${APP_ID}, laraveldown-${APP_ID}, artisan-${APP_ID}, etc."
        echo "   • Reload shell: source $SHELL_CONFIG"
    else
        echo "✅  Aliases already exist in $SHELL_CONFIG"
    fi
fi

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 9  •  System Links
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "🌐  Available Systems:"
echo "   • Laravel Application: http://${PROJECT_DOMAIN}"
echo "   • Traefik Dashboard:   http://localhost:8080"
echo "   • phpMyAdmin:          http://phpmyadmin.test"
echo "   • Mailpit:             http://mailpit.test"
echo "   • Adminer:             http://adminer.test"
echo "   • Elasticsearch:       http://localhost:9200"
echo "   • Kibana:              http://kibana-$APP_ID.test"
echo ""
echo "📝  Notes:"
echo "   • Database name:       ${DB_NAME}"
echo "   • Laravel logs:        ${PROJECT_DIR}/storage/logs/laravel.log"
echo "   • Environment file:    ${PROJECT_DIR}/.env"
echo ""
echo "📚  Laravel Commands:"
echo "   • Run artisan:         artisan-${APP_ID} <command>"
echo "   • Access shell:        laravelshell-${APP_ID}"
echo "   • Run migrations:      laravelmigrate-${APP_ID}"
echo "   • Run tests:           laraveltest-${APP_ID}"
echo "   • Run queue worker:    laravelqueue-${APP_ID}"
echo ""