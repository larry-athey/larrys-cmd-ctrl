# LCC Messaging Protocol

_The purpose of this document is to help demystify that device status line in the Mission Control dashboard when it displays the current command being executed on the LCC Slave. This will also help the log viewer pages make more sense to you. This isn't intended to be any kind of developer's guide, the source code itself would explain that stuff far better (see lcc_api.h)._

LCC slave units only respond to messages of less than 100 characters that meet a very strict structure and these messages may only come from the Mission Control server's IP address. Meaning, the slave's WiFi default gateway IP address. If you try to send one to an LCC Slave from your laptop on the LCC-WLAN network, you will get a JSON failure message every time.

Messages from the Mission Control server are somewhat structured like a URL where the elements are all delimited by forward slashes. This is why the status line of each device shows **cmd://** at the beginning of commands but not for other status messages.

Example outbound message: `/765c6123585c702a248fbc47b4dd74c9/stepper/0/4/800/50`

Messages all begin with a 32-character ID tag that is used to match LCC Slave responses with database records on the server. For example, when a slave executes a command, the message ID is echoed back to Mission Control so the command can be marked as executed. You can view this status on the **Log Viewer** page in the **Outbound** log. The **Acknowledged** column simply means that the message was successfully transmitted to the LCC Slave.

Inbound command execution message: `/exec/765c6123585c702a248fbc47b4dd74c9`

_**NOTE:** The message ID is stripped from the device status line display, but is still visible in the logs._

Below is an outline of all commands (11 at this time) recognized by LCC Slave units. If you look at the message structures and compare them to the fields in the command editor pages in the Mission Control dashboard, everything will make perfect sense to you.

### /light/ : RGB LED Control (individual lights)

`cmd://light/led-id/red-level/green-level/blue-level/fade-time`

These commands control individual Neopixel/WS2812 RGB LEDs on the lighting bus. These LEDs can be anything from discrete surface mount LEDs in a strip, to individual full-size LEDs, up to DC powered RGB LED light fixtures.

### /location/ : Location Detection and Triggered Actions

`cmd://location/pin/action-type/action-data`

LCC Slaves have a buffer that stores up to 16 location transponder ID numbers and associated actions that they should trigger when they are encountered. These commands are used to stuff entries into that buffer. Once an associated action has been triggered and executed, that entry is removed from the buffer.

### /motor/ : Brushed Motor Control (PWM)

`cmd://motor/direction/speed/progression/duration`

These commands are what drives a brushed motor, such those used in a model train locomotive, DC pumps, battery powered power tools, etc. LCC Slaves run brushed electric motors using pulse width modulation (PWM) so you can control the speed and direction and perform smooth timed speed changes.

### /reboot/ : System Reboot

`cmd://reboot`

This one pretty much explains itself, or at least I certainly hope that it does.

### /replay/ : Replay Command or Script

`cmd://replay/cmd or script/cmd-id or script-id`

This is mostly a behind-the-scenes command and only one variant of it is visible to the Mission Control user. The last option in the command script editor lets you choose a script replay option to either re-run the same script or run a different script. Command replays are supported in the undercarriage code strictly in location based actions. These only work if replays are enabled in the device settings itself. These cause the LCC Slave to request a specific command or script from Mission Control.

### /scene/ : RGB LED Scenes (LedBasic Scripts)

`cmd://scene/scene-id`

These commands kind of work like replays, but they tell an LCC Slave which scene source code (LedBasic script) to download from the Mission Control server and execute. Much like replays tell LCC Slaves which command or script to request. You will see these requests show up as `/scene-request/#` in the inbound message log.

### /sound/ : Sound Effects

`cmd://sound/file-number/volume/loop`

These commands tell the LCC Slave to play a sound effect from its internal SD card or from an LCC Sound Server. If the LCC Slave doesn't have an on-board DFRobot DFPlayer, you will see the device status line show a `/sound-server/` version of this message first.

### /stepper/ : Stepper Motor Control

`cmd://stepper/direction/resolution/steps/speed`

If you're using a stepper motor rather than a brushed motor, you will see these messages instead of the `/motor/` commands. In case you aren't aware, stepper motors are used in robotics where you need to precisely position things or rotate something at extremely low speeds (less than 1 RPM).

### /switch/ : GPIO Switching

`cmd://switch/gpio/state`

These commands tell the LCC Slave to set GPIO pins on and off when you are performing remote switching. Such as when you are controlling a bank of solid state relays to switch AC powered devices on and off.

### /update-firmware/ : Firmware Updating

`cmd://update-firmware`

This is an invisible command. Mission Control sends this command when you click on the "Update Firmware button in the device editor. This reboots the LCC Slave in over-the-air (OTA) firmware update mode so you can connect to it with your computer and upload new firmware to it with your web browser.

### /wifi-signal/ : WiFi Signal Level Reporting

`cmd://wifi-signal`

This is an invisible command. Mission control sends this to all LCC slaves at the top of each hour to request their signal level. It's more important to see the signal level from the LCC Slave side than it is to look at the Mission Control access point signal level for a device.

# Inbound Messages From LCC Slaves

Below is an outline of LCC Slave messages to Mission Control that you will see in the inbound message log. Knowing what these messages actually mean will help you greatly any time that you need to troubleshoot an LCC Slave that seems to be misbehaving.

`/exec/messaged-id` and `/exec/command-name` : As explained at the beginning of this document, an LCC Slave will always notify Mission Control every time it begins executing a command. On-the-fly commands not stored in the database with a messaged ID will just send this message showing the command name after the `/exec/`.

`/limit/switch-id` : If you are utilizing limit switches with your LCC Slaves, these messages will appear in the inbound message log to let you know that a limit switch has been reached and closed. There is no specific designation as to which one is an upper or lower limit switch, that's up to you to decide based on the physical location of the switch.

`/location/id/action` and `/location/id/report` : Any time that a `cmd://location/pin/action-type/action-data` command is sent to an LCC Slave, it creates an entry in what you might call a RAM-based database. The entries are always associated with some kind of action any time an LCC Slave encounters the beacon from an LCC Location Transponder. In which case, a notification is sent to Mission Control to let you know that it has been actioned. If no action is associated with that location ID, it is simply reported so you know the LCC Slave's last known location.

`/replay/cmd/command-id` and `/replay/scr/script-id` : Any time that a `cmd://replay/cmd/cmd-id` or `cmd://replay/scr/scr-id` command is sent to an LCC Slave, it is stored in its queue so that it will request a command or script from Mission Control once all other commands in the queue ahead of it have executed. You will see these messages in the inbound message log any time an LCC Slave requests a command or script.

`/runtime/end` : Any time you are using a stepper motor or a brushed motor with a run duration set, the LCC Slave will send this message to Mission Control when the runtime has ended. While a stepper motor doesn't have a run duration setting, it does have a specific number of steps in every command, which constitutes the motor's actual runtime.

`/scene-request/scene-id` : Any time that a `cmd://scene/scene-id` command is sent to an LCC Slave, this will cause it to turn around and download an LedBasic script (a scene) from Mission Control. This is because the LedBasic scripts have no maximum possible size and all LCC messages are intentionally kept below 100 characters. There's no way to guarantee an LedBasic script would fit within that limit, so the LCC Slave does a U-Turn and downloads the script itself.

`/wifi-signal/signal-level` : Every time an LCC Slave unit reboots and connects to the network, you will see one of these messages showing its current signal level. Mission Control will also query all devices at the top of the hour to request this reading. Keep in mind that this is the signal level of how strong the LCC Slave sees the Mission Control server, not the other way around.
