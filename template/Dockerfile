# Craft project image. One file, three stages:
#   dev    -> compose.dev.yml (code bind-mounted; vendor/assets not baked in)
#   assets -> Vite build (delete for projects without a frontend build)
#   prod   -> last stage = default target, what devpush builds from compose.yml
ARG BASE_IMAGE=ghcr.io/anuarhdz/craft-base:php8.5

# --- Dev -----------------------------------------------------------------
FROM ${BASE_IMAGE} AS dev
# Linux hosts: pass your UID/GID so bind-mounted files stay writable.
# macOS (OrbStack / Docker Desktop) maps ownership itself; leave empty.
ARG USER_ID=""
ARG GROUP_ID=""
USER root
RUN if [ -n "$USER_ID" ]; then \
      docker-php-serversideup-set-id www-data "$USER_ID:${GROUP_ID:-$USER_ID}" \
      && docker-php-serversideup-set-file-permissions --owner "$USER_ID:${GROUP_ID:-$USER_ID}" --service nginx; \
    fi
# ADAPT: uncomment for step debugging.
# RUN install-php-extensions xdebug
USER www-data

# --- Assets --------------------------------------------------------------
# ADAPT: copy whatever the build reads (Tailwind scans templates).
FROM node:24-alpine AS assets
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY vite.config.ts tsconfig.json ./
COPY src ./src
COPY templates ./templates
RUN npm run build

# --- Prod ----------------------------------------------------------------
FROM ${BASE_IMAGE} AS prod
# ADAPT: project-only extensions / packages go here.
# USER root
# RUN install-php-extensions imagick
# USER www-data

# Dependencies first so code changes don't invalidate the composer layer.
COPY --chown=www-data:www-data composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --no-progress --no-scripts --no-autoloader
COPY --chown=www-data:www-data . .
COPY --chown=www-data:www-data --from=assets /app/web/dist ./web/dist
RUN composer dump-autoload --no-dev --optimize
