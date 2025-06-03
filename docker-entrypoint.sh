#!/bin/bash
set -e

APP_DIR="/var/www/yii2_sample_app"

echo "Starting PHP-FPM container setup..."

# Configure git in user home directory instead of global
if [ -w "$HOME" ]; then
    git config --global --add safe.directory "$APP_DIR" 2>/dev/null || echo "Git config skipped (no write permission)"
fi

# Check if we can write to the app directory
if [ ! -w "$APP_DIR" ]; then
    echo "Warning: No write permission to $APP_DIR"
    echo "Please fix permissions on the host with: sudo chown -R \$USER:\$USER yii2_sample_app/"
    exit 1
fi

# Always ensure we have dev dependencies for development
if [ ! -d "$APP_DIR/vendor" ] || [ ! -f "$APP_DIR/vendor/yiisoft/yii2-debug/composer.json" ]; then
    echo "Installing/updating Composer dependencies (including dev)..."
    cd "$APP_DIR"
    
    # Check if we can create vendor directory
    if [ ! -d "vendor" ]; then
        mkdir -p vendor || {
            echo "Failed to create vendor directory. Permission issue?"
            exit 1
        }
    fi
    
    # Remove vendor if it exists but doesn't have debug module
    if [ -d "vendor" ] && [ ! -f "vendor/yiisoft/yii2-debug/composer.json" ]; then
        rm -rf vendor
    fi
    
    composer install --optimize-autoloader --no-interaction
else
    echo "Dev dependencies already installed."
fi

# Create runtime and assets directories if they don't exist and make them writable
mkdir -p "$APP_DIR/runtime" "$APP_DIR/web/assets" || true
chmod -R 755 "$APP_DIR/runtime" "$APP_DIR/web/assets" 2>/dev/null || true

echo "PHP-FPM setup complete. Starting PHP-FPM..."

# Start PHP-FPM
exec php-fpm