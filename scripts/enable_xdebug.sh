#!/bin/bash

# Enable Xdebug...
echo "..."
cp /etc/php7/custom.d/00_xdebug.ini /etc/php7/conf.d/
supervisorctl restart php-fpm 1>/dev/null
