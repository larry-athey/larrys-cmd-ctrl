#!/usr/bin/php
<?php
//---------------------------------------------------------------------------------------------
require_once("/var/www/html/subs.php");
//---------------------------------------------------------------------------------------------
$DBcnx = mysqli_connect(DB_HOST,DB_USER,DB_PASS,DB_NAME);
//---------------------------------------------------------------------------------------------
function formatCommand($DBcnx,$ID) {
  $Msg = "";
  $Result = mysqli_query($DBcnx,"SELECT * FROM timeline WHERE ID=$ID");
  if (mysqli_num_rows($Result) > 0) {
    $Cmd = mysqli_fetch_assoc($Result);
    if ($Cmd["cmd_type"] == 1) { // Motor Control
      $Msg = "/motor/" . $Cmd["direction"] . "/" . $Cmd["speed"] . "/" . $Cmd["progression"] . "/" . $Cmd["duration"];
    } elseif ($Cmd["cmd_type"] == 2) { // Stepper Control
      $Msg = "/stepper/" . $Cmd["direction"] . "/" . $Cmd["resolution"] . "/" . $Cmd["steps"] . "/" . $Cmd["speed"];
    } elseif ($Cmd["cmd_type"] == 3) { // Location based action
      $Msg = "/location/" . $Cmd["location_id"] . "/" . $Cmd["location_action"] . "/" . $Cmd["location_data"];
    } elseif ($Cmd["cmd_type"] == 4) { // Sound effects
      $Msg = "/sound/" . $Cmd["sound"] . "/" . $Cmd["volume"] . "/" . $Cmd["replay"];
    } elseif ($Cmd["cmd_type"] == 5) { // GPIO output switching
      $Msg = "/switch/" . $Cmd["gpio_pin"] . "/" . $Cmd["direction"];
    } elseif ($Cmd["cmd_type"] == 6) { // RGB LED control
      $Msg = "/light/" . $Cmd["light"] . "/" . $Cmd["red"] . "/" . $Cmd["green"] . "/" . $Cmd["blue"] . "/" . $Cmd["fade"];
    } elseif ($Cmd["cmd_type"] == 7) { // LedBasic scene
      $Msg = "/scene/" . $Cmd["scene"];
    }
  }
  return $Msg;
}
//---------------------------------------------------------------------------------------------------
while (true) {
  $startTime = microtime(true);
  $Result = mysqli_query($DBcnx,"SELECT * FROM timeline_status WHERE ID=1");
  $Status = mysqli_fetch_assoc($Result);
  if ($Status["running"] == 1) {
    // Check to see if there are any remaining frames in the timeline to process
    $Result2 = mysqli_query($DBcnx,"SELECT * FROM timeline ORDER BY position DESC LIMIT 1");
    if (mysqli_num_rows($Result) > 0) {
      $Test = mysqli_fetch_assoc($Result2);
      if ($Test["position"] < $Status["position"]) {
        // Process any timeline frames that match the current position up to 9/10 of a second (900 ms) in the future
        $Result3 = mysqli_query($DBcnx,"SELECT * FROM timeline WHERE (position >= " . $Status["position"] . ") AND (position <= " . $Status["position"] + 900 . ")");
        if (mysqli_num_rows($Result3) > 0) {
          while ($Timeline = mysqli_fetch_assoc($Result3)) {
            // Add the frames to the timeline_queue table as formatted commands
            $Msg = formatCommand($DBcnx,$Timeline["ID"]);
            if ($Msg != "") $Insert = mysqli_query($DBcnx,"INSERT INTO timeline_queue (address,msg,creation) VALUES ('" . $Timeline["address"] . "','$Msg',NOW())");
          }
        }
        // Increment the current timeline position
        $Update = mysqli_query($DBcnx,"UPDATE timeline_status SET position=(position + 1) WHERE ID=1");
      } else {
        // Nothing to do, stop the timeline run
        $Update = mysqli_query($DBcnx,"UPDATE timeline_status SET running=0 WHERE ID=1");
      }
    } else {
      // Nothing to do, stop the timeline run
      $Update = mysqli_query($DBcnx,"UPDATE timeline_status SET running=0 WHERE ID=1");
    }
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
