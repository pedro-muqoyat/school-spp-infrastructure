# ==========================================
# STAGE 1: Composer & Node Builder
# ==========================================
FROM php:8.3-cli-alpine AS builder

RUN apk add --no-cache git unzip curl libpng-dev libzip-dev icu-dev linux-headers nodejs npm

RUN docker-php-ext-install gd zip intl pcntl

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

COPY package.json package-lock.json* vite.config.js tailwind.config.js ./
RUN npm ci

COPY . .

RUN mkdir -p storage/framework/views storage/framework/cache storage/framework/sessions bootstrap/cache

RUN composer dump-autoload --optimize --no-dev
RUN npm run build
RUN php artisan filament:optimize

# ==========================================
# STAGE 2: Production Runner (FrankenPHP)
# ==========================================
FROM dunglas/frankenphp:php8.3-alpine

RUN install-php-extensions pdo_pgsql gd intl zip redis pcntl opcache

WORKDIR /app

COPY --from=builder /app /app

RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache \
    && chmod -R 775 /app/storage /app/bootstrap/cache

RUN echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && echo "opcache.validate_timestamps=0" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
