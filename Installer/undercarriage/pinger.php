#!/usr/bin/php
<?php
//---------------------------------------------------------------------------------------------
require_once("/var/www/html/subs.php");
$DBcnx = mysqli_connect(DB_HOST,DB_USER,DB_PASS,DB_NAME);
//---------------------------------------------------------------------------------------------
function pingHost($Host) {
  $Output = exec("/usr/bin/ping -c 2 -W 5 " . escapeshellarg($Host) . " > /dev/null 2>&1",$Result,$Status);
  if ($Status == 0) {
    return true;
  } else {
    return false;
  }
}
//---------------------------------------------------------------------------------------------
$Result = mysqli_query($DBcnx,"SELECT * FROM devices WHERE address <> '00-00-00-00-00-00'");
if (mysqli_num_rows($Result) > 0) {
  while ($Dev = mysqli_fetch_assoc($Result)) {
    if (pingHost($Dev["address"] . ".lcc.local")) {
      echo($Dev["address"] . ".lcc.local online\n");
      $Tries = 0;
      while ($Tries < 3) {
        $Tries ++;
        $Test = curlRequest("http://". $Dev["address"] . ".lcc.local/wifi-signal");
        if ($Test == $jsonSuccess) break;
      }
    } else {
      $Update = mysqli_query($DBcnx,"UPDATE devices SET signal_level='<span class=\"text-secondary\">Offline</span>' WHERE ID=" . $Dev["ID"]);
    }
  }
}
//---------------------------------------------------------------------------------------------
mysqli_close($DBcnx);
//---------------------------------------------------------------------------------------------
?>
