FROM php:7-fpm
RUN apt-get update && apt-get install -y \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libmcrypt-dev \
  libpng12-dev \
  libpq-dev

RUN docker-php-ext-install -j$(nproc) iconv mcrypt pdo pdo_mysql pdo_pgsql mysqli \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j$(nproc) gd

#RUN pecl install redis-3.1.0 \
#  && pecl install xdebug-2.5.0 \
#  && docker-php-ext-enable redis xdebug
