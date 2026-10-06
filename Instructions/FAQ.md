# Frequently Asked Questions

Q: If you're not a model railroader, what exactly do you use this system for?

A: A friend of mine who is a model railroader asked me if I could build a cheaper alternative to DCC and I said, _"yes - but it has to be something that I can use it for as well"_. So I thought about it and said...Remote switching? Hey, that works for underground sprinklers, especially if it has timers! Remote RGB LED control? Hey, I have lots of NeoPixel light strips sitting around! Remote stepper motor control? Hey, I'd love to be able to open my greenhouse vents without having to go out there! Hey, what about integrating RGB LEDs inside of a sprinkler head for a DIY Bellagio light show with water works?

---

Q: Why does the Mission Control system show 4 different device types but the ESP32 code really only provides 2 types?

A: It's mainly for command class segregation. For example, the **Brushed Motor Controller** and the **Model Train Locomotive** are 100% identical in functionality. Mission Control calls these two different device types so the commands for each device type aren't inter-mingled. The **Switching Controller** is also the same but the motor control functionality is hidden so that you can't accidentally send a motor control command to it and cause switching delays. The only one that's really different is the **Stepper Motor Controller** device.

---

Q: How many total RGB LEDs can an LCC Slave address? Meaning, how many can I drive with one LCC Slave?

A: In theory, there is no limit, but in reality you should never use more than 500 because of the amount of delay that is introduced as LEDs relay packets down the bus. The default code for the LCC Slave is set to 50, you will need to modify the TOTAL_LEDS constant to match what you intend to use and then flash the ESP32 again.

---

Q: When using location transponders with a model train to stop it, how do you resolve the over-shoot caused by the train's inertia?

A: Use two transponders where the first one slows down the motor in advance and the second one is the actual stopping point.

---

Q: Why do script and manual commands appear to be delayed after a motor command has been sent?

A: If you send a motor command with a progression time, all commands after that will be held in the queue until the progression completes. If there's no progression time, there's no delay because the command completes immediately. If you're using a stepper motor, later commands are also queued until the stepper has reached its target position. The same rule also applies to RGB LED commands with a non-zero fade time. This is intentional and not an oversight or design flaw.

---

Q: Can you add the capability to update the MP3 files on the LCC Slave remotely?

A: Unfortunately, this will never be possible. The MP3s are played by a completely separate circuit board, not the ESP32 itself. The DFRobot DFPlayer board has no file transfer capabilities, the ESP32 only talks to it by low-speed 9600 baud serial communications. You can only update the MP3 files by modifying the contents of the SD card.

---

Q: Can you make it possible to select MP3s to play by file name rather than by number?

A: Technically, that's how it already works, the number is the file name. The DFRobot DFPlayer requires each MP3 to have a number as the file name. Even if it allowed full verbal file names, there's no way to remotely query the list of files on the SD card. Anything else would require a lookup table on the Mission Control side that you would have to manually keep updated and in-sync on a per-device level.

---

Q: Are there any plans to create a DCC-style handheld controller for this?

A: That will have to be up to somebody else. As far as I'm concerned, your cell phone is all the handheld controller that a person needs for this system. I don't have the necessary engineering team and resources for that kind of production work.

---

Q: What is the maximum wireless range of this system?

A: That all depends on the antennas that you choose for both ends and obstacles in the path between the antennas. Realistically, a person could install the Mission Control server in a white weather-proof box outside on a pole connected to a high gain omni directional antenna using a short pigtail. Then use either panel or yagi antennas on the LCC Slaves pointed at the server's antenna. With a setup like that and fairly clear line of sight, you could likely get up to a mile or possibly even more if you're good at aiming.

---
