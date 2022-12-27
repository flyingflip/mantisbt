#!/bin/bash

FILE=/var/www/html/config/config_inc.php
if [ !-f "$FILE" ]; then
  mkdir -p /var/www/html/config
  touch /var/www/html/config/config_inc.php
fi

ln -s /var/www/html/config/config_inc.php /var/www/html/web/config/config_inc.php

httpd -DFOREGROUND
