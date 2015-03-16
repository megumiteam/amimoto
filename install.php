<?php
// Sanity check.
if ( false ) {
?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Error: PHP is not running</title>
</head>
<body class="wp-core-ui">
	<h1 id="logo"><a href="http://amimoto-ami.com/" tabindex="-1">AMIMOTO AMI</a></h1>
	<h2>Error: PHP is not running</h2>
	<p>WordPress requires that your web server is running PHP. Your server does not have PHP installed, or PHP is turned off.</p>
</body>
</html>
<?php
}

function wp_check_invalid_utf8( $string, $strip = false ) {
	$string = (string) $string;

	if ( 0 === strlen( $string ) ) {
		return '';
	}

	// Check for support for utf8 in the installed PCRE library once and store the result in a static
	$utf8_pcre = @preg_match( '/^./u', 'a' );
	// We can't demand utf8 in the PCRE installation, so just return the string in those cases
	if ( !$utf8_pcre ) {
		return $string;
	}

	// preg_match fails when it encounters invalid UTF8 in $string
	if ( 1 === @preg_match( '/^./us', $string ) ) {
		return $string;
	}

	// Attempt to strip the bad chars if requested (not recommended)
	if ( $strip && function_exists( 'iconv' ) ) {
		return iconv( 'utf-8', 'utf-8', $string );
	}

	return '';
}

function _wp_specialchars( $string, $quote_style = ENT_NOQUOTES, $charset = 'UTF-8' ) {
	$string = (string) $string;

	if ( 0 === strlen( $string ) )
		return '';

	// Don't bother if there are no specialchars - saves some processing
	if ( ! preg_match( '/[&<>"\']/', $string ) )
		return $string;

	// Account for the previous behaviour of the function when the $quote_style is not an accepted value
	if ( empty( $quote_style ) )
		$quote_style = ENT_NOQUOTES;
	elseif ( ! in_array( $quote_style, array( 0, 2, 3, 'single', 'double' ), true ) )
		$quote_style = ENT_QUOTES;

	// Store the site charset as a static to avoid multiple calls to wp_load_alloptions()
	if ( in_array( $charset, array( 'utf8', 'utf-8', 'UTF8' ) ) )
		$charset = 'UTF-8';

	$_quote_style = $quote_style;

	if ( $quote_style === 'double' ) {
		$quote_style = ENT_COMPAT;
		$_quote_style = ENT_COMPAT;
	} elseif ( $quote_style === 'single' ) {
		$quote_style = ENT_NOQUOTES;
	}

	// Handle double encoding ourselves
	$string = @htmlspecialchars( $string, $quote_style, $charset );

	// Backwards compatibility
	if ( 'single' === $_quote_style )
		$string = str_replace( "'", '&#039;', $string );

	return $string;
}

function esc_attr( $text ) {
	$safe_text = wp_check_invalid_utf8( $text );
	$safe_text = _wp_specialchars( $safe_text, ENT_QUOTES );
	return $safe_text;
}

$instance_id = trim(isset($_POST['instance_id']) ? $_POST['instance_id'] : '');
$err_msg = '';
$nfs_client = false;
if (isset($_POST['instance_id'])) {
    $valid_instance_ids = array(file_get_contents('http://169.254.169.254/latest/meta-data/instance-id'));
    //$valid_instance_ids = array('<%= @instance_id %>');
    if ( file_exists('/opt/aws/cloud_formation.json') ) {
        $data = json_decode(file_get_contents('/opt/aws/cloud_formation.json', true));
        if ( isset($data['nfs']) ) {
        	$valid_instance_ids[] = trime($data['nfs']['server']['instance-id']);
			$nfs_client = true;
        }
        unset($data);
    }
    if ( in_array($instance_id,$valid_instance_ids) ) {
    	$host_name = esc_attr($_SERVER['SERVER_NAME']);
    	file_put_contents(dirname(dirname(__FILE__)).'/.valid.'.$host_name, 'valid');
    	header('Location: /');
    } else {
    	$err_msg = 'Sorry, that isn&#8217;t a valid instance ID.';
    }
}

?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta name="viewport" content="width=device-width" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>WordPress &rsaquo; Installation</title>
	<link rel='stylesheet' id='buttons-css'  href='/wp-includes/css/buttons.min.css?ver=4.1' type='text/css' media='all' />
<link rel='stylesheet' id='open-sans-css'  href='//fonts.googleapis.com/css?family=Open+Sans%3A300italic%2C400italic%2C600italic%2C300%2C400%2C600&#038;subset=latin%2Clatin-ext&#038;ver=4.1' type='text/css' media='all' />
<link rel='stylesheet' id='install-css'  href='/wp-admin/css/install.min.css?ver=4.1' type='text/css' media='all' />
<style type="text/css">
    #logo a {
        background: url(//amimoto-ami.com/wp-content/themes/amimoto-theme-2014/images/site-title.png) no-repeat !important;
        margin: -150px auto 25px;
        width: 104px;
        height: 104px;
        background-size: 104px auto;
    }
</style>
</head>
<body class="wp-core-ui">
<h1 id="logo"><a href="http://amimoto-ami.com/" tabindex="-1">AMIMOTO AMI</a></h1>

<h1>Welcome to AMIMOTO AMI</h1>

<p>Please enter your Instance ID to continue installation.</p>

<?php
if ( !empty($err_msg) ) {
	printf('<p class="message">%s</p>'."\n", $err_msg);
}
?>
<form id="setup" method="post" action="install.php" novalidate="novalidate">
	<table class="form-table">
		<tr>
			<th scope="row"><label for="instance_id"><?php echo $nfs_client ? 'Your NFS Server Instance ID' : 'Your Instance ID'; ?></label></th>
			<td>
			<input name="instance_id" type="text" id="instance_id" size="25" value="<?php echo esc_attr($instance_id); ?>" />
		</tr>
	</table>
	<p class="step"><input type="submit" name="Submit" value="Next Step" class="button button-large" /></p>
	<input type="hidden" name="language" value="" />
</form>
<p style="text-align:center">Powered by <a href="http://wordpress.org/">WordPress</a></p>
<script type="text/javascript">var t = document.getElementById('weblog_title'); if (t){ t.focus(); }</script>
<script type='text/javascript' src='/wp-includes/js/jquery/jquery.js?ver=1.11.1'></script>
<script type='text/javascript' src='/wp-includes/js/jquery/jquery-migrate.min.js?ver=1.2.1'></script>
<script type='text/javascript'>
/* <![CDATA[ */
var _zxcvbnSettings = {"src":"http:\/\/54.92.45.110\/wp-includes\/js\/zxcvbn.min.js"};
/* ]]> */
</script>
<script type='text/javascript' src='/wp-includes/js/zxcvbn-async.min.js?ver=1.0'></script>
<script type='text/javascript'>
/* <![CDATA[ */
var pwsL10n = {"empty":"\u5f37\u5ea6\u8868\u793a\u5668","short":"\u975e\u5e38\u306b\u5f31\u3044","bad":"\u5f31\u3044","good":"\u666e\u901a","strong":"\u5f37\u529b","mismatch":"\u4e0d\u4e00\u81f4"};
/* ]]> */
</script>
<script type='text/javascript' src='/wp-admin/js/password-strength-meter.min.js?ver=4.1'></script>
<script type='text/javascript' src='/wp-includes/js/underscore.min.js?ver=1.6.0'></script>
<script type='text/javascript'>
/* <![CDATA[ */
var _wpUtilSettings = {"ajax":{"url":"\/wp-admin\/admin-ajax.php"}};
/* ]]> */
</script>
<script type='text/javascript' src='/wp-includes/js/wp-util.min.js?ver=4.1'></script>
<script type='text/javascript' src='/wp-admin/js/user-profile.min.js?ver=4.1'></script>
<script type='text/javascript' src='/wp-admin/js/language-chooser.min.js?ver=4.1'></script>
</body>
</html>
