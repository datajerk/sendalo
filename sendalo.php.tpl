<?php
	if (isset($_REQUEST["url"])) {
        $url = $_REQUEST["url"];
        
        header('Content-type: application/octet-stream');
        $data = file_get_contents($url, $maxlen=150000);
        file_put_contents("php://output", $data);
        
		die();
	}
?>
