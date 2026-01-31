#!/bin/sh
set -e

# Install PHP dependencies if vendor directory is empty
if [ ! -f "/app/vendor/autoload.php" ]; then
    echo "Installing PHP dependencies..."
    composer install --no-interaction --prefer-dist
fi

# Install Node dependencies if node_modules is empty
if [ ! -d "/app/node_modules" ] || [ -z "$(ls -A /app/node_modules 2>/dev/null)" ]; then
    echo "Installing Node dependencies..."
    npm install
fi

# Run database migrations (skip errors if DB not ready)
php artisan migrate --force 2>/dev/null || echo "Migrations skipped (DB may not be ready)"

# Execute the main command
exec "$@"
