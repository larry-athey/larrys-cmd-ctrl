//------------------------------------------------------------------------------------------------
// Larry's CMD & CTRL (LCC) | (CopyLeft) 2025-Present | Larry Athey (https://panhandleponics.com)
//
// You must be using the Espressif ESP32 v2.0.17 library to compile this code. This code will not
// fit in the majority of ESP32 boards using v3.x board libraries. You will need to add the URL
// below in your Arduino IDE preferences under Additional Boards Manager URLs.
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
// FOLLOWUP: Yes, I also tried using ESP-NOW and it was even less reliable than the LoRa modems.
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
//   Seeed XIAO ESP32-S3      - $5.00
//   3.3v 3A Regulator        - $0.70
//   IR LED Transmitter       - $1.00
//   3D Printed Case          - $2.00
//
// NOTE: The location transponder MCU can actually run up to 11 unique LED transmitters.
/************************************************************************************************/
//#define I2CSWITCH              // Use an MCP23017 GPIO expansion module for all GPIO switching
//#define STEPPER                // Remember, no sound effects are possible when using a stepper
//#define WAVESHARE              // Define this if you are using a Waveshare ESP32-S3FH4R2 board
/************************************************************************************************/
#define DISABLE_CODE_FOR_TRANSMITTER
#define SEND_LEDC_CHANNEL 2
#include "IRremote.hpp"          // IR remote controller library, for location/position detection

#ifdef I2CSWITCH
#include "Wire.h"                // I2C communications library
#include "Adafruit_MCP23X17.h"   // MCP23017 I2C 16 port GPIO expansion module library
#endif

#ifndef STEPPER
#include "DFRobotDFPlayerMini.h" // From https://github.com/DFRobot/DFRobotDFPlayerMini
                                 // NOTE: DFPlayer should be powered by the same 5 volt
                                 // rail that powers the ESP32, not its 3.3 volt output
#include "Adafruit_NeoPixel.h"   // Used for LedBasic scripting of LED lighting scenes
#include "LedBasic.h"            // NeoPixel BASIC scripting from https://github.com/vktrsansara/LedBasic (Russian)
#else
#include "AccelStepper.h"        // Stepper motor driver for use where non-blocking functionality is needed
#endif

#include "WiFi.h"                // ESP32 high-level WiFi connectivity library
#include "esp_wifi.h"            // ESP32 low-level WiFi connectivity library
#include "HTTPClient.h"          // HTTP client library used for communicating with slave units
#include "ESP32Ping.h"           // ICMP (ping) library from https://github.com/marian-craciunescu/ESP32Ping
#include "Preferences.h"         // ESP32 Flash memory read/write library
#include "ota_update.h"          // Over-The-Air firmware updating library
//------------------------------------------------------------------------------------------------
#define LED_PIN 21               // Internal LED on GPIO21 used for the heartbeat indicator
#define LED_CHANNEL 1            // PWM channel for the heartbeat indicator

#define TOTAL_LEDS 50            // Total number of LEDs on the Neopixel/WS2812 lighting bus.
                                 // This value cannot be dynamicaly updated if you add more LEDs.
                                 // You need to modify this value here and re-flash the ESP32.
#ifdef WAVESHARE
// Waveshare ESP32-S3FH4R2 (Mini/Stamp) GPIO Left side (USB top)
#define LIMIT_1 1                // Limit switch 1 (forward)
#define LIMIT_2 2                // Limit switch 2 (reverse)
#define IR_RCV 3                 // TSOP34838 input pin
#define OUT_1 4                  // Output 1 (SSR) or I2C SDA
#define OUT_2 5                  // Output 2 (SSR) or I2C SCL
#define MOT_PWM 6                // H-Bridge PWM or DRV8825 M2
// Waveshare ESP32-S3FH4R2 (Mini/Stamp) Right side (USB top)
#define MOT_F 11                 // H-Bridge forward pin or DRV8825 M0
#define MOT_R 10                 // H-Bridge reverse pin or DRV8825 M1
#define BUS_1 9                  // TX to DFPlayer or DRV8825 step pin
#define BUS_2 8                  // RX from DFPlayer or DRV8825 direction pin
#define BUS_3 7                  // NeoPixel/WS2812 bus or DRV8825 sleep pin
#else
// Seeed Studio XAIO ESP32-S3 GPIO Left side (USB top)
#define MOT_F 1                  // H-Bridge forward pin or DRV8825 M0
#define MOT_R 2                  // H-Bridge reverse pin or DRV8825 M1
#define MOT_PWM 3                // H-Bridge PWM or DRV8825 M2
#define BUS_3 4                  // NeoPixel/WS2812 bus or DRV8825 sleep pin
#define OUT_1 5                  // Output 1 (SSR) or I2C SDA
#define OUT_2 6                  // Output 2 (SSR) or I2C SCL
#define BUS_1 43                 // TX to DFPlayer or DRV8825 step pin
// Seeed Studio XAIO ESP32-S3 GPIO Right side (USB top)
#define LIMIT_1 9                // Limit switch 1 (forward)
#define LIMIT_2 8                // Limit switch 2 (reverse)
#define IR_RCV 7                 // TSOP34838 input pin
#define BUS_2 44                 // RX from DFPlayer or DRV8825 direction pin
#endif
//------------------------------------------------------------------------------------------------
#ifdef I2CSWITCH
Adafruit_MCP23X17 mcp;           // Be sure to use 4.7K pullup resistors on the I2C lines with these
#endif                           // I use the Waveshare boards https://www.amazon.com/dp/B082MMRNM4

#ifndef STEPPER
DFRobotDFPlayerMini myDFPlayer;  // Set up the sound effects system object
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
#else
AccelStepper Stepper(AccelStepper::DRIVER,BUS_1,BUS_2);
#endif
Preferences preferences;
WiFiServer Server(80);
//------------------------------------------------------------------------------------------------
bool FWupdate = false;           // True if the system should start up in OTA firmware update 
bool SFX = false;                // True if the sound effects system successfully initialized
bool sfxLoop = false;            // True if a sound effect command is supposed to play endlessly
bool UpdateMode = false;         // True if the LCC Slave is running in firmware update mode
bool stepperRunning = false;     // True if the stepper is running (no built-in ending callback function)
byte motorDirection = 1;         // Motor direction, 0 = reverse, 1 = forward
byte progressDir = 0;            // Motor speed progress direction, 0 = down, 1 = up
byte sfxVolume = 25;             // Dound effects volume level [0..30]
byte sysInit = 0;                // Flag to indicate whether this is a first boot and no flash settings
byte wifiCheckCounter = 0;       // Used to check the WiFi connection once every 30 seconds
int Locations[16][3];            // Queue for caching location ID numbers and associated actions
int soundFile = -1;              // Sound file number to play from the DFPlayer Mini
unsigned long fadeTarget = 0;    // Timestamp of when the current RGB LED fade ends
unsigned long motorTimestamp = 0;// Timestamp of the last motor command execution
unsigned long targetRuntime = 0; // Timestamp of the motor end run (0 = indefinite runtime)
long currentPos = 0;             // Stepper current position of the current running command
long targetPos = 0;              // Stepper target position of the current running command
float motorSpeed = 0.0;          // Current motor speed [0..100]
float progressFactor = 0.0;      // How much (percent) to change the motor speed per second
float targetSpeed = 0.0;         // Motor target speed [0..100]
String Commands[17];             // Queue for caching up to 16 commands plus 1 repeat command 
String myMacStr = "";            // MAC address string, used as the device ID in Mission Control
String scriptCode = "";          // Current LedBasic script code downloaded from Mission Control
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

  #ifndef STEPPER
  // Initialize the Neopixel/WS2812 bus for LedBasic
  lights.begin();
  lights.setBrightness(100);
  lights.clear();
  lights.setPixelColor(0,lights.Color(255,255,255));
  lights.setPixelColor(1,lights.Color(255,0,0));
  lights.show();
  #endif

  // Intialize the GPIO pins
  pinMode(IR_RCV,INPUT_PULLUP);
  pinMode(LIMIT_1,INPUT_PULLUP); // Probably not of much use in a model train locomotive
  pinMode(LIMIT_2,INPUT_PULLUP); // Convert these to outputs if you need additional ones
  #ifndef I2CSWITCH
  // Expand this part as needed if you are using a larger ESP32 with more exposed GPIO pins for output switching
  pinMode(OUT_1,OUTPUT); digitalWrite(OUT_1,LOW);
  pinMode(OUT_2,OUTPUT); digitalWrite(OUT_2,LOW);
  #else
  Wire.begin(OUT_1,OUT_2);
  delay(1000);
  if (mcp.begin_I2C(0x27)) {
    if (Serial) Serial.println("MCP23017 successfully started");
    for (byte i = 0; i <= 15; i ++) {
      mcp.pinMode(i,OUTPUT);
      mcp.digitalWrite(i,LOW);
    }
  } else {
    if (Serial) Serial.println("Unable to initialize MCP23017!");
  }
  #endif

   // Set up the heartbeat LED PWM
  ledcSetup(LED_CHANNEL,5000,8);
  ledcAttachPin(LED_PIN,LED_CHANNEL);
  ledcWrite(LED_CHANNEL,255);

  #ifndef STEPPER
  pinMode(MOT_F,OUTPUT); digitalWrite(MOT_F,LOW); // AIN1 (Standby is pulled high to enable the driver)
  pinMode(MOT_R,OUTPUT); digitalWrite(MOT_R,LOW); // AIN2
  pinMode(MOT_PWM,OUTPUT); digitalWrite(MOT_PWM,LOW); // PWMA
  // Initialize the PWM motor speed/direction controller
  ledcSetup(0,20000,8); // 20 KHz, 8 bit resolution
  ledcAttachPin(MOT_PWM,0);
  ledcWrite(0,0); // Set the speed to zero [0..255]
  setMotorDirection(1);
  #else
  pinMode(MOT_F,OUTPUT); digitalWrite(MOT_F,LOW);
  pinMode(MOT_R,OUTPUT); digitalWrite(MOT_R,LOW);
  pinMode(MOT_PWM,OUTPUT); digitalWrite(MOT_PWM,LOW);
  pinMode(BUS_1,OUTPUT); digitalWrite(BUS_1,LOW);
  pinMode(BUS_2,OUTPUT); digitalWrite(BUS_2,LOW);
  pinMode(BUS_3,OUTPUT); digitalWrite(BUS_3,LOW);
  #endif

  // Initialize the location/position detection sensor
  IrReceiver.begin(IR_RCV,DISABLE_LED_FEEDBACK);

  #ifndef STEPPER
  // Initialize the sound effects system
  Serial1.begin(9600,SERIAL_8N1,BUS_2,BUS_1);
  delay(1000);
  if (Serial) Serial.println(F("Initializing DFPlayer Mini..."));
  if (! myDFPlayer.begin(Serial1)) {
    if (Serial) Serial.println(F("Unable to initialize DFPlayer Mini!"));
  } else {
    if (Serial) Serial.println(F("DFPlayer Mini successfully started"));
    myDFPlayer.volume(sfxVolume);
    SFX = true;
  }
  #endif

  // Zero out the location detection and task queue
  for (byte i = 0; i <= 15; i ++) {
    Locations[i][0] = 0;
    Locations[i][1] = 0;
    Locations[i][2] = 0;
  }

  // FWupdate is only true if the API call was made to activate the OTA firmware updater
  if (FWupdate) {
    FWupdate = false;
    SetMemory();
    Server.end();
    UpdateMode = true;

    Serial.println("Starting LCC Slave Firmware Updater (AP mode)...");

    // Start WiFi Access Point
    WiFi.mode(WIFI_AP);
    uint8_t protocol = WIFI_PROTOCOL_11B | WIFI_PROTOCOL_11G | WIFI_PROTOCOL_11N;
    esp_wifi_set_protocol(WIFI_IF_AP,protocol);
    esp_wifi_set_bandwidth(WIFI_IF_AP,WIFI_BW_HT20);
    esp_wifi_set_max_tx_power(84);
    WiFi.softAP(ap_ssid,ap_password,6);
    IPAddress myIP = WiFi.softAPIP();
    Serial.print("AP IP address: ");
    Serial.println(myIP);

    // Start Bonjour/ZeroConf
    if (MDNS.begin("lcc-slave")) {
      Serial.println("mDNS started - http://lcc-slave.local");
    }

    // Set the server home page, sent upon browser connection
    server.on("/",HTTP_GET,[]() {
      server.send(200,"text/html",serverIndex);
    });

    // Set the OTA firmware update handler
    server.on("/update",HTTP_POST,[]() {
      server.sendHeader("Connection","close");
      server.send(200,"text/plain",(Update.hasError()) ? "FAIL" : "OK");
      ESP.restart();
    },[]() {
      HTTPUpload& upload = server.upload();
      if (upload.status == UPLOAD_FILE_START) {
        Serial.printf("Update: %s\n",upload.filename.c_str());
        if (!Update.begin(UPDATE_SIZE_UNKNOWN)) {
          Update.printError(Serial);
        }
      } else if (upload.status == UPLOAD_FILE_WRITE) {
        if (Update.write(upload.buf,upload.currentSize) != upload.currentSize) {
          Update.printError(Serial);
        }
      } else if (upload.status == UPLOAD_FILE_END) {
        if (Update.end(true)) {
          Serial.printf("Update Success: %u bytes\n",upload.totalSize);
        } else {
          Update.printError(Serial);
        }
      }
    });

    server.begin();
    Serial.println("HTTP server ready. Connect to the AP and go to 192.168.4.1");
  } else {
    ConnectWiFi();
    if (Serial) {
      if (WiFi.status() == WL_CONNECTED) {
        Serial.println("LCC Slave waiting for commands.");
      } else{
        Serial.println("LCC Slave waiting for network connection.");
      }
    }
  }

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
  FWupdate   = preferences.getBool("fw_update",false);
  preferences.end();
}
//------------------------------------------------------------------------------------------------
void SetMemory() { // Update flash memory with the current configuration settings
  preferences.begin("prefs",false);
  preferences.putString("wifi_ssid",wifiSSID);
  preferences.putString("wifi_pw",wifiPW);
  preferences.putUInt("sys_init",sysInit);
  preferences.putBool("fw_update",FWupdate);
  preferences.end();
}
//------------------------------------------------------------------------------------------------
bool beaconCheck(int Pin) { // Perform any registered actions based on the current location beacon
  String Request;
  for (byte i = 0; i <= 15; i ++) {
    if (Pin == Locations[i][0]) {
      if (Locations[i][1] == 1) { // Stop motor/stepper
        #ifndef STEPPER
        setMotorSpeed(0);
        targetRuntime = 0;
        targetSpeed = 0;
        progressFactor = 0;
        #else
        Stepper.stop();
        currentPos = 0;
        targetPos  = 0;
        stepperRunning = false;
        #endif
      } else if (Locations[i][1] == 2) { // Play sound effect
        #ifndef STEPPER
        soundFile = Locations[i][2];
        sfxVolume = 25;
        sfxLoop = false;
        if (! SFX) { // Play sound remotely on the sound server
          sendCommand("/sound-server/" + String(soundFile) + "/25/0");
        }
        #endif
      } else if (Locations[i][1] == 3) { // Request command with /replay/cmd/#
        Request = "/replay/cmd/" + String(Locations[i][2]);
        sendCommand(Request);
      } else if (Locations[i][1] == 4) { // Request script with /replay/scr/#
        Request = "/replay/scr/" + String(Locations[i][2]);
        sendCommand(Request);
      } else if (Locations[i][1] == 5) { // Toggle GPIO pin
        #ifndef I2CSWITCH
        // Map gpioPin to new values as necessary
        byte thePin = 0;
        if (Locations[i][2] == 0) {
          thePin = OUT_1;
        } else if (Locations[i][2] == 1) {
          thePin = OUT_2;
        }
        byte State = digitalRead(thePin);
        if (State == 0) {
          digitalWrite(thePin,HIGH);
        } else {
          digitalWrite(thePin,LOW);
        }
        #else
        byte State = mcp.digitalRead(Locations[i][2]);
        if (State == 0) {
          mcp.digitalWrite(Locations[i][2],HIGH);
        } else {
          mcp.digitalWrite(Locations[i][2],LOW);
        }
        #endif
      } else if (Locations[i][1] == 6) { // Toggle a specific (or all) Neopixel/WS2812 (off or full white)
        #ifndef STEPPER
        if (basic.isRunning()) basic.stop();
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
        #endif
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
  #ifndef STEPPER
  if (Serial) Serial.println("Set motor speed: " + String(Percent) + "%");
  ledcWrite(0,round(motorSpeed * 2.55));
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
  #endif
}
//------------------------------------------------------------------------------------------------
String strToUpper(String Str) { // AT command helper to reduce redundant code
  Str.toUpperCase();
  return Str;
}
//------------------------------------------------------------------------------------------------
bool processCmd(String Cmd) { // Process AT+ commands received via serial communications
  if (strToUpper(Cmd).indexOf("AT+") == 0) {
    Cmd.remove(0,3);
    //if (Cmd.indexOf("CMD=") == 0) {
    if (strToUpper(Cmd).indexOf("CMD=") == 0) {
      // AT+CMD=
      Cmd.remove(0,4);
      if (sendCommand(Cmd)) {
        return true;
      } else {
        return false;
      }
    } else if (strToUpper(Cmd) == "HOSTNAME") {
      // AT+HOSTNAME
      Serial.println(myMacStr + ".lcc.local");
      return true;
    } else if (strToUpper(Cmd) == "MAC") {
      // AT+MAC
      Serial.println(myMacStr);
      return true;      
    } if (strToUpper(Cmd) == "PASSWD") {
      // AT+PASSWD
      Serial.println(wifiPW);
      return true;
    } else if (strToUpper(Cmd).indexOf("PASSWD=") == 0) {
      // AT+PASSWD=
      Cmd.remove(0,7);
      wifiPW = Cmd;
      SetMemory();
      return true;
    } if (strToUpper(Cmd) == "RECON") {
      // AT+RECON
      ConnectWiFi();
      return true;
    } if (strToUpper(Cmd) == "RESET") {
      // AT+RESET
      Serial.println("Rebooting...");
      delay(1000);
      ESP.restart();
    } if (strToUpper(Cmd) == "SERVER") {
      // AT+SERVER
      Serial.println(serverIP);
      return true;
    } if (strToUpper(Cmd) == "SSID") {
      // AT+SSID
      Serial.println(wifiSSID);
      return true;
    } else if (strToUpper(Cmd).indexOf("SSID=") == 0) {
      // AT+SSID=
      Cmd.remove(0,5);
      wifiSSID = Cmd;
      SetMemory();
      return true;
    } if (strToUpper(Cmd) == "UPDATE") {
      // AT+UPDATE
      FWupdate = true;
      SetMemory();
      ESP.restart();
    } if (strToUpper(Cmd) == "VERSION") {
      // AT+VERSION
      Serial.println("v" + Version);
      return true;
    } if (strToUpper(Cmd) == "WIFISTATS") {
      // AT+WIFISTATS
      Serial.println("WiFi Channel: " + String(WiFi.channel()) + "\n" + "WiFi Signal: " + String(WiFi.RSSI()));
      return true;
    } if (strToUpper(Cmd) == "Z") {
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
  if (UpdateMode) { // Firmware update mode is running
    server.handleClient();
    delay(1);
    return;
  }

  static unsigned long ledUpdate = 0;
  static unsigned long lastCheck = millis();
  static float angle = 0.0;
  unsigned long CurrentTime = millis();
  if (CurrentTime > 4200000000) {
    // Reboot the system if we're reaching the maximum long integer value of CurrentTime (49 days)
    ESP.restart();
  } 

  // Non-blocking heartbeat LED fader so users know the ESP32 isn't locked up or dead
  if (CurrentTime - ledUpdate >= 10) {
    ledUpdate = CurrentTime;
    int dutyCycle = (sin(angle) + 1.0) * 127.5;
    #ifdef WAVESHARE
    // NOTE: LedBasic operations may cause this WS2812 LED to go haywire
    neopixelWrite(LED_PIN,dutyCycle / 4,dutyCycle / 4,0);
    #else
    ledcWrite(LED_CHANNEL,255 - dutyCycle);
    #endif
    angle += 0.03;
    if (angle >= 2 * PI) {
      angle -= 2 * PI;
    }
  }

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
  // Give the LedBasic engine some CPU time on every loop iteration
  basic.tick();

  // Handle the sound effects as necessary
  if (SFX) {
    if (soundFile >= 0) {
      myDFPlayer.volume(sfxVolume);
      if (sfxLoop)  {
        myDFPlayer.loop(soundFile);
      } else {
        myDFPlayer.play(soundFile);
      }
      soundFile = -1;
    }
  }
  #else
  // Give the stepper motor driver some CPU time on every loop iteration
  Stepper.run();
  if (Stepper.isRunning()) {
    currentPos = Stepper.currentPosition();
  } else {
    if ((stepperRunning) && (currentPos != targetPos)) {
      stepperRunning = false;
      currentPos = targetPos;
      // Send the runtime end status to Mission Control
      String Status = "/runtime/end";
      if (Serial) {    
        Serial.println("Stepper position: " + String(currentPos));
        Serial.println("Status: " + Status);
      }
      sendCommand(Status);
    }
  }
  #endif

  // Shut down the motor/stepper if either limit switch has been tripped
  #ifndef STEPPER
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
    // Send the status notification to Mission Control
    sendCommand(Status);
  }
  #else
  if ((currentPos != targetPos) && ((digitalRead(LIMIT_1) == 0) || (digitalRead(LIMIT_2) == 0))) {
    Stepper.stop();
    currentPos = 0;
    targetPos  = 0;
    stepperRunning = false;
    String Status;
    if (digitalRead(LIMIT_1) == 0) {
      Status = "/limit/0";
    } else {
      Status = "/limit/1";
    }
    if (Serial) Serial.println("Limit switch tripped: " + Status);
    // Send the status notification to Mission Control
    sendCommand(Status);
  }
  #endif

  // Handle new location transponder detection
  if (IrReceiver.decode()) {
    uint32_t Location = IrReceiver.decodedIRData.decodedRawData;
    if ((Location > 0) && (Location < 1001)) {
      String Status;
      if (beaconCheck(Location)) {
        Status = "/location/" + String(Location) + "/action";
      } else {
        Status = "/location/" + String(Location) + "/report";
      }
      if (Serial) Serial.println("Location transponder detected: " + Status);
      sendCommand(Status);
    }
    IrReceiver.resume();
  }

  #ifndef STEPPER
  // Shut down the motor if a target runtime has been set and met
  if ((targetRuntime > 0) && (CurrentTime >= targetRuntime)) {
    setMotorSpeed(0);
    targetSpeed = 0;
    progressFactor = 0;
    targetRuntime = 0;
    // Send the runtime end status to Mission Control
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
    #else
    if ((Serial) && (currentPos != targetPos)) Serial.println("Stepper position: " + String(currentPos));
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

    lastCheck = CurrentTime;
  }

  while (Serial.available()) {
    String Data = Serial.readStringUntil('\n');
    Data.trim();
    if (strToUpper(Data) == "AT") {
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

#include "IRremote.hpp"

#define IR_SEND_PIN 6  // Use D6 (PA06) for IR LED, a PWM-capable pin
const uint16_t LOCATION_ID = 1234;  // Unique ID for this location (1..1000)

IRsend irsend(IR_SEND_PIN);  // Initialize IRsend with specific pin

void setup() {
  Serial.begin(115200);
  delay(1000);
  if (Serial) Serial.println("XIAO SAMD21 IR Transmitter Initialized");
}

void loop() {
  irsend.sendNEC(LOCATION_ID,8);  // Send 8-bit LOCATION_ID using NEC protocol
  if (Serial) {
    Serial.print("Sent IR Code: 0x");
    Serial.println(LOCATION_ID, HEX);
  }
  delay(50);  // Repeat every 50 ms
}
*/
