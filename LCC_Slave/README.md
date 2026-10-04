# Compilation Notes

While you will notice that there are four different device types in the Mission Control system, there are actually only two real different device types that you can target in thise source code. The reason for the four device types in Mission Control is strictly for the sake of keeping command/script types isolated.

`#define STEPPER`

Defining the STEPPER constant is used to tell the LCC Slave that we're running a stepper motor rather than a PWM diven brushed motor. A stepper motor requires the use of 6 GPIO pins rather than the 3 required by a brushed motor. Defining this constant disables the two serial data lines used by the DFRobot MP3 player and the Neopixel/WS2812 RGB LED bus.

You still have the capabilities to use IR location detection, limit switches, and GPIO switching when using a stepper motor.

`#define I2CSWITCH`

Defining the I2CSWITCH constant enables the I2C bus on the original OUT_1 and OUT_2 GPIO pins and enables support for the MCP23017 GPIO expansion module. This increases the GPIO switching capabilities from 2 outputs to 16.

### GPIO Pin Definitions

You will notice that there are GPIO pin definitions for the **Seed Studio XAIO ESP32-S3** and **Waveshare ESP32-S3FH4R2 (Mini/Stamp)** boards. While the default target for this code is the Seeed Studio board, I originally wrote the initial code while working with the Waveshare board. The Waveshare board works perfectly fine, but only has a chip antenna and runs quite a bit hotter. I switched to the Seeed Studio board because of the external antenna and cooler operating temperature. Yes, the Waveshare board has two extra GPIO pins on the edge of the board, but they're unnecessary and unused. The Waveshare board is still a perfectly suitable target for an LCC Slave.

### LedBasic Compile Error

Stock unmodified LedBasic code doesn't play nice with ESP32-S3 board libraries and you may see this linker error.

`dangerous relocation: l32r: literal placed after use: .literal._ZN8LedBasic12hsv2rgb_fast...`

This comes from this function in `LedBasic.h` (around line 202–247):

`IRAM_ATTR static inline void hsv2rgb_fast(uint8_t h, uint8_t s, uint8_t v, uint8_t &r, uint8_t &g, uint8_t &b)`

On ESP32 / ESP32-S3 the compiler places the function in IRAM (`.iram1.xx`), but the **literal pool** (the constants the `l32r` instruction needs) does not get the matching `.iram` section name. The linker then puts the literals in flash, which is too far away for the `l32r` instruction → “dangerous relocation”.

This is a classic problem with `IRAM_ATTR` on C++ methods that are defined inline in a header, and it shows up frequently with Arduino-ESP32 2.0.x (including 2.0.17).

LedBasic was written with ESP8266-style IRAM optimizations in mind; those attributes are not always safe on ESP32.

### Quick fix

Edit the library header:

File: `~/Arduino/libraries/LedBasic/src/LedBasic.h`

Find `hsv2rgb_fast` and remove `IRAM_ATTR`:

Change this: `IRAM_ATTR static inline void hsv2rgb_fast(...)`

To this: `static inline void hsv2rgb_fast(...)`
