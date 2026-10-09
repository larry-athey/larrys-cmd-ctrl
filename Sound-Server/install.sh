#!/bin/bash

clear

echo " .----------------.  .----------------.  .----------------. "
echo "| .--------------. || .--------------. || .--------------. |"
echo "| |   _____      | || |     ______   | || |     ______   | |"
echo "| |  |_   _|     | || |   .' ___  |  | || |   .' ___  |  | |"
echo "| |    | |       | || |  / .'   \_|  | || |  / .'   \_|  | |"
echo "| |    | |   _   | || |  | |         | || |  | |         | |"
echo "| |   _| |__/ |  | || |  \ \`.___.'\  | || |  \ \`.___.'\  | |"
echo "| |  |________|  | || |   \`._____.'  | || |   \`._____.'  | |"
echo "| |              | || |              | || |              | |"
echo "| '--------------' || '--------------' || '--------------' |"
echo " '----------------'  '----------------'  '----------------' "
echo
echo "          Larry's Command & Control - Sound Server"
echo
echo "THIS INSTALLER EXPECTS YOU TO BE USING A RAW UNMODIFIED OS INSTALLATION!!!!"
echo
echo "This installer script assumes that you are running it as the username 'pi'."
echo "If you are using another user account, press CTRL+C to terminate the script"
echo "create a 'pi' user with sudo access and then run this script again."
echo
read -p "Press ENTER to continue the installation or CTRL+C to cancel..." nothing
echo

apt=$(which apt)
if [ "$apt" != "/usr/bin/apt" ]; then
  echo "LCC Mission Control requires a Debian derivative Linux operating system."
  exit 1
fi


sudo curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
sudo mkdir -p /etc/filebrowser /var/www/shared_files
cat << 'EOF' > /tmp/filebrowser.service
[Unit]
Description=File Browser
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/filebrowser -r /var/www/html/mp3 -p 8080 -a 0.0.0.0 -d /etc/filebrowser/filebrowser.db
Restart=always

[Install]
WantedBy=multi-user.target
EOF
sudo mv /tmp/filebrowser.service /etc/systemd/system/filebrowser.service

sudo systemctl daemon-reload
sudo systemctl enable --now filebrowser

# Set the File Browser admin password, I recommend changing this here or after you've installed it
sudo systemctl stop filebrowser
sudo filebrowser users update admin --password sound-server -d /etc/filebrowser/filebrowser.db
sudo systemctl start filebrowser


clear
MAC=$(cat /sys/class/net/wlan0/address | tr ":" "-")
echo " .----------------.  .----------------.  .----------------. "
echo "| .--------------. || .--------------. || .--------------. |"
echo "| |   _____      | || |     ______   | || |     ______   | |"
echo "| |  |_   _|     | || |   .' ___  |  | || |   .' ___  |  | |"
echo "| |    | |       | || |  / .'   \_|  | || |  / .'   \_|  | |"
echo "| |    | |   _   | || |  | |         | || |  | |         | |"
echo "| |   _| |__/ |  | || |  \ \`.___.'\  | || |  \ \`.___.'\  | |"
echo "| |  |________|  | || |   \`._____.'  | || |   \`._____.'  | |"
echo "| |              | || |              | || |              | |"
echo "| '--------------' || '--------------' || '--------------' |"
echo " '----------------'  '----------------'  '----------------' "
echo
echo "          Larry's Command & Control - Sound Server"
echo

echo "Here is the Sound Server Address to add to Mission Control: $MAC"
echo
