ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-cli-bookworm

# Extensions needed by core PHP repos:
# dom, curl, libxml, mbstring, zip, pcntl, pdo, sqlite, pdo_sqlite, pcov
RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip libzip-dev libsqlite3-dev libxml2-dev libcurl4-openssl-dev libonig-dev \
    && docker-php-ext-install dom curl mbstring zip pcntl pdo pdo_sqlite \
    && pecl install pcov && docker-php-ext-enable pcov \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Pre-warm Composer cache with common dependencies across all core/php-* repos.
# This means `composer install` in CI hits local cache instead of downloading.
RUN mkdir /tmp/warmup && cd /tmp/warmup \
    && composer init --name=lthn/warmup --no-interaction \
    && composer config allow-plugins.pestphp/pest-plugin true \
    && composer config allow-plugins.phpstan/extension-installer true \
    && composer require --no-interaction --prefer-dist \
       laravel/framework livewire/livewire \
       laravel/pint pestphp/pest orchestra/testbench \
    && rm -rf /tmp/warmup

# Verify
RUN php -v && composer --version
