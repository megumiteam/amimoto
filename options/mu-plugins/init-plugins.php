<?php
/*
Plugin Name: Jinkei Just do it.
Version: 0.0.1
Plugin URI:https://github.com/megumiteam/
Description:Just do it
Author: digitalcube
Author URI: https://github.com/megumiteam/
*/

add_action('init', function(){
	new jinkei_just_do_it();
});

class jinkei_just_do_it {

	function __construct() {
		if (!is_user_logged_in())
			return;

		add_action('shutdown', array($this, 'setup_jinkei'));
	}

	public function setup_jinkei() {
		$db_data = false;
		if ( file_exists('/opt/aws/cloud_formation.json') ) {
			$db_data = json_decode(file_get_contents('/opt/aws/cloud_formation.json'), true);
		}
		if ( $db_data ) {
			if ( isset( $db_data['s3_conf'] ) ) {
				$nephila_clavata = new nephila_clavata();
				$nephila_clavata->setup( $db_data['s3_conf'] );
			}
		}

		@unlink(__FILE__);
	}
}


class nephila_clavata {
	const OPTION_KEY  = 'nephila_clavata';

	public function setup( $s3_conf ) {
		$params = array(
			'region' => $s3_conf['region'],
			'bucket' => $s3_conf['bucket'],
			's3_url' => $s3_conf['url'],
			'storage_class' => $s3_conf['storage'],
		);
		update_option( self::OPTION_KEY, $params );
	}
}
