# LCC Messaging Protocol

LCC slave units only respond to messages that meet a very strict structure and these messages may only come from the Mission Control server's IP address. Meaning, the slave's WiFi default gateway IP address. If you try to send one to an LCC Slave from your laptop on the LCC-WLAN network, you will get a JSON failure message every time.

Messages from the Mission Control server are somewhat structured like a URL where the elements are all delimited by forward slashes. This is why the status line of each device shows **cmd://** at the beginning of commands but not for other status messages.

Example mesage: `/765c6123585c702a248fbc47b4dd74c9/stepper/0/4/800/50`

Messages all begin with a 32-character ID tag that is used to match LCC Slave responses with database records on the server. For example, when a slave executes a command, the message ID is echoed back to Mission Control so the command can be marked as executed. You can view this status on the **Log Viewer** page in the **Outbound** log. The **Acknowledged** column simply means that the message was successfully transmitted to the LCC Slave.

Below is an explanation of all commands (11 at this time) recognized by LCC Slave units. If you look at the message structures and compare them to the fields in the command editor pages in the Mission Control dashboard, everything will make perfect sense.

### RGB LED Light (individual lights)

`cmd://ID/light/led-id/red-level/green-level/blue-level/fade-time`

These commands control individual Neopixel/WS2812 RGB LEDs on the lighting bus. The first LED is ID #0 and the last one in a chain of 30 would be #29. You'll need to modify the TOTAL_LEDS constant in the source code and re-flash the ESP32 if you intend to have more than the default value of 30. These LEDs can be anything from discrete surface mount LEDs up to individual light fixtures.

### Location Detection and Triggered Actions

`cmd://ID/location/pin/action-type/action-data`

LCC Slaves have a buffer that stores up to 16 location transponder ID numbers and associated actions that they should trigger when they are encountered. These commands are used to stuff entries into that buffer. Once an associated action has been triggered and executed, that entry is removed from the buffer.

### Brushed Motor Control (PWM)

`cmd://ID/motor/direction/speed/progression/duration`

### System Reboot

`cmd://ID/reboot`

### Replay Command or Script

`cmd://ID/replay/cmd or script/cmd-id or script-id`

### RGB LED Scenes (LedBasic Scripts)

`cmd://ID/scene/scene-id`

### Sound Effects

`cmd://ID/sound/file-number/volume/loop`

### Stepper Motor Control

`cmd://ID/stepper/direction/resolution/steps/speed`

### GPIO Switching

`cmd://ID/switch/gpio/state`

### Firmware Updating

`cmd://ID/update-firmware`

### WiFi Signal Level Reporting

`cmd://ID/wifi-signal`
