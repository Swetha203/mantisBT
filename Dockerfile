# Use an official PHP runtime as a parent image
FROM php:7.4-apache

# Set the working directory
WORKDIR /var/www/html

# Update and install dependencies
RUN apt-get update && \
    apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    libxml2-dev \
    libxslt1-dev \
    mariadb-client \
    unzip \
    wget


RUN apt-get install libonig-dev
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y libzip-dev

# Configure GD library with FreeType and JPEG support
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
# Install PHP extensions in isolated steps
RUN docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-install -j$(nproc) intl
RUN docker-php-ext-install -j$(nproc) mbstring || (cat /usr/src/php/ext/mbstring/config.log && false)
RUN docker-php-ext-install -j$(nproc) mysqli
RUN docker-php-ext-install -j$(nproc) pdo
RUN docker-php-ext-install -j$(nproc) pdo_mysql
RUN docker-php-ext-install -j$(nproc) xml
RUN docker-php-ext-install -j$(nproc) xsl
RUN docker-php-ext-install -j$(nproc) zip

# Download and unzip MantisBT 2.26.2
 RUN wget https://github.com/mantisbt/mantisbt/archive/refs/tags/release-2.26.2.zip -O mantisbt.zip && \
     unzip mantisbt.zip && \
     mv mantisbt-release-2.26.2/* . && \
     rm -rf mantisbt-release-2.26.2 mantisbt.zip
## COPY /mantisbt/* . && \
# Copy the default configuration file
COPY config_inc.php /var/www/html/config/config_inc.php

#RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
#RUN composer init
#COPY composer.json composer.lock ./
#RUN composer install

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Enable Apache mod_rewrite
RUN a2enmod rewrite
# Copy the application files
COPY . /var/www/html/

# Install PHP dependencies
RUN composer install
# Give the appropriate permissions
RUN chown -R www-data:www-data /var/www/html


# Set appropriate permissions
#RUN chown -R www-data:www-data /var/www/html
##RUN ls -l /var/www/html/vendor/autoload.php
#COPY . /var/www/html

# Expose the default web port
EXPOSE 80


# Copy custom configuration file into the container
#COPY ./my-apache-config.conf /usr/local/apache2/conf/httpd.conf

# Start Apache in the foreground
CMD ["apache2-foreground"]
#CMD ["apache2ctl", "-D", "FOREGROUND"]
##ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
#RUN apache2ctl configtest
