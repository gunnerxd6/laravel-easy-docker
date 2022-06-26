FROM php:7.4.27-apache-bullseye

RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    && docker-php-ext-install zip

RUN docker-php-ext-install mysqli pdo pdo_mysql
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
RUN a2enmod rewrite
RUN service apache2 restart

WORKDIR /var/www/html

COPY . /var/www/html/

RUN chown -R www-data:www-data /var/www

COPY --from=composer /usr/bin/composer /usr/bin/composer


RUN chmod -R 755 storage

ENV  COMPOSER_ALLOW_SUPERUSER 1

RUN composer install
