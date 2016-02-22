<?php
/*
Plugin Name: AMIMOTO Utilities
Version: 0.0.1
Plugin URI:https://github.com/megumiteam/amimoto-utilities
Description:This is simple plugin
Author: hideokamoto
Author URI: http://wp-kyoto.net/
Text Domain: amimoto-utilities
*/

// for CloudFront
add_filter( 'c3_credential',   'amimoto_remove_credentials_for_cloudfront', 11 );
add_filter( 'c3_settings',     'amimoto_remove_credential_for_cloudfront' );
add_filter( 'c3_setting_keys', 'amimoto_remove_credential_for_cloudfront');
add_filter( 'c3_get_setting',  'amimoto_remove_credential_for_cloudfront');

function amimoto_remove_credentials_for_cloudfront( $credentials ) {
  return null;
}

function amimoto_remove_credential_for_cloudfront( $c3_settings ) {
  unset( $c3_settings['access_key'] );
  unset( $c3_settings['secret_key'] );
  return $c3_settings;
}

// for S3
add_filter( 'nephila_clavata_flag_for_ec2', 'amimoto_change_flag_for_s3', 11 );
add_filter( 'nephila_clavata_credential',   'amimoto_remove_credential_for_s3', 11 );
add_filter( 'nephila_clavata_option_keys',  'amimoto_edit_option_keys_for_s3', 11 );
function amimoto_change_flag_for_s3( $flag ) {
	return true;
}
function amimoto_remove_credential_for_s3( $credentials ) {
	unset( $credentials['key'] );
	unset( $credentials['secret'] );
	return $credentials;
}
function amimoto_edit_option_keys_for_s3( $option_keys ) {
	unset( $option_keys['access_key'] );
	unset( $option_keys['secret_key'] );
	return $option_keys;
}


// Force Activation
add_action('init', function(){new just_do_it();});
class just_do_it {
  private $must_plugins = array();

  function __construct() {
    if (!is_user_logged_in())
      return;

      $this->must_plugins['Nephila clavata'] = 'nephila-clavata/plugin.php';
      $this->must_plugins['C3 Cloudfront Clear Cache'] = 'c3-cloudfront-clear-cache/c3-cloudfront-clear-cache.php';
    add_action('shutdown', array($this, 'plugins_loaded'));
  }

  public function plugins_loaded() {
    $activated = false;
    $activePlugins = get_settings('active_plugins');
    foreach ($this->must_plugins as $key => $plugin) {
      if ( !array_search($plugin, $activePlugins) && file_exists(WP_PLUGIN_DIR.'/'.$plugin) ) {
        activate_plugin( $plugin, '', $this->is_multisite() );
        $activated = true;
      }
    }
    if ($activated)
      @unlink(__FILE__);
  }

  private function is_multisite() {
    return function_exists('is_multisite') && is_multisite();
  }
}
