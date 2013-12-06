<?php
//$cf_json = '/opt/aws/cloud_formation.json';
$cf_json = './cloud_formation.json';
$instance_id = file_get_contents('http://169.254.169.254/latest/meta-data/instance-id');
if ( file_exists($cf_json) && ($cf_data = json_decode(file_get_contents($cf_json), true)) ) {
  if ( isset($cf_data['nfs']) && isset($cf_data['nfs']['server']) ) {
    $server_instance_id = $cf_data['nfs']['server']['instance-id'];
    echo $instance_id == $server_instance_id ? 'nfs_server' : 'nfs_client';
  } else if ( isset($cf_data['rds']) ) {
    echo 'rds';
  } else {
    echo '';
  }
} else {
  echo '';
}
