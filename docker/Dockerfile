FROM php:8.1-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www

# Create basic Yii2 structure
RUN mkdir -p /var/www/web /var/www/runtime /var/www/web/assets /var/www/config /var/www/controllers /var/www/views

# Create a simple index.php file
RUN echo '<?php echo "Yii2 Application Container is running!"; ?>' > /var/www/web/index.php

# Set proper permissions
RUN chown -R www-data:www-data /var/www/runtime \
    && chown -R www-data:www-data /var/www/web/assets \
    && chown -R www-data:www-data /var/www/web \
    && chmod -R 775 /var/www/runtime \
    && chmod -R 775 /var/www/web/assets \
    && chmod -R 775 /var/www/web

# Create health check script
RUN echo '#!/bin/sh\nphp -r "echo \"healthy\n\";" || exit 1' > /healthcheck.sh \
    && chmod +x /healthcheck.sh

# Expose port for PHP-FPM
EXPOSE 9000

# Define health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 CMD /healthcheck.sh

# Start PHP-FPM
CMD ["php-fpm"]