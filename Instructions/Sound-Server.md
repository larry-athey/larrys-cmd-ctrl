# LCC Sound Server

This is a companion project still in development and not available to download from here yet. This is based on another Pi style SBC but must have an audio output jack, such as an Orange Pi 3B or Banana Pi M4 Berry. Those are just two examples, there are many others out there that will also work for this. I just always recommend anything else besides a Raspberry Pi.

### The Problem
When a person is using LCC in a model railroad setup, some locomotives don't have enough room inside to install the DFRobot DFPlayer MP3 player module and sugar-cube speaker.

### The solution
LCC Slave units play sound files on the sound server instead. The sound server has stereo audio output and can play multiple MP3 files simultaneously.

- The right channel feeds a central speaker in the center of the model railroad, this is for sound effects not related to the train itself.

- The left channel feeds any number of remote amplified speakers that use a LIDAR sensor to tell when a train is near and increase the volume of that speaker. The volume reduces again when there is no train near the speaker. This simulates the effect of sound coming from the train itself.

- Left channel speakers can be of any speaker of your choosing, the amplifier used for these is the Adafruit Stereo 2.8W Class D Audio Amplifier (TPA2016D2, part number 1712). These are managed by a Seeed Studio XAIO SAMD21 development board and a VL53L0X LIDAR sensor for the proximity sensor that controls the volume.

- Sound files can easily be customized using the free **Audacity** audio editor so you can pan train sound effects to the left channel and everything else to the right channel.
