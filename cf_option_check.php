<?php
$cf_json = '/opt/aws/cf_option.json';
if ( file_exists($cf_json) && ($cf_data = json_decode(file_get_contents($cf_json), true)) ) {
  if ( isset($cf_data['option']) ) {
    if ( isset($cf_data['option']['cloudfront']) ) {
      echo 'cloudfront';
    } else {
      echo '';
    }
  } else {
    echo '';
  }
} else {
  echo '';
}
