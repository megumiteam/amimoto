#!/bin/sh
function plugin_install(){
  cd /tmp
  /usr/bin/wget http://downloads.wordpress.org/plugin/$1
  /usr/bin/unzip /tmp/$1 -d /var/www/vhosts/$2/wp-content/plugins/
  /bin/rm /tmp/$1
}

WP_VER=3.8.1

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
  /usr/bin/curl -L https://raw.github.com/wp-cli/wp-cli.github.com/master/installer.sh | /bin/bash
  WP_CLI=$HOME/.wp-cli/bin/wp
fi
if [ ! -d /var/www/vhosts/$SERVERNAME ]; then
  mkdir -p /var/www/vhosts/$SERVERNAME
fi
cd /var/www/vhosts/$SERVERNAME
if [ "$REGION" = "ap-northeast-1" ]; then
  $WP_CLI core download --locale=ja --version=$WP_VER
else
  $WP_CLI core download --version=$WP_VER
fi
if [ -f /tmp/amimoto/wp-setup.php ]; then
  /usr/bin/php /tmp/amimoto/wp-setup.php $SERVERNAME $INSTANCEID $PUBLICNAME
fi
/bin/chown -R nginx:nginx /var/log/nginx
plugin_install "nginx-champuru.zip" "$SERVERNAME" > /dev/null 2>&1
plugin_install "wpbooster-cdn-client.zip" "$SERVERNAME" > /dev/null 2>&1
plugin_install "wp-remote-manager-client.zip" "$SERVERNAME" > /dev/null 2>&1
plugin_install "head-cleaner.zip" "$SERVERNAME" > /dev/null 2>&1
plugin_install "wp-total-hacks.zip" "$SERVERNAME" > /dev/null 2>&1
plugin_install "flamingo.zip" "$SERVERNAME" > /dev/null 2>&1
plugin_install "contact-form-7.zip" "$SERVERNAME" > /dev/null 2>&1
plugin_install "nephila-clavata.zip" "$SERVERNAME" > /dev/null 2>&1
plugin_install "jetpack.zip" "$SERVERNAME" > /dev/null 2>&1
plugin_install "hotfix.zip" "$SERVERNAME" > /dev/null 2>&1

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
