# LCC Messaging Protocol

LCC slave units only respond to messages that meet a very strict structure and these messages may only come from the Mission Control server's IP address. Meaning, the slave's WiFi default gateway IP address. If you try to send one to an LCC Slave from your laptop on the LCC-WLAN network, you will get a JSON failure message every time.

Example mesage: `/765c6123585c702a248fbc47b4dd74c9/stepper/0/4/800/50`
