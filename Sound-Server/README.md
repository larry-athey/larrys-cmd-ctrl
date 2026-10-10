# LCC Sound Server

This device is based on a Pi style SBC and must have a stereo audio output jack, such as an Orange Pi 3B or Banana Pi M4 Berry. Those are just two examples, there are many others out there that will also work for this. You could even use the same Orange Pi Zero 3 as the Mission Control server uses, just with the expansion hat added on. Once you hear this system in action, I can guarantee that you won't even bother with onboard sound effects in the locomotive itself.

_**NOTE:** I just always recommend anything else besides a Raspberry Pi because that company sucks and so do their products._

### The Problem
When a person is using LCC in a model railroad setup, some locomotives don't have enough room inside to install the DFRobot DFPlayer MP3 player module and sugar-cube speaker.

### The solution
LCC Slave units play sound files on the sound server instead, which is actually a low-tech - yet unique and convincing 3D surround sound system. That does what it's intended to do without barfing all over the track bed even if a couple dozen MP3s are playing.

- The right channel feeds a central speaker in the middle of the model railroad, this is for sound effects not related to the train itself.

- The left channel feeds any number of remote amplified speakers that use a LIDAR sensor to tell when a train is near and increase the volume of that speaker. The volume reduces again when there is no train near the speaker. This simulates the effect of sound coming from the train itself. The volume attack and release is smooth and produces a very realistic 3D soundscape as a train passes by.

- Left channel speakers can be of any speaker of your choosing, the amplifier I used for these is the Adafruit Stereo 2.8W Class D Audio Amplifier (part number 1712) or other generic TPA2016D2 module. The extra channel on these boards can be used to drive an additional non-powered speaker if you'd like to. These are managed by a Seeed Studio XAIO SAMD21 development board and a VL53L0X LIDAR sensor for the proximity based volume control.

- The speakers are designed by myself and two enclosure styles are available, a cube and a matchbox style. Both use a Dayton Audio 2" bass reflex full-range speaker with a 2" passive radiator for enhanced bass. Without the LIDAR sensor plugged in, the speaker runs normally with no proximity based volume control. This would be the one that you attach to the right channel of the sound-server for the middle of the railroad. Since these are active speakers, there's really no limit to the number that you can have. They all use a simple 3-conductor TRS headphone style cable that carries the audio and 5 volt power.

- A breakout box is necessary for this setup, but it's not hard to build. Audio comes from the Pi computer, right channel goes to the tip of one TRS jack, left channel goes to the tip of four or more TRS jacks. The ring connector of all jacks are connected together and powered by a 5 volt power supply. Common grounds all the way around, no engineering degree necessary.

- Speaker placement can be done creatively and easily. The cube enclosure is 70x70x70 mm and the matchbox is 110x60x50 mm. If you mount them under the track bed, all you need is a 2" hole saw and something to disguise the hole with after the fact. Neither one is better than the other, the passive radiator is on the back side of each one. If you've ever heard a [JBL Flip 5](https://www.amazon.com/JBL-Waterproof-Portable-Bluetooth-Speaker/dp/B07QK2SPP7) speaker then you know how much impact a 2" passive radiator has in any room. Now imagine 4 or more of them in a room.

- Sound files can easily be customized using the free **Audacity** audio editor so you can pan train sound effects to the left channel and everything else to the right channel. They're still stereo MP3 files, one channel is just silent depending on the purpose of the sound file.

# Installation

As with the Mission Control server, you must install this on a Pi style computer running a fresh unmodified OS installation under a user account named "pi".

You will need this computer already connected to the LCC-WLAN network as well, so you will need to connect its ethernet port to a router with internet access in order to git-clone this repository to it. This is because the LCC-WLAN network has no internet access, even if the Mission Control server has an ethernet connection.

`git clone https://github.com/larry-athey/larrys-cmd-ctrl`

After that

`cd larrys-cmd-ctrl/Sound-Server`<br>
`./install.sh`

At the end of the installation, the script will tell you the Sound Server address that you need to add to the Mission Control settings page.

After the installation is complete, you will need to open the browser-based file manager on the Sound Server in order to upload MP3 files to it.

On the LCC-WLAN network: http://sound-server-address.lcc.local:8080

Username: **admin**<br>
Password: **sound-server**

You can change the default password before installation by editing the **install.sh** script or after you're logged in.

Unlike the bizarre SD card folder and file name structure, you just upload the numbered MP3 files all in the same folder here. No need to add extra zeros at the beginning of the file name in order to maintain a 3 digit number for the file name. You can also create a text file on the Sound Server stating what each MP3 file is.

If you already use on-board sounds in your locomotives and now want to use the Sound Server instead, simply eject its SD card.

_**NOTE:** This server also has phpMyAdmin installed using the same credentials as the Mission Control server. However, the database on this one is used for nothing more than logging which devices sent sound requests through it. The database here may be used for more in the future, but it's just a device log at this time._
