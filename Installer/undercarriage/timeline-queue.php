#!/usr/bin/php
<?php
//---------------------------------------------------------------------------------------------
require_once("/var/www/html/subs.php");
//---------------------------------------------------------------------------------------------
$DBcnx = mysqli_connect(DB_HOST,DB_USER,DB_PASS,DB_NAME);
//---------------------------------------------------------------------------------------------
while (true) {
  $startTime = microtime(true);
  $Result = mysqli_query($DBcnx,"SELECT * FROM settings WHERE ID=1");
  $RS = mysqli_fetch_assoc($Result);
  if ($RS["timeline_running"] == 1) {
    // Process all waiting outbound messages
    $Result = mysqli_query($DBcnx,"SELECT * FROM timeline_queue WHERE sent=0");
    if (mysqli_num_rows($Result) > 0) {
      while ($Cmd = mysqli_fetch_assoc($Result)) {
        usleep(5000); // Give back some CPU time
        $Response = sendCommand($DBcnx,$Cmd["address"],$Cmd["msg"]);
        $Update = mysqli_query($DBcnx,"UPDATE devices SET status='$Response' WHERE address=" . $Cmd["address"]);
        $Update = mysqli_query($DBcnx,"UPDATE timeline_queue SET sent=1 WHERE ID=" . $Cmd["ID"]);
        usleep(5000); // Give back some CPU time
      }
    }
  }
  $endTime = microtime(true);
  $runTime = $endTime - $startTime;
  if ($runTime < 1000000.0) {
    usleep((int)(1000000.0 - $runTime)); // Give back some CPU time while allowing 1 second between checks
    echo(1000000.0 - $runTime . "\n");
  }
}
//---------------------------------------------------------------------------------------------
mysqli_close($DBcnx);
//---------------------------------------------------------------------------------------------
?>
