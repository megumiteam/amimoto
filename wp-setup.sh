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

WP_VER=4.4.1

SERVERNAME=$1
INSTANCEID=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id`
#PUBLICNAME=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/public-hostname`

if [ ! -d /opt/local/amimoto/wp-admin ]; then
  /bin/mkdir -p /opt/local/amimoto/wp-admin
fi
if [ ! -f /opt/local/amimoto/wp-admin/install.php ]; then
  /bin/cp /tmp/amimoto/install.php /opt/local/amimoto/wp-admin
fi
/bin/chown -R nginx:nginx /opt/local/amimoto

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

echo "WordPress install ..."
WP_CLI=/usr/bin/wp
if [ ! -f $WP_CLI ]; then
  WP_CLI=/usr/local/bin/wp
fi
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
$WP_CLI core download --version=$WP_VER --allow-root
if [ -f /tmp/amimoto/wp-setup.php ]; then
  /usr/bin/php /tmp/amimoto/wp-setup.php $SERVERNAME $INSTANCEID $PUBLICNAME
fi

# Performance
plugin_install "nginx-champuru" "$SERVERNAME" > /dev/null 2>&1
#plugin_install "wpbooster-cdn-client" "$SERVERNAME" > /dev/null 2>&1
#plugin_install "nephila-clavata" "$SERVERNAME" > /dev/null 2>&1

# Developer
plugin_install "debug-bar" "$SERVERNAME" > /dev/null 2>&1
plugin_install "debug-bar-extender" "$SERVERNAME" > /dev/null 2>&1
plugin_install "debug-bar-console" "$SERVERNAME" > /dev/null 2>&1

#Security
plugin_install "crazy-bone" "$SERVERNAME" > /dev/null 2>&1
plugin_install "login-lockdown" "$SERVERNAME" > /dev/null 2>&1
plugin_install "rublon" "$SERVERNAME" > /dev/null 2>&1

#Other
plugin_install "nginx-mobile-theme" "$SERVERNAME" > /dev/null 2>&1
plugin_install "flamingo" "$SERVERNAME" > /dev/null 2>&1
plugin_install "contact-form-7" "$SERVERNAME" > /dev/null 2>&1
plugin_install "simple-ga-ranking" "$SERVERNAME" > /dev/null 2>&1

MU_PLUGINS="/var/www/vhosts/${SERVERNAME}/wp-content/mu-plugins"
if [ ! -d ${MU_PLUGINS} ]; then
  /bin/mkdir -p ${MU_PLUGINS}
fi
if [ -d /tmp/amimoto/mu-plugins ]; then
  /bin/cp /tmp/amimoto/mu-plugins/mu-plugins.php $MU_PLUGINS
fi

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
