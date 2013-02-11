#!/bin/bash

tar cvzPf lyx2rfc_web.tar.gz --exclude /var/www/lyx2rfc/files ./package.sh ./install_log /etc/apt/sources.list.d/lyx2rfc.list /etc/cron.hourly/lyx2rfc /etc/apache2/conf.d/lyx2rfc.conf /var/local/lyx2rfc/update.sh /var/www/favicon.ico /var/www/lyx2rfc/
