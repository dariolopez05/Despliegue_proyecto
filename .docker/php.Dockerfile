# Usa la imagen oficial de PHP con FPM y las extensiones necesarias
FROM php:8.2-fpm

# Configurar entorno a producción
ENV APP_ENV=prod
ENV APP_DEBUG=0

# Instala paquetes necesarios
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    unzip \
    git \
    curl \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql zip gd intl opcache

# Configura el directorio de trabajo y copia el código
WORKDIR /var/www/html
COPY ../src .  
# Copia el código desde ../src al contenedor

RUN curl -sS https://getcomposer.org/installer -o /tmp/composer-installer.php
RUN php /tmp/composer-installer.php --install-dir=/usr/local/bin --filename=composer

USER root
# Instala Composer y dependencias sin ejecutar auto-scripts
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && COMPOSER_MEMORY_LIMIT=-1 composer install --no-dev --no-interaction --optimize-autoloader --no-scripts

# Ejecuta cache:clear manualmente en entorno prod
RUN php bin/console cache:clear --env=prod || true

# Ajusta permisos
RUN chown -R www-data:www-data /var/www/html

# Comando de inicio
CMD ["php-fpm"]
