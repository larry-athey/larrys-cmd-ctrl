# Frequently Asked Questions

Q: Why does the Mission Control system show 4 different device types but the ESP32 code really only provides 2 types?

A: It's mainly for command class segregation. For example, the **Brushed Motor Controller** and the **Model Train Locomotive** are 100% identical in functionality. Mission Control calls these two different device types so the commands for each device type aren't inter-mingled. The **Switching Controller** is also the same but the motor control functionality is hidden so that you can't accidentally send a motor control command to it and cause switching delays. The only one that's really different is the **Stepper Motor Controller** device type.

---

Q: Can you add the capability to update the MP3 files on the LCC Slave remotely?

A: Unfortunately, this will never be possible. The MP3s are played by a completely separate circuit board, not the ESP32 itself. The DFRobot DFPlayer board has no file transfer capabilities, the ESP32 only talks to it by serial communications. You can only update the MP3 files by modifying the contents of the SD card.

---

Q: Are there any plans to create a DCC-style handheld controller for this?

A: That would be up to somebody else. As far as I'm concerned, your cell phone is all the handheld controller that a person needs for this system. I don't have the necessary engineering team and resources for that kind of production work.

---

Q: What is the maximum wireless range of this system?

A: That all depends on the antennas that you choose for both ends and obstacles in the path between the antennas. Realistically, a person could install the Mission Control server in a white weather-proof box outside on a pole connected to a high gain omni directional antenna using a short pigtail. Then use either panel or yagi antennas on the LCC Slaves pointed at the server's antenna. With a setup like that and fairly clear line of sight, you could likely get up to a mile or possibly even more if you're good at aiming.

---
