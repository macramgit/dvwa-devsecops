FROM php:8-apache

LABEL org.opencontainers.image.source=https://github.com/digininja/DVWA
LABEL org.opencontainers.image.description="DVWA pre-built image."
LABEL org.opencontainers.image.licenses="gpl-3.0"

WORKDIR /var/www/html

# Zaktualizuj pakiety systemowe i zainstaluj zależności
RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev iputils-ping git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Konfiguracja rozszerzeń PHP i Apache
RUN docker-php-ext-configure gd --with-jpeg --with-freetype && \
    a2enmod rewrite && \
    docker-php-ext-install gd mysqli pdo pdo_mysql

# Kopiowanie zależności i konfiguracji
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
COPY --chown=www-data:www-data . .
COPY --chown=www-data:www-data config/config.inc.php.dist config/config.inc.php

# Instalacja zależności API (jeśli composer.json istnieje)
RUN cd /var/www/html/vulnerabilities/api && composer install || true
