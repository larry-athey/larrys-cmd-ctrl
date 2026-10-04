# Compilation Notes

While you will notice that there are four different device types in the Mission Control system, there are actually only two real different device types that you can target in thise source code. The reason for the four device types in Mission Control is strictly for the sake of keeping command/script types isolated.

`#define STEPPER`

Defining the STEPPER constant is used to tell LCC Slave that we're running a stepper motor rather than a PWM diven brushed motor. A stepper motor requires the use of 6 GPIO pins rather than the 3 required by a brushed motor. Defining this constant disables the two serial data lines used by the DFRobot MP3 player and the Neopixel/WS2812 RGB LED bus.

You still have the capabilities to use IR location detection, limit switches, and GPIO switching when using a stepper motor.
