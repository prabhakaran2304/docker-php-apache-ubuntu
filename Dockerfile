FROM ubuntu:18.04
MAINTAINER prabhavarul@gmail.com

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -yq --no-install-recommends \
    apt-utils \
    curl \
    # Install git
    git \
    # Install apache
    apache2 \
    # Install php 7.2
    libapache2-mod-php7.2 \
    php7.2-cli \
    php7.2-json \
    php7.2-curl \
    php7.2-fpm \
    php7.2-gd \
    php7.2-ldap \
    php7.2-mbstring \
    php7.2-mysql \
    php7.2-soap \
    php7.2-sqlite3 \
    php7.2-xml \
    php7.2-zip \
    php7.2-intl \
    php-imagick \
    # Install tools
    openssl \
    nano \
    graphicsmagick \
    imagemagick \
    ghostscript \
    mysql-client \
    iputils-ping \
    locales \
    sqlite3 \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install composer 
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set locales
RUN locale-gen en_US.UTF-8 en_GB.UTF-8 de_DE.UTF-8 es_ES.UTF-8 fr_FR.UTF-8 it_IT.UTF-8 km_KH sv_SE.UTF-8 fi_FI.UTF-8

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Configure PHP for php.ini
COPY php.ini /etc/php/7.2/mods-available/
RUN phpenmod php.ini
# Configure apache for php.ini
RUN a2enmod rewrite expires
RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/servername.conf
RUN a2enconf servername

# Configure vhost for SITE1
COPY site1.conf /etc/apache2/sites-available/
RUN a2dissite 000-default
RUN a2ensite site1.conf

# Expose apache.
EXPOSE 80 443

#Remove default index.html file 
WORKDIR /var/www/html
RUN rm index.html

# Copy this repo into place.
ADD site1 /var/www/html

HEALTHCHECK --interval=5s --timeout=3s --retries=3 CMD curl -f http://localhost || exit 1

CMD apachectl -D FOREGROUND 
