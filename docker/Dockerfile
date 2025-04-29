FROM php:8.1-fpm

# Define build arguments
ARG APP_PATH=yii2_sample_app

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

# Set working directory
WORKDIR /var/www

# Copy application files
COPY ${APP_PATH}/ /var/www/

# Create necessary directories
RUN mkdir -p /var/www/runtime /var/www/web/assets

# Set permissions
RUN chmod -R 775 /var/www/runtime \
    && chmod -R 775 /var/www/web/assets \
    && chmod 755 /var/www/yii

# Create health check script
RUN echo '#!/bin/sh\nphp -r "echo \"healthy\n\";" || exit 1' > /healthcheck.sh \
    && chmod +x /healthcheck.sh

# Expose port for PHP-FPM
EXPOSE 9000

# Define health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 CMD /healthcheck.sh

# Start PHP-FPM
CMD ["php-fpm"] 