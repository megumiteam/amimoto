#!/bin/sh
function plugin_install(){
  cd /tmp
  /usr/bin/wget http://downloads.wordpress.org/plugin/$1
  /usr/bin/unzip /tmp/$1 -d /var/www/vhosts/$2/wp-content/plugins/
  /bin/rm /tmp/$1
}

if [ ! -d /etc/chef/ohai/hints ]; then
  mkdir -p /etc/chef/ohai/hints
fi
if [ ! -f /etc/chef/ohai/hints/ec2.json ]; then
  echo '{}' > /etc/chef/ohai/hints/ec2.json
fi

INSTANCEID=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id`
AZ=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone/`
SERVERNAME=$INSTANCEID

/sbin/service mysql stop
/bin/cp /dev/null /root/.bash_history > /dev/null 2>&1; history -c
/bin/cp /dev/null /home/ec2-user/.bash_history > /dev/null 2>&1
/usr/bin/yes | /usr/bin/crontab -r

if [ ! -d /var/www/vhosts/${INSTANCEID} ]; then
  /bin/mkdir -p /var/www/vhosts/${INSTANCEID}
fi
echo '<html>
<head>
<title>Setting up your WordPress now.</title>
</head>
 <body>
<p>Setting up your WordPress now.</p>
<p>After a while please reload your web browser.</p>
</body>' > /var/www/vhosts/${INSTANCEID}/index.html

cd /tmp
/usr/bin/git clone git://github.com/opscode/chef-repo.git
cd /tmp/chef-repo/cookbooks
/usr/bin/git clone git://github.com/megumiteam/chef-amimoto.git amimoto
cd /tmp/chef-repo/
echo '{ "run_list" : [ "recipe[amimoto]" ] }' > /tmp/chef-repo/amimoto.json
echo 'file_cache_path "/tmp/chef-solo"
cookbook_path ["/tmp/chef-repo/cookbooks"]' > /tmp/chef-repo/solo.rb
/usr/bin/chef-solo -c /tmp/chef-repo/solo.rb -j /tmp/chef-repo/amimoto.json
CF_PATTERN=`/usr/bin/curl -s https://raw.github.com/megumiteam/amimoto/master/cf_patern_check.php | /usr/bin/php`
if [ "$CF_PATTERN" = "nfs_server" ]; then
  /usr/bin/chef-solo -o amimoto::nfs_dispatcher -c /tmp/chef-repo/solo.rb -j /tmp/chef-repo/amimoto.json
fi
if [ "$CF_PATTERN" = "nfs_client" ]; then
  /usr/bin/chef-solo -o amimoto::nfs_dispatcher -c /tmp/chef-repo/solo.rb -j /tmp/chef-repo/amimoto.json
  if [ -d /var/www/vhosts/${INSTANCEID} ]; then
    /binrm -rf /var/www/vhosts/${INSTANCEID}
  fi
fi
/bin/rm -rf /tmp/chef-repo/

cd /tmp
/usr/bin/git clone git://github.com/megumiteam/amimoto.git

if [ "$AZ" = "eu-west-1a" -o "$AZ" = "eu-west-1b" -o "$AZ" = "eu-west-1c" ]; then
  REGION=eu-west-1
elif [ "$AZ" = "sa-east-1a" -o "$AZ" = "sa-east-1b" ]; then
  REGION=sa-east-1
elif [ "$AZ" = "us-east-1a" -o "$AZ" = "us-east-1b" -o "$AZ" = "us-east-1c" -o "$AZ" = "us-east-1d" -o "$AZ" = "us-east-1e" ]; then
  REGION=us-east-1
elif [ "$AZ" = "ap-northeast-1a" -o "$AZ" = "ap-northeast-1b" -o "$AZ" = "ap-northeast-1c" ]; then
  REGION=ap-northeast-1
elif [ "$AZ" = "us-west-2a" -o "$AZ" = "us-west-2b" -o "$AZ" = "us-west-2c" ]; then
  REGION=us-west-2
elif [ "$AZ" = "us-west-1a" -o "$AZ" = "us-west-1b" -o "$AZ" = "us-west-1c" ]; then
  REGION=us-west-1
elif [ "$AZ" = "ap-southeast-1a" -o "$AZ" = "ap-southeast-1b" ]; then
  REGION=ap-southeast-1
else
  REGION=unknown
fi

cd /tmp/

if [ "$REGION" = "ap-northeast-1" ]; then
  /bin/cp /tmp/amimoto/etc/motd /etc/motd
  /bin/cat /etc/system-release >> /etc/motd
  /bin/cat /tmp/amimoto/etc/motd.jp >> /etc/motd
else
  /bin/cp /tmp/amimoto/etc/motd /etc/motd
  /bin/cat /etc/system-release >> /etc/motd
  /bin/cat /tmp/amimoto/etc/motd.en >> /etc/motd
fi

/sbin/service nginx stop
/bin/rm -Rf /var/log/nginx/*
/bin/rm -Rf /var/cache/nginx/*
/sbin/service nginx start

/sbin/service php-fpm stop
/bin/rm -Rf /var/log/php-fpm/*
/sbin/service php-fpm start

/sbin/service mysql stop
/bin/rm /var/lib/mysql/ib_logfile*
/bin/rm /var/log/mysqld.log*
/sbin/service mysql start

if [ "$CF_PATTERN" != "nfs_client" ]; then
  echo "WordPress install ..."
  if [ ! -d /var/www/vhosts/$SERVERNAME ]; then
    mkdir /var/www/vhosts/$SERVERNAME
  fi
  cd /var/www/vhosts/$SERVERNAME
  if [ "$REGION" = "ap-northeast-1" ]; then
    /usr/bin/wp core download --locale=ja
  else
    /usr/bin/wp core download
  fi
  if [ -f /tmp/amimoto/wp-setup.php ]; then
    /usr/bin/php /tmp/amimoto/wp-setup.php $SERVERNAME $INSTANCEID $PUBLICNAME
  fi
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
  echo "... WordPress installed"

  /bin/rm /var/www/vhosts/${INSTANCEID}/index.html
  /bin/chown -R nginx:nginx /var/cache/nginx
  /bin/chown -R nginx:nginx /var/www/vhosts/$SERVERNAME
fi

/bin/chown -R nginx:nginx /var/log/nginx
/bin/chown -R nginx:nginx /var/log/php-fpm
/bin/chown -R nginx:nginx /var/tmp/php
/bin/chown -R nginx:nginx /var/lib/php

PHP_MY_ADMIN_VER="4.0.9"
PHP_MY_ADMIN="phpMyAdmin-${PHP_MY_ADMIN_VER}-all-languages"
if [ ! -d /usr/share/phpMyAdmin/${PHP_MY_ADMIN} ]; then
  cd /usr/share/
  /usr/bin/wget http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/${PHP_MY_ADMIN_VER}/${PHP_MY_ADMIN}.zip
  /usr/bin/unzip /usr/share/${PHP_MY_ADMIN}.zip
  /bin/rm /usr/share/${PHP_MY_ADMIN}.zip
  /bin/ln -s /usr/share/${PHP_MY_ADMIN} /usr/share/phpMyAdmin
fi

/bin/rm -rf /tmp/amimoto
