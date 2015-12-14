<?php
/*
Plugin Name: CloudFront Host Fix
Plugin URI:
Description: Fix CloudFront & Nginx Reverse Proxy Cache Problems.
Version: 0.1
Author:hideokamoto
Author URI:
*/
add_action('redirect_canonical', 'change_requested_url');
function change_requested_url($redirect_url, $requested_url) {
	$redirect_url = is_ssl() ? 'https://' : 'http://';
	$redirect_url .= $_SERVER['HTTP_HOST'];
	$redirect_url .= $_SERVER['REQUEST_URI'];
	return $redirect_url;
}
