#!/bin/sh
cd /tmp/
/bin/cp -Rf /tmp/amimoto/etc/* /etc/
/sbin/service nginx restart
/sbin/service php-fpm restart
/sbin/service mysql stop
/bin/rm /var/lib/mysql/ib_logfile*
/sbin/service mysql start

/usr/bin/wget http://ja.wordpress.org/latest-ja.tar.gz
/bin/tar xvfz latest-ja.tar.gz
/bin/mv /tmp/wordpress /var/www/vhosts/$1

if [ -f /tmp/amimoto/wp_start.php ]; then
  /usr/bin/php /tmp/amimoto/wp_start.php $1
fi

/bin/chown -R nginx:nginx /var/www/vhosts/$1
