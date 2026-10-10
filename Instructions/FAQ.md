# Frequently Asked Questions

Q: If you're not a model railroader, what exactly do you use this LCC system for?

A: A friend of mine who is a model railroader asked me if I could build a cheaper alternative to DCC/WCC and I said, _"yes - but it has to be something that I can use it for as well"_. So I thought about it...Remote switching? Hey, that works for underground sprinklers, especially if it has timers! Remote RGB LED control? Hey, I have lots of NeoPixel light strips sitting around! Remote stepper motor control? Hey, I'd love to be able to open my greenhouse vents without having to go out there! Hey, what about integrating RGB LEDs inside of a sprinkler head for a DIY Bellagio light show with water works? And that's how I ended up where I am with this.

---

Q: Why do you so strongly emphasize the _"for private use only"_ and _"don't put it on the internet"_ stuff?

A: That's easy, three words. **ZERO SECURITY MECHANISMS!** This is why everything is so fast and lightweight. This is why everything runs on a 100% isolated wireless network with no internet access. If you port forward your router into this system, you are going to create a honey pot that is going to attract every kind of attention that you never want. Just because you "can" do something, doesn't mean that you should. Consider this all the warning that you should ever need, end of story.

---

Q: Why does the Mission Control system show 4 different device types but the ESP32 code really only provides 2 types?

A: It's mainly for command class segregation. For example, the **Brushed Motor Controller** and the **Model Train Locomotive** are 100% identical in functionality. Mission Control calls these two different device types so the commands for each device type aren't inter-mingled. The **Switching Controller** is also the same but the motor control functionality is hidden so that you can't accidentally send a motor control command to it and cause switching delays. The only one that's really different is the **Stepper Motor Controller** device.

---

Q: Why does it appear that sometimes there is a delay in what appears on the Mission Control dashboard even in the same room?

A: Your phone/computer isn't establishing a real-time connection with each LCC Slave. The undercarriage of the Mission Control server only checks for incoming messages from LCC Slaves once every 5 seconds and signal level queries only happen at the top of the hour. So, while you can manually send a command to a slave and see it react instantly, there can be up to a 5 second delay between the Mission Control server seeing an acknowledgment message from an LCC Slave and displaying it on your screen. This is 100% normal behavior in the client/server world, it's all message exchanges (just like SMB), not a live data stream.

---

Q: How many total RGB LEDs can an LCC Slave address? Meaning, how many can I drive with one LCC Slave?

A: In theory, there is no limit, but in reality you should never use more than 500 because of the amount of delay that is introduced as LEDs relay packets down the bus. The default code for the LCC Slave is set to 50, you will need to modify the TOTAL_LEDS constant to match what you intend to use and then flash the ESP32 again.

---

Q: I'm not a programmer. How does a non-programmer create RGB LED lighting scenes?

A: You're in luck! The programming language it uses is called BASIC, which stands for Beginner's All-Purpose Symbolic Instruction Code. The language it uses is specifically for non-programmers and is so simple to learn that kids in elementary school used to learn it back in the 1980s when home computers were a totally new thing. The dialect of BASIC used here is a really simplified version too, so it's even easier to learn. Click on the **Language Reference** button in the scene editor and then go watch this [YouTube Video](https://www.youtube.com/watch?v=CpJf_6nWqLk).

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
