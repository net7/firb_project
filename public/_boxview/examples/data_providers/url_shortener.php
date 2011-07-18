<?php

// Define the shortened URL allowed characters
define('ALLOWED_CHARS', '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');

// Create SQLiteDatabase object
if (!$db = new SQLiteDatabase('db.sqlite', 0666)) 
    die("Cant connect to the file database. Make sure the db file is in the right place and the directory is writable by the web server.");

// TODO: make this configurable someway? .. some nicer way! 
define('DB_TABLE', 'shortenedurls');
define('SHORTENER_BASE_HREF', "http://" . $_SERVER["HTTP_HOST"] . ":" . $_SERVER["SERVER_PORT"] . $_SERVER["REQUEST_URI"] . "?u=");
define('FALLBACK_URL', $_["SERVER_NAME"] . $_SERVER["SERVER_PORT"] . '/boxview/examples/');

// Request to shorten a long url
if ($_REQUEST['longurl']) {

    $url_to_shorten = get_magic_quotes_gpc() ? stripslashes(trim($_REQUEST['longurl'])) : trim($_REQUEST['longurl']);

    if (!empty($url_to_shorten) && preg_match('|^https?://|', $url_to_shorten)) {

    	// check if the URL has already been shortened
    	$q = 'SELECT id FROM ' . DB_TABLE. ' WHERE long_url="' . mysql_real_escape_string($url_to_shorten) . '"';
        $already_shortened = $db->singleQuery($q);
        
    	if (!empty($already_shortened)) {
    		// URL has already been shortened
    		$shortened_url = getShortenedURLFromID($already_shortened);
    	} else {
    		// URL not in database, insert building an unique id 
            $q = 'SELECT max(id) FROM '.DB_TABLE;
            $res = $db->singleQuery($q);

            $new_id = intval($res)+1;
            $q = 'INSERT INTO '.DB_TABLE.' (id, long_url, created, creator) VALUES ('.$new_id.', "'.mysql_real_escape_string($url_to_shorten).'", "'.time().'", "'.        mysql_real_escape_string($_SERVER['REMOTE_ADDR']).'")';
            $res = $db->query($q);
            $shortened_url = getShortenedURLFromID($new_id);
    	}
    	// Output the shortened url
    	die(SHORTENER_BASE_HREF . $shortened_url);
    	
    } // if empty() && preg_match()
    
} // if _REQUEST[longurl]


// Requesting a short url to be redirected to long_url
if ($_REQUEST['u']) {

    if (!preg_match('|^[0-9a-zA-Z]{1,6}$|', $_GET['u'])) {
        header('Location: ' . FALLBACK_URL);
        exit;
    }
        
    $shortened_id = getIDFromShortenedURL($_GET['u']);

    $q = 'SELECT long_url FROM ' . DB_TABLE . ' WHERE id="' . mysql_real_escape_string($shortened_id) . '"';
	$long_url = $db->singleQuery($q);

    // Send the Location header to redirect the browser to long_url
    header('Location: ' .  $long_url);
    exit;

} // if _REQUEST[u]

function getIDFromShortenedURL ($string, $base = ALLOWED_CHARS) {
	$length = strlen($base);
	$size = strlen($string) - 1;
	$string = str_split($string);
	$out = strpos($base, array_pop($string));
	foreach($string as $i => $char) {
		$out += strpos($base, $char) * pow($length, $size - $i);
	}
	return $out;
}

function getShortenedURLFromID ($integer, $base = ALLOWED_CHARS) {
	$length = strlen($base);
	while($integer > $length - 1) {
		$out = $base[fmod($integer, $length)] . $out;
		$integer = floor( $integer / $length );
	}
	return $base[$integer] . $out;
}

// If nothing happened, redirect to the default index
header('Location: ' . FALLBACK_URL);
