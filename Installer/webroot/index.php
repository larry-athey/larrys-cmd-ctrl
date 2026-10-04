<?php
//---------------------------------------------------------------------------------------------------
require_once("html.php");
//---------------------------------------------------------------------------------------------------
?>
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
  <title>LCC Mission Control v<?= VERSION ?></title>
  <meta charset="UTF-8">
  <meta http-equiv="cache-control" content="max-age=0">
  <meta http-equiv="cache-control" content="no-cache">
  <meta http-equiv="expires" content="0">
  <meta http-equiv="expires" content="Tue, 01 Jan 1980 1:00:00 GMT">
  <meta http-equiv="pragma" content="no-cache">
  <meta http-equiv="refresh" content="3600">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <link href="/assets/css/prism-tomorrow.min.css" rel="stylesheet">
  <link href="/assets/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <script src="/assets/bootstrap/js/bootstrap.bundle.min.js"></script>
  <!-- script src="/assets/js/chart.js"></script -->
  <script src="/assets/js/jquery.min.js"></script>
  <link rel="icon" href="/favicon.ico?v=1.1">
  <script type="text/javascript">
    //---------------------------------------------------------------------------------------------------
    $(function() {
      $("#rssFG").addClass("text-purple");
      $("#rssBG").addClass("bg-purple");
    });
    //---------------------------------------------------------------------------------------------------
  </script>
  <style>
    .navbar-brand-img {
      max-height: 40px;
      width: auto;
    }

    .text-magenta {
      color: purple !important;
    }
    .bg-magenta {
      background-color: purple !important;
    }

    @-webkit-keyframes blinker {
      from {opacity: 1.0;}
      to {opacity: 0.0;}
    }

    .blink {
      text-decoration: blink;
      -webkit-animation-name: blinker;
      -webkit-animation-duration: 0.6s;
      -webkit-animation-iteration-count:infinite;
      -webkit-animation-timing-function:ease-in-out;
      -webkit-animation-direction: alternate;
    }

    a, a:hover {text-decoration: none;}

   .editor {
      border: 1px solid #444;
      border-radius: 6px;
      min-height: 320px;
      max-height: 600px;
      overflow: auto;
      padding: 12px 14px;
      font-family: "Cascadia Code", "Fira Code", "Source Code Pro", Consolas, monospace;
      font-size: 14px;
      line-height: 1.45;
      tab-size: 2;
      white-space: pre;
      background: #1e1e1e;          /* matches prism-tomorrow */
      color: #ccc;
      outline: none;
    }
  </style>
</head>
<body>
<?php
$DBcnx = mysqli_connect(DB_HOST,DB_USER,DB_PASS,DB_NAME);

echo(drawMenu($DBcnx) . "\n");

/*
if (isset($_GET["cmd"])) {
  if ($_GET["cmd"] == 0) {
    echo(sendCommand($DBcnx,100,"/motor/1/0/15/0"));
  } elseif ($_GET["cmd"] == 1) {
    echo(sendCommand($DBcnx,100,"/motor/1/25/30/0"));
  } elseif ($_GET["cmd"] == 2) {
    echo(sendCommand($DBcnx,100,"/motor/1/50/30/0"));
  } elseif ($_GET["cmd"] == 3) {
    echo(sendCommand($DBcnx,100,"/motor/1/75/30/0"));
  } elseif ($_GET["cmd"] == 4) {
    echo(sendCommand($DBcnx,100,"/motor/1/100/30/0"));
  } elseif ($_GET["cmd"] == 5) {
    echo(sendCommand($DBcnx,100,"/sound/1/0"));
  }
}
*/

$Content  = "<div class=\"container-fluid\" style=\"align: left; margin-top: 0.5em;\">";
$Content .=   "<div class=\"row\">";

if (! isset($_GET["page"])) {
  $Content .= showHomePage($DBcnx);
} else {
  if ($_GET["page"] == "commands") {
    $Content .= showCommands($DBcnx);
  } elseif ($_GET["page"] == "delete_confirm") {
    $Content .= deleteConfirm($DBcnx);
  } elseif ($_GET["page"] == "devices") {
    $Content .= showDevices($DBcnx);
  } elseif ($_GET["page"] == "edit_command") {
    $Content .= editCommand($DBcnx);
  } elseif ($_GET["page"] == "edit_device") {
    $Content .= editDevice($DBcnx);
  } elseif ($_GET["page"] == "edit_location") {
    $Content .= editLocation($DBcnx);
  } elseif ($_GET["page"] == "edit_scene") {
    $Content .= editScene($DBcnx);
  } elseif ($_GET["page"] == "edit_script") {
    $Content .= editScript($DBcnx);
  } elseif ($_GET["page"] == "edit_task") {
    $Content .= editTask($DBcnx);
  } elseif ($_GET["page"] == "locations") {
    $Content .= showLocations($DBcnx);
  } elseif ($_GET["page"] == "logs") {
    $Content .= showLogs($DBcnx);
  } elseif ($_GET["page"] == "pairing") {
    $Content .= setPairing($DBcnx);
  } elseif ($_GET["page"] == "scenes") {
    $Content .= showScenes($DBcnx);
  } elseif ($_GET["page"] == "schedule") {
    $Content .= showSchedule($DBcnx);
  } elseif ($_GET["page"] == "scripts") {
    $Content .= showScripts($DBcnx);
  }
}

$Content .=   "</div>";
$Content .= "</div>";

echo("$Content\n");
mysqli_close($DBcnx);
?>
</body>
</html>
