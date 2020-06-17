<?php
    $alldata = "";
    function curl_callback($handle, $data) {
        global $alldata;
        $alldata .= $data;
        if (strlen($alldata) > 150000) {
            die();
        }
    
        else return strlen($data);
    } 

	if (isset($_REQUEST["url"])) {
        $url = $_REQUEST["url"];
        
        if (
            substr($url, 0, strlen('http://')) !== 'http://'
            && substr($url, 0, strlen('https://')) !== 'https://'
        ) die();
        
        $ch = curl_init($url);
        $headers = array('X-Forwarded-For: ' . $_SERVER['REMOTE_ADDR']);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt ($ch, CURLOPT_CONNECTTIMEOUT, 2);
        curl_setopt ($ch, CURLOPT_WRITEFUNCTION, 'curl_callback');
        
        curl_exec($ch);
        
        header('Content-type: application/octet-stream');
        file_put_contents("php://output", $alldata);
        
		die();
	}
?>
