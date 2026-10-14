# Notes On Diagrams

### LCC Slave PCB (type 1)

This is the LCC Slave printed circuit board for everything other than a stepper motor controller. As you can see, this is just the power supply and carrier for the ESP32-S3, everything else is an external peripheral that plugs into the main PCB. Note the pin orientation of the ESP32-S3, it is surface mounted (or edge soldered) on the bottom side of the PCB. The power connections (P1 and P2) are polarity-agnostic due to the built-in 2 amp Schottky bridge rectifier. This is used because it's possible to use this board in a model train and their tracks can flip polarity. Schottky rectifiers are used due to their much lower voltage drop. The board measures 17mm x 100mm.

LCC Slave PCB (type 2)

This is the LCC Slave printed circuit board for stepper motor controllers. Unlike the type 1 boards, these are not polarity-agnostic.
