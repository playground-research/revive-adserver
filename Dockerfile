# Use an official PHP image with Apache and necessary extensions
FROM php:8.1-apache

# Install required PHP extensions and system tools
RUN apt-get update && apt-get install -y \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    libonig-dev \
    zlib1g-dev \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
    zip \
    gd \
    intl \
    mbstring \
    pdo \
    pdo_mysql \
    mysqli \
    && a2enmod rewrite dir

# Clone the Revive Adserver repository into /var/www/html
WORKDIR /var/www/html
RUN git clone https://github.com/revive-adserver/revive-adserver.git . 

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set permissions to ensure Apache has access to files
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Add a custom Apache configuration file
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf

# Enable the site configuration and rewrite module
RUN a2ensite 000-default.conf && a2enmod rewrite

# Install PHP dependencies via Composer
RUN composer install --no-dev --optimize-autoloader

# Expose port 80
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]
