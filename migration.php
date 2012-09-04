<?php
switch($argc) {
    case 1:
    case 2:
        echo "please input wp directory name and new site name!\n";
        exit();
    default:
        $new_site_name = isset($argv[2]) ? $argv[2] : '';
        $path = $argv[1];
}

if ( !file_exists($path.'wp-load.php') && file_exists($path.'wp-config.php') ) {
	echo "Not found wp-config.php!\n";
	exit();
}
require_once(file_exists($path.'wp-load.php') ? $path.'wp-load.php' : $path.'wp-config.php');

function deep_replace($origin, $replaced, $datas)
{
	if ( is_array($datas) || is_object($datas) ) {
		foreach ( $datas as &$data ) {
			if ( is_array($data) || is_object($data) ) {
				$data = deep_replace($origin, $replaced, $data);
			} else {
				$data = str_replace($origin, $replaced, $data);
			}
		}
	}
	return $datas;
}


global $wpdb;
$new_site = untrailingslashit(preg_match('/^https?:\/\//i', $new_site_name) ? $new_site_name : 'http://'.$new_site_name );
$old_site = untrailingslashit(home_url());


// wp_options
echo "{$wpdb->options} : replace '$old_site' to '$new_site' ...\n";
$sql = $wpdb->prepare("SELECT * from `{$wpdb->options}` where option_value like \"%s\"",
	'%'.untrailingslashit($old_site).'%'
	);
$count = 0;
$results = $wpdb->get_results($sql);
foreach ($results as $result){
	$value = $result->option_value;
	if ( is_serialized($value) ) {
		$value = maybe_unserialize($value);
		$value = deep_replace($old_site, $new_site, $value);
		$value = maybe_serialize($value);
	} else {
		$value = str_replace($old_site, $new_site, $value);
	}
	$sql = $wpdb->prepare(
		"UPDATE `{$wpdb->options}` SET option_value=\"%s\" where option_id = %d",
		$value,
		$result->option_id
		);
	$wpdb->query($sql);
	$count++;
}
printf("Result: %s\n\n", $count);


// wp_posts
echo "{$wpdb->posts} : replace '$old_site' to '$new_site' ...\n";
$sql = $wpdb->prepare(
	"UPDATE `{$wpdb->posts}` SET post_content=REPLACE(post_content, \"%s\",\"%s\") where post_content like \"%s\"",
	$old_site,
	$new_site,
	"%{$old_site}%"
	);
$result = $wpdb->query($sql);
printf("Result: %s\n\n", $result);


// wp_postmeta
echo "{$wpdb->postmeta} : replace '$old_site' to '$new_site' ...\n";
$sql = $wpdb->prepare("SELECT * from `{$wpdb->postmeta}` where meta_value like \"%s\"",
	'%'.untrailingslashit($old_site).'%'
	);
$count = 0;
$results = $wpdb->get_results($sql);
foreach ($results as $result){
	$value = $result->meta_value;
	if ( is_serialized($value) ) {
		$value = maybe_unserialize($value);
		$value = deep_replace($old_site, $new_site, $value);
		$value = maybe_serialize($value);
	} else {
		$value = str_replace($old_site, $new_site, $value);
	}
	$sql = $wpdb->prepare(
		"UPDATE `{$wpdb->postmeta}` SET meta_value=\"%s\" where meta_id = %d",
		$value,
		$result->meta_id
		);
	$wpdb->query($sql);
	$count++;
}
printf("Result: %s\n\n", $count);


// wp_usermeta
echo "{$wpdb->usermeta} : replace '$old_site' to '$new_site' ...\n";
$sql = $wpdb->prepare("SELECT * from `{$wpdb->usermeta}` where meta_value like \"%s\"",
	'%'.untrailingslashit($old_site).'%'
	);
$count = 0;
$results = $wpdb->get_results($sql);
foreach ($results as $result){
	$value = $result->meta_value;
	if ( is_serialized($value) ) {
		$value = maybe_unserialize($value);
		$value = deep_replace($old_site, $new_site, $value);
		$value = maybe_serialize($value);
	} else {
		$value = str_replace($old_site, $new_site, $value);
	}
	$sql = $wpdb->prepare(
		"UPDATE `{$wpdb->usermeta}` SET meta_value=\"%s\" where umeta_id = %d",
		$value,
		$result->umeta_id
		);
	$wpdb->query($sql);
	$count++;
}
printf("Result: %s\n\n", $count);


// wp_commentmeta
echo "{$wpdb->commentmeta} : replace '$old_site' to '$new_site' ...\n";
$sql = $wpdb->prepare("SELECT * from `{$wpdb->commentmeta}` where meta_value like \"%s\"",
	'%'.untrailingslashit($old_site).'%'
	);
$count = 0;
$results = $wpdb->get_results($sql);
foreach ($results as $result){
	$value = $result->meta_value;
	if ( is_serialized($value) ) {
		$value = maybe_unserialize($value);
		$value = deep_replace($old_site, $new_site, $value);
		$value = maybe_serialize($value);
	} else {
		$value = str_replace($old_site, $new_site, $value);
	}
	$sql = $wpdb->prepare(
		"UPDATE `{$wpdb->commentmeta}` SET meta_value=\"%s\" where meta_id = %d",
		$value,
		$result->meta_id
		);
	$wpdb->query($sql);
	$count++;
}
printf("Result: %s\n\n", $count);
