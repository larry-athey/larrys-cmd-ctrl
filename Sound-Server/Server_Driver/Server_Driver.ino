//------------------------------------------------------------------------------------------------
// Larry's CMD & CTRL (LCC) | (CopyLeft) 2025-Present | Larry Athey (https://panhandleponics.com)
//------------------------------------------------------------------------------------------------
// XIAO SAMD21 Powered Surround Sound Speaker Driver For The LCC Sound Server
// MCU: Seeed Studio XIAO SAMD21 (Arduino IDE board name “Seeeduino XIAO”)
// Board library: https://files.seeedstudio.com/arduino/package_seeeduino_boards_index.json
//
// No, this project isn't a misspelling of the ServoDrive (BassTech 7) speaker brand name from the
// 1980s. This is just the main driver of the LCC Sound Server, because it would just be any other
// MP3 player if it simply used off-the-shelf speakers.
//
// The TPA2016(D2) runs a single Dayton Audio 2" full-range driver on one channel with a passive
// radiator. The spare channel is active in case a person wants to add a second non-powered unit
// next to it.
//
// No compression/limiting or noise gating features of the TPA2016(D2) are used in this speaker,
// we want the passive radiator to do what it's intended for so we need the amp 100% unrestricted.
//------------------------------------------------------------------------------------------------
#include "Adafruit_TPA2016.h"  // TPA2016(D2) digital auudio amp library by Adafruit
#include "Adafruit_VL53L0X.h"  // VL53L0X LIDAR sensor library by Adafruit
#include "Wire.h"              // I2C communications library
//------------------------------------------------------------------------------------------------
#define TRIGGER_RANGE 300      // A train needs to be within 300mm to trigger the volume boost
#define IDLE_VOLUME 60         // Idle volume % when the LIDAR isn't triggered
#define ATTACK_TIME 400        // Milliseconds to rise to 100% volume when LIDAR is triggered
#define SUSTAIN_TIME 1000      // Milliseconds to hold 100% volume after LIDAR is triggered
#define RELEASE_TIME 1200      // Milliseconds to fade back to IDLE_VOLUME after LIDAR measurement goes over 300mm
//------------------------------------------------------------------------------------------------
Adafruit_TPA2016 audioAmp = Adafruit_TPA2016();
Adafruit_VL53L0X Lidar = Adafruit_VL53L0X();
//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------
void setup() {
  Serial.begin(115200);
  delay(1000);

  Wire.begin();

  if (audioAmp.begin()) {
    // Yay, the amplifier lived to see another day
    audioAmp.enableChannel(true,true);
  } else {
    // We're dead in the water, no amplifier
    if (Serial) Serial.println("Audio amplifier failed to initialize, halting system.");
    while(true);
  }

  if (Lidar.begin(VL53L0X_I2C_ADDR,false,&Wire,Lidar.VL53L0X_SENSE_HIGH_ACCURACY)) {
    // Using proximity based volume control, idle at IDLE_VOLUME % boost to 100% when triggered
  } else {
    // Amplifier runs wide open, the Sound Server and LCC commands control the volume
  }
}
//------------------------------------------------------------------------------------------------
void loop() {

}
//------------------------------------------------------------------------------------------------