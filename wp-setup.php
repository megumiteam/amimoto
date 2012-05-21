<?php
$mysql_db = $mysql_user = $mysql_pwd = $public_name = $instance_id = $site_name = "";
switch($argc) {
    case 1:
        echo "please input site name!\n";
        exit();
    default:
        $mysql_pwd   = isset($argv[5]) ? $argv[5] : '';
        $mysql_user  = isset($argv[4]) ? $argv[4] : '';
        $public_name = isset($argv[3]) ? $argv[3] : '';
        $instance_id = isset($argv[2]) ? $argv[2] : '';
        $site_name   = $argv[1];
}
$mysql_db   = str_replace(array('.','-'), '_', $site_name);
$mysql_user = empty($mysql_user) ? substr('wp_'.md5($mysql_db),0,16) : $mysql_user;
$mysql_pwd  = empty($mysql_pwd)  ? md5(mt_rand().date("YmdHisu"))    : $mysql_pwd;

// make user and database
$link = mysql_connect('localhost:3307', 'root', '');
if ( !$link )
    die('MySQL connect error!!: '.mysql_error());
if ( !mysql_select_db('mysql', $link) )
    die('MySQL select DB error!!: '.mysql_error());
if ( !mysql_query("create database {$mysql_db} default character set utf8 collate utf8_general_ci;") )
    die('MySQL create database error!!: '.mysql_error());
if ( !mysql_query("grant all privileges on {$mysql_db}.* to {$mysql_user}@localhost identified by '{$mysql_pwd}';") )
    die('MySQL create user error!!: '.mysql_error());
    
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
}

$wp_cfg = preg_replace('/define\([\s]*[\'"]DB_NAME[\'"][\s]*,[\s]*[\'"][^\'"]*[\'"][\s]*\)/i', "define('DB_NAME', '{$mysql_db}')", $wp_cfg);
$wp_cfg = preg_replace('/define\([\s]*[\'"]DB_USER[\'"][\s]*,[\s]*[\'"][^\'"]*[\'"][\s]*\)/i', "define('DB_USER', '{$mysql_user}')", $wp_cfg);
$wp_cfg = preg_replace('/define\([\s]*[\'"]DB_PASSWORD[\'"][\s]*,[\s]*[\'"][^\'"]*[\'"][\s]*\)/i', "define('DB_PASSWORD', '{$mysql_pwd}')", $wp_cfg);

$salts  = preg_split('/[\r\n]+/ms', file_get_contents('https://api.wordpress.org/secret-key/1.1/salt/'));
foreach ( $salts as $salt ) {
    if ( preg_match('/define\([\s]*[\'"](AUTH_KEY|SECURE_AUTH_KEY|LOGGED_IN_KEY|NONCE_KEY|AUTH_SALT|SECURE_AUTH_SALT|LOGGED_IN_SALT|NONCE_SALT)[\'"][\s]*,[\s]*[\'"]([^\'"]*)[\'"][\s]*\)/i', $salt, $matches) ) {
        $wp_cfg = preg_replace(
            '/define\([\'"]'.preg_quote($matches[1],'/').'[\'"],[\s]*[\'"][^\'"]*[\'"]\);/i',
            "define('{$matches[1]}', '{$matches[2]}');",
            $wp_cfg);
    }
    unset($matches);
}

if ( $instance_id === $site_name ) {
    $wp_cfg = preg_replace(
        '/(table_prefix[\s]*\=[\s]*[\'"][^\'"]*[\'"];)/i',
        '$1'."\n\n".sprintf("//define('WP_SITEURL','http://%1\$s');\n//define('WP_HOME','http://%1\$s');", $public_name),
        $wp_cfg);
}

$wp_cfg = str_replace("\r\n", "\n", $wp_cfg);

file_put_contents("/var/www/vhosts/{$site_name}/wp-config.php", $wp_cfg);

echo "\n--------------------------------------------------\n";
echo " MySQL DataBase: {$mysql_db}\n";
echo " MySQL User:     {$mysql_user}\n";
echo " MySQL Password: {$mysql_pwd}\n";
echo "--------------------------------------------------\n";

echo "\n";
printf ("Success!! http://%s/\n", $instance_id === $site_name ? $public_name : $site_name);
echo "--------------------------------------------------\n";
