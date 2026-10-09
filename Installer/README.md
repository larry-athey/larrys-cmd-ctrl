# Notes

The WiFi access point is configured in the file **hostapd.conf** and you should change the WiFi password in there  **BEFORE** installation! You may also change the network name (SSID) as well, there's no need to keep it as-is. If you modify these settings, you will need to log into phpMyAdmin and update these fields in the Settings table. When you pair a new LCC Slave device over USB, the Mission Control server needs to know this information in advance to configure the ESP32's WiFi.

### Default WiFi Network
SSID: **LCC-WLAN**<br>
Password: **1a2b3c4d5e**<br>
DHCP Scope: **192.168.4.50 - 192.168.4.200**<br>
Mission Control: **http://192.168.4.1**

_**NOTE:** Absolutely do not configure any static IP devices inside of the DHCP scope!_

This server was developed on an Orange Pi Zero 3 running Armbian Linux 6.18.54 and it "should" work on a Raspberry Pi and a current version of Raspberry Pi OS. Just keep in mind that a Raspberry Pi has a weak WiFi radio and antenna combination. While I can't guarantee that this system will work flawlessly for everybody, I can guarantee that you will have far fewer problems with anything else besides a Raspberry Pi, and they'll cost you far less money.

# Installation

You must install this on a Pi style computer running a fresh unmodified OS installation under a user account named "pi".

First, git-clone this repository.

`git clone https://github.com/larry-athey/larrys-cmd-ctrl`

After that

`cd larrys-cmd-ctrl/Installer`<br>
`./install.sh`

At the end of the installation you will be instructed to create a CRON job and restart the computer.
