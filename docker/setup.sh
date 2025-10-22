#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if project name is provided
if [ -z "$1" ]; then
    print_error "Usage: $0 <project-name>"
    print_info "Example: $0 smartylaravel"
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_PATH="../www/$PROJECT_NAME"

# Check if project exists
if [ ! -d "$PROJECT_PATH" ]; then
    print_error "Project directory $PROJECT_PATH does not exist!"
    exit 1
fi

print_info "Setting up Docker environment for project: $PROJECT_NAME"

# Detect project type
if [ -f "$PROJECT_PATH/artisan" ] && [ -f "$PROJECT_PATH/composer.json" ]; then
    PROJECT_TYPE="laravel"
    print_success "Detected Laravel project"
elif [ -f "$PROJECT_PATH/wp-config.php" ] || [ -f "$PROJECT_PATH/wp/wp-config.php" ]; then
    PROJECT_TYPE="wordpress"
    print_success "Detected WordPress project"
else
    print_error "Could not determine project type. Looking for Laravel (artisan) or WordPress (wp-config.php) files."
    exit 1
fi

# Copy appropriate environment file
if [ "$PROJECT_TYPE" == "laravel" ]; then
    if [ -f ".env.laravel" ]; then
        cp ".env.laravel" ".env"
        print_success "Using Laravel environment configuration"
        
        # Update APP_ID and PROJECT_DOMAIN in .env
        sed -i.bak "s/APP_ID=smartylaravel/APP_ID=$PROJECT_NAME/" .env
        sed -i.bak "s/PROJECT_DOMAIN=smartylaravel.test/PROJECT_DOMAIN=$PROJECT_NAME.test/" .env
        sed -i.bak "s/DB_NAME=smartylaravel/DB_NAME=$PROJECT_NAME/" .env
        sed -i.bak "s/DB_USER=smartylaravel/DB_USER=$PROJECT_NAME/" .env
        sed -i.bak "s/DB_PASSWORD=smartylaravel/DB_PASSWORD=$PROJECT_NAME/" .env
        rm .env.bak
        
        COMPOSE_FILE="docker-compose.laravel.yml"
    else
        print_error ".env.laravel file not found!"
        exit 1
    fi
elif [ "$PROJECT_TYPE" == "wordpress" ]; then
    if [ -f ".env.wordpress" ]; then
        cp ".env.wordpress" ".env"
        print_success "Using WordPress environment configuration"
        
        # Update APP_ID and PROJECT_DOMAIN in .env
        sed -i.bak "s/APP_ID=smartyapp/APP_ID=$PROJECT_NAME/" .env
        sed -i.bak "s/PROJECT_DOMAIN=smartyapp.test/PROJECT_DOMAIN=$PROJECT_NAME.test/" .env
        sed -i.bak "s/DB_NAME=smartyapp/DB_NAME=$PROJECT_NAME/" .env
        sed -i.bak "s/DB_USER=smartyapp/DB_USER=$PROJECT_NAME/" .env
        sed -i.bak "s/DB_PASSWORD=smartyapp/DB_PASSWORD=$PROJECT_NAME/" .env
        rm .env.bak
        
        COMPOSE_FILE="docker-compose.wordpress.yml"
    else
        print_error ".env.wordpress file not found!"
        exit 1
    fi
fi

print_success "Environment configured for $PROJECT_NAME ($PROJECT_TYPE)"

# Create dip.yml file from template
print_info "Creating dip.yml configuration..."
if [ "$PROJECT_TYPE" == "laravel" ]; then
    DIP_TEMPLATE="templates/dip.laravel.yml"
    DB_NAME="$PROJECT_NAME"
    DB_USER="$PROJECT_NAME"
    DB_PASSWORD="$PROJECT_NAME"
elif [ "$PROJECT_TYPE" == "wordpress" ]; then
    DIP_TEMPLATE="templates/dip.wordpress.yml"
    # WordPress database naming convention from existing projects
    DB_NAME="$(echo "$PROJECT_NAME" | cut -c1-2)_$PROJECT_NAME"
    DB_USER="${PROJECT_NAME}_user"
    DB_PASSWORD="${PROJECT_NAME}_pass"
fi

if [ -f "$DIP_TEMPLATE" ]; then
    # Copy template and replace placeholders
    sed -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
        -e "s/{{PROJECT_DOMAIN}}/$PROJECT_NAME.test/g" \
        -e "s/{{DB_NAME}}/$DB_NAME/g" \
        -e "s/{{DB_USER}}/$DB_USER/g" \
        -e "s/{{DB_PASSWORD}}/$DB_PASSWORD/g" \
        "$DIP_TEMPLATE" > "$PROJECT_PATH/dip.yml"

    print_success "Created dip.yml in project directory"
    print_info "You can now use DIP commands from $PROJECT_PATH/"
    print_info "Example: cd $PROJECT_PATH && dip up"
else
    print_warning "DIP template not found at $DIP_TEMPLATE"
fi

# Stop any running containers
print_info "Stopping existing containers..."
docker-compose -f "$COMPOSE_FILE" down --remove-orphans 2>/dev/null || true

# Start the project
print_info "Starting $PROJECT_TYPE project..."
docker-compose -f "$COMPOSE_FILE" up --build -d

if [ $? -eq 0 ]; then
    print_success "🚀 Project started successfully!"
    print_info "Project URL: http://$PROJECT_NAME.test"
    print_info "phpMyAdmin: http://phpmyadmin.test"
    print_info "Mailhog: http://mailhog.test"
    print_info "Traefik Dashboard: http://localhost:8080"
    
    if [ "$PROJECT_TYPE" == "laravel" ]; then
        print_info "Installing Laravel dependencies..."
        docker exec "laravel_$PROJECT_NAME" composer install --no-interaction
        docker exec "laravel_$PROJECT_NAME" php artisan key:generate --no-interaction
        
        print_info "Setting up database..."
        # Wait for database to be ready
        sleep 5
        
        # Create database user and database
        docker exec "db_$PROJECT_NAME" mysql -u root -proot -e "CREATE USER '$PROJECT_NAME'@'%' IDENTIFIED BY '$PROJECT_NAME';" 2>/dev/null || true
        docker exec "db_$PROJECT_NAME" mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS $PROJECT_NAME;" 2>/dev/null || true
        docker exec "db_$PROJECT_NAME" mysql -u root -proot -e "GRANT ALL PRIVILEGES ON $PROJECT_NAME.* TO '$PROJECT_NAME'@'%';" 2>/dev/null || true
        docker exec "db_$PROJECT_NAME" mysql -u root -proot -e "FLUSH PRIVILEGES;" 2>/dev/null || true
        
        print_info "Running migrations..."
        docker exec "laravel_$PROJECT_NAME" php artisan migrate --no-interaction
    fi
else
    print_error "Failed to start project!"
    exit 1
fi