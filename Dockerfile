FROM fireflyiii/core:latest

# Build arguments for UID/GID
ARG PUID=1000
ARG PGID=1000

USER root

# Modify PHP-FPM configuration to ensure user is defined
RUN grep -q "^user = " /usr/local/etc/php-fpm.d/www.conf || echo "user = www-data" >> /usr/local/etc/php-fpm.d/www.conf && \
    grep -q "^group = " /usr/local/etc/php-fpm.d/www.conf || echo "group = www-data" >> /usr/local/etc/php-fpm.d/www.conf

# Modify www-data UID/GID to match host user
RUN usermod -u ${PUID} www-data && \
    groupmod -g ${PGID} www-data && \
    # Explicitly create all required cache directories
    mkdir -p /var/www/html/storage/framework/views/twig/00 && \
    mkdir -p /var/www/html/storage/framework/cache && \
    mkdir -p /var/www/html/storage/framework/sessions && \
    mkdir -p /var/www/html/storage/logs && \
    # Adjust permissions for critical directories
    chown -R www-data:www-data /var/www/html && \
    chown -R www-data:www-data /etc/nginx && \
    chown -R www-data:www-data /var/log/nginx && \
    chown -R www-data:www-data /run && \
    # Broader permissions for storage directories
    chmod -R 777 /var/www/html/storage

# Copy initialization script (executable permissions set in GitHub Actions)
COPY rootless-init.sh /etc/entrypoint.d/01-rootless-init.sh

# Switch back to www-data user to run as non-root
USER www-data