#Author:PG - Demo/Training/Testing

FROM centos:centos7

#Update and install basic package 
RUN yum -y update --nogpgcheck; yum clean all
RUN yum install -y epel-release --nogpgcheck
RUN yum install -y bzip2 wget curl ntp gcc gcc-c++ zlib-devel libuuid-devel pcre-devel libxml2 libxml2-devel curl curl-devel libjpeg libjpeg-devel libpng-devel freetype freetype-devel  mysql-devel pdo-mysql autoconf --nogpgcheck

#Install nginx repo
RUN rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm

# Install latest version of nginx
RUN yum install -y nginx --nogpgcheck

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

RUN mkdir /hwdata && mkdir -p /hwdata/php7 && mkdir -p /hwdata/src && mkdir /hwdata/www 
WORKDIR /hwdata/src
RUN wget http://cn2.php.net/get/php-7.0.10.tar.bz2/from/this/mirror -O php-7.0.10.tar.bz2
RUN tar -jxf php-7.0.10.tar.bz2
WORKDIR /hwdata/src/php-7.0.10
RUN ./configure --prefix=/hwdata/php7 --enable-fpm --with-mysqli --with-mysql-sock --with-zlib --with-iconv --enable-sockets --with-config-file-path=/hwdata/php7/etc --with-config-file-scan-dir=/hwdata/php7/etc/php.d --with-gd --with-jpeg-dir=/usr/lib --with-png-dir=/usr/lib --enable-mbstring --enable-gd-native-ttf --enable-xml --with-freetype-dir --with-curl --with-pdo-mysql --enable-ftp --with-libdir=lib64 --with-openssl
RUN make && make install	

#Update PHP configs
ADD ./php.ini /hwdata/php7/etc/php.ini
ADD ./php-fpm.conf /hwdata/php7/etc/php-fpm.conf
ADD ./www.conf /hwdata/php7/etc/php-fpm.d/www.conf

#Update nginx config
ADD ./default.conf /etc/nginx/conf.d/default.conf

#Add default php file
ADD ./index.php /hwdata/www/index.php
ADD ./info.php /hwdata/www/info.php

# Install supervisor to run jobs
RUN yum install -y supervisor --nogpgcheck

ADD ./supervisord.conf /etc/supervisord.conf

EXPOSE 80

#Run nginx engine
CMD ["/usr/bin/supervisord","-n","-c","/etc/supervisord.conf"]
