#!/usr/bin/php
<?php
//---------------------------------------------------------------------------------------------
require_once("/var/www/html/subs.php");
//---------------------------------------------------------------------------------------------
$DBcnx = mysqli_connect(DB_HOST,DB_USER,DB_PASS,DB_NAME);
//---------------------------------------------------------------------------------------------
$Content = "";

// Handle API calls

if ((isset($_GET["action"])) && (isset($_GET["data"])) {
  $action = $_GET["action"];
  $data   = $_GET["data"];

  switch ($action) {
    case "list":
        // ...
        break;
    case "status":
        // ...
        break;
    default:
        $Content = $jsonFailure;
  }
} elseif ((isset($_POST["action"])) && (isset($_POST["data"])) {
  $action = $_POST["action"];
  $data   = $_POST["data"];

  switch ($action) {
    case "add":
        break;
    case "update":
        break;
    case "delete":
        break;
    case "start":
        break;
    case "stop":
        break;
    default:
        $Content = $jsonFailure;
  }
} else {
  $Content = $jsonFailure;
}

echo("$Content\n");
//---------------------------------------------------------------------------------------------
mysqli_close($DBcnx);
//---------------------------------------------------------------------------------------------
?>
