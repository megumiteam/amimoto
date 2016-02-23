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
add_filter( 'amimoto_just_do_it', 'amimoto_cfn_simple_stack' ) ;
function amimoto_cfn_simple_stack( $must_plugins ) {
	$must_plugins['Nephila clavata'] = 'nephila-clavata/plugin.php';
	$must_plugins['C3 Cloudfront Clear Cache'] = 'c3-cloudfront-clear-cache/c3-cloudfront-clear-cache.php';
	return $must_plugins;
}
