<?php
/*
Plugin Name: must use functions.
Plugin URI:
Description:
Version: 0.1
Author: DigitalCube
Author URI:
License: GPLv2 or later
*/

// http://dogmap.jp/2012/08/25/must-use-plugins/
new just_do_it();
class just_do_it {
  private $must_plugins = array();

  function __construct() {
    if (defined('WPLANG') && WPLANG == 'ja')
      $this->must_plugins['WP Multibyte Patch'] = 'wp-multibyte-patch/wp-multibyte-patch.php';
    if (defined('IS_AMIMOTO') && IS_AMIMOTO)
      $this->must_plugins['Nginx Cache Controller'] = 'nginx-champuru/nginx-champuru.php';
    add_action('shutdown', array($this, 'plugins_loaded'));
  }

  public function plugins_loaded() {
    $activated = false;
    $activePlugins = get_settings('active_plugins');
    foreach ($this->must_plugins as $key => $plugin) {
      if ( !array_search($plugin, $activePlugins) && file_exists(WP_PLUGIN_DIR.'/'.$plugin) ) {
        activate_plugin( $plugin, '', $this->is_multisite() );
        $activated = true;
      }
    }
    if ($activated)
      @unlink(__FILE__);
  }

  private function is_multisite() {
    return function_exists('is_multisite') && is_multisite();
  }
}
