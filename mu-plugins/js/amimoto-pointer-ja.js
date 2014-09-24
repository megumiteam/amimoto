jQuery(document).ready(function($){
	$('#wp-admin-bar-site-name').pointer({
		content: '<h3>網元AMIからのお知らせ</h3><p>網元AMIのオプションとしてクラウド型セキュリティサービス「Trend Micro Security™ as a Service」が利用できるようになりました。<br>詳しくは下記URLをご参照ください。<br><a href="http://cloudpack.jp/service/option/dsaas-amimoto.html">http://cloudpack.jp/service/option/dsaas-amimoto.html</a></p>',
		close: function(){
			$.post('/wp-admin/admin-ajax.php', {
				action: 'dismiss-wp-pointer',
				pointer: 'amimoto_pointer'
				});
			}
	}).pointer('open');
});
