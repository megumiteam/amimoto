#!/usr/bin/php
<?php
switch($argc) {
    case 1:
    case 2:
        echo "please input new site url and wp directory name!\n";
        exit();
    default:
        $path = $argv[2];
        $new_site = $argv[1];
}

if ( !file_exists($path.'wp-load.php') && file_exists($path.'wp-config.php') ) {
	echo "Not found wp-config.php!\n";
	exit();
}
require_once(file_exists($path.'wp-load.php') ? $path.'wp-load.php' : $path.'wp-config.php');


global $wpdb;


$replace = new ReplaceSiteURL($new_site, $path);

// wp_options
echo "{$wpdb->options} : replace '{$replace->old_site}' to '{$replace->new_site}' ...\n";
printf("Result: %d\n\n", $replace->options());

// wp_posts
echo "{$wpdb->posts} : replace '{$replace->old_site}' to '{$replace->new_site}' ...\n";
printf("Result: %d\n\n", $replace->posts());

// wp_postmeta
echo "{$wpdb->postmeta} : replace '{$replace->old_site}' to '{$replace->new_site}' ...\n";
printf("Result: %d\n\n", $replace->postmeta());

// wp_usermeta
echo "{$wpdb->usermeta} : replace '{$replace->old_site}' to '{$replace->new_site}' ...\n";
printf("Result: %d\n\n", $replace->usermeta());

// wp_commentmeta
echo "{$wpdb->commentmeta} : replace '{$replace->old_site}' to '{$replace->new_site}' ...\n";
printf("Result: %d\n\n", $replace->commentmeta());



// replace class
class ReplaceSiteURL {
	public $new_site;
	public $old_site;
	public $wp_path;


	function __construct($new_site, $path) {
		$this->new_site = untrailingslashit(preg_match('/^https?:\/\//i', $new_site) ? $new_site : 'http://'.$new_site );
		$this->old_site = untrailingslashit(home_url());
		$this->wp_path = $path;
	}

	// wp_options
	public function options() {
		global $wpdb;

		$count = 0;
		$sql = $wpdb->prepare(
			"SELECT * from `{$wpdb->options}` where option_value like \"%s\"",
			'%'.untrailingslashit($this->old_site).'%'
			);
		$results = $wpdb->get_results($sql);
		foreach ($results as $result){
			$sql = $wpdb->prepare(
				"UPDATE `{$wpdb->options}` SET option_value=\"%s\" where option_id = %d",
				$this->replace($this->old_site, $this->new_site, $result->option_value) ,
				$result->option_id
				);
			$wpdb->query($sql);
			$count++;
		}
		return $count;
	}

	// wp_posts
	public function posts() {
		global $wpdb;
		$sql = $wpdb->prepare(
			"UPDATE `{$wpdb->posts}` SET post_content=REPLACE(post_content, \"%s\",\"%s\") where post_content like \"%s\"",
			$this->old_site,
			$this->new_site,
			"%{$this->old_site}%"
		);
		return $wpdb->query($sql);
	}


	// wp_postmeta
	public function postmeta() {
		global $wpdb;

		$count = 0;
		$sql = $wpdb->prepare(
			"SELECT * from `{$wpdb->postmeta}` where meta_value like \"%s\"",
			'%'.untrailingslashit($this->old_site).'%'
			);
		$results = $wpdb->get_results($sql);
		foreach ($results as $result){
			$sql = $wpdb->prepare(
				"UPDATE `{$wpdb->postmeta}` SET meta_value=\"%s\" where meta_id = %d",
				$this->replace($this->old_site, $this->new_site, $result->meta_value) ,
				$result->meta_id
				);
			$wpdb->query($sql);
			$count++;
		}
		return $count;
	}

	// wp_usermeta
	public function usermeta() {
		global $wpdb;

		$count = 0;
		$sql = $wpdb->prepare(
			"SELECT * from `{$wpdb->usermeta}` where meta_value like \"%s\"",
			'%'.untrailingslashit($this->old_site).'%'
			);
		$results = $wpdb->get_results($sql);
		foreach ($results as $result){
			$sql = $wpdb->prepare(
				"UPDATE `{$wpdb->usermeta}` SET meta_value=\"%s\" where umeta_id = %d",
				$this->replace($this->old_site, $this->new_site, $result->meta_value) ,
				$result->umeta_id
				);
			$wpdb->query($sql);
			$count++;
		}
		return $count;
	}

	// wp_commentmeta
	public function commentmeta() {
		global $wpdb;

		$count = 0;
		$sql = $wpdb->prepare(
			"SELECT * from `{$wpdb->commentmeta}` where meta_value like \"%s\"",
			'%'.untrailingslashit($this->old_site).'%'
			);
		$results = $wpdb->get_results($sql);
		foreach ($results as $result){
			$sql = $wpdb->prepare(
				"UPDATE `{$wpdb->commentmeta}` SET meta_value=\"%s\" where meta_id = %d",
				$this->replace($this->old_site, $this->new_site, $result->meta_value) ,
				$result->meta_id
				);
			$wpdb->query($sql);
			$count++;
		}
		return $count;
	}

	private function replace($origin, $replaced, $value) {
		if ( is_serialized($value) ) {
			$value = maybe_unserialize($value);
			$value = $this->deep_replace($origin, $replaced, $value);
			$value = maybe_serialize($value);
		} else {
			$value = str_replace($origin, $replaced, $value);
		}
		return $value;
	}

	private function deep_replace($origin, $replaced, $datas) {
		if ( is_array($datas) || is_object($datas) ) {
			foreach ( $datas as &$data ) {
				if ( is_array($data) || is_object($data) ) {
					$data = $this->deep_replace($origin, $replaced, $data);
				} else {
					$data = str_replace($origin, $replaced, $data);
				}
			}
		}
		return $datas;
	}
}