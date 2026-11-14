#!/bin/sh
# Dev convenience: with the project bind-mounted and no vendor/ yet, install
# dependencies on boot. Production images bake vendor/ in, so this is a no-op.
[ "$CRAFT_COMPOSER_AUTOINSTALL" = "true" ] || return 0
[ -f /var/www/html/composer.json ] || return 0
[ -f /var/www/html/vendor/autoload.php ] && return 0
echo "craft-base: vendor/ missing, running composer install"
composer install --working-dir=/var/www/html --no-interaction --no-progress
