<?php
/*
Plugin Name: AMIMOTO Utilities for AutoScale Stack
Version: 0.0.1
Plugin URI:https://github.com/megumiteam/amimoto-utilities
Description:This is simple plugin for JINKEI AutoScale Stack
Author: DigitalCube
Author URI:
Text Domain: amimoto-woo-utilities
*/

// Thanks to http://www.warna.info/archives/781/
remove_action( 'wp_version_check', 'wp_version_check' );
remove_action( 'admin_init', '_maybe_update_core' );
add_filter( 'pre_site_transient_update_core', '__return_zero' );

//Disallow edit plugin & theme files.
if ( ! defined( 'DISALLOW_FILE_EDIT' ) ) {
	define( 'DISALLOW_FILE_EDIT', true );
}
if ( ! defined( 'DISALLOW_FILE_MODS' ) ) {
	define( 'DISALLOW_FILE_MODS', true );
}
