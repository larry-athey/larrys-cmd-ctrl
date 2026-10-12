# LCC Messaging Protocol

LCC slave units only respond to messages that meet a very strict structure and these messages may only come from the Mission Control server's IP address. Meaning, the slave's WiFi default gateway IP address. If you try to send one to an LCC Slave from your laptop on the LCC-WLAN network, you will get a JSON failure message every time.

Messages from the Mission Control server are somewhat structured like a URL where the elements are all delimited by forward slashes. This is why the status line of each device shows **cmd://** at the beginning of commands but not for other status messages.

Example mesage: `/765c6123585c702a248fbc47b4dd74c9/stepper/0/4/800/50`

Messages all begin with a 32-character ID tag that is used to match LCC Slave responses with database records on the server. For example, when a slave executes a command, the message ID is echoed back to Mission Control so the command can be marked as executed. You can view this status on the **Log Viewer** page in the **Outbound** log. The **Acknowledged** column simply means that the message was successfully transmitted to the LCC Slave.
