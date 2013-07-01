#!/bin/sh
function plugin_install(){
  cd /tmp
  /usr/bin/wget http://downloads.wordpress.org/plugin/$1
  /usr/bin/unzip /tmp/$1 -d /var/www/vhosts/$2/wp-content/plugins/
  /bin/rm /tmp/$1
}

SERVERNAME=$1
INSTANCEID=default
TZ="Asia\/Tokyo"

cd /tmp/

if [ "$SERVERNAME" = "$INSTANCEID" ]; then
  /bin/mv /etc/localtime /etc/localtime.bak
  /bin/cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
  /bin/cp /tmp/amimoto/etc/motd.jp /etc/motd
  /bin/cp /tmp/amimoto/etc/sysconfig/i18n.jp /etc/sysconfig/i18n
fi
  
if [ "$SERVERNAME" = "$INSTANCEID" ]; then
  /bin/cp -Rf /tmp/amimoto/etc/nginx/* /etc/nginx/
  sed -e "s/\$host\([;\.]\)/$INSTANCEID\1/" /tmp/amimoto/etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf
  sed -e "s/\$host\([;\.]\)/$INSTANCEID\1/" /tmp/amimoto/etc/nginx/conf.d/default.backend.conf > /etc/nginx/conf.d/default.backend.conf
  /sbin/service nginx stop
  /bin/rm -Rf /var/log/nginx/*
  /bin/rm -Rf /var/cache/nginx/*
  /sbin/service nginx start
else
  sed -e "s/\$host\([;\.]\)/$SERVERNAME\1/" /tmp/amimoto/etc/nginx/conf.d/default.conf | sed -e "s/ default;/;/" | sed -e "s/\(server_name \)_/\1$SERVERNAME/" | sed -e "s/\(\\s*\)\(include     \/etc\/nginx\/phpmyadmin;\)/\1#\2/" > /etc/nginx/conf.d/$SERVERNAME.conf
  sed -e "s/\$host\([;\.]\)/$SERVERNAME\1/" /tmp/amimoto/etc/nginx/conf.d/default.backend.conf | sed -e "s/ default;/;/" | sed -e "s/\(server_name \)_/\1$SERVERNAME/" > /etc/nginx/conf.d/$SERVERNAME.backend.conf
  /usr/sbin/nginx -s reload
fi

if [ "$SERVERNAME" = "$INSTANCEID" ]; then
  /sbin/service php-fpm stop
  sed -e "s/date\.timezone = \"UTC\"/date\.timezone = \"$TZ\"/" /tmp/amimoto/etc/php.ini > /etc/php.ini
  /bin/cp -Rf /tmp/amimoto/etc/php.d/* /etc/php.d/
  /bin/cp /tmp/amimoto/etc/php-fpm.conf /etc/
  /bin/cp -Rf /tmp/amimoto/etc/php-fpm.d/* /etc/php-fpm.d/
  /bin/rm -Rf /var/log/php-fpm/*
  /sbin/service php-fpm start
fi

if [ "$SERVERNAME" = "$INSTANCEID" ]; then
  /sbin/service mysql stop
  /bin/cp /tmp/amimoto/etc/my.cnf /etc/
  /bin/rm /var/lib/mysql/ib_logfile*
  /bin/rm /var/log/mysqld.log*
  /sbin/service mysql start
fi

echo "WordPress install ..."
/usr/bin/wget http://ja.wordpress.org/latest-ja.tar.gz > /dev/null 2>&1
/bin/tar xvfz /tmp/latest-ja.tar.gz > /dev/null 2>&1
/bin/rm /tmp/latest-ja.tar.gz
/bin/mv /tmp/wordpress /var/www/vhosts/$SERVERNAME
plugin_install "nginx-champuru.1.5.0.zip" "$SERVERNAME" > /dev/null 2>&1
plugin_install "wpbooster-cdn-client.2.6.0.zip" "$SERVERNAME" > /dev/null 2>&1
plugin_install "wp-remote-manager-client.0.7.0.2.zip" "$SERVERNAME" > /dev/null 2>&1
plugin_install "head-cleaner.1.4.2.11.zip" "$SERVERNAME" > /dev/null 2>&1
plugin_install "wp-total-hacks.1.3.1.zip" "$SERVERNAME" > /dev/null 2>&1
plugin_install "flamingo.1.0.3.zip" "$SERVERNAME" > /dev/null 2>&1
plugin_install "contact-form-7.3.4.2.zip" "$SERVERNAME" > /dev/null 2>&1
plugin_install "jetpack.2.3.zip" "$SERVERNAME" > /dev/null 2>&1
plugin_install "hotfix.1.0.zip" "$SERVERNAME" > /dev/null 2>&1
plugin_install "hello-claudia.0.4.2.1.zip" "$SERVERNAME" > /dev/null 2>&1
if [ -f /tmp/amimoto/wp-setup.php ]; then
  /usr/bin/php /tmp/amimoto/other/wp-setup.php $SERVERNAME $INSTANCEID
fi
echo "... WordPress installed"

/bin/chown -R nginx:nginx /var/log/nginx
/bin/chown -R nginx:nginx /var/log/php-fpm
/bin/chown -R nginx:nginx /var/cache/nginx
/bin/chown -R nginx:nginx /var/tmp/php
/bin/chown -R nginx:nginx /var/www/vhosts/$SERVERNAME
