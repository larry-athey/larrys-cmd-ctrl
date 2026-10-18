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

    // Process an outbound message

  }
  $endTime = microtime(true);
  $runTime = $endTime - $startTime;
  if ($runTime < 1000000.0) {
    usleep((int)(1000000.0 - $runTime));
    echo(1000000.0 - $runTime . "\n");
  }
}
//---------------------------------------------------------------------------------------------
mysqli_close($DBcnx);
//---------------------------------------------------------------------------------------------
?>
