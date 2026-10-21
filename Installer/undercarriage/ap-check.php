#!/usr/bin/php
<?php
//---------------------------------------------------------------------------------------------
require_once("/var/www/html/subs.php");
$DBcnx = mysqli_connect(DB_HOST,DB_USER,DB_PASS,DB_NAME);
$DevTotal  = 0;
$DevOnline = 0;
//---------------------------------------------------------------------------------------------
function pingHost($Host) {
  $Output = exec("/usr/bin/ping -c 1 -W 1 " . escapeshellarg($Host) . " > /dev/null 2>&1",$Result,$Status);
  if ($Status == 0) {
    return true;
  } else {
    return false;
  }
}
//---------------------------------------------------------------------------------------------
$Result = mysqli_query($DBcnx,"SELECT * FROM settings WHERE ID=1");
$Settings = mysqli_fetch_assoc($Result);
if ($Settings["sound_server"] != "00-00-00-00-00-00") {
  $DevTotal = 1;
  echo("Pinging " . $Settings["sound_server"] . ".lcc.local\n");
  if (pingHost($Settings["sound_server"] . ".lcc.local")) $DevOnline ++;
}
//---------------------------------------------------------------------------------------------
$Result = mysqli_query($DBcnx,"SELECT * FROM devices WHERE address <> '00-00-00-00-00-00'");
$DevTotal += mysqli_num_rows($Result);

if (mysqli_num_rows($Result) > 0) {
  while ($Dev = mysqli_fetch_assoc($Result)) {
    echo("Pinging " . $Dev["address"] . ".lcc.local\n");
    if (pingHost($Dev["address"] . ".lcc.local")) $DevOnline ++;
  }
}

echo("$DevOnline out of $DevTotal devices pinging.\n");
if ($DevOnline == 0) {
  echo("Restarting access point services.\n");
  shell_exec("./ap-restart");
}
//---------------------------------------------------------------------------------------------
mysqli_close($DBcnx);
//---------------------------------------------------------------------------------------------
?>
