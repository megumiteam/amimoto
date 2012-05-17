#!/usr/bin/php
<?php
$mysql_db = "";
switch($argc) {
    case 1:
        echo "please input site name!\n";
        exit();
    case 2:
    default:
        $mysql_db = $argv[1];
}
$mysql_db   = str_replace(array('.','_'), '_', $mysql_db);
$mysql_user = $mysql_db;
$mysql_pwd  = md5(mt_rand().date("YmdHisu"));

// make user and database
$link = mysql_connect('localhost:3307', 'root', '');
if ( !$link ) {
    die('MySQL connect error!!: '.mysql_error());
}
$db_selected = mysql_select_db('mysql', $link);
if ( !$db_selected ) {
    die('MySQL select DB error!!: '.mysql_error());
}
        
mysql_query("create database {$mysql_db} default character set utf8 collate utf8_general_ci;");
mysql_query("grant all privileges on {$mysql_db}.* to {$mysql_user}@localhost identified by '{$mysql_pwd}';");

mysql_close($link);

// make wp-config.php
$wp_cfg = "/var/www/vhosts/{$site_name}/wp-config-sample.php";
if ( file_exists($wp_cfg) ) {
    $wp_cfg = file_get_contents($wp_cfg);
} else {
    $wp_cfg = <<<EOT
<?php
define('DB_NAME', 'database_name_here');
define('DB_USER', 'username_here');
define('DB_PASSWORD', 'password_here');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');
\$table_prefix  = 'wp_';
define('WPLANG', 'ja');
define('WP_DEBUG', false);
if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');
EOT;

$wp_cfg = preg_replace('/define\([\'"]DB_NAME[\'"],[\s]*[\'"][^\'"]*[\'"]\);/i', "define('DB_NAME', '{$mysql_db}');", $wp_cfg);
$wp_cfg = preg_replace('/define\([\'"]DB_USER[\'"],[\s]*[\'"][^\'"]*[\'"]\);/i', "define('DB_USER', '{$mysql_user}');", $wp_cfg);
$wp_cfg = preg_replace('/define\([\'"]DB_PASSWORD[\'"],[\s]*[\'"][^\'"]*[\'"]\);/i', "define('DB_PASSWORD', '{$mysql_pwd}');", $wp_cfg);

$salts  = preg_split('/[\r\n]+/ms', file_get_contents('https://api.wordpress.org/secret-key/1.1/salt/'));
foreach ( $salts as $salt ) {
    if ( preg_match('/define\([\'"](AUTH_KEY|SECURE_AUTH_KEY|LOGGED_IN_KEY|NONCE_KEY|AUTH_SALT|SECURE_AUTH_SALT|LOGGED_IN_SALT|NONCE_SALT)[\'"],[\s]*[\'"]([^\'"]*)[\'"]\);/i', $salt, $matches) ) {
        $wp_cfg = preg_replace('/define\([\'"]'.preg_quote($matches[1],'/').'[\'"],[\s]*[\'"][^\'"]*[\'"]\);/i', "define('{$matches[1]}', '{$matches[2]}');", $wp_cfg);
    }
    unset($matches);
}
file_put_contents("/var/www/vhosts/{$site_name}/wp-config.php", $wp_cfg);


echo "\n--------------------------------------------------\n";
echo " MySQL DataBase: {$mysql_db}\n";
echo " MySQL User:     {$mysql_user}\n";
echo " MySQL Password: {$mysql_pwd}\n";
echo "--------------------------------------------------\n";

echo "\n";
echo "Success!! http://{$site_name}/\n";
echo "--------------------------------------------------\n";
