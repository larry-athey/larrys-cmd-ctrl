<?php
//---------------------------------------------------------------------------------------------------
require_once("subs.php");
//---------------------------------------------------------------------------------------------------
$DBcnx = mysqli_connect(DB_HOST,DB_USER,DB_PASS,DB_NAME);
//---------------------------------------------------------------------------------------------------
$Result = mysqli_query($DBcnx,"SELECT * FROM settings WHERE ID=1");
$Settings = mysqli_fetch_assoc($Result);
//---------------------------------------------------------------------------------------------------
if ((isset($_GET["addr"])) && (isset($_GET["cmd"]))) {
  $Address = $_GET["addr"];
  $Cmd = $_GET["cmd"];
  $Result = mysqli_query($DBcnx,"SELECT * FROM devices WHERE address='$Address'");
  if (mysqli_num_rows($Result) > 0) {
    $Insert = mysqli_query($DBcnx,"INSERT INTO inbound (address,msg,creation) VALUES ('$Address','$Cmd',NOW())");
    $LastID = mysqli_insert_id($DBcnx);
    if (InStr("/scene-request/",$Cmd)) { // LedBasic scene script requested, send back the script, not the $jsonSuccess result
      $Update = mysqli_query($DBcnx,"UPDATE inbound SET rcvd=1 WHERE ID=" . $LastID);
      $Data = explode("/",trim($Cmd,"/"));
      $Result = mysqli_query($DBcnx,"SELECT * FROM scenes WHERE ID=" . $Data[1]);
      if (mysqli_num_rows($Result) > 0) {
        $Scene = mysqli_fetch_assoc($Result);
        echo($Scene["source"] . "\n");
      } else {
        echo("10 CLEAR\n");
      }
    } elseif (InStr("/sound-server/",$Cmd)) { // LCC Slave request to play a sound on the sound server rather than locally
      $Update = mysqli_query($DBcnx,"UPDATE inbound SET rcvd=1 WHERE ID=" . $LastID);
      $Update = mysqli_query($DBcnx,"UPDATE devices SET status='<span class=\"text-purple\">cmd:/$Cmd</span>' WHERE address='$Address'");
      $Data = explode("/",trim($Cmd,"/"));
      $Response = curlRequest("http://" . $Settings["sound_server"] . ".lcc.local/play-sound.php?addr=$Address&cmd=$Cmd");
      echo("$Response\n");
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
