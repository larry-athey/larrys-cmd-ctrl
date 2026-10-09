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
//
// The wiring of this circuit is stupid simple, all of the I2C lines are gang matched.
//
// On the Seeed Studio XIAO SAMD21 (Seeeduino XIAO):
//   SDA -> D4 / A4 (PA08)
//   SCL -> D5 / A5 (PA09)
//
// Then you do the same with the VCC and GND lines. In very rare cases, the VL53L0X has to run off
// the 3.3 volt output of the Seeed Studio XIAO SAMD21. After that, just feed the audio signal to
// both amp inputs, connect the speaker to one output, and that's it.
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
// Gain mapping for tuning
#define GAIN_FULL 6            // dB ≈ 100%
#define GAIN_IDLE -2           // dB ≈ 60%  (Hack job, adjust by ear)
//------------------------------------------------------------------------------------------------
Adafruit_TPA2016 audioAmp = Adafruit_TPA2016();
Adafruit_VL53L0X Lidar = Adafruit_VL53L0X();
//------------------------------------------------------------------------------------------------
bool lidarPresent = false;

enum VolState { IDLE, ATTACK, SUSTAIN, RELEASE };
VolState state = IDLE;

unsigned long stateStart = 0;
unsigned long lastTrigger = 0;
float currentGain = GAIN_IDLE;
//------------------------------------------------------------------------------------------------
void setup() {
  Serial.begin(115200);
  delay(1000);

  Wire.begin();

  // Amp – mandatory
  if (! audioAmp.begin()) {
    Serial.println("Audio amplifier failed to initialize, halting.");
    while (true);
  }
  audioAmp.enableChannel(true,true); // Both channels on
  // Disable AGC / compression / limiter so passive radiator is unrestricted
  audioAmp.setAGCCompression(TPA2016_AGC_OFF);
  audioAmp.setReleaseControl(0);

  setVolumePercent(IDLE_VOLUME); // Start at idle

  // LIDAR – optional
  if (Lidar.begin(VL53L0X_I2C_ADDR,false,&Wire,Adafruit_VL53L0X::VL53L0X_SENSE_HIGH_ACCURACY)) {
    lidarPresent = true;
    Serial.println("LIDAR present - proximity volume control active.");
  } else {
    lidarPresent = false;
    setVolumePercent(100); // Wide open amp
    Serial.println("No LIDAR - amp is running unmanaged.");
  }
}
//------------------------------------------------------------------------------------------------
int8_t percentToGain(float pct) {
  // Linear map 60 % -> GAIN_IDLE, 100 % -> GAIN_FULL
  float g = GAIN_IDLE + (pct - IDLE_VOLUME) * (GAIN_FULL - GAIN_IDLE) / (100.0 - IDLE_VOLUME);
  return constrain((int8_t)round(g),-28,30);
}
//------------------------------------------------------------------------------------------------
void setVolumePercent(float pct) {
  currentGain = percentToGain(pct);
  audioAmp.setGain((int8_t)currentGain);
}
//------------------------------------------------------------------------------------------------
void loop() {
  if (! lidarPresent) {
    // Nothing to do - volume is fixed at 100%
    delay(100);
    return;
  }

  // Read LIDAR sensor
  VL53L0X_RangingMeasurementData_t measure;
  Lidar.rangingTest(&measure,false);
  bool triggered = (measure.RangeStatus != 4) && (measure.RangeMilliMeter <= TRIGGER_RANGE);

  unsigned long now = millis();

  if (triggered) {
    lastTrigger = now;
    if (state != ATTACK && state != SUSTAIN) {
      state = ATTACK;
      stateStart = now;
    } else if (state == ATTACK) {
      // Stay in attack
    } else {
      state = SUSTAIN;
      stateStart = now;
    }
  }

  switch (state) {
    case IDLE:
      // Already at idle
      break;

    case ATTACK: {
      float progress = (float)(now - stateStart) / ATTACK_TIME;
      if (progress >= 1.0) {
        setVolumePercent(100);
        state = SUSTAIN;
        stateStart = now;
      } else {
        float pct = IDLE_VOLUME + progress * (100.0 - IDLE_VOLUME);
        setVolumePercent(pct);
      }
      break;
    }

    case SUSTAIN:
      if (now - lastTrigger > SUSTAIN_TIME) {
        state = RELEASE;
        stateStart = now;
      } else {
        setVolumePercent(100);
      }
      break;

    case RELEASE: {
      float progress = (float)(now - stateStart) / RELEASE_TIME;
      if (progress >= 1.0) {
        setVolumePercent(IDLE_VOLUME);
        state = IDLE;
      } else {
        float pct = 100.0 - progress * (100.0 - IDLE_VOLUME);
        setVolumePercent(pct);
      }
      break;
    }
  }

  delay(20); // ~50 Hz update seems reasonable
}
//------------------------------------------------------------------------------------------------
