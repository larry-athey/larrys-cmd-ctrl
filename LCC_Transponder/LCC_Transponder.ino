//------------------------------------------------------------------------------------------------
// Larry's CMD & CTRL (LCC) | (CopyLeft) 2025-Present | Larry Athey (https://panhandleponics.com)
//------------------------------------------------------------------------------------------------
// XIAO SAMD21 Powered Dephlegmator Cooling Valve Emulator for Peristaltic Pump
// MCU: Seeed Studio XIAO SAMD21 (Arduino IDE board name “Seeeduino XIAO”)
// Board library: https://files.seeedstudio.com/arduino/package_seeeduino_boards_index.json
//
// This device repeatedly transmits its ID number (1 to 1000) just like an IR remote control and
// can be used by LCC Slaves as a locatio/position marker.
//------------------------------------------------------------------------------------------------
#include "IRremote.hpp"
//------------------------------------------------------------------------------------------------
#define IR_SEND_PIN 6  // Use D6 (PA06) for IR LED, a PWM-capable pin
#define TX_OFFSET 60000  // Location ID numbers are actually 60001 to 61000 for safety
//------------------------------------------------------------------------------------------------
const uint16_t LOCATION_ID = TX_OFFSET + 1000;  // Unique ID for this location (1..1000)
//------------------------------------------------------------------------------------------------
IRsend irsend(IR_SEND_PIN);  // Initialize IRsend with specific pin
//------------------------------------------------------------------------------------------------
void setup() {
  Serial.begin(115200);
  delay(1000);
  if (Serial) Serial.println("LCC Location Tranponder Initialized");
}
//------------------------------------------------------------------------------------------------
void loop() {
  irsend.sendNEC(LOCATION_ID,0,0);  // Send 18-bit LOCATION_ID using NEC protocol
  if (Serial) {
    Serial.print("Sent IR Code: 0x");
    Serial.println(LOCATION_ID, HEX);
  }
  delay(50);  // Repeat every 50 ms
}
//------------------------------------------------------------------------------------------------