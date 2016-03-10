<?php
/*
Plugin Name: AMIMOTO with WooCommerce Utilities
Version: 0.0.1
Plugin URI:https://github.com/megumiteam/amimoto-utilities
Description:This is simple plugin
Author: hideokamoto
Author URI: http://wp-kyoto.net/
Text Domain: amimoto-woo-utilities
*/

// Force Activation
add_filter( 'amimoto_just_do_it', 'amimoto_woo_cfn_simple_stack' ) ;
function amimoto_woo_cfn_simple_stack( $must_plugins ) {
	$must_plugins['WooCommerce'] = 'woocommerce/woocommerce.php';
	return $must_plugins;
}
