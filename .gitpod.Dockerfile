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

#Adjust few options for xDebug
RUN echo "xdebug.remote_enable=on" >> /etc/php/7.2/mods-available/xdebug.ini
    #&& echo "xdebug.remote_autostart=on" >> /etc/php/7.2/mods-available/xdebug.ini
    #&& echo "xdebug.profiler_enable=On" >> /etc/php/7.2/mods-available/xdebug.ini \
    #&& echo "xdebug.profiler_output_dir = /workspace/magento2pitpod" >> /etc/php/7.2/mods-available/xdebug.ini \
    #&& echo "xdebug.profiler_output_name = nemanja.log >> /etc/php/7.2/mods-available/xdebug.ini \
    #&& echo "xdebug.show_error_trace=On" >> /etc/php/7.2/mods-available/xdebug.ini \
    #&& echo "xdebug.show_exception_trace=On" >> /etc/php/7.2/mods-available/xdebug.ini

# Install MySQL
RUN apt-get update \
 && apt-get install -y mysql-server \
 && apt-get clean && rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/* \
 && mkdir /var/run/mysqld \
 && chown -R gitpod:gitpod /etc/mysql /var/run/mysqld /var/log/mysql /var/lib/mysql /var/lib/mysql-files /var/lib/mysql-keyring /var/lib/mysql-upgrade

# Install our own MySQL config
COPY mysql.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

USER gitpod

# Install default-login for MySQL clients
COPY client.cnf /etc/mysql/mysql.conf.d/client.cnf

COPY mysql-bashrc-launch.sh /etc/mysql/mysql-bashrc-launch.sh

USER root

#Copy nginx default and php-fpm.conf file
#COPY default /etc/nginx/sites-available/default
COPY php-fpm.conf /etc/php/7.2/fpm/php-fpm.conf
RUN chown -R gitpod:gitpod /etc/php

USER gitpod

RUN echo "/etc/mysql/mysql-bashrc-launch.sh" >> ~/.bashrc
COPY nginx.conf /etc/nginx

USER root

# Install Redis.
RUN sudo apt-get update \
 && sudo apt-get install -y \
  redis-server \
 && sudo rm -rf /var/lib/apt/lists/*
     
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

USER gitpod

#RUN bash -c ". /home/gitpod/.sdkman/bin/sdkman-init.sh \
#    && sdk default java 11.0.5-open"
    
RUN curl https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.16.tar.gz --output elasticsearch-5.6.16.tar.gz \
    && tar -xzf elasticsearch-5.6.16.tar.gz
ENV ES_HOME="$HOME/elasticsearch-5.6.16"
