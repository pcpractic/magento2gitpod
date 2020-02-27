FROM gitpod/workspace-full

USER root

RUN apt-get update
RUN apt-get -y install apt-utils
RUN apt-get -y install python
RUN apt-get -y install python-mysqldb
RUN apt-get -y install nginx
RUN apt-get -y install rsync
RUN apt-get -y install curl
RUN apt-get -y install libnss3-dev
RUN apt-get -y install openssh-client
RUN apt-get -y install mc
RUN apt install software-properties-common
RUN apt-get -y install gcc make autoconf libc-dev pkg-config
RUN apt-get -y install php7.2-dev
RUN apt-get -y install libmcrypt-dev
RUN apt-get -y install redis-tools
RUN apt-get install -y mysql-client

#
# enable contrib repo
#
RUN sed -i 's/main/main contrib/g' /etc/apt/sources.list

#
# install varnish build deps
#
RUN apt-get update && apt-get install -y --no-install-recommends \
    automake \
    autotools-dev \
    build-essential \
    ca-certificates \
    curl \
    git \
    libedit-dev \
    libgeoip-dev \
    libjemalloc-dev \
    libmhash-dev \
    libncurses-dev \
    libpcre3-dev \
    libtool \
    pkg-config \
    python-docutils \
    python-sphinx \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y debian-archive-keyring \
    && apt-get install -y curl gnupg apt-transport-https \
    && curl -L https://packagecloud.io/varnishcache/varnish41/gpgkey | sudo apt-key add - \
    && echo "deb https://packagecloud.io/varnishcache/varnish41/ubuntu/ trusty main" > /etc/apt/sources.list.d/varnishcache_varnish41.list \
    && echo "deb-src https://packagecloud.io/varnishcache/varnish41/ubuntu/ trusty main" >> /etc/apt/sources.list.d/varnishcache_varnish41.list \
    && apt-get update \
    && apt-get install -y varnish

RUN mkdir /etc/varnish
RUN chown -R gitpod:gitpod /usr/local/var/varnish/

#Install php-fpm7.2
RUN apt-get update \
    && apt-get install -y nginx curl zip unzip git software-properties-common supervisor sqlite3 \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y php7.2-fpm php7.2-common php7.2-cli php7.2-imagick php7.2-gd php7.2-mysql \
       php7.2-pgsql php7.2-imap php-memcached php7.2-mbstring php7.2-xml php7.2-xmlrpc php7.2-soap php7.2-zip php7.2-curl \
       php7.2-bcmath php7.2-sqlite3 php7.2-apcu php7.2-apcu-bc php-xdebug php-redis \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && pecl install mcrypt-1.0.1 \
    && mkdir /run/php \
    && chown gitpod:gitpod /run/php \
    && chown -R gitpod:gitpod /etc/php \
    && apt-get remove -y --purge software-properties-common \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "daemon off;" >> /etc/nginx/nginx.conf

USER root

#Copy nginx default and php-fpm.conf file
#COPY default /etc/nginx/sites-available/default
COPY php-fpm.conf /etc/php/7.2/fpm/php-fpm.conf
RUN chown -R gitpod:gitpod /etc/php

USER gitpod

RUN echo "/etc/mysql/mysql-bashrc-launch.sh" >> ~/.bashrc
COPY nginx.conf /etc/nginx

USER root
     
#Install APCU
RUN echo "apc.enable_cli=1" > /etc/php/7.2/cli/conf.d/20-apcu.ini
RUN echo "priority=25" > /etc/php/7.2/cli/conf.d/25-apcu_bc.ini
RUN echo "extension=apcu.so" >> /etc/php/7.2/cli/conf.d/25-apcu_bc.ini
RUN echo "extension=apc.so" >> /etc/php/7.2/cli/conf.d/25-apcu_bc.ini

RUN chown -R gitpod:gitpod /etc/php
RUN chown -R gitpod:gitpod /etc/nginx
RUN chown -R gitpod:gitpod /home/gitpod/.composer
RUN chown -R gitpod:gitpod /etc/init.d/
RUN echo "net.core.somaxconn=65536" >> /etc/sysctl.conf
     
RUN chown -R gitpod:gitpod /etc/php
RUN chown -R gitpod:gitpod /etc/varnish
