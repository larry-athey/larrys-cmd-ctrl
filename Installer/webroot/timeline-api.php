<?php
//---------------------------------------------------------------------------------------------
require_once("/var/www/html/subs.php");
//---------------------------------------------------------------------------------------------
$DBcnx = mysqli_connect(DB_HOST,DB_USER,DB_PASS,DB_NAME);
//---------------------------------------------------------------------------------------------
// Handle API calls, hope you stocked up on ibruprophen...

// Points to keep in mind.
//
// - There is no timeline length to set, the length is just determined by the position of the
//   last frame that you insert. In all honesty, when plotting the timeline in a piano roll
//   view, each frame only needs to be 1 second in length. This is because the back end only
//   progresses through the timeline one second at a time and commands don't have a length.
//
// - While the timeline is considered to be 10 FPS, LCC slaves don't feature this level of
//   precision. They just execute commands in sequence and can store up to 16 in their cache.
//   The 10 FPS thing is just there to make timeline editing easier. It's easier to modify
//   10 back-to-back commands if they aren't stacked right on top of each other. It's OK to
//   have two commands at the same time on different devices, but they should be separated
//   by 100ms if they're on the same device. (just a suggestion, your users will thank you)
//
// - The only commands that pre-empt other commands from executing are specific motor control
//   commands. If you are using a brushed motor and set a non-zero progression time, nothing
//   else will execute until the motor has reached its target speed. The same rule applies to
//   stepper motors, but the rule is that nothing else happens until the stepper has reached
//   its target position (steps). Keep this in mind when sending back-to-back commands to a
//   device and adjust the order as necessary.
//
// - The length of MP3 files has no bearing on the timeline length, if a device is playing an
//   MP3 and you send another /sound/ command to it, this will kill the current MP3 and start
//   playing the next one. If you're doing a holiday decoration scene/show that you want to
//   synchronize with background music, you'll need to make a note of the length of the audio
//   sound track and work within that timeframe.
//
// - Fade times on RGB LEDs work the same way as MP3 files. If you set one with a 30 second
//   fade time and send another /light/ command within that 30 seconds, it will interrupt the
//   fade. The smarter choice here would be to create an LedBasic scene to automate complex
//   fades and other lighting effects, then send that scene at a specific time instead.
//
// - Remember that device type 2 (stepper motor controllers) do not have sound effects and
//   RGB LED capabilities, so you'll need to adjust your command editor forms accordingly.
//   All other 3 device types are the same at the electronic level but switching controller
//   devices simply don't have any motor control capability in Mission Control so you can't
//   send a motor command to it and cause a delay in its GPIO switching.
//
//---------------------------------------------------------------------------------------------
function validateFrame($DBcnx,$json) {
  if ((! isset($json["id"])) || (! is_numeric($json["id"]))) return false;
  if ((! isset($json["cmd_name"])) || (strlen($json["cmd_name"]) == 0)) return false;
  if ((! isset($json["address"])) || (strlen($json["address"]) != 17)) return false;
  if ((! isset($json["position"])) || (! is_numeric($json["position"]))) return false;
  if ((! isset($json["cmd_type"])) || (! is_numeric($json["cmd_type"]))) return false;
  if ((! isset($json["gpio_pin"])) || (! is_numeric($json["gpio_pin"]))) return false;
  if ((! isset($json["direction"])) || (! is_numeric($json["direction"]))) return false;
  if ((! isset($json["speed"])) || (! is_numeric($json["speed"]))) return false;
  if ((! isset($json["duration"])) || (! is_numeric($json["duration"]))) return false;
  if ((! isset($json["progression"])) || (! is_numeric($json["progression"]))) return false;
  if ((! isset($json["steps"])) || (! is_numeric($json["steps"]))) return false;
  if ((! isset($json["resolution"])) || (! is_numeric($json["resolution"]))) return false;
  if ((! isset($json["sound"])) || (! is_numeric($json["sound"]))) return false;
  if ((! isset($json["volume"])) || (! is_numeric($json["volume"]))) return false;
  if ((! isset($json["replay"])) || (! is_numeric($json["replay"]))) return false;
  if ((! isset($json["location_id"])) || (! is_numeric($json["location_id"]))) return false;
  if ((! isset($json["location_action"])) || (! is_numeric($json["location_action"]))) return false;
  if ((! isset($json["location_data"])) || (! is_numeric($json["location_data"]))) return false;
  if ((! isset($json["light"])) || (! is_numeric($json["light"]))) return false;
  if ((! isset($json["red"])) || (! is_numeric($json["red"]))) return false;
  if ((! isset($json["green"])) || (! is_numeric($json["green"]))) return false;
  if ((! isset($json["blue"])) || (! is_numeric($json["blue"]))) return false;
  if ((! isset($json["fade"])) || (! is_numeric($json["fade"]))) return false;
  if ((! isset($json["scene"])) || (! is_numeric($json["scene"]))) return false;
  if ($json["id"] > 0) {
    $Result = mysqli_query($DBcnx,"SELECT * FROM timeline WHERE ID=" . $json["id"]);
    if (mysqli_num_rows($Result) == 0) return false;
  }
  return true;
}
//---------------------------------------------------------------------------------------------
function saveFrame($DBcnx,$json) {
  // Got interrupted by my 9-to-5
}
//---------------------------------------------------------------------------------------------
$Content = $jsonFailure;

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
        if ($Status["current_script"] != "0") { // timeline_scripts is isolated from the API so the current_script ID is replaced by its name
          $Result2 = mysqli_query($DBcnx,"SELECT * FROM timeline_scripts WHERE ID=" . $Status["current_script"]);
          $Script = mysqli_fetch_assoc($Result2);
          $Status["current_script"] = $Script["script_name"];
        } else {
          $Status["current_script"] = "Unsaved Script";
        }
        $Content = json_encode($Status);
      } else {
        http_response_code(500);
        $Content = json_encode(["success" => false,"error" => "Database query failed"]);
      }
      break;
    default:
      // Do nothing, return $jsonFailure
  }
} else {
  $rawData = file_get_contents("php://input");
  $json = json_decode($rawData,true);

  if ((is_array($json)) && (isset($json["action"]))) {
    switch ($json["action"]) {
      case "add": // Add a new command frame to the timeline (requires $json["action"] and every field of the "timeline" database table, $json["id"] must be zero)
        if (validateFrame($DBcnx,$json)) {
          $Result = mysqli_query($DBcnx,"INSERT INTO timeline (cmd_name) VALUES ('Temp')");
          $json["id"] = mysqli_insert_id($DBcnx);
          if (saveFrame($DBcnx,$json)) {
            $Content = $jsonSuccess;
          } else {
            http_response_code(500);
            $Content = json_encode(["success" => false,"error" => "Database query failed"]);
          }
        }
        break;
      case "update": // Update an existing command frame in the timeline (requires $json["action"] and every field of the "timeline" database table)
        if (validateFrame($DBcnx,$json)) {
          if (saveFrame($DBcnx,$json)) {
            $Content = $jsonSuccess;
          } else {
            http_response_code(500);
            $Content = json_encode(["success" => false,"error" => "Database query failed"]);
          }
        }
        break;
      case "delete": // Delete an existing command frame in the timeline (requires $json["action"] and $json["id"])
        if ((isset($json["id"])) && (is_numeric($json["id"]))) {
          $Update = mysqli_query($DBcnx,"DELETE FROM timeline WHERE ID=" . $json["id"]);
          if ($Update === false) {
            http_response_code(500);
            $Content = json_encode(["success" => false,"error" => "Database query failed"]);
          } else {
            $Content = $jsonSuccess;
          }
        }
        break;
      case "setrunning": // Set the running state of the timeline script (requires $json["action"] and $json["running"])
        if ((isset($json["running"])) && (is_numeric($json["running"])) && ($json["running"] >= 0) && ($json["running"] <= 1)) {
          $Update = mysqli_query($DBcnx,"UPDATE timeline_status SET running=" . $json["running"] . " WHERE ID=1");
          $Content = $jsonSuccess;
        }
        break;
      case "setposition": // Set the position to start running the timeline script from (requires $json["action"] and $json["position"])
        if ((isset($json["position"])) && (is_numeric($json["position"])) && ($json["position"] >= 0)) {
          $Update = mysqli_query($DBcnx,"UPDATE timeline_status SET position=" . $json["position"] . " WHERE ID=1");
          $Content = $jsonSuccess;
        }
        break;
      default:
        // Do nothing, return $jsonFailure
    }
  }
}

if ($Content == $jsonFailure) http_response_code(500);
header("Content-Type: application/json");
echo("$Content\n");
//---------------------------------------------------------------------------------------------
mysqli_close($DBcnx);
//---------------------------------------------------------------------------------------------
?>
