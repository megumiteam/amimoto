#!/bin/sh
SERVERNAME=$1
INSTANCEID=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id`

cd /tmp/
/bin/cp -Rf /tmp/amimoto/etc/* /etc/
sed -e "s/\$host\([;\.]\)/$INSTANCE_ID\1/" /tmp/amimoto/etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf
sed -e "s/\$host\([;\.]\)/$INSTANCE_ID\1/" /tmp/amimoto/etc/nginx/conf.d/backend.conf > /etc/nginx/conf.d/default.backend.conf
/bin/rm /etc/nginx/conf.d/backend.conf 
if [ "$SERVERNAME" != "$INSTANCEID" ]; then
  sed -e "s/\$host\([;\.]\)/$SERVERNAME\1/" /tmp/amimoto/etc/nginx/conf.d/default.conf | sed -e "s/ default;/;/" | sed -e "s/\(server_name \)_/\1$SERVERNAME/" > /etc/nginx/conf.d/$SERVERNAME.conf
  sed -e "s/\$host\([;\.]\)/$SERVERNAME\1/" /tmp/amimoto/etc/nginx/conf.d/backend.conf | sed -e "s/ default;/;/" | sed -e "s/\(server_name \)_/\1$SERVERNAME/" > /etc/nginx/conf.d/$SERVERNAME.backend.conf
fi

/sbin/service nginx restart
/sbin/service php-fpm restart
/sbin/service mysql stop
/bin/rm /var/lib/mysql/ib_logfile*
/sbin/service mysql start

/usr/bin/wget http://ja.wordpress.org/latest-ja.tar.gz
/bin/tar xvfz /tmp/latest-ja.tar.gz
/bin/rm /tmp/latest-ja.tar.gz
/bin/mv /tmp/wordpress /var/www/vhosts/$SERVERNAME

if [ -f /tmp/amimoto/wp-setup.php ]; then
  /usr/bin/php /tmp/amimoto/wp-setup.php $SERVERNAME
fi

/bin/chown -R nginx:nginx /var/www/vhosts/$SERVERNAME
