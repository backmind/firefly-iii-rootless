#!/bin/bash
set -e

echo "🚀 Firefly III - Rootless Edition"
echo "=================================="
echo "User running script: $(whoami)"
echo "Current UID: $(id -u)"
echo "Current GID: $(id -g)"
echo ""

# Verify critical directories
echo "✅ Verifying critical directories..."
if [ -d "/var/www/html/storage" ]; then
    echo "  → Checking /var/www/html/storage"
    chmod -R 775 /var/www/html/storage
fi

if [ ! -d "/var/www/html/storage/upload" ]; then
    echo "  → Creating directory /var/www/html/storage/upload"
    mkdir -p /var/www/html/storage/upload
    chmod -R 775 /var/www/html/storage/upload
fi

# Verify that temporary directories exist
for dir in "framework/cache" "framework/sessions" "framework/views/twig" "logs"; do
    if [ ! -d "/var/www/html/storage/$dir" ]; then
        echo "  → Creating directory /var/www/html/storage/$dir"
        mkdir -p "/var/www/html/storage/$dir"
        chmod -R 775 "/var/www/html/storage/$dir"
    fi
done

echo "✅ Rootless configuration complete!"

