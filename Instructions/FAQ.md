# Frequently Asked Questions

Q: Why does the Mission Control system show 4 different device types but the ESP32 code really only provides 2 types?

A: It's mainly for command class segregation. For example, the **Brushed Motor Controller** and the **Model Train Locomotive** are 100% identical in functionality. Mission Control calls these two different device types so the commands for each device type aren't inter mingled. The **Switching Controller** is also the same but the motor control functionality is hidden so that you can't accidentally sent a motor command to it and cause delays in switching commands. The only one that's really different is the **Stepper Motor Controller** device type.

---
