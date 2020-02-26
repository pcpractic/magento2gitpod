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

#
# install varnish
#
ENV VARNISH_VERSION=5.2.1
ENV VARNISH_SHA256SUM=b8452c9d78c16f78c8cfd1c1a1e696523bf64b7721c330150dcc0852459014b3

RUN mkdir -p /usr/local/src && \
    cd /usr/local/src && \
    curl -sfLO http://varnish-cache.org/_downloads/varnish-${VARNISH_VERSION}.tgz && \
    echo "${VARNISH_SHA256SUM} varnish-${VARNISH_VERSION}.tgz" | sha256sum -c - && \
    tar -xzf varnish-${VARNISH_VERSION}.tgz && \
    cd varnish-${VARNISH_VERSION} && \
    ./autogen.sh && \
    ./configure && \
    make install && \
    cd /usr/local/src && \
    rm -rf varnish-*

#
# install stock varnish module library
#
ENV VARNISHMODULES_VERSION=0.12.1
ENV VARNISHMODULES_SHA256SUM=84cfff1f585557117d282a502c109020b1cf8ccb82bdcdfdf3cfdf577f6f38d4

RUN cd /usr/local/src/ && \
    curl -sfL https://github.com/varnish/varnish-modules/archive/${VARNISHMODULES_VERSION}.tar.gz \
        -o varnish-modules-${VARNISHMODULES_VERSION}.tar.gz && \
    echo "${VARNISHMODULES_SHA256SUM} varnish-modules-${VARNISHMODULES_VERSION}.tar.gz" | sha256sum -c - && \
    tar -xzf varnish-modules-${VARNISHMODULES_VERSION}.tar.gz && \
    cd varnish-modules-${VARNISHMODULES_VERSION} && \
    ./bootstrap && \
    ./configure && \
    make install && \
    cd /usr/local/src && \
    rm -rf varnish-modules-${VARNISHMODULES_VERSION}* && \
    ldconfig

#
# install libvmod-dynamic
#
ENV LIBVMOD_DYNAMIC_BRANCH=master
ENV LIBVMOD_DYNAMIC_COMMIT=89f489146f129a841ec91467178b28cea57236df

RUN cd /usr/local/src/ && \
    git clone -b ${LIBVMOD_DYNAMIC_BRANCH} https://github.com/nigoroll/libvmod-dynamic.git && \
    cd libvmod-dynamic && \
    git reset --hard ${LIBVMOD_DYNAMIC_COMMIT} && \
    ./autogen.sh && \
    ./configure && \
    make install && \
    cd /usr/local/src && \
    rm -rf libvmod-dynamic && \
    ldconfig

#
# install libvmod-digest
#
ENV LIBVMOD_DIGEST_VERSION=1.0.1
ENV LIBVMOD_DIGEST_SHA256SUM=491c3e54ebca3340464a227732de7f475bc5136c0fdaab587b764dd77db376e2

RUN cd /usr/local/src/ && \
    curl -sfLO https://github.com/varnish/libvmod-digest/archive/libvmod-digest-${LIBVMOD_DIGEST_VERSION}.tar.gz && \
    echo "${LIBVMOD_DIGEST_SHA256SUM} libvmod-digest-${LIBVMOD_DIGEST_VERSION}.tar.gz" | sha256sum -c - && \
    tar -xzf libvmod-digest-${LIBVMOD_DIGEST_VERSION}.tar.gz && \
    cd libvmod-digest-libvmod-digest-${LIBVMOD_DIGEST_VERSION} && \
    ./autogen.sh && \
    ./configure && \
    make install && \
    cd /usr/local/src && \
    rm -rf libvmod-digest* && \
    ldconfig

#
# install libvmod-geoip
#
ENV LIBVMOD_GEOIP_BRANCH=master
ENV LIBVMOD_GEOIP_COMMIT=b4d72ecc23895d4a0e9b28655093861f0c85cb66

RUN cd /usr/local/src/ && \
    git clone -b ${LIBVMOD_GEOIP_BRANCH} https://github.com/varnish/libvmod-geoip.git && \
    cd libvmod-geoip && \
    git reset --hard ${LIBVMOD_GEOIP_COMMIT} && \
    ./autogen.sh && \
    ./configure && \
    make install && \
    cd /usr/local/src && \
    rm -rf libvmod-geoip && \
    ldconfig

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
