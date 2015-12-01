<?php
/*
Plugin Name: CloudFront Preview Fix
Plugin URI:
Description: WPログイン時にパーマリンクに記事変更日付を含み、プレビューが最新になるようにする
Version: 0.4
Author:
Author URI:
*/
add_action( 'init', function(){
	$cf_fix = cloudfront_preview_fix::get_instance();
	$cf_fix->add_hook();
});
class cloudfront_preview_fix{
	private static $instance;
	private function __construct() {}
	public static function get_instance() {
		if ( ! isset( self::$instance ) ) {
			$c = __CLASS__;
			self::$instance = new $c();
		}
		return self::$instance;
	}
	public function add_hook() {
		add_action( 'template_redirect', array($this, 'template_redirect') );
		add_filter( 'post_link', array($this, 'post_link_fix'), 10, 3 );
		add_filter( 'preview_post_link', array($this, 'preview_post_link_fix'), 10, 2 );
		add_filter( 'sanitize_file_name', array($this,'sanitizeFileName') );
	}
	public function template_redirect() {
		if ( is_user_logged_in() ) {
			nocache_headers();
		}
	}
	public function post_link_fix( $permalink, $post, $leavename ){
		if ( !is_user_logged_in() || !is_admin() ) {
			return $permalink;
		}
		$post = get_post( $post );
		$post_time =
			isset($post->post_modified)
			? date('YmdHis', strtotime($post->post_modified))
			: current_time('YmdHis');
		$permalink = add_query_arg( 'post_date', $post_time, $permalink );
		return $permalink;
	}
	public function preview_post_link_fix( $permalink, $post ){
		$post = get_post( $post );
		$preview_time = current_time('YmdHis');
		$permalink = add_query_arg( 'preview_time', $preview_time, $permalink );
		return $permalink;
	}
	public function sanitizeFileName( $filename ){
		$info = pathinfo($filename);
		$ext  = empty($info['extension']) ? '' : '.' . $info['extension'];
		$name = basename($filename, $ext);
		$finalFileName = $name.'-'.current_time('YmdHis');
		return $finalFileName.$ext;
	}
}
