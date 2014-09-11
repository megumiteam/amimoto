#!/bin/sh
function plugin_install(){
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

WP_VER=4.0

SERVERNAME=$1
INSTANCEID=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id`
#PUBLICNAME=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/public-hostname`
AZ=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone/`

if [ "$AZ" = "eu-west-1a" -o "$AZ" = "eu-west-1b" -o "$AZ" = "eu-west-1c" ]; then
  REGION=eu-west-1
  TZ=WET
elif [ "$AZ" = "sa-east-1a" -o "$AZ" = "sa-east-1b" ]; then
  REGION=sa-east-1
  TZ="America\/Sao_Paulo"
elif [ "$AZ" = "us-east-1a" -o "$AZ" = "us-east-1b" -o "$AZ" = "us-east-1c" -o "$AZ" = "us-east-1d" -o "$AZ" = "us-east-1e" ]; then
  REGION=us-east-1
  TZ="US\/Eastern"
elif [ "$AZ" = "ap-northeast-1a" -o "$AZ" = "ap-northeast-1b" -o "$AZ" = "ap-northeast-1c" ]; then
  REGION=ap-northeast-1
  TZ="Asia\/Tokyo"
elif [ "$AZ" = "us-west-2a" -o "$AZ" = "us-west-2b" -o "$AZ" = "us-west-2c" ]; then
  REGION=us-west-2
  TZ="US\/Pacific"
elif [ "$AZ" = "us-west-1a" -o "$AZ" = "us-west-1b" -o "$AZ" = "us-west-1c" ]; then
  REGION=us-west-1
  TZ="US\/Pacific"
elif [ "$AZ" = "ap-southeast-1a" -o "$AZ" = "ap-southeast-1b" ]; then
  REGION=ap-southeast-1
  TZ="Asia\/Singapore"
else
  REGION=unknown
  TZ="UTC"
fi

cd /tmp/

if [ "$SERVERNAME" = "$INSTANCEID" -a "$REGION" = "eu-west-1" ]; then
  /bin/mv /etc/localtime /etc/localtime.bak
  /bin/ln -s /usr/share/zoneinfo/WET /etc/localtime
  /bin/cp /tmp/amimoto/etc/motd /etc/motd
  /bin/cat /etc/system-release >> /etc/motd
  /bin/cat /tmp/amimoto/etc/motd.en >> /etc/motd
  /bin/cp /tmp/amimoto/etc/sysconfig/i18n /etc/sysconfig/i18n
elif [ "$SERVERNAME" = "$INSTANCEID" -a "$REGION" = "sa-east-1" ]; then
  /bin/mv /etc/localtime /etc/localtime.bak
  /bin/ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
  /bin/cp /tmp/amimoto/etc/motd /etc/motd
  /bin/cat /etc/system-release >> /etc/motd
  /bin/cat /tmp/amimoto/etc/motd.en >> /etc/motd
  /bin/cp /tmp/amimoto/etc/sysconfig/i18n /etc/sysconfig/i18n
elif [ "$SERVERNAME" = "$INSTANCEID" -a "$REGION" = "us-east-1" ]; then
  /bin/mv /etc/localtime /etc/localtime.bak
  /bin/ln -s /usr/share/zoneinfo/US/Eastern /etc/localtime
  /bin/cp /tmp/amimoto/etc/motd /etc/motd
  /bin/cat /etc/system-release >> /etc/motd
  /bin/cat /tmp/amimoto/etc/motd.en >> /etc/motd
  /bin/cp /tmp/amimoto/etc/sysconfig/i18n /etc/sysconfig/i18n
elif [ "$SERVERNAME" = "$INSTANCEID" -a "$REGION" = "ap-northeast-1" ]; then
  /bin/mv /etc/localtime /etc/localtime.bak
  /bin/ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
  /bin/cp /tmp/amimoto/etc/motd /etc/motd
  /bin/cat /etc/system-release >> /etc/motd
  /bin/cat /tmp/amimoto/etc/motd.jp >> /etc/motd
  /bin/cp /tmp/amimoto/etc/sysconfig/i18n.jp /etc/sysconfig/i18n
elif [ "$SERVERNAME" = "$INSTANCEID" -a "$REGION" = "us-west-2" ]; then
  /bin/mv /etc/localtime /etc/localtime.bak
  /bin/ln -s /usr/share/zoneinfo/US/Pacific /etc/localtime
  /bin/cp /tmp/amimoto/etc/motd /etc/motd
  /bin/cat /etc/system-release >> /etc/motd
  /bin/cat /tmp/amimoto/etc/motd.en >> /etc/motd
  /bin/cp /tmp/amimoto/etc/sysconfig/i18n /etc/sysconfig/i18n
elif [ "$SERVERNAME" = "$INSTANCEID" -a "$REGION" = "us-west-1" ]; then
  /bin/mv /etc/localtime /etc/localtime.bak
  /bin/ln -s /usr/share/zoneinfo/US/Pacific /etc/localtime
  /bin/cp /tmp/amimoto/etc/motd /etc/motd
  /bin/cat /etc/system-release >> /etc/motd
  /bin/cat /tmp/amimoto/etc/motd.en >> /etc/motd
  /bin/cp /tmp/amimoto/etc/sysconfig/i18n /etc/sysconfig/i18n
elif [ "$SERVERNAME" = "$INSTANCEID" -a "$REGION" = "ap-southeast-1" ]; then
  /bin/mv /etc/localtime /etc/localtime.bak
  /bin/ln -s /usr/share/zoneinfo/Asia/Singapore /etc/localtime
  /bin/cp /tmp/amimoto/etc/motd /etc/motd
  /bin/cat /etc/system-release >> /etc/motd
  /bin/cat /tmp/amimoto/etc/motd.en >> /etc/motd
  /bin/cp /tmp/amimoto/etc/sysconfig/i18n /etc/sysconfig/i18n
elif [ "$SERVERNAME" = "$INSTANCEID" ]; then
  /bin/mv /etc/localtime /etc/localtime.bak
  /bin/ln -s /usr/share/zoneinfo/UTC /etc/localtime
  /bin/cp /tmp/amimoto/etc/motd /etc/motd
  /bin/cat /etc/system-release >> /etc/motd
  /bin/cat /tmp/amimoto/etc/motd.en >> /etc/motd
  /bin/cp /tmp/amimoto/etc/sysconfig/i18n /etc/sysconfig/i18n
fi

if [ "$SERVERNAME" = "$INSTANCEID" ]; then
  /bin/cp /dev/null /root/.bash_history > /dev/null 2>&1; history -c
  echo '# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:/usr/local/bin:$HOME/bin:$HOME/.wp-cli/bin

export PATH' > $HOME/.bash_profile
  /usr/bin/yes | /usr/bin/crontab -r
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
  sed -e "s/\date\.timezone = \"UTC\"/date\.timezone = \"$TZ\"/" /tmp/amimoto/etc/php.ini > /etc/php.ini
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
if [ "$REGION" = "ap-northeast-1" ]; then
  $WP_CLI core download --locale=ja --version=$WP_VER --allow-root
else
  $WP_CLI core download --version=$WP_VER --allow-root
fi
if [ -f /tmp/amimoto/wp-setup.php ]; then
  /usr/bin/php /tmp/amimoto/wp-setup.php $SERVERNAME $INSTANCEID $PUBLICNAME
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
if [ -f /tmp/amimoto/mu-plugins.php ]; then
  /bin/cp /tmp/amimoto/mu-plugins.php $MU_PLUGINS
else
  cd $MU_PLUGINS
  /usr/bin/wget https://raw.github.com/megumiteam/amimoto/master/mu-plugins.php
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
