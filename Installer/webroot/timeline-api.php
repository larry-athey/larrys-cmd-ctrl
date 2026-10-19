<?php
//---------------------------------------------------------------------------------------------
require_once("/var/www/html/subs.php");
//---------------------------------------------------------------------------------------------
$DBcnx = mysqli_connect(DB_HOST,DB_USER,DB_PASS,DB_NAME);
//---------------------------------------------------------------------------------------------
$Content = $jsonFailure;

// Handle API calls, hope you stocked up on ibruprophen...

if (isset($_GET["action"])) {
  switch ($_GET["action"]) {
    case "list": // ?action=list : Generates JSON arrays from specific MySQL queries
      if (isset($_GET["type"])) {
        switch ($_GET["type"]) {
          case "devices": // ?action=list&type=devices : Returns a JSON array of the "devices" table
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
          default:
            ; // Do nothing
        }
      }
      break;
    case "status":
      // ...
      break;
    default:
      ; // Do nothing
  }
} elseif ((isset($_POST["action"])) && (isset($_POST["data"]))) {
  $action = $_POST["action"];
  $data   = $_POST["data"];

  switch ($_POST["action"]) {
    case "add":
      break;
    case "update":
      break;
    case "delete":
      break;
    case "rewind":
      break;
    case "start":
      break;
    case "stop":
      break;
    default:
      ; // Do nothing
  }
} else {
  $Content = $jsonFailure;
}

if ($Content == $jsonFailure) http_response_code(500);
header("Content-Type: application/json");
echo("$Content\n");
//---------------------------------------------------------------------------------------------
mysqli_close($DBcnx);
//---------------------------------------------------------------------------------------------
?>
