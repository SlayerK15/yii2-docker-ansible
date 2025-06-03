#!/bin/bash
set -e

APP_DIR="/var/www/yii2_sample_app"

echo "Starting PHP-FPM container setup..."

# Add git safe directory config for current user (www-data)
git config --global --add safe.directory "$APP_DIR" || true

# Always ensure we have dev dependencies for development
if [ ! -d "$APP_DIR/vendor" ] || [ ! -f "$APP_DIR/vendor/yiisoft/yii2-debug/composer.json" ]; then
    echo "Installing/updating Composer dependencies (including dev)..."
    cd "$APP_DIR"
    # Remove vendor if it exists but doesn't have debug module
    [ -d "vendor" ] && [ ! -f "vendor/yiisoft/yii2-debug/composer.json" ] && rm -rf vendor
    composer install --optimize-autoloader
else
    echo "Dev dependencies already installed."
fi

# Create runtime and assets directories if they don't exist and make them writable
mkdir -p "$APP_DIR/runtime" "$APP_DIR/web/assets" || true

echo "PHP-FPM setup complete. Starting PHP-FPM..."

# Start PHP-FPM
exec php-fpm