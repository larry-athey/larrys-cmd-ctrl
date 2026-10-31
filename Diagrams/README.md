# Notes On This Folder

No schematics necessary here, these boards are stupid simple, they either require a Seeed Studio XIAO ESP32-S3 or SAMD21 and the board is labeled as such. if you see +/- in and out, that's a 5 volt buck regulator footprint. If you see a diode/rectifier, that's a 2 amp Schottky rectifier. Anything else is a pin header or screw terminal, your choice. That's it. no need for schematics.

Both of the LCC Slave boards below require a well filtered power supply for reliable and stable motor operation. The places where these boards are expected to live, don't have the room for a big 470uf/50v electrolytic on the input side of the buck regulator. Get a basic [Mean Well](https://www.amazon.com/dp/B0131UU9E2) 3D printer power supply, they're not expensive! Also, on type 1 LCC Slave boards being used as a brushed motor controller or model train locomotive, be sure that the **Enable** pin on your H-Bridge is always pulled high or your motor won't run.

Refer to [the wiki](https://github.com/larry-athey/larrys-cmd-ctrl/wiki/8.-LCC-Slave-PCB-Usage) for LCC Slave pinouts.

### LCC Slave PCB (type 1)

This is the LCC Slave printed circuit board for everything other than a stepper motor controller. As you can see, this is just the power supply and carrier for the ESP32-S3, everything else is an external peripheral that plugs into the main PCB. Note the pin orientation of the ESP32-S3, it is surface mounted (or edge soldered) on the bottom side of the PCB. The power connections (P1 and P2) are polarity-agnostic due to the built-in 2 amp Schottky bridge rectifier. This is used because it's possible to use this board in a model train and their tracks can flip polarity. Schottky rectifiers are used due to their much lower voltage drop. The board measures 17mm x 100mm.

### LCC Slave PCB (type 2)

This is the LCC Slave printed circuit board for stepper motor controllers. Unlike the type 1 boards, these are not polarity-agnostic. This board is based on the DRV8825 stepper motor driver module which is compatible with a number of stepper motors. However, a person could just as easily use it with any other stepper driver which may require jumper wires from the board to the driver if the pin footprint is different. Stepper motor controllers do not support sound or RGB LED lighting, but do still support limit switches, GPIO switching, and remote location detection. The board measures 50mm x 50mm.

### LCC Transponder

This is the infrared transponder that LCC Slaves respond to for location detection and associated actions. As with the LCC Slave type 1 boards, these are also polarity-agnostic so they can also run on model railroad track power. Keep in mind that polarity-agnostic doesn't mean AC powered, these still require filtered DC voltage. The board measures 25mm x 75mm.

### Server Driver

This is board that drives the surround sound speakers in a Sound Server setup. Aside from requiring a Seeed Studio XIAO SAMD21, this board also requires an Adafruit TPA2016D2 (part number 1712) stereo audio amplifier board. When looking at the PCB as shown in the top view image, the LIDAR connector from left to right is (1) Ground, (2) SCL, (3) SDA, (4) 3.3 volts. The board measures 30mm x 59mm.
