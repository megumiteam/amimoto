<?php
$cloud_formation_json   = '/opt/aws/cloud_formation.json';
$nginx_proxy_cache_path = '/var/cache/nginx/proxy_cache';

$mysql_db = $mysql_user = $mysql_pwd = $public_name = $instance_id = $site_name = "";
switch($argc) {
    case 1:
        echo "please input site name!\n";
        exit();
    default:
        $public_name = isset($argv[3]) ? $argv[3] : '';
        $instance_id = isset($argv[2]) ? $argv[2] : '';
        $site_name   = $argv[1];
}
$mysql_db   = $site_name !== 'default' ? str_replace(array('.','-'), '_', $site_name) : 'wordpress';
$mysql_user = empty($mysql_user) ? substr('wp_'.md5($mysql_db),0,16) : $mysql_user;
$mysql_pwd  = empty($mysql_pwd)  ? md5(mt_rand().date("YmdHisu"))    : $mysql_pwd;
$mysql_host = 'localhost';

// make user and database
$link = @mysql_connect('localhost:3307', 'root', '');
if ( $link ) {
	if ( !mysql_select_db('mysql', $link) )
	    die('MySQL select DB error!!: '.mysql_error());
	if ( !mysql_query("create database {$mysql_db} default character set utf8 collate utf8_general_ci;") )
	    die('MySQL create database error!!: '.mysql_error());
	if ( !mysql_query("grant all privileges on {$mysql_db}.* to {$mysql_user}@localhost identified by '{$mysql_pwd}';") )
	    die('MySQL create user error!!: '.mysql_error());
	mysql_close($link);
}

// make wp-config.php
$wp_cfg = <<<EOT
<?php
/**
 * The base configurations of the WordPress.
 *
 * This file has the following configurations: MySQL settings, Table Prefix,
 * Secret Keys, WordPress Language, and ABSPATH. You can find more information
 * by visiting {@link http://codex.wordpress.org/Editing_wp-config.php Editing
 * wp-config.php} Codex page. You can get the MySQL settings from your web host.
 *
 * This file is used by the wp-config.php creation script during the
 * installation. You don't have to use the web site, you can just copy this file
 * to "wp-config.php" and fill in the values.
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
\$db_data = false;
if ( file_exists('$cloud_formation_json') ) {
	\$db_data = json_decode(file_get_contents('$cloud_formation_json'), true);
	if ( isset(\$db_data['rds']) ) {
		\$db_data = \$db_data['rds'];
		\$db_data['host'] = \$db_data['endpoint'] . ':' . \$db_data['port'];
	}
}
if ( !\$db_data ) {
	\$db_data = array(
		'database' => '%DB_NAME%',
		'username' => '%DB_USER%',
		'password' => '%DB_PASSWORD%',
		'host'     => '%DB_HOST%',
	);
}

/** The name of the database for WordPress */
define('DB_NAME', \$db_data['database']);

/** MySQL database username */
define('DB_USER', \$db_data['username']);

/** MySQL database password */
define('DB_PASSWORD', \$db_data['password']);

/** MySQL hostname */
define('DB_HOST', \$db_data['host']);

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

unset(\$db_data);

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         '%AUTH_KEY%');
define('SECURE_AUTH_KEY',  '%SECURE_AUTH_KEY%');
define('LOGGED_IN_KEY',    '%LOGGED_IN_KEY%');
define('NONCE_KEY',        '%NONCE_KEY%');
define('AUTH_SALT',        '%AUTH_SALT%');
define('SECURE_AUTH_SALT', '%SECURE_AUTH_SALT%');
define('LOGGED_IN_SALT',   '%LOGGED_IN_SALT%');
define('NONCE_SALT',       '%NONCE_SALT%');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each a unique
 * prefix. Only numbers, letters, and underscores please!
 */
\$table_prefix  = 'wp_';

/**
 * WordPress Localized Language, defaults to English.
 *
 * Change this to localize WordPress. A corresponding MO file for the chosen
 * language must be installed to wp-content/languages. For example, install
 * de_DE.mo to wp-content/languages and set WPLANG to 'de_DE' to enable German
 * language support.
 */
define('WPLANG', '%WPLANG%');

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 */
define('WP_DEBUG', false);
//define('WP_DEBUG', true);
//define('SAVEQUERIES', true);
//define('WP_DEBUG_DISPLAY', false);

/**
 * Multisite Settings
 */
// define ('WP_ALLOW_MULTISITE', true);
//
// define('MULTISITE', true);
// define('SUBDOMAIN_INSTALL', false);
// define('DOMAIN_CURRENT_SITE', 'example.com');
// define('PATH_CURRENT_SITE', '/');
// define('SITE_ID_CURRENT_SITE', 1);
// define('BLOG_ID_CURRENT_SITE', 1);

/**
 * For VaultPress
 */
define( 'VAULTPRESS_DISABLE_FIREWALL', true );
if ( !empty( \$_SERVER['HTTP_X_FORWARDED_FOR'] ) ) {
   \$forwarded_ips = explode( ',', \$_SERVER['HTTP_X_FORWARDED_FOR'] );
   \$_SERVER['REMOTE_ADDR'] = \$forwarded_ips[0];
   unset( \$forwarded_ips );
}

/**
 * For Nginx Cache Controller
 */
define('IS_AMIMOTO', true);
define('NCC_CACHE_DIR', '$nginx_proxy_cache_path');

/**
 * set post revisions
 */
//define('WP_POST_REVISIONS', 5);

/**
 * disallow file edit and modifie
 */
//define('DISALLOW_FILE_MODS',true);
//define('DISALLOW_FILE_EDIT',true);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
EOT;

$wp_cfg = str_replace('%DB_NAME%',     $mysql_db,   $wp_cfg);
$wp_cfg = str_replace('%DB_USER%',     $mysql_user, $wp_cfg);
$wp_cfg = str_replace('%DB_PASSWORD%', $mysql_pwd,  $wp_cfg);
$wp_cfg = str_replace('%DB_HOST%',     $mysql_host, $wp_cfg);

$salts  = preg_split('/[\r\n]+/ms', file_get_contents('https://api.wordpress.org/secret-key/1.1/salt/'));
foreach ( $salts as $salt ) {
    if ( preg_match('/define\([\s]*[\'"](AUTH_KEY|SECURE_AUTH_KEY|LOGGED_IN_KEY|NONCE_KEY|AUTH_SALT|SECURE_AUTH_SALT|LOGGED_IN_SALT|NONCE_SALT)[\'"][\s]*,[\s]*[\'"]([^\'"]*)[\'"][\s]*\);/i', $salt, $matches) ) {
        $wp_cfg = preg_replace(
            '/define\([\'"]'.preg_quote($matches[1],'/').'[\'"],[\s]*[\'"][^\'"]*[\'"]\);/i',
            str_replace('$','\$',$matches[0]),
            $wp_cfg);
    }
    unset($matches);
}

if ( $instance_id === $site_name && !empty($public_name) ) {
    $wp_cfg = preg_replace(
        '/(table_prefix[\s]*\=[\s]*[\'"][^\'"]*[\'"];)/i',
        '$1'."\n\n".sprintf("//define('WP_SITEURL','http://%1\$s');\n//define('WP_HOME','http://%1\$s');", $public_name),
        $wp_cfg);
}

$language = file_exists("/var/www/vhosts/{$site_name}/readme-ja.html") ? 'ja' : '';
$wp_cfg = str_replace('%WPLANG%', $language, $wp_cfg);

$wp_cfg = str_replace("\r\n", "\n", $wp_cfg);

file_put_contents("/var/www/vhosts/{$site_name}/wp-config.php", $wp_cfg);

$ngx_champuru = "/var/www/vhosts/{$site_name}/wp-content/plugins/nginx-champuru/nginx-champuru.php";
if ( file_exists($ngx_champuru) ) {
    $ngx_champuru_php = str_replace('"/var/cache/nginx"','"/var/cache/nginx/proxy_cache"', file_get_contents($ngx_champuru));
    file_put_contents($ngx_champuru, $ngx_champuru_php);
}

echo "\n--------------------------------------------------\n";
echo " MySQL DataBase: {$mysql_db}\n";
echo " MySQL User:     {$mysql_user}\n";
echo " MySQL Password: {$mysql_pwd}\n";
echo "--------------------------------------------------\n";

if ( $instance_id !== $site_name ) {
	echo "\n";
	printf ("Success!! http://%s/\n", $site_name);
	echo "--------------------------------------------------\n";
}
