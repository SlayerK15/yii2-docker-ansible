FROM php:8.1-fpm

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        zip \
        intl \
        opcache \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/yii2_sample_app

# Copy entrypoint script and make it executable
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create www-data user with same UID as host user (1000)
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

# Create directories and set permissions as root (before switching to www-data)
RUN mkdir -p /var/www/yii2_sample_app/runtime \
             /var/www/yii2_sample_app/web/assets \
             /var/www/yii2_sample_app/vendor \
    && chown -R www-data:www-data /var/www

# Switch to www-data user
USER www-data

# Expose port 9000
EXPOSE 9000

# Use entrypoint script
ENTRYPOINT ["docker-entrypoint.sh"]