<?php
//---------------------------------------------------------------------------------------------------
// Set this to match your time zone or your scheduled events will run at unexpected times
date_default_timezone_set("America/Denver");

/*
// Edit /etc/php/[version]/fpm/php.ini if the ini_set calls don't work for you
display_errors = On
display_startup_errors = On
error_reporting = E_ALL
*/
ini_set("display_errors",1);
ini_set("display_startup_errors",1);
error_reporting(E_ALL);
//---------------------------------------------------------------------------------------------------
define("VERSION","1.0.1");
define("DB_HOST","localhost");
define("DB_NAME","LCC");
define("DB_USER","lccdbuser");
define("DB_PASS","LoRaCmdCtrl");

$jsonSuccess = "{\"status\": \"success\",\"message\": \"Operation completed successfully\"}";
$jsonFailure = "{\"status\": \"error\",\"message\": \"Operation failed\"}";
//---------------------------------------------------------------------------------------------------
$DBcnx = mysqli_connect(DB_HOST,DB_USER,DB_PASS,DB_NAME);
//---------------------------------------------------------------------------------------------------
function mpg123_scale($percent) {
  // 50% would be: mpg123 -f 16384 yourfile.mp3
  // Clamp to valid range
  $percent = max(0,min(100,$percent));
  // Linear mapping to 0...32768
  return round(($percent / 100) * 32768);
}
//---------------------------------------------------------------------------------------------------
if ((isset($_GET["addr"])) && (isset($_GET["cmd"]))) {
  $Address = $_GET["addr"];
  $Data = explode("/",trim($_GET["cmd"],"/"));

  $Result = mysqli_query($DBcnx,"SELECT * FROM sound_server WHERE address='$Address'");
  if (mysqli_num_rows($Result) == 0) {
    $Insert = mysqli_query($DBcnx,"INSERT INTO sound_server (address,last_update) VALUES ('$Address',NOW())");
  }

  $Update = mysqli_query($DBcnx,"UPDATE sound_server SET sound=$Data[1],volume=$Data[2],replay=$Data[3],last_update=NOW() WHERE address='$Address'");

  shell_exec("pkill -f /tmp/$Address");
  $Script = "#!/bin/bash\n";
  if ($Data[3] == 1) {
    $Script .= "mpg123 -f " . mpg123_scale($Data[2]) . " --loop /var/www/html/mp3/" . $Data[1] . "\n";
  } else {
    $Script .= "mpg123 -f " . mpg123_scale($Data[2]) . " /var/www/html/mp3/" . $Data[1] . "\n";
  }
  put_file_contents("/tmp/$Address",Script);
  shell_exec("chmod +x /tmp/$Address");
  shell_exec("/tmp/$Address &");

  echo("$jsonSuccess\n");
}
//---------------------------------------------------------------------------------------------------
mysqli_close($DBcnx);
//---------------------------------------------------------------------------------------------------
?>
