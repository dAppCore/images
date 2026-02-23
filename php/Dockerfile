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

# Verify
RUN php -v && composer --version
