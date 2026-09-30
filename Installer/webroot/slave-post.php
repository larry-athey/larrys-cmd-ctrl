<?php
//---------------------------------------------------------------------------------------------------
require_once("subs.php");
//---------------------------------------------------------------------------------------------------
$DBcnx = mysqli_connect(DB_HOST,DB_USER,DB_PASS,DB_NAME);
//---------------------------------------------------------------------------------------------------
if ((isset($_GET["addr"])) && (isset($_GET["cmd"]))) {
  $Address = $_GET["addr"];
  $Cmd = $_GET["cmd"];
  $Result = mysqli_query($DBcnx,"SELECT * FROM devices WHERE address='$Address'");
  if (mysqli_num_rows($Result) > 0) {
    $Insert = mysqli_query($DBcnx,"INSERT INTO inbound (address,msg,creation) VALUES ('$Address','$Cmd',NOW())");
    if (InStr("/scene-request/",$Cmd)) { // LedBasic scene script requested, send back the script, not the $jsonSuccess result

    } else {
      echo("$jsonSuccess\n");
    }
  } else {
    echo("$jsonFailure\n");
  }
} else {
  echo("$jsonFailure\n");
}
//---------------------------------------------------------------------------------------------------
mysqli_close($DBcnx);
//---------------------------------------------------------------------------------------------------
?>
