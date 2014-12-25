#!/bin/sh
function plugin_install(){
  cd /tmp

  if [ -f /tmp/${1}.zip ]; then
    rm -r /tmp/${1}.zip
  fi
  /usr/bin/wget http://downloads.wordpress.org/plugin/${1}.zip

  if [ -d /var/www/vhosts/${2}/wp-content/plugins/${1} ]; then
    /bin/rm -rf /var/www/vhosts/${2}/wp-content/plugins/${1}
  fi
  /usr/bin/unzip /tmp/${1}.zip -d /var/www/vhosts/${2}/wp-content/plugins/

  /bin/rm -r /tmp/${1}.zip
}

WP_VER=4.1

SERVERNAME=$1
INSTANCEID=default
TZ="Asia\/Tokyo"

cd /tmp/

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
WP_CLI=/usr/local/bin/wp
if [ ! -f $WP_CLI ]; then
  cd /usr/local/bin
  /usr/bin/curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  mv wp-cli.phar /usr/local/bin/wp
  chmod +x /usr/local/bin/wp
fi
if [ ! -d /var/www/vhosts/$SERVERNAME ]; then
  mkdir -p /var/www/vhosts/$SERVERNAME
fi
cd /var/www/vhosts/$SERVERNAME
$WP_CLI core download --locale=ja --version=$WP_VER --allow-root
if [ -f /tmp/amimoto/centos/wp-setup.php ]; then
  /usr/bin/php /tmp/amimoto/centos/wp-setup.php $SERVERNAME $INSTANCEID
fi

# Performance
plugin_install "nginx-champuru" "$SERVERNAME" > /dev/null 2>&1
plugin_install "wpbooster-cdn-client" "$SERVERNAME" > /dev/null 2>&1
plugin_install "nephila-clavata" "$SERVERNAME" > /dev/null 2>&1

# Developer
plugin_install "debug-bar" "$SERVERNAME" > /dev/null 2>&1
plugin_install "debug-bar-extender" "$SERVERNAME" > /dev/null 2>&1
plugin_install "debug-bar-console" "$SERVERNAME" > /dev/null 2>&1

#Security
plugin_install "crazy-bone" "$SERVERNAME" > /dev/null 2>&1
plugin_install "login-lockdown" "$SERVERNAME" > /dev/null 2>&1
plugin_install "google-authenticator" "$SERVERNAME" > /dev/null 2>&1

#Other
plugin_install "nginx-mobile-theme" "$SERVERNAME" > /dev/null 2>&1
plugin_install "flamingo" "$SERVERNAME" > /dev/null 2>&1
plugin_install "contact-form-7" "$SERVERNAME" > /dev/null 2>&1
plugin_install "simple-ga-ranking" "$SERVERNAME" > /dev/null 2>&1

MU_PLUGINS="/var/www/vhosts/${SERVERNAME}/wp-content/mu-plugins"
if [ ! -d ${MU_PLUGINS} ]; then
  /bin/mkdir -p ${MU_PLUGINS}
fi
cp $SRC_DIR/mu-plugins/mu-plugins.php $MU_PLUGINS

echo "... WordPress installed"

if [ ! -d /var/tmp/php ]; then
  mkdir -p /var/tmp/php
fi
if [ ! -d /var/lib/php ]; then
  mkdir -p /var/lib/php
fi

/bin/chown -R nginx:nginx /var/log/nginx
/bin/chown -R nginx:nginx /var/log/php-fpm
/bin/chown -R nginx:nginx /var/cache/nginx
/bin/chown -R nginx:nginx /var/tmp/php
/bin/chown -R nginx:nginx /var/lib/php
/bin/chown -R nginx:nginx /var/www/vhosts/$SERVERNAME

PHP_MY_ADMIN_VER="4.3.3"
PHP_MY_ADMIN="phpMyAdmin-${PHP_MY_ADMIN_VER}-all-languages"
if [ ! -d /usr/share/${PHP_MY_ADMIN} ]; then
  cd /usr/share/
  /usr/bin/wget http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/${PHP_MY_ADMIN_VER}/${PHP_MY_ADMIN}.zip
  /usr/bin/unzip /usr/share/${PHP_MY_ADMIN}.zip
  /bin/rm /usr/share/${PHP_MY_ADMIN}.zip
  if [ -e /usr/share/phpMyAdmin ]; then
    rm -r /usr/share/phpMyAdmin
  fi
  /bin/ln -s /usr/share/${PHP_MY_ADMIN} /usr/share/phpMyAdmin
fi
