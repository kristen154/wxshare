<?php
define('DT_DEBUG', 0);
if(DT_DEBUG) {
	error_reporting(E_ALL);
	$mtime = explode(' ', microtime());
	$debug_starttime = $mtime[1] + $mtime[0];
} else {
	error_reporting(0);
}
if(isset($_REQUEST['GLOBALS']) || isset($_FILES['GLOBALS'])) exit('Request Denied');
@set_magic_quotes_runtime(0);
$MQG = get_magic_quotes_gpc();
foreach(array('_POST', '_GET') as $__R) {
	if($$__R) { 
		foreach($$__R as $__k => $__v) {
			if(substr($__k, 0, 1) == '_') if($__R == '_POST') { unset($_POST[$__k]); } else { unset($_GET[$__k]); }
			if(isset($$__k) && $$__k == $__v) unset($$__k);
		}
	}
}

//以上代码防止$_GET['url']报错

require_once "jssdk.php";//引入jssdk.php

$jssdk = new JSSDK("yourappid", "yoursecret");//配置appid和app_secret
$url = !empty($_GET['url']) ? $_GET['url'] : '';
$signPackage = $jssdk->GetSignPackage($url);//传入url
echo json_encode($signPackage);
?>