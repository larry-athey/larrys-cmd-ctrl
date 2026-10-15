## Orange Pi Zero 3 Case

If you want to 3D print a case for your Orange Pi Zero 3 rather than buying one, I will provide links to 2 different ones rather than bothering with designing my own from scratch. Why reinvent the wheel? I think these are much nicer than anything for sale on Amazon.

- Mission Control Server: https://www.printables.com/model/542569-orange-pi-zero-3-case

- Optional Sound Server: https://www.printables.com/model/572566-orange-pi-zero-3-case-with-expansion-board

## Cube Speaker Models

If you are using a Sound Server with an LCC controlled model railroad, this will be the most common speaker enclosure used on the top side of the track bed. This enclosure requires a Dayton Audio DMA58-8 or DMA58-4 full range 2" speaker and a matching 2" passive radiator. Two speakers can be driven by the same Server Driver PCB since those are a stereo amplifier, just plug the unused hole on top with silicone if one is used as an extension speaker. You should use triple wall perimeters and 30% or more infill in order to eliminate cabinet resonance.

## Matchbox Speaker Models

If you are using a Sound Server with an LCC controlled model railroad, this will be the most common speaker enclosure used on the under side of the track bed. These use the same speaker and passive radiator as the Cube Speaker models. It's recommended that you use the passive radiator as a template for the hole that you will need to cut in the track bed for the speaker to lock into and then use a small section of strapping material to snug the speaker cabinet up against the under side of the track bed.

_**NOTE:** The backs of the speaker enclosures fit stupidly tight and may need sanded. This intentional because these need to be absolutely air-tight for the passive raditor to do what it's intended to do. If you have air leaks, then the passive raidator is nothing more than a decoration._

## SD-LIDAR-Mount.stl

This is the LIDAR sensor mount for the Server Driver PCB used in the Sound Server surround sound speakers. This is meant to be mounted to the track bed within 1 foot of the track to detect the presence of the train in order to increase that speaker's volume. This produces a 3D sound effect where the sound effects follow the train around the track. If the LIDAR sensor detects any obstacle within 300mm (12 inches) it will trigger the volume boost, then smoothly release the boost when the obstacle has gone.
