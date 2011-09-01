<html>
<head>
	<title> BoxView Example: simple extern data visualizer </title>

    <link href="../css/boxview.css" media="screen" type="text/css" rel="stylesheet">
    <link href="../css/widgets.css" media="screen" type="text/css" rel="stylesheet">
    <link href="../css/jquery-ui-1.8.9.custom.css" media="screen" type="text/css" rel="stylesheet">
    <link href="examples.css" media="screen" type="text/css" rel="stylesheet">

	<script src="../jq/jquery.js"></script>
	<script src="../jq/jquery-ui.js"></script>
	<script src="../src/boxview.js"></script>
	<script src="../src/widgets.js"></script>

<?

    $what = isset($_GET['what']) ? $_GET['what'] : 'html_index';
    $id = isset($_GET['id']) ? $_GET['id'] : '';

    $parts = pathinfo($_SERVER['PHP_SELF']);
    $url = "http://".$_SERVER["SERVER_NAME"].":".$_SERVER["SERVER_PORT"].$parts['dirname']."/data_providers/ajax_provider.php?what=".$what."&id=".$id;
    $content = file_get_contents($url);

?>

</head>
    

    <div class="boxViewContainer">
        <div class="box">
            <?
                // Dont forget to personalize the cookie name!
                if (isset($_COOKIE['LastVisitedBoxView'])) 
                    echo "<a href='".$_COOKIE['LastVisitedBoxView']."'>&lt;&lt; Back to the boxview</a><br><br>";
            ?>
            <div class="boxContent"><?php echo $content; ?></div>
        </div>
    </div>

<body></body>
</html>