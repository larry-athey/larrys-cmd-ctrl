<?php
//---------------------------------------------------------------------------------------------
require_once("/var/www/html/subs.php");
//---------------------------------------------------------------------------------------------
$DBcnx = mysqli_connect(DB_HOST,DB_USER,DB_PASS,DB_NAME);
//---------------------------------------------------------------------------------------------
$Content = $jsonFailure;

// Handle API calls, hope you stocked up on ibruprophen...

// Points to keep in mind.
//
// - While the timeline is considered to be 10 FPS, LCC slaves don't feature this level of
//   precision. They just execute commands in sequence and can store up to 16 in their cache.
//   The 10 FPS thing is just there to make timeline editing easier. It's easier to modify
//   10 back-to-back commands if they aren't stacked right on top of each other. It's OK to
//   have two commands at the same time on different devices, but they should be separated
//   by 100ms if they're on the same device. (just a suggestion, users will thank you)
//
// - Any time that you create a new frame in the timeline, you need to use the database ID
//   number zero to tell the API that this is a new record. Otherwise, creating a new record
//   is no different than editing an existing record.
//
// - The only commands that pre-empt other commands from executing are specific motor control
//   commands. If you are using a brushed motor and set a non-zero progression time, nothing
//   else will execute until the motor has reached its target speed. The same rule applies to
//   stepper motors, but the rule is that nothing else happens until the stepper has reached
//   its target position (steps).
//
// - The length of MP3 files has no bearing on the timeline, if one MP3 is playing and you
//   send another /sound/ command, it will kill the current MP3 and start playing the other.
//   If you're doing a holiday decoration scene that you want to synchronize with lights or
//   motorized items, you need to make a note of the length of the featured music track and
//   work within that timeframe.
//
// - Fade times on RGB LEDs work the same way as MP3 files. If you set one with a 30 second
//   fade time and send another command within that 30 seconds, it will interrupt that fade.
//   The smarter choice here would be to create an LedBasic scene to automate complex fades
//   and other lighting effects, then send that scene at a specific time instead.
//
// - Remember that device type 2 (stepper motor controllers) do not have sound effects and
//   RGB LED capabilities, so you'll need to adjust your command editor forms accordingly.
//   All other 3 device types are the same at the electronic level but switching controller
//   devices simply don't have any motor control capability in Mission Control so you can't
//   send a motor command to it and cause a delay in its GPIO switching.

if (isset($_GET["action"])) {
  switch ($_GET["action"]) {
    case "list": // ?action=list : Generates JSON arrays from specific MySQL queries
      if (isset($_GET["type"])) {
        switch ($_GET["type"]) {
          case "devices": // ?action=list&type=devices : Returns the contents of the "devices" table
            $Result = mysqli_query($DBcnx,"SELECT * FROM devices ORDER BY dev_name");
            if (mysqli_num_rows($Result) > 0) {
              while ($Device = mysqli_fetch_assoc($Result)) {
                $List[] = $Device;
              }
              $Content = json_encode($List);
            } else {
              http_response_code(500);
              $Content = json_encode(["success" => false,"error" => "Database query failed"]);
            }
            break;
          case "frames": // ?action=list&type=frames&address=00-11-22-33-44-55-66 : Returns all timeline frames for the device specified by address
            if (isset($_GET["address"])) {
              $Result = mysqli_query($DBcnx,"SELECT * FROM timeline WHERE address='" . $_GET["address"] . "' ORDER BY position");
              if (mysqli_num_rows($Result) > 0) {
                while ($Frame = mysqli_fetch_assoc($Result)) {
                  $Frames[] = $Frame;
                }
                $Content = json_encode($Frames);
              } else {
                http_response_code(500);
                $Content = json_encode(["success" => false,"error" => "Database query failed"]);
              }
            }
            break;
          case "getframe": // ?action=list&type=getframe&id=12345 : Returns a specific frame from the timeline by its table ID number
            if (isset($_GET["id"])) {
              $Result = mysqli_query($DBcnx,"SELECT * FROM timeline WHERE ID=" . $_GET["id"]);
              if (mysqli_num_rows($Result) > 0) {
                $Frame = mysqli_fetch_assoc($Result);
                $Content = json_encode($Frame);
              } else {
                http_response_code(500);
                $Content = json_encode(["success" => false,"error" => "Database query failed"]);
              }
            }
            break;
          default:
            // Do nothing, return $jsonFailure
        }
      }
      break;
    case "status": // ?action=status : Returns the timeline_status table (single row) used for updating the display as a timeline script is running.
      $Result = mysqli_query($DBcnx,"SELECT * FROM timeline_status WHERE ID=1");
      if (mysqli_num_rows($Result) > 0) {
        $Status = mysqli_fetch_assoc($Result);
        $Content = json_encode($Status);
      } else {
        http_response_code(500);
        $Content = json_encode(["success" => false,"error" => "Database query failed"]);
      }
      break;
    default:
      // Do nothing, return $jsonFailure
  }
} elseif (isset($_POST["action"])) {
  switch ($_POST["action"]) {
    case "add": // Add a new device frame to the timeline
      break;
    case "update": // Update an existing device frame in the timeline
      break;
    case "delete": // Delete an existing device frame in the timeline
      break;
    case "setstart": // Set the start point to start running the timeline script from (or rewind to zero)
      break;
    case "start": // Start running the timeline script
      break;
    case "stop": // Stop the timeline script
      break;
    default:
      // Do nothing, return $jsonFailure
  }
} else {
  // Do nothing, return $jsonFailure
}

if ($Content == $jsonFailure) http_response_code(500);
header("Content-Type: application/json");
echo("$Content\n");
//---------------------------------------------------------------------------------------------
mysqli_close($DBcnx);
//---------------------------------------------------------------------------------------------
?>
