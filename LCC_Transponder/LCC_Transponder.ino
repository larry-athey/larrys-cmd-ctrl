//------------------------------------------------------------------------------------------------
// Larry's CMD & CTRL (LCC) | (CopyLeft) 2025-Present | Larry Athey (https://panhandleponics.com)
//------------------------------------------------------------------------------------------------
// XIAO SAMD21 Powered Location Transponder For Larry's CMD & CTRL (LCC)
// MCU: Seeed Studio XIAO SAMD21 (Arduino IDE board name “Seeeduino XIAO”)
// Board library: https://files.seeedstudio.com/arduino/package_seeeduino_boards_index.json
//
// This device repeatedly transmits its ID number (1 to 1000) just like an IR remote control and
// can be used by LCC Slaves as a locatio/position marker. Depending on how you have things set up
// in your Mission Control server, these can trigger actions when encountered or simply update the
// device status to reflect its last known location.
//
// Parts list for each transponder:
//
//   Seeed XIAO SAMD21        - $5.00
//   5V 1.8A Buck Regulator   - $1.50
//   2A Bridge Rectifier      - $1.00 (Only if you need these to be polarity-agnostic)
//   IR LED with 220 ohm res. - $1.50
//   3D Printed Case          - $2.00
//
// If used in a model railroad, these can be track powered but this will require the addition of a
// $1.00 bridge rectifier to make it polarity agnostic. These are simply placed 6 to 8 inches from
// the track pointing outward so the locomotive can't possibly read two of them at the same time.
//------------------------------------------------------------------------------------------------
#define IR_SEND_PIN 6            // Use D6 (PA06) for IR LED, a PWM-capable pin
#define TX_OFFSET 60000          // Location ID numbers are actually 60001 to 61000 for safety
//------------------------------------------------------------------------------------------------
#include "IRremote.hpp"          // This has to be included AFTER the IR_SEND_PIN definition
//------------------------------------------------------------------------------------------------
const uint16_t LOCATION_ID = TX_OFFSET + 1000;  // Unique ID for this location (1..1000)
//------------------------------------------------------------------------------------------------
void setup() {
  Serial.begin(115200);
  delay(1000);

  IrSender.begin();
  pinMode(LED_BUILTIN,OUTPUT);

  if (Serial) Serial.println("LCC Location Tranponder Initialized");
}
//------------------------------------------------------------------------------------------------
void loop() {
  static unsigned long ledUpdate = 0;
  static unsigned long lastCheck = millis();
  static float angle = 0.0;
  unsigned long CurrentTime = millis();

  if (CurrentTime - ledUpdate >= 10) { // The IrSender code below isn't non-blocking and seriously slows this down
    ledUpdate = CurrentTime;
    int dutyCycle = (sin(angle) + 1.0) * 127.5;
    analogWrite(LED_BUILTIN,255 - dutyCycle);
    angle += 0.03;
    if (angle >= 2 * PI) {
      angle -= 2 * PI;
    }
  }

  if (CurrentTime - lastCheck >= 50) {
    IrSender.sendNEC(LOCATION_ID,0,0);  // Send 18-bit LOCATION_ID using NEC protocol
    if (Serial) {
      Serial.print(lastCheck);
      Serial.print(" : ");
      Serial.print("Sent IR Code: 0x");
      Serial.println(LOCATION_ID,HEX);
    }
    lastCheck = CurrentTime;
  }
}
//------------------------------------------------------------------------------------------------
