//------------------------------------------------------------------------------------------------
// Larry's CMD & CTRL (LCC) | (CopyLeft) 2025-Present | Larry Athey (https://panhandleponics.com)
//
// Inline functions used for modular unit organization
//------------------------------------------------------------------------------------------------
inline void sendReplayRequest(String Request, String ID) { // Request a repeat of the last command/script
  String Status = "/replay/" + Request + "/" + ID;
  if (Serial) Serial.println("Requesting replay: " + Status);
  sendCommand(Status);
}
//------------------------------------------------------------------------------------------------
inline void setupLights(int ID, uint8_t targetR, uint8_t targetG, uint8_t targetB, float Fade) { // Sets the color of a specific LED or all of them
  #ifndef STEPPER
  char scriptBuf[512];

  Serial.end();
  // Stop any currently running LedBasic script
  if (basic.isRunning()) basic.stop();

  // Guard against zero / negative fade times
  if (Fade <= 0.0f) Fade = 0.001f;

  // Number of steps (aiming for ~25 ms per step)
  const int stepMs = 25;
  int steps = (int)(Fade * 1000.0f / stepMs);
  if (steps < 1) steps = 1;
  if (steps > 200) steps = 200; // safety limit

  // LedBasic variable map (all single letters A–Z only):
  //   T = total steps
  //   U = target R
  //   V = target G
  //   W = target B
  //   S = current step
  //   P = pixel index (single-LED mode)
  //   R,G,B = interpolated color

  if (ID == 65535) {
    // Fade whole bus
    snprintf(scriptBuf, sizeof(scriptBuf),
            "10 T = %d\n"                 // total steps
            "20 U = %d\n"                 // target R
            "30 V = %d\n"                 // target G
            "40 W = %d\n"                 // target B
            "50 S = 0\n"                  // current step
            "100 R = U * S / T\n"         // linear interpolation 0 → target
            "110 G = V * S / T\n"
            "120 B = W * S / T\n"
            "130 FILL R , G , B\n"
            "140 WAIT %d\n"
            "150 S = S + 1\n"
            "160 IF S <= T THEN GOTO 100\n"
            "170 FILL U , V , W\n"        // guarantee exact final color
            "180 SHOW\n",
            steps,targetR,targetG,targetB,stepMs);
  } else {
    // Fade single LED
    snprintf(scriptBuf, sizeof(scriptBuf),
            "10 T = %d\n"
            "20 U = %d\n"
            "30 V = %d\n"
            "40 W = %d\n"
            "50 P = %d\n"                 // pixel index
            "60 S = 0\n"
            "100 R = U * S / T\n"
            "110 G = V * S / T\n"
            "120 B = W * S / T\n"
            "130 SET P , R , G , B\n"
            "140 WAIT %d\n"
            "150 S = S + 1\n"
            "160 IF S <= T THEN GOTO 100\n"
            "170 SET P , U , V , W\n"
            "180 SHOW\n",
            steps,targetR,targetG,targetB,ID,stepMs);
  }

  // Compile & start
  bool Pass = basic.compileFromText(scriptBuf);
  if (Pass) {
    basic.play();
    fadeTarget = millis() + (int)(Fade * 1000.0f);
  }
  Serial.begin(115200);
  if ((! Pass) && (Serial)) {
    delay(1000);
    Serial.println("ERROR: LedBasic code failed to compile!");
  }
  #endif
}
//------------------------------------------------------------------------------------------------
inline void setupLocation(int Pin, int Action, int Data) { // Add a transponder pin and action to the Locations queue
  for (byte i = 0; i <= 15; i ++) {
    if (Locations[i][0] == 0) {
      Locations[i][0] = Pin;
      Locations[i][1] = Action;
      Locations[i][2] = Data;
      if (Serial) {
        Serial.println("Location Pin added: " + String(Pin));
        Serial.println("Location Action added: " + String(Action));
        Serial.println("Location Data added: " + String(Data));
      }
      break;
    }
  }
}
//------------------------------------------------------------------------------------------------
inline void setupMotor(byte Direction, float Speed, int Progression, int Duration) { // Set up motor background process
  #ifndef STEPPER
  unsigned long motorTimestamp = millis();

  if ((motorSpeed > 0) && (Direction != motorDirection)) {
    setMotorSpeed(0);
    while (millis() < motorTimestamp + 2000) {
      delay(10);
    }
    motorTimestamp += 2000;
  }
  setMotorDirection(Direction);

  if (Duration > 0) {
    targetRuntime = motorTimestamp + (Duration * 1000);
  } else {
    targetRuntime = 0;
  }

  targetSpeed = round(Speed);
  if (Progression > 0) {
    if (motorSpeed == 0) {
      progressFactor = Speed / Progression;
      progressDir = 1;
    } else {
      if (Speed > motorSpeed) {
        float Change = Speed - motorSpeed;
        progressFactor = Change / Progression;
        progressDir = 1;
      } else {
        float Change = motorSpeed - Speed;
        progressFactor = Change / Progression;
        progressDir = 0;
      }
    }
  } else {
    setMotorSpeed(Speed);
    progressFactor = 0;
  }
  if (Serial) {
    Serial.println("Motor target speed: " + String(targetSpeed) + "%");
    Serial.println("Motor direction: " + String(Direction));
    Serial.println("Progress time: " + String(Progression) + " seconds");
    Serial.println("Progress factor: " + String(progressFactor) + "%");
    Serial.println("Progress direction: " + String(progressDir));
  }
  #endif
}
//------------------------------------------------------------------------------------------------
inline void setupStepper(byte Direction, byte Resolution, int Steps) { // Set up stepper background process
  #ifdef STEPPER
  String Res = "";
  switch (Resolution) {
    case 1:  // Full step
      digitalWrite(MOT_F,LOW);  digitalWrite(MOT_R,LOW);  digitalWrite(MOT_PWM,LOW);  Res = "Full Step"; break;
    case 2:  // 1/2 step
      digitalWrite(MOT_F,HIGH); digitalWrite(MOT_R,LOW);  digitalWrite(MOT_PWM,LOW);  Res = "1\/2 Step";  break;
    case 4:  // 1/4 step
      digitalWrite(MOT_F,LOW);  digitalWrite(MOT_R,HIGH); digitalWrite(MOT_PWM,LOW);  Res = "1\/4 Step";  break;
    case 8:  // 1/8 step
      digitalWrite(MOT_F,HIGH); digitalWrite(MOT_R,HIGH); digitalWrite(MOT_PWM,LOW);  Res = "1\/8 Step";  break;
    case 16: // 1/16 step
      digitalWrite(MOT_F,LOW);  digitalWrite(MOT_R,LOW);  digitalWrite(MOT_PWM,HIGH); Res = "1\/16 Step"; break;
    case 32: // 1/32 step
      digitalWrite(MOT_F,HIGH); digitalWrite(MOT_R,HIGH); digitalWrite(MOT_PWM,HIGH); Res = "1\/32 Step"; break;
  }
  if (Serial) {
    Serial.println("Stepper direction: " + String(Direction));
    Serial.println("Stepper resolution: " + Res);
    Serial.println("Total steps: " + String(Steps));
  }
  targetPos = (Direction == 1) ? (long)Steps : -(long)Steps;
  float stepsPerSec = 400.0 * Resolution;
  Stepper.setMaxSpeed(stepsPerSec);
  Stepper.setAcceleration(stepsPerSec * 2.0);
  Stepper.setCurrentPosition(0);
  Stepper.moveTo(targetPos);
  stepperRunning = true;
  #endif
}
//------------------------------------------------------------------------------------------------
inline void setupScene(int Scene) { // Pull an LedBasic script from the Mission Control server and run it
  #ifndef STEPPER
  if (sendCommand("/scene-request/" + String(Scene))) {
    Serial.end();
    if (basic.isRunning()) basic.stop();
    bool Pass = basic.compileFromText(scriptCode.c_str());
    if (Pass) basic.play();
    Serial.begin(115200);
    if ((! Pass) && (Serial)) {
      delay(1000);
      Serial.println("ERROR: LedBasic code failed to compile!");
    }
  }
  #endif
}
//------------------------------------------------------------------------------------------------
inline void setupSound(int FileNumber, byte Volume, byte Loop) { // Set up sound effect background process
  #ifndef STEPPER
  if (SFX) {
    if (FileNumber == 0) {
      myDFPlayer.stop();
      return;
    }

    soundFile = FileNumber;
    sfxVolume = Volume;
    if (Loop == 1) {
      sfxLoop = true;
    } else {
      sfxLoop = false;
    }
    if (Serial) {
      Serial.println("Sound file queued: " + String(soundFile));
      Serial.println("Volume level: " + String(Volume));
      Serial.println("Playback loop: " + String(Loop));
    }
  }
  #endif
}
//------------------------------------------------------------------------------------------------
inline void toggleSwitch(byte gpioPin, byte State) { // Toggle a specific GPIO pin
  #ifndef I2CSWITCH
  // Map gpioPin to new values as necessary
  byte thePin = 0;
  if (gpioPin == 0) {
    thePin = OUT_1;
  } else if (gpioPin == 1) {
    thePin = OUT_2;
  } else {
    return;
  }
  digitalWrite(thePin,State);
  #else
  mcp.digitalWrite(gpioPin,State);
  #endif
  if (Serial) {
    Serial.println("Setting GPIO pin: " + String(gpioPin));
    Serial.println("Current state: " + String(State));
  }
}
//------------------------------------------------------------------------------------------------
inline void runCommand(String Cmd) { // Execute a queued LCC Mission Control command
  Cmd.trim();
  if (Cmd.length() == 0) return;

  // Remove any trailing slashes if they exist
  while (Cmd.endsWith("/")) {
    Cmd = Cmd.substring(0,Cmd.length() - 1);
  }

  // Count "/" delimiters
  int delimiterCount = 0;
  for (int i = 0; i < Cmd.length(); i ++) {
    if (Cmd[i] == '/') delimiterCount ++;
  }

  // Create an array for the parts
  String parts[delimiterCount + 1];
  int partCount = 0;
  int startIndex = 0;

  // Split the Cmd string
  while (startIndex < Cmd.length()) {
    int endIndex = Cmd.indexOf('/',startIndex);
    if (endIndex == -1) {
      parts[partCount] = Cmd.substring(startIndex);
      break;
    }
    parts[partCount] = Cmd.substring(startIndex,endIndex);
    partCount ++;
    startIndex = endIndex + 1;
  }

  if (parts[0].length() == 0) {
    for (int i = 0; i < partCount; i ++) {
      parts[i] = parts[i + 1];
    }
  }

  // Send the command execution start notice to Mission Control
  if (! sendCommand("/exec/" + parts[0])) {
    if (Serial) Serial.println("Failed to send /exec/" + parts[0]);
  }

  // parts[0] : Command ID tag (32 character random string)
  // parts[1] : The command type identifier
  // parts[2..(partCount-1)] : Any additional parameters for the command type
  if (parts[1] == "light") {
    //ID/light/led-id/red-level/green-level/blue-level/fade-time
    if (partCount == 7) setupLights(parts[2].toInt(),parts[3].toInt(),parts[4].toInt(),parts[5].toInt(),parts[6].toFloat());
  } else if (parts[1] == "location") {
    //ID/location/pin/action-type/action-data
    if (partCount == 5) setupLocation(parts[2].toInt(),parts[3].toInt(),parts[4].toInt());
  } else if (parts[1] == "motor") {
    //ID/motor/direction/speed/progression/duration
    if (partCount == 6) setupMotor(parts[2].toInt(),parts[3].toInt(),parts[4].toInt(),parts[5].toInt());
  } else if (parts[1] == "reboot") {
    //ID/reboot
    if (partCount == 2) ESP.restart();
  } else if (parts[1] == "replay") {
    //ID/replay/cmd or script/cmd-id or script-id
    if (partCount == 4) sendReplayRequest(parts[2],parts[3]);
  } else if (parts[1] == "scene") {
    //ID/scene/scene-id
    if (partCount == 3) setupScene(parts[2].toInt());
  } else if (parts[1] == "sound") {
    //ID/sound/file-number/volume/loop
    if (partCount == 5) setupSound(parts[2].toInt(),parts[3].toInt(),parts[4].toInt());
  } else if (parts[1] == "stepper") {
    //ID/stepper/direction/resolution/steps
    if (partCount == 5) setupStepper(parts[2].toInt(),parts[3].toInt(),parts[4].toInt());
  } else if (parts[1] == "switch") {
    //ID/switch/gpio/state
    if (partCount == 4) toggleSwitch(parts[2].toInt(),parts[3].toInt());
  } else if (parts[1] == "update-firmware") {
    //ID/update-firmware (reboot in OTA firmware updater mode)
    FWupdate = true;
    SetMemory();
    ESP.restart();
  } else if (parts[1] == "wifi-signal") {
    //ID/wifi-signal
    sendCommand("/wifi-signal/" + String(WiFi.RSSI()));
  }
}
//------------------------------------------------------------------------------------------------
inline void processQueue() { // Process the next command in the queue (FIFO style handling)
  // Prevent new motor/stepper control and RGB LED commands from cancelling incomplete ones
  #ifndef STEPPER
  if ((motorSpeed != targetSpeed) || (millis() < fadeTarget)) return;
  #else
  if (Stepper.isRunning()) return;
  #endif
  if (Commands[0].length() > 0) {
    if (Serial) Serial.println("Executing: " + Commands[0]);
    runCommand(Commands[0]);
    for (byte i = 0; i <= 15; i ++) { // Remove the processed command from the queue
      Commands[i] = Commands[i + 1];
    }
    Commands[16].clear(); // Add a blank slot to the end of the queue
  }
}
//------------------------------------------------------------------------------------------------
