FROM alpine:3.16

LABEL name="FlyingFlip MantisBT Image"
LABEL author="Michael R. Bagnall <mbagnall@flyingflip.com>"
LABEL vendor="FlyingFlip Studios, LLC."

ENV TERM xterm

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/src/vendor/bin

# Install all of our base packages for making the image work.
RUN apk update && \
  apk add --no-cache \
  openrc php81-apache2 wget bash  \
  php81 php81-bcmath php81-bz2 php81-curl php81-dba php81-ldap php81-mbstring php81-mysqli \
  php81-opcache php81-pdo_mysql php81-pdo_pgsql php81-soap php81-xml php81-zip php81-pecl-redis php81-pecl-memcached lsof \
  php81-pecl-imagick php81-pear git vim zip gzip bzip2 pv rsync curl php81-cgi php81-common sudo php81-simplexml \
  php81-cli mlocate php81-phar php81-dom php81-tokenizer apache2-ctl php81-ctype php81-fileinfo apache2-ssl \
  php81-iconv apache2-proxy php81-gd gnu-libiconv apache2-ssl php81-xmlreader

# By default, alpine puts PHP in as "php7" or "php8". We need to homogenize it.
RUN ln -s /usr/bin/php81 /bin/php

COPY mantis/mantisbt-2.26.0.tar.gz /var/www/html/mantisbt-2.26.0.tar.gz
RUN cd /var/www/html/ && tar -xvzf mantisbt-2.26.0.tar.gz && mv mantisbt-2.26.0 web
RUN chown -R root:root /var/www/html/web
RUN chmod 755 /var/www/html/web

RUN chown -R apache:apache /var/www/html

RUN rm /etc/apache2/conf.d/ssl.conf
COPY files/apache-default-host.conf /etc/apache2/conf.d/apache-default-host.conf
COPY files/ssl_environment_variable.conf /etc/apache2/conf.d/ssl_environment_variable.conf
COPY files/httpd.conf /etc/apache2/httpd.conf
COPY files/bashrc /root/.bashrc
COPY files/startup.sh /startup.sh
RUN chmod 755 /startup.sh

# Add our localhost certificate
ADD ./files/localhost.crt /etc/ssl/certs/localhost.crt
ADD ./files/localhost.key /etc/ssl/private/localhost.key

RUN rm /usr/bin/vi
RUN ln -s /usr/bin/vim /usr/bin/vi

CMD ["/startup.sh"]

