<?php
add_action('admin_menu', function(){
    if ( 'ja' !== get_locale() )
        return;

/*
	$dismissed = explode(',', get_user_meta( get_current_user_id(), 'dismissed_wp_pointers', true ));
	if(false == array_search('amimoto_pointer', $dismissed)){
		add_action('admin_print_scripts', function(){
			$js = ('ja' === get_locale() ? '/js/amimoto-pointer-ja.js' : '/js/amimoto-pointer.js');
			wp_enqueue_script(
				'amimoto-pointer',
				site_url(str_replace(ABSPATH, '', dirname(__FILE__))).$js,
				array('jquery', 'wp-pointer'),
				1.0);
		});
		add_action('admin_print_styles', function(){
			wp_enqueue_style( 'wp-pointer' );
		});
	}
*/
});
