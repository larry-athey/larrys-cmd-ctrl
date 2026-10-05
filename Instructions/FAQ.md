# Frequently Asked Questions

Q: Why does the Mission Control system show 4 different device types but the ESP32 code really only provides 2 types?

A: It's mainly for command class segregation. For example, the **Brushed Motor Controller** and the **Model Train Locomotive** are 100% identical in functionality. Mission Control calls these two different device types so the commands for each device type aren't inter-mingled. The **Switching Controller** is also the same but the motor control functionality is hidden so that you can't accidentally sent a motor command to it and cause delays in switching commands. The only one that's really different is the **Stepper Motor Controller** device type.

---

Q: Can you add the capability to update the MP3 files on the LCC Slave remotely?

A: Unfortunately, this will never be possible. The MP3s are played by a completely separate circuit board, not the ESP32 itself. The DFRobot DFPlayer board has no file transfer capabilities, the ESP32 only talks to it by serial communications. You can only update the MP3 files by modifying the contents of the SD card.

---
