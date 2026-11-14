# Shared base image for Craft CMS projects: same image locally and on devpush.
# PHP-FPM + nginx (serversideup/php), unprivileged, listening on 8080.
# Projects extend it: FROM ghcr.io/anuarhdz/craft-base:php8.5
ARG PHP_VERSION=8.5
FROM serversideup/php:${PHP_VERSION}-fpm-nginx-trixie

USER root

# Craft requirements missing from the upstream image. Projects add their own
# (imagick, soap, ...) with `install-php-extensions` in their Dockerfile.
# default-mysql-client: Craft shells out to mysqldump for backups and `craft up`.
RUN install-php-extensions bcmath exif gd intl \
    && apt-get update \
    && apt-get install -y --no-install-recommends default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Debian ships MariaDB clients, which reject MySQL's self-signed cert.
COPY --chmod=755 rootfs/usr/local/bin/mysql-client-wrapper /usr/local/bin/mysqldump
RUN ln -s mysqldump /usr/local/bin/mysql
COPY --chmod=755 rootfs/etc/entrypoint.d/ /etc/entrypoint.d/

# Production defaults. compose.dev.yml overrides what dev needs.
ENV NGINX_WEBROOT=/var/www/html/web \
    PHP_OPCACHE_ENABLE=1 \
    PHP_MEMORY_LIMIT=256M \
    PHP_UPLOAD_MAX_FILE_SIZE=32M \
    PHP_POST_MAX_SIZE=32M \
    CRAFT_COMPOSER_AUTOINSTALL=false

# Writable paths must exist and belong to www-data before named volumes mount
# on them, or Docker initializes the volume as root.
WORKDIR /var/www/html
RUN mkdir -p storage/runtime storage/logs storage/backups web/cpresources web/uploads \
    && chown -R www-data:www-data /var/www/html

USER www-data

LABEL org.opencontainers.image.source="https://github.com/anuarhdz/craft-base" \
      org.opencontainers.image.description="PHP-FPM + nginx base image for Craft CMS"
