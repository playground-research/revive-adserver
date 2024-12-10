# Use an official PHP image with Apache support
FROM php:8.1-apache

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    REVIVE_VERSION=5.5.2

# Update packages and install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    libzip-dev \
    mariadb-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql mysqli zip mbstring

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Download and extract Revive Adserver
RUN wget https://download.revive-adserver.com/revive-adserver-${REVIVE_VERSION}.tar.gz -O revive.tar.gz && \
    tar -xzf revive.tar.gz --strip-components=1 && \
    rm -f revive.tar.gz

# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Expose the default web server port
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]

