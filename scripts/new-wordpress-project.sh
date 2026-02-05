#!/usr/bin/env bash
set -e

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 1  •  Project name
# ──────────────────────────────────────────────────────────────────────────────
# Determine the base directory (parent of scripts if we're in scripts)
if [[ "$(basename "$(pwd)")" == "scripts" ]]; then
    BASE_DIR=".."
    cd "$BASE_DIR"
else
    BASE_DIR="."
fi

mkdir -p www
read -rp "Enter project name (APP_ID): " APP_ID
[ -z "$APP_ID" ] && { echo "❌  Project name cannot be empty."; exit 1; }

PROJECT_DOMAIN="${APP_ID}.test"
PROJECT_DIR="www/${APP_ID}"
WP_DIR="${PROJECT_DIR}/wp"

# Generate simple credentials on-the-fly (not stored anywhere)
DB_NAME=$(echo ${APP_ID} | cut -c1-2)_${APP_ID}
DB_USER=${APP_ID}_user
DB_PASSWORD=${APP_ID}_pass

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 2  •  .env
# ──────────────────────────────────────────────────────────────────────────────
# Create .env file only if it doesn't exist (to avoid overwriting existing projects)
if [ ! -f "$BASE_DIR/docker/.env" ]; then
    echo "🧪  Creating .env file for shared settings"
    cat > "$BASE_DIR/docker/.env" <<ENV
PHP_VERSION=8.3-apache
MARIADB_VERSION=10.11
PHPMYADMIN_VERSION=5.2

APP_ID=${APP_ID}
PROJECT_DOMAIN=${PROJECT_DOMAIN}

# GitHub Authentication (for private repositories)
# Get your token from: https://github.com/settings/tokens
GITHUB_AUTH_TOKEN=your_github_token_here
ENV
else
    echo "✅  .env file already exists (shared across projects)"
fi

# Prompt for GitHub token if needed
echo "🔑  GitHub Authentication Setup"
echo "   If you have a private GitHub repository, you'll need a GitHub token."
echo "   Get one from: https://github.com/settings/tokens"
echo "   Note: Your repository should have a composer.json file for proper installation."

# Check if GitHub token is already configured (supports ghp_ and github_pat_ prefixes)
if grep -qE "GITHUB_AUTH_TOKEN=(ghp_|github_pat_)" "$BASE_DIR/docker/.env"; then
    # Extract the existing token from .env file
    GITHUB_TOKEN=$(grep "GITHUB_AUTH_TOKEN=" "$BASE_DIR/docker/.env" | cut -d'=' -f2)
    echo "✅  Using existing GitHub token from .env file"
else
    read -rp "Enter your GitHub token (or press Enter to skip): " GITHUB_TOKEN

    if [ -n "$GITHUB_TOKEN" ]; then
        # Update .env file with the actual token
        sed -i.bak "s/GITHUB_AUTH_TOKEN=your_github_token_here/GITHUB_AUTH_TOKEN=$GITHUB_TOKEN/" "$BASE_DIR/docker/.env"
        # Clean up the backup file
        rm -f "$BASE_DIR/docker/.env.bak"
        echo "✅  GitHub token added to .env file"
    else
        echo "⚠️  No GitHub token provided. Private repositories may not work."
    fi
fi

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 3  •  Folders
# ──────────────────────────────────────────────────────────────────────────────
echo "📁  Creating folders"
mkdir -p "$WP_DIR" \
         "$WP_DIR/wp-content/plugins" \
         "$WP_DIR/wp-content/themes/theme-basic" \
         "$PROJECT_DIR/mysql"

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 4  •  composer.json (with installer-paths)
# ──────────────────────────────────────────────────────────────────────────────
echo "🖍️  Generating composer.json"
cat > "$PROJECT_DIR/composer.json" <<JSON
{
  "name": "$APP_ID/wp-site",
  "require": {
    "johnpbloch/wordpress": "^6.5",
    "composer/installers": "^2.2",
    "johnbillion/query-monitor": "^3.15",
    "johnbillion/wp-crontrol": "^1.16",
    "mnestorov/smarty-change-admin-colors": "1.0.0"
  },
  "repositories": [
    {
      "type": "vcs",
      "url": "https://github.com/mnestorov/smarty-change-admin-colors"
    }
  ],
  "extra": {
    "wordpress-install-dir": "wp",
    "installer-paths": {
      "wp/wp-content/plugins/query-monitor/": ["johnbillion/query-monitor"],
      "wp/wp-content/plugins/wp-crontrol/": ["johnbillion/wp-crontrol"],
      "wp/wp-content/plugins/smarty-change-admin-colors/": ["mnestorov/smarty-change-admin-colors"],
      "wp/wp-content/plugins/{$name}/": ["type:wordpress-plugin"],
      "wp/wp-content/themes/{$name}/":  ["type:wordpress-theme"]
    }
  },
  "config": {
    "allow-plugins": {
      "johnpbloch/wordpress-core-installer": true,
      "composer/installers": true
    }
  }
}
JSON

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 5  •  Install WordPress
# ──────────────────────────────────────────────────────────────────────────────
echo "📦  Running composer install"

# Configure GitHub authentication for composer
if [ -n "$GITHUB_TOKEN" ]; then
    export GITHUB_AUTH_TOKEN="$GITHUB_TOKEN"
    # Use COMPOSER_AUTH for more reliable token handling
    export COMPOSER_AUTH="{\"github-oauth\": {\"github.com\": \"$GITHUB_TOKEN\"}}"
    echo "🔑  GitHub token configured for Composer"
else
    echo "⚠️  No GitHub token available - private repositories may fail"
fi

(
  cd "$PROJECT_DIR"
  echo "📋  Installing packages from composer.json..."
  
  # Try composer install with better error handling
  if composer install --no-interaction --verbose; then
    echo "✅  Composer installation completed successfully"
  else
    echo "⚠️  Composer installation failed, trying with fallback approach..."
    
    # If it failed, try installing with different authentication method
    echo "🔄  Attempting with alternative authentication..."
    
    # Try with HTTPS instead of SSH for the private repository
    composer config --global github-protocols https
    composer install --no-interaction --verbose || {
      echo "❌  Composer installation failed. This might be due to:"
      echo "   • Missing GitHub authentication"
      echo "   • Network connectivity issues"
      echo "   • Private repository access problems"
      echo ""
      echo "💡  You can:"
      echo "   • Check your GitHub token in the .env file"
      echo "   • Ensure you have access to the private repository"
      echo "   • Try running the script again"
      echo ""
      echo "🔄  Continuing with WordPress setup (some plugins may be missing)..."
    }
  fi
)

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 6  •  Create wp-config.php
# ──────────────────────────────────────────────────────────────────────────────
echo "⚙️  Creating wp-config.php"

# Generate secure WordPress authentication keys and salts
generate_key() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-64
}

AUTH_KEY=$(generate_key)
SECURE_AUTH_KEY=$(generate_key)
LOGGED_IN_KEY=$(generate_key)
NONCE_KEY=$(generate_key)
AUTH_SALT=$(generate_key)
SECURE_AUTH_SALT=$(generate_key)
LOGGED_IN_SALT=$(generate_key)
NONCE_SALT=$(generate_key)

cat > "$WP_DIR/wp-config.php" <<PHP
<?php
/**
 * The base configuration for WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', '${DB_NAME}' );

/** MySQL database username */
define( 'DB_USER', '${DB_USER}' );

/** MySQL database password */
define( 'DB_PASSWORD', '${DB_PASSWORD}' );

/** MySQL hostname */
define( 'DB_HOST', 'db' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY', '${AUTH_KEY}' );
define( 'SECURE_AUTH_KEY', '${SECURE_AUTH_KEY}' );
define( 'LOGGED_IN_KEY', '${LOGGED_IN_KEY}' );
define( 'NONCE_KEY', '${NONCE_KEY}' );
define( 'AUTH_SALT', '${AUTH_SALT}' );
define( 'SECURE_AUTH_SALT', '${SECURE_AUTH_SALT}' );
define( 'LOGGED_IN_SALT', '${LOGGED_IN_SALT}' );
define( 'NONCE_SALT', '${NONCE_SALT}' );

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
\$table_prefix = '$(echo ${APP_ID} | cut -c1-2)_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', true );

// Additional debugging constants for development
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG_DISPLAY', false );
define( 'SCRIPT_DEBUG', true );
define( 'SAVEQUERIES', true );

// Add any custom values between this line and the "stop editing" comment.

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
PHP

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 7  •  Basic theme
# ──────────────────────────────────────────────────────────────────────────────
echo "🎨  Creating basic theme"
cat > "$WP_DIR/wp-content/themes/theme-basic/style.css" <<'CSS'
/*
Theme Name: Theme Basic
Version: 1.0
*/
CSS
echo '<?php echo "<h1>Hello from Theme Basic</h1>";' \
  > "$WP_DIR/wp-content/themes/theme-basic/index.php"

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 8  •  Debugging setup
# ──────────────────────────────────────────────────────────────────────────────
echo "🐛  Setting up debugging environment"
# Create debug.log file
touch "$WP_DIR/wp-content/debug.log"
chmod 666 "$WP_DIR/wp-content/debug.log"

echo "📊  Debugging plugins installed:"
echo "   • Query Monitor (https://wordpress.org/plugins/query-monitor/)"
echo "   • WP Crontrol (https://wordpress.org/plugins/wp-crontrol/)"
echo "   • Smarty Change Admin Colors (custom plugin)"

echo "🖥️  WP-CLI installed and ready:"
echo "   • Use: wpcli-${APP_ID} <command>"
echo "   • Examples: wpcli-${APP_ID} user list, wpcli-${APP_ID} plugin list"
echo "   • Install WordPress: wpinstall-${APP_ID}"
echo "   • Check status: wpstatus-${APP_ID}"

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 9  •  /etc/hosts
# ──────────────────────────────────────────────────────────────────────────────
echo "📌  Updating /etc/hosts"
for d in "$PROJECT_DOMAIN" phpmyadmin.test adminer.test mailpit.test "kibana-$APP_ID.test"; do
  sudo grep -q "$d" /etc/hosts || echo "127.0.0.1 $d" | sudo tee -a /etc/hosts
done

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 10  •  Docker up
# ──────────────────────────────────────────────────────────────────────────────
echo "🧹  Cleaning up any existing containers/volumes for this project"

# Determine the base directory (parent of scripts if we're in scripts)
if [[ "$(basename "$(pwd)")" == "scripts" ]]; then
    BASE_DIR=".."
else
    BASE_DIR="."
fi

(cd "$BASE_DIR/docker" && docker compose -f docker-compose.wordpress.yml --env-file .env down -v 2>/dev/null || true)

echo "🚀  docker compose up …"

# Export environment variables for docker compose (not stored in any file)
export DB_NAME="$DB_NAME"
export DB_USER="$DB_USER"
export DB_PASSWORD="$DB_PASSWORD"
export APP_ID="$APP_ID"
export PROJECT_DOMAIN="$PROJECT_DOMAIN"

# Run docker compose with exported environment variables
(cd "$BASE_DIR/docker" && docker compose -f docker-compose.wordpress.yml up -d)

echo "✅  Done.  Visit → http://${PROJECT_DOMAIN}"

echo ""
echo "🐳  Docker Management Commands:"
echo "   • Start containers:   cd docker && docker compose --env-file .env up -d"
echo "   • Stop containers:    cd docker && docker compose --env-file .env down"
echo "   • View logs:          cd docker && docker compose --env-file .env logs -f"
echo "   • Restart containers: cd docker && docker compose --env-file .env restart"
echo "   • Remove everything:  cd docker && docker compose --env-file .env down -v"

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 11  •  Setup Shell Aliases
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
    # Get the absolute path to the wp-local directory
    WP_LOCAL_DIR="$(cd "$BASE_DIR" && pwd)"
    
    # Check if aliases already exist
    if ! grep -q "alias wpup.*${APP_ID}" "$SHELL_CONFIG"; then
        # Add aliases with project-specific comments
        cat >> "$SHELL_CONFIG" <<ALIASES

# WordPress Docker aliases for ${APP_ID} project
alias wpup-${APP_ID}='cd ${WP_LOCAL_DIR}/docker && export DB_NAME="$(echo ${APP_ID} | cut -c1-2)_${APP_ID}" && export DB_USER="${APP_ID}_user" && export DB_PASSWORD="${APP_ID}_pass" && export APP_ID="${APP_ID}" && export PROJECT_DOMAIN="${APP_ID}.test" && docker compose -f docker-compose.wordpress.yml up -d'
alias wpdown-${APP_ID}='cd ${WP_LOCAL_DIR}/docker && export DB_NAME="$(echo ${APP_ID} | cut -c1-2)_${APP_ID}" && export DB_USER="${APP_ID}_user" && export DB_PASSWORD="${APP_ID}_pass" && export APP_ID="${APP_ID}" && export PROJECT_DOMAIN="${APP_ID}.test" && docker compose -f docker-compose.wordpress.yml down'
alias wplogs-${APP_ID}='cd ${WP_LOCAL_DIR}/docker && export DB_NAME="$(echo ${APP_ID} | cut -c1-2)_${APP_ID}" && export DB_USER="${APP_ID}_user" && export DB_PASSWORD="${APP_ID}_pass" && export APP_ID="${APP_ID}" && export PROJECT_DOMAIN="${APP_ID}.test" && docker compose -f docker-compose.wordpress.yml logs -f'
alias wprestart-${APP_ID}='cd ${WP_LOCAL_DIR}/docker && export DB_NAME="$(echo ${APP_ID} | cut -c1-2)_${APP_ID}" && export DB_USER="${APP_ID}_user" && export DB_PASSWORD="${APP_ID}_pass" && export APP_ID="${APP_ID}" && export PROJECT_DOMAIN="${APP_ID}.test" && docker compose -f docker-compose.wordpress.yml restart'
alias wpclean-${APP_ID}='cd ${WP_LOCAL_DIR}/docker && export DB_NAME="$(echo ${APP_ID} | cut -c1-2)_${APP_ID}" && export DB_USER="${APP_ID}_user" && export DB_PASSWORD="${APP_ID}_pass" && export APP_ID="${APP_ID}" && export PROJECT_DOMAIN="${APP_ID}.test" && docker compose -f docker-compose.wordpress.yml down -v'
alias wpprune-${APP_ID}='docker system prune -a --volumes -f'

# WP-CLI aliases for ${APP_ID} project
alias wpcli-${APP_ID}='docker exec -it php_${APP_ID} wp --allow-root'
alias wpinfo-${APP_ID}='docker exec -it php_${APP_ID} wp --info --allow-root'
alias wpstatus-${APP_ID}='docker exec -it php_${APP_ID} wp core is-installed --allow-root && echo "WordPress is installed" || echo "WordPress is NOT installed"'
alias wpinstall-${APP_ID}='docker exec -it php_${APP_ID} wp core install --url=http://${PROJECT_DOMAIN} --title="${APP_ID}" --admin_user=admin --admin_password=admin123 --admin_email=admin@${PROJECT_DOMAIN} --allow-root'
alias wpdb-${APP_ID}='docker exec -it php_${APP_ID} wp db --allow-root'

ALIASES
        echo "✅  Aliases added to $SHELL_CONFIG"
        echo "   • Use: wpup-${APP_ID}, wpdown-${APP_ID}, wplogs-${APP_ID}, wprestart-${APP_ID}, wpclean-${APP_ID}, wpprune-${APP_ID}, etc."
        echo "   • Reload shell: source $SHELL_CONFIG"
    else
        echo "✅  Aliases already exist in $SHELL_CONFIG"
    fi
fi

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 12  •  Create dip.yml configuration
# ──────────────────────────────────────────────────────────────────────────────
echo "🔧  Creating DIP configuration..."
DIP_TEMPLATE="$BASE_DIR/docker/templates/dip.wordpress.yml"

if [ -f "$DIP_TEMPLATE" ]; then
    sed -e "s/{{PROJECT_NAME}}/$APP_ID/g" \
        -e "s/{{PROJECT_DOMAIN}}/$PROJECT_DOMAIN/g" \
        -e "s/{{DB_NAME}}/$DB_NAME/g" \
        -e "s/{{DB_USER}}/$DB_USER/g" \
        -e "s/{{DB_PASSWORD}}/$DB_PASSWORD/g" \
        "$DIP_TEMPLATE" > "$PROJECT_DIR/dip.yml"

    echo "✅  Created dip.yml in project directory"
    echo "   You can now use DIP commands from $PROJECT_DIR/"
    echo "   Example: cd $PROJECT_DIR && dip up"
else
    echo "⚠️  DIP template not found at $DIP_TEMPLATE"
    echo "   You can manually create dip.yml later"
fi

# ──────────────────────────────────────────────────────────────────────────────
#  STEP 13  •  System Links
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "🌐  Available Systems:"
echo "   • WordPress Site:     http://${PROJECT_DOMAIN}"
echo "   • Traefik Dashboard:   http://localhost:8080"
echo "   • phpMyAdmin:         http://phpmyadmin.test"
echo "   • Mailpit:            http://mailpit.test"
echo "   • Adminer:            http://adminer.test"
echo "   • Elasticsearch:      http://localhost:9201"
echo "   • Kibana:             http://kibana-$APP_ID.test"
echo ""
echo "📝  Notes:"
echo "   • WordPress admin:    http://${PROJECT_DOMAIN}/wp-admin"
echo "   • Database name:      ${DB_NAME}"
echo "   • Debug log:          ${PROJECT_DIR}/wp/wp-content/debug.log"
echo ""
echo "📚  Documentation:"
echo "   • Full documentation: ${PWD}/README.md"
echo "   • All aliases and commands are documented there"
