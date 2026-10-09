# LCC Sound Server

This device is based on a Pi style SBC and must have a stereo audio output jack, such as an Orange Pi 3B or Banana Pi M4 Berry. Those are just two examples, there are many others out there that will also work for this. I just always recommend anything else besides a Raspberry Pi. Any basic SBC with 1 GB of RAM and on-board sound is all that's needed for this. Once you hear this system in action, I can guarantee that you won't even bother with onboard sound effects in the locomotive itself.

### The Problem
When a person is using LCC in a model railroad setup, some locomotives don't have enough room inside to install the DFRobot DFPlayer MP3 player module and sugar-cube speaker.

### The solution
LCC Slave units play sound files on the sound server instead. The sound server has stereo audio output and can play multiple MP3 files simultaneously.

- The right channel feeds a central speaker in the middle of the model railroad, this is for sound effects not related to the train itself.

- The left channel feeds any number of remote amplified speakers that use a LIDAR sensor to tell when a train is near and increase the volume of that speaker. The volume reduces again when there is no train near the speaker. This simulates the effect of sound coming from the train itself. The volume attack and release is smooth and produces a very realistic 3D soundscape as a train passes by.

- Left channel speakers can be of any speaker of your choosing, the amplifier used for these is the Adafruit Stereo 2.8W Class D Audio Amplifier (part number 1712) or other generic TPA2016D2 module. These are managed by a Seeed Studio XAIO SAMD21 development board and a VL53L0X LIDAR sensor for the proximity based volume control.

- All speakers are the same and are custom designed by myself. Two enclosure styles are available, a cube and a matchbox style. Both use a Dayton Audio 2" bass reflex full-range speaker with a 2" passive radiator for enhanced bass. Without the LIDAR sensor plugged in, the speaker runs normally with no proximity based volume control. This would be the one that you attach to the right channel of the sound-server for the middle of the railroad. Since these are active speakers, there's really no limit to the number that you can have. They all use a simple 3-conductor TRS headphone style cable that carries the audio and 5 volt power.

- Speaker placement can be done creatively and easily. The cube enclosure is 70x70x70 mm and the matchbox is 100x55x45 mm. If you mount them under the track bed, all you need is a 2" hole saw and something to disguise the hole with after the fact. Neither one is better than the other, the passive radiator is on the back side of each one. If you've ever heard a [JBL Flip 5](https://www.amazon.com/JBL-Waterproof-Portable-Bluetooth-Speaker/dp/B07QK2SPP7) speaker then you know how much impact a 2" passive radiator has in any room. Now imagine 4 or more of them in a room.

- Sound files can easily be customized using the free **Audacity** audio editor so you can pan train sound effects to the left channel and everything else to the right channel. They're still stereo MP3 files, one channel is just silent depending on the purpose of the sound file.

# Installation

As with the Mission Control server, you must install this on a Pi style computer running a fresh unmodified OS installation under a user account named "pi".

You will need this computer already connected to the LCC-WLAN network as well, so you will need to connect its ethernet port to a router with internet access in order to git-clone this repository to it. This is because the LCC-WLAN network has no internet access, even if the Mission Control server has an ethernet connection.

`git clone https://github.com/larry-athey/larrys-cmd-ctrl`

After that

`cd larrys-cmd-ctrl/Sound-Server`<br>
`./install.sh`

At the end of the installation, the script will tell you the Sound Server address that you need to add to the Mission Control settings page.
