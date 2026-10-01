//------------------------------------------------------------------------------------------------
// Larry's CMD & CTRL (LCC) | (CopyLeft) 2025-Present | Larry Athey (https://panhandleponics.com)
//
// You must be using the Espressif ESP32 v2.0.17 library to compile this code. You will need to
// add the URL below in your Arduino IDE preferences under Additional Boards Manager URLs.
//
// https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
//
// This project is based on the ESP32-S3, I'm using a Seeed Studio XAIO ESP32-S3 development board.
//
// Arduino IDE Board: ESP32S3 Dev Module
//
// NOTE: This project originally started out as LoRa CMD & CTRL using Reyax RYLR998 modems for the
// communications backbone. These turned out to introduce too much delay in the communications, so
// I switched things to a client/server model on a dedicated low-tech basic 802.11bg network. Even
// if the Mission Control server is hard-wired to your network, its WiFi AP doesn't route into it.
// This system is still totally functional without any internet access into the building.
//
// FOLLOWUP: Yes, I also tried using ESP-NOW and it was even more unreliable than the LoRa modems.
//
// This is an LCC slave unit prototype that can be used for anything from a model train locomotive
// to anything else where you may need to wirelessly control a brushed motor with a PWM, a stepper
// motor, RGB LEDs, a bank of solid state relays, or even play MP3 files for announcements/alerts,
// all on a manual, triggered, or scheduled basis.
//
// For model railroad enthusiasts, this ESP32 project and a collection of components that can be
// mounted in the top of an HO scale (or larger) locomotive body to accomplish everything that you
// can do with a DCC/WCC locomotive (and more) for not a whole lot of money.
//
// These components are as follows:
//
//   Seeed XAIO ESP32-S3  - $7.50
//   TB6612FNG H-Bridge   - $3.50
//   TSOP34838 IR Rcvr    - $1.00
//   WWZMDiB Audio Module - $2.00
//   10x15mm Speaker      - $0.80
//   2x WS2812 RGB LED    - $2.00
//   5V 1.8A Regulator    - $0.70
//   2A Bridge Rectifier  - $0.50
//
// Less than $20 in parts to convert any model train locomotive to have all of the features found
// in a full blown DCC enabled locomotive with sound effects.
//
// Commands from the LCC Mission Control server are stored in a buffer on an LCC Save device and
// then executed in a FIFO (first-in, first-out) order. Feedback is sent back to the server when
// a command starts so the operator knows what each device is doing at any moment.
//
// Sound effects are MP3 files and stored on an SD card (up to 32GB) in the MP3 player. These can
// be played in a single shot or in a loop. Sound effects are played by a separate MP3 player unit
// rather than the ESP32 itself which prevents other CPU tasks from interrupting sound effects.
//------------------------------------------------------------------------------------------------
// LCC Mission Control Server:
//
//   Orange Pi Zero 3 1GB     - $40.00 (with power supply)
//   3D Printed Case          - $3.00
//
// LCC Location Transponder:
//
//   Seeed XIAO SAMD21        - $5.00
//   3.3v 3A Regulator        - $0.70
//   IR LED Transmitter       - $1.00
//   3D Printed Case          - $2.00
//
// NOTE: The location transponder MCU can actually run up to 11 unique LED transmitters.
/************************************************************************************************/
//#define STEPPER                // Remember, no sound effects are possible when using a stepper
/************************************************************************************************/
#define DISABLE_CODE_FOR_TRANSMITTER
#define SEND_LEDC_CHANNEL 1
#include "IRremote.hpp"          // IR remote controller library, for location/position detection

#ifndef STEPPER
#include "DFRobotDFPlayerMini.h" // From https://github.com/DFRobot/DFRobotDFPlayerMini
#endif

#include "WiFi.h"                // ESP32 high-level WiFi connectivity library
#include "esp_wifi.h"            // ESP32 low-level WiFi connectivity library
#include "HTTPClient.h"          // HTTP client library used for communicating with slave units
#include "ESP32Ping.h"           // ICMP (ping) library from https://github.com/marian-craciunescu/ESP32Ping
#include "Preferences.h"         // ESP32 Flash memory read/write library
#include "Adafruit_NeoPixel.h"   // Used for LedBasic scripting of LED lighting scenes
#include "LedBasic.h"            // NeoPixel BASIC scripting from https://github.com/vktrsansara/LedBasic (Russian)
//------------------------------------------------------------------------------------------------
#define LED_PIN 21               // Internal LED on GPIO21
#define TOTAL_LEDS 64            // Total number of LEDs on the Neopixel/WS2812 lighting bus
// GPIO Left side (USB top)
#define LIMIT_1 1                // Limit switch 1 (forward)
#define LIMIT_2 2                // Limit switch 2 (reverse)
#define IR_RCV 3                 // TSOP34838 input pin
#define OUT_1 4                  // Output 1 (SSR) or DRV8825 M0
#define OUT_2 5                  // Output 2 (SSR) or DRV8825 M1
#define MOT_PWM 6                // H-Bridge PWM or DRV8825 M2
// GPIO Right side (USB top)
#define OUT_3 13                 // Output 3 (SSR)
#define OUT_4 12                 // Output 4 (SSR)
#define MOT_F 11                 // H-Bridge forward pin or user defined if using a stepper
#define MOT_R 10                 // H-Bridge reverse pin or user defined if using a stepper
#define BUS_1 9                  // DFRobot TX or DRV8825 step pin
#define BUS_2 8                  // DFRobot RX or DRV8825 direction pin
#define BUS_3 7                  // NeoPixel/WS2812 bus or DRV8825 sleep pin
//------------------------------------------------------------------------------------------------
#ifndef STEPPER
DFRobotDFPlayerMini myDFPlayer;  // Set up the sound effects system object
#endif
Adafruit_NeoPixel neopixel(1,LED_PIN,NEO_RGB + NEO_KHZ800); // Set up the heartbeat/pulse LED
#ifndef STEPPER
Adafruit_NeoPixel lights(TOTAL_LEDS,BUS_3,NEO_RGB + NEO_KHZ800); // Set up the Neopixel/WS2812 lighting bus
LedBasic basic( // Set up the LedBasic callbacks
  TOTAL_LEDS,
  // set pixel
  [](uint16_t pos, uint8_t r, uint8_t g, uint8_t b) {
    lights.setPixelColor(pos, lights.Color(r, g, b));
  },
  // show
  []() { lights.show(); },
  // clear
  []() { lights.clear(); lights.show(); }
);
#endif
Preferences preferences;
WiFiServer Server(80);
//------------------------------------------------------------------------------------------------
bool SFX = false;                // True if the sound effects system successfully initialized
bool sfxLoop = false;            // True if a sound effect command is supposed to play endlessly
byte cmdCount = 0;               // Counts the number of received mission control commands
byte pulseIndex = 1;             // Tracks the color changes for the heartbeat/pulse LED
byte motorDirection = 1;         // Motor direction, 0 = reverse, 1 = forward
byte progressDir = 0;            // Motor speed progress direction, 0 = down, 1 = up
byte sysInit = 0;                // Flag to indicate whether this is a first boot and no flash settings
byte stepperSpeed = 0;           // Speed percentage for the stepper motor PWM
byte wifiCheckCounter = 0;       // Used to check the WiFi connection once every 30 seconds
int Locations[16][3];            // Queue for caching location ID numbers and associated actions
int soundFile = -1;              // Sound file number to play from the DFPlayer Mini
unsigned long currentPos = 0;    // Stepper current position relative to targetPos
unsigned long lastCheck = 0;     // Used to track 1-second checks in the main loop()
unsigned long motorTimestamp = 0;// Timestamp of the last motor command execution
unsigned long stepperCheck = 0;  // Used for stepper PWM time keeping in the main loop()
unsigned long targetPos = 0;     // Stepper target position of the last executed command
unsigned long targetRuntime = 0; // Timestamp of the motor end run (0 = indefinite runtime)
float motorSpeed = 0.0;          // Current motor speed [0..100]
float progressFactor = 0.0;      // How much (percent) to change the motor speed per second
float targetSpeed = 0.0;         // Motor target speed [0..100]
String Commands[17];             // Queue for caching up to 16 commands plus 1 repeat command 
String myMacStr = "";            // MAC address string, used as the device ID in Mission Control
String scriptCode = "";          // LedBasic script code downloaded from Mission Control
String serverIP = "";            // Mission Control server IP address
String wifiSSID = "LCC-WLAN";    // WiFi SSID (network name)
String wifiPW = "1a2b3c4d5e";    // WiFi password
String Version = "1.0.1";        // Current release version of the project

String jsonSuccess = "{\"status\": \"success\",\"message\": \"Operation completed successfully\"}";
String jsonFailure = "{\"status\": \"error\",\"message\": \"Operation failed\"}";
//------------------------------------------------------------------------------------------------
bool sendCommand(String Cmd) { // Send LCC messages to Mission Control
  bool Result = true;

  if (Serial) Serial.println("Sending: " + Cmd);

  HTTPClient http;
  http.begin("http://" + serverIP + "/slave-post.php?addr=" + myMacStr + "&cmd=" + Cmd);
  int httpCode = http.GET(); 
  if (httpCode > 0) {
    if (httpCode == HTTP_CODE_OK) {
      String Payload = http.getString();
      Payload.trim();
      //if (Serial) Serial.println("Received: " + Payload);
      if (Cmd.indexOf("/scene-request/") == 0) {
        // Payload will be an LedBasic script
        Payload.replace("\r","");
        Payload.toUpperCase();
        scriptCode = Payload;
      } else {
        if (Payload != jsonSuccess) Result = false;
      }
    }
  } else {
    Result = false;
    if (Serial) Serial.printf("Error: %s\n",http.errorToString(httpCode).c_str());
  }
  http.end();
  return Result;
}
//------------------------------------------------------------------------------------------------
void setup() {
  Serial.begin(115200);
  delay(1000);
  if (Serial) Serial.println("Starting LCC Slave v" + Version);

  // Get the last user settings from flash memory
  GetMemory();
  if (sysInit == 1) {
    sysInit = 0;
    SetMemory();
  }

  // Initialize the Neopixel bus for the heartbeat/pulse LED
  neopixel.begin();
  neopixel.setBrightness(15);
  neopixel.clear();
  neopixel.setPixelColor(0,neopixel.Color(0,0,255));
  neopixel.show();

  // Initialize the Neopixel bus for the locomotive lights
  lights.begin();
  lights.setBrightness(100);
  lights.clear();
  lights.setPixelColor(0,lights.Color(255,255,255));
  lights.setPixelColor(1,lights.Color(255,0,0));
  lights.show();

  // Intialize the GPIO pins
  pinMode(IR_RCV,INPUT_PULLUP);
  pinMode(LIMIT_1,INPUT_PULLUP); // Probably not of much use in a model train locomotive
  pinMode(LIMIT_2,INPUT_PULLUP); // Convert these to outputs if you need additional ones
  pinMode(OUT_1,OUTPUT); digitalWrite(OUT_1,LOW);
  pinMode(OUT_2,OUTPUT); digitalWrite(OUT_2,LOW);
  pinMode(OUT_3,OUTPUT); digitalWrite(OUT_3,LOW);
  pinMode(OUT_4,OUTPUT); digitalWrite(OUT_4,LOW);
  pinMode(MOT_F,OUTPUT); digitalWrite(MOT_F,LOW); // AIN1 (Standby is pulled high to enable the driver)
  pinMode(MOT_R,OUTPUT); digitalWrite(MOT_R,LOW); // AIN2
  pinMode(MOT_PWM,OUTPUT); digitalWrite(MOT_PWM,LOW); // PWMA

  #ifndef STEPPER
  // Initialize the PWM motor speed/direction controller
  ledcSetup(0,20000,8); // 20 KHz, 8 bit resolution
  ledcAttachPin(MOT_PWM,0);
  ledcWrite(0,0); // Set the speed to zero [0..255]
  #else
  
  #endif
  setMotorDirection(1);

  // Initialize the location/position detection sensor
  IrReceiver.begin(IR_RCV,DISABLE_LED_FEEDBACK);

  #ifndef STEPPER
  // Initialize the sound effects system
  Serial1.begin(9600,SERIAL_8N1,BUS_2,BUS_1);
  if (Serial) Serial.println(F("Initializing DFPlayer Mini..."));
  if (! myDFPlayer.begin(Serial1)) {
    if (Serial) Serial.println(F("Unable to initialize DFPlayer Mini"));
  } else {
    if (Serial) Serial.println(F("DFPlayer Mini successfully started"));
    myDFPlayer.volume(20); // [0..30]
    SFX = true;
  }
  #endif

  // Zero out the location detection and task queue
  for (byte i = 0; i <= 15; i ++) {
    Locations[i][0] = 0;
    Locations[i][1] = 0;
    Locations[i][2] = 0;
  }

  ConnectWiFi();

  if (Serial) {
    if (WiFi.status() == WL_CONNECTED) {
      Serial.println("LCC Slave waiting for commands.");
    } else{
      Serial.println("LCC Slave waiting for network connection.");
    }
  }

  // Initialize the main loop() 1 second timer
  lastCheck = millis();
}
//------------------------------------------------------------------------------------------------
void ConnectWiFi() { // Connect to Mission Control access point
  byte x = 0;
  if (Server) Server.end();
  WiFi.mode(WIFI_STA);
  WiFi.setSleep(false);
  esp_wifi_set_ps(WIFI_PS_NONE);
  WiFi.disconnect();
  myMacStr = WiFi.macAddress();
  myMacStr.toLowerCase();
  myMacStr.replace(":","-");

  uint8_t protocol = WIFI_PROTOCOL_11B | WIFI_PROTOCOL_11G;
  esp_wifi_set_protocol(WIFI_IF_STA,protocol); // Force only 802.11bg mode (no N channel)
  esp_wifi_set_bandwidth(WIFI_IF_STA,WIFI_BW_HT20); // Force 20 MHz bandwidth
  esp_wifi_set_max_tx_power(84); // Maximum TX power (unit is 0.25 dBm, so 84 = 21 dBm)

  String Hostname = myMacStr + ".lcc.local";
  WiFi.setHostname(Hostname.c_str());
  WiFi.begin(wifiSSID,wifiPW);
  if (Serial) Serial.print("\nConnecting to WiFi ..");
  while (WiFi.status() != WL_CONNECTED) {
    if (Serial) Serial.print('.');
    delay(1000);
    x ++;
    if (x == 15) break;
  }
  if (WiFi.status() == WL_CONNECTED) {
    Server.begin();
    serverIP = WiFi.gatewayIP().toString();
    if (Serial) Serial.println(" WiFi Connected!\n");
  } else {
    if (Serial) Serial.println("\nConnection Failed!\n");
    delay(2000);
  }
}
//------------------------------------------------------------------------------------------------
void GetMemory() { // Get the configuration settings from flash memory on startup
  preferences.begin("prefs",true);
  wifiSSID   = preferences.getString("wifi_ssid","LCC-WLAN");
  wifiPW     = preferences.getString("wifi_pw","1a2b3c4d5e");
  sysInit    = preferences.getUInt("sys_init",1);
  preferences.end();
}
//------------------------------------------------------------------------------------------------
void SetMemory() { // Update flash memory with the current configuration settings
  preferences.begin("prefs",false);
  preferences.putString("wifi_ssid",wifiSSID);
  preferences.putString("wifi_pw",wifiPW);
  preferences.putUInt("sys_init",sysInit);
  preferences.end();
}
//------------------------------------------------------------------------------------------------
bool beaconCheck(int Pin) { // Perform any registered actions based on the current location beacon
  String Request;
  for (byte i = 0; i <= 15; i ++) {
    if (Pin == Locations[i][0]) {
      if (Locations[i][1] == 1) { // Stop motor/stepper
        setMotorSpeed(0);
        targetRuntime = 0;
        targetSpeed = 0;
        progressFactor = 0;
      } else if (Locations[i][1] == 2) { // Play sound effect
        soundFile = Locations[i][2];
        sfxLoop = false;
      } else if (Locations[i][1] == 3) { // Request command with /replay/cmd/#
        Request = "/replay/cmd/" + String(Locations[i][2]);
        sendCommand(Request);
      } else if (Locations[i][1] == 4) { // Request script with /replay/scr/#
        Request = "/replay/scr/" + String(Locations[i][2]);
        sendCommand(Request);
      } else if (Locations[i][1] == 5) { // Toggle GPIO pin
        byte State = digitalRead(Locations[i][2]);
        if (State == 0) {
          digitalWrite(Locations[i][2],HIGH);
        } else {
          digitalWrite(Locations[i][2],LOW);
        }
      } else if (Locations[i][1] == 6) { // Toggle a specific (or all) Neopixel/WS2812 (off or full white)
        if (Locations[i][2] < 65535) {
          uint32_t currentColor = lights.getPixelColor(Locations[i][2]);
          if (currentColor == 0) {
            lights.setPixelColor(Locations[i][2],lights.Color(255,255,255));
          } else {
            lights.setPixelColor(Locations[i][2],lights.Color(0,0,0));
          }
        } else {
          uint32_t currentColor = lights.getPixelColor(0);
          if (currentColor == 0) {
            for (int x = 0; x < TOTAL_LEDS; x ++) {
              lights.setPixelColor(x,lights.Color(255,255,255));
            }
          } else {
            for (int x = 0; x < TOTAL_LEDS; x ++) {
              lights.setPixelColor(x,lights.Color(0,0,0));
            }
          }
        }
        lights.show();
      }
      // Clear the location memory slot
      Locations[i][0] = 0;
      Locations[i][1] = 0;
      Locations[i][2] = 0;
      return true;
    }
  }
  return false;
}
//------------------------------------------------------------------------------------------------
void setMotorSpeed(float Percent) { // Set the motor speed
  motorSpeed = Percent;
  if (Serial) Serial.println("Set motor speed: " + String(Percent) + "%");
  #ifndef STEPPER
  ledcWrite(0,round(motorSpeed * 2.55));
  #else

  #endif
}
//------------------------------------------------------------------------------------------------
void setMotorDirection(byte Direction) { // Set the motor direction
  motorDirection = Direction;
  #ifndef STEPPER
  if (Direction == 1) {
    digitalWrite(MOT_F,HIGH);
    digitalWrite(MOT_R,LOW);
  } else {
    digitalWrite(MOT_F,LOW);
    digitalWrite(MOT_R,HIGH);
  }
  #else

  #endif
}
//------------------------------------------------------------------------------------------------
void pulseLED() { // Update the color of the heartbeat/pulse LED
  pulseIndex ++;
  if (pulseIndex > 7) pulseIndex = 1;
  if (pulseIndex == 1) {
    neopixel.setPixelColor(0,neopixel.Color(0,0,255));
  } else if (pulseIndex == 2) {
    neopixel.setPixelColor(0,neopixel.Color(0,255,255));
  } else if (pulseIndex == 3) {
    neopixel.setPixelColor(0,neopixel.Color(0,255,0));
  } else if (pulseIndex == 4) {
    neopixel.setPixelColor(0,neopixel.Color(255,255,0));
  } else if (pulseIndex == 5) {
    neopixel.setPixelColor(0,neopixel.Color(255,0,0));
  } else if (pulseIndex == 6) {
    neopixel.setPixelColor(0,neopixel.Color(255,0,255));
  } else if (pulseIndex == 7) {
    neopixel.setPixelColor(0,neopixel.Color(255,255,255));
  }
  neopixel.show();
}
//------------------------------------------------------------------------------------------------
bool processCmd(String Cmd) { // Process AT+ commands received via serial communications
  if (Cmd.indexOf("AT+") == 0) {
    Cmd.remove(0,3);
    if (Cmd.indexOf("CMD=") == 0) {
      // AT+CMD=
      Cmd.remove(0,4);
      if (sendCommand(Cmd)) {
        return true;
      } else {
        return false;
      }
    } else if (Cmd == "HOSTNAME") {
      // AT+HOSTNAME
      Serial.println(myMacStr + ".lcc.local");
      return true;
    } else if (Cmd == "MAC") {
      // AT+MAC
      Serial.println(myMacStr);
      return true;      
    } if (Cmd == "PASSWD") {
      // AT+PASSWD
      Serial.println(wifiPW);
      return true;
    } else if (Cmd.indexOf("PASSWD=") == 0) {
      // AT+PASSWD=
      Cmd.remove(0,7);
      Cmd.toLowerCase();
      wifiPW = Cmd;
      SetMemory();
      return true;
    } if (Cmd == "RECON") {
      // AT+RECON
      ConnectWiFi();
      return true;
    } if (Cmd == "RESET") {
      // AT+RESET
      Serial.println("Rebooting...");
      delay(1000);
      ESP.restart();
    } if (Cmd == "SERVER") {
      // AT+SERVER
      Serial.println(serverIP);
      return true;
    } if (Cmd == "SSID") {
      // AT+SSID
      Serial.println(wifiSSID);
      return true;
    } else if (Cmd.indexOf("SSID=") == 0) {
      // AT+SSID=
      Cmd.remove(0,5);
      wifiSSID = Cmd;
      SetMemory();
      return true;
    } if (Cmd == "VERSION") {
      // AT+VERSION
      Serial.println("v" + Version);
      return true;
    } if (Cmd == "WIFISTATS") {
      // AT+WIFISTATS
      Serial.println("WiFi Channel: " + String(WiFi.channel()) + "\n" + "WiFi Signal: " + String(WiFi.RSSI()));
      return true;
    } if (Cmd == "Z") {
      // AT+Z (factory reset)
      wifiSSID = "LCC-WLAN";
      wifiPW = "1a2b3c4d5e";
      SetMemory();
      ESP.restart();
    }
    return false;
  } else {
    return false;
  }
}
//------------------------------------------------------------------------------------------------
void queueCommand(String Header) {
  Header.remove(0,4); // Delete the "GET " from the beginning
  Header.remove(Header.indexOf(" HTTP/1.1"),9); // Delete the " HTTP/1.1" from the end
  for (byte i = 0; i <= 16; i ++) { // Add the command to the queue
    if (Commands[i].length() == 0) {
      Commands[i] = Header;
      cmdCount ++;
      break;
    }
  }
}
//------------------------------------------------------------------------------------------------
// External function includes are used here to reduce the overall size of the main sketch.
// Go ahead and call it non-standard, but I don't like spaghetti code that goes on forever.
#include "lcc_api.h" // Inline function library for the LCC message processing functions.
//------------------------------------------------------------------------------------------------
void loop() {
  static StepperOn = false;
  unsigned long stepperTime = micros();
  unsigned long CurrentTime = millis();
  if (CurrentTime > 4200000000) {
    // Reboot the system if we're reaching the maximum long integer value of CurrentTime (49 days)
    ESP.restart();
  } 

  // Give the LedBasic engine some CPU time on every loop iteration
  basic.tick();

  // Check for LCC commands and handle as necessary
  WiFiClient Client = Server.available();
  if (Client) {
    IPAddress clientIP = Client.remoteIP();
    IPAddress gatewayIP = WiFi.gatewayIP();
    long PreviousTime = CurrentTime;
    String Header = "";
    while (Client.connected() && CurrentTime - PreviousTime <= 5000) { // 5 second connection timeout
      CurrentTime = millis();
      if (Client.available()) {
        char c = Client.read();
        if ((c != '\r') && (c != '\n')) Header += c;
        if (c == '\n') {
          if (Header.indexOf("GET ") == 0) {
            if (clientIP == gatewayIP) { // Only allow commands from Mission Control
              queueCommand(Header);
              Client.println(jsonSuccess);
            } else {
              Client.println(jsonFailure);
            }
            break;
          }
        }
      }
    }
    Client.stop();
  }

  #ifndef STEPPER
  // Handle the sound effects as necessary
  if (SFX) {
    if (soundFile >= 0) {
      if (sfxLoop)  {
        myDFPlayer.loop(soundFile);
      } else {
        myDFPlayer.play(soundFile);
      }
      soundFile = -1;
    }
  }
  #endif

  // Shut down the motor if either limit switch has been tripped
  if ((motorSpeed > 0) && ((digitalRead(LIMIT_1) == 0) || (digitalRead(LIMIT_2) == 0))) {
    setMotorSpeed(0);
    targetRuntime = 0;
    targetSpeed = 0;
    progressFactor = 0;
    String Status;
    if (digitalRead(LIMIT_1) == 0) {
      Status = "/limit/0";
    } else {
      Status = "/limit/1";
    }
    if (Serial) Serial.println("Limit switch tripped: " + Status);
    // Send the status notification to mission control
    sendCommand(Status);
  }

  // Handle new location transponder detection
  if (IrReceiver.decode()) {
    uint32_t Location = IrReceiver.decodedIRData.decodedRawData;

    String Status;
    if (beaconCheck(Location)) {
      Status = "/location/" + String(Location) + "/action";
    } else {
      Status = "/location/" + String(Location) + "/report";
    }
    if (Serial) Serial.println("Location transponder detected: " + Status);
    sendCommand(Status);

    IrReceiver.resume();
  }

  #ifndef STEPPER
  // Shut down the motor if a target runtime has been set and met
  if ((targetRuntime > 0) && (CurrentTime >= targetRuntime)) {
    setMotorSpeed(0);
    targetSpeed = 0;
    progressFactor = 0;
    targetRuntime = 0;
    // Send the runtime end status to mission control
    String Status = "/runtime/end";
    if (Serial) Serial.println("Status: " + Status);
    sendCommand(Status);
  }
  #endif

  if (CurrentTime - lastCheck >= 1000) {
    #ifndef STEPPER
    // Handle motor speed progression
    if (motorSpeed != targetSpeed) {
      float Update = 0;
      if ((progressDir == 1) && (motorSpeed < targetSpeed)) {
        Update = motorSpeed + progressFactor;
        if (Update > 100) Update = 100;
        if (Update > targetSpeed) Update = targetSpeed;
      } else if ((progressDir == 0) && (motorSpeed > targetSpeed)) {
        Update = motorSpeed - progressFactor;
        if (Update < 1) Update = 0;
        if (Update < targetSpeed) Update = targetSpeed;
      }
      setMotorSpeed(Update);
    }
    #endif

    wifiCheckCounter ++;

    if (wifiCheckCounter >= 30) {
      bool PingTest = Ping.ping(serverIP.c_str(),2);
      if ((WiFi.status() != WL_CONNECTED) || (! PingTest)) { // Reconnect WiFi if we got dropped
        WiFi.disconnect(true);
        delay(250);
        if ((wifiSSID != "") && (wifiPW != "")) {
          WiFi.mode(WIFI_OFF);
          delay(500);
          ConnectWiFi();
        }
      }
      wifiCheckCounter = 0;
    }

    pulseLED();
    lastCheck = CurrentTime;
  }

  #ifdef STEPPER
    // Stepper speed works as a 1-second PWM, each 1% equals 10ms motor-on time per second

  #endif

  while (Serial.available()) {
    String Data = Serial.readStringUntil('\n');
    Data.trim();
    Data.toUpperCase();
    if (Data == "AT") {
      Serial.print("OK\r\n");
    } else {
      if (Data.length() > 0) {
        if (processCmd(Data)) {
          Serial.print("+OK\r\n");
        } else {
          Serial.print("+ERROR\r\n");
        }
      }
    }
  }

  // Execute the next command (if any) in the queue
  processQueue();
}
//------------------------------------------------------------------------------------------------
/*
// Location transponder code

#include <IRremote.hpp>

#define IR_SEND_PIN 6  // Use D6 (PA06) for IR LED, a PWM-capable pin
const uint16_t LOCATION_ID = 0x03;  // Unique ID for this track section

IRsend irsend(IR_SEND_PIN);  // Initialize IRsend with specific pin

void setup() {
  Serial.begin(115200);
  while (!Serial) {
    ; // Wait for Serial to initialize (important for XIAO SAMD21)
  }
  Serial.println("XIAO SAMD21 IR Transmitter Initialized");
}

void loop() {
  irsend.sendNEC(LOCATION_ID, 8);  // Send 8-bit LOCATION_ID using NEC protocol
  Serial.print("Sent IR Code: 0x");
  Serial.println(LOCATION_ID, HEX);
  delay(50);  // Repeat every 50 ms
}
*/