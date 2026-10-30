# Firmware Updating

To put an LCC Slave into firmware update mode, open it in the Mission Control device editor and click the **Update Firmware** button at the bottom of the editor pane.

The Boilermaker will start up a WiFi access point with the SSID **"Boilermaker-Updater"** and the password to connect is **"12345678"**.

Now open this URL: **http://192.168.4.1**

<img width="1024" alt="image" src="https://github.com/user-attachments/assets/3fdbedfb-eb5d-4bf7-99f6-26fa449a9b8b"><br>

If you are unable to connect, check to make sure that your device pulled an IP address from the Boilermaker. If it does not pull one, you will need to manually configure a static IP address on your device. Here are settings that will work for you if you encounter this problem.

Address: 192.168.4.100<br>
Subnet Mask: 255.255.255.0<br>
Gateway: 192.168.4.1<br>
DNS: 192.168.4.1<br>

Click on the button to browse to your **boilermaker-firmware.bin** file and click the blue button to start the upload.

Once the upload progress bar has completed, the Boilermaker will reboot and will be running the new firmware.
