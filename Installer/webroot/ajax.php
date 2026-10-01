<?php
//---------------------------------------------------------------------------------------------------
require_once("html.php");
//---------------------------------------------------------------------------------------------------
$DBcnx = mysqli_connect(DB_HOST,DB_USER,DB_PASS,DB_NAME);

if ($_GET["ID"] == "device_stats") {
  $Content = getDeviceStats($DBcnx,$_GET["address"]); // Changed the content to the ID due to USB pairing changing the address mid refresh
}

echo("$Content\n");
//---------------------------------------------------------------------------------------------------
mysqli_close($DBcnx);
//---------------------------------------------------------------------------------------------------
?>
