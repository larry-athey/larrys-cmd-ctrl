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

sudo dpkg-reconfigure locales

sudo apt update
sudo apt upgrade -y

sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
sudo apt install -y alsa-utils curl ffmpeg mpg123 lighttpd php php-common php-fpm php-mysql mariadb-server mariadb-client
sudo apt --fix-broken install -y
sudo apt autoremove -y

sudo systemctl enable lighttpd.service
sudo systemctl start lighttpd.service
sudo lighttpd-enable-mod fastcgi
sudo lighttpd-enable-mod fastcgi-php
sudo cp -f 15-fastcgi-php.conf /etc/lighttpd/conf-available/15-fastcgi-php.conf
PHPversion=$(php --version | sed -n 's/^PHP \([0-9]\+\.[0-9]\+\).*/\1/p')
sudo sed -i "s/7.4/$PHPversion/g" /etc/lighttpd/conf-available/15-fastcgi-php.conf
sudo chown -R www-data:www-data /var/log/lighttpd
sudo systemctl restart lighttpd.service

sudo rm -f /var/www/html/index.lighttpd.html
sudo cp -f play-sound.php /var/www/html/play-sound.php
sudo mkdir -p /var/www/html/mp3
sudo chown -R www-data:www-data /var/www/html
sudo chmod g+w -R /var/www/html
sudo usermod -a -G www-data pi
sudo usermod -a -G audio www-data
ln -s /var/www/html /home/pi/webroot

sudo curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
sudo mkdir -p /etc/filebrowser
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

sudo systemctl enable mariadb > /dev/null 2>&1
sudo systemctl start mariadb > /dev/null 2>&1

which mysql_secure_installation > /dev/null 2>&1
if [ $? -eq 0 ]; then
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
  echo "Time to secure the MySQL server, you will want to answer Yes to all questions"
  echo "EXCEPT for the one about using a Unix socket for authentication. Just be sure"
  echo "to set the root password to one that you can remember, simple is fine. Keep in"
  echo "mind that this system isn't designed to for inbound internet access, you don't"
  echo "have to worry about anything too complicated. THIS IS NOT A PUBLIC WEB SERVER!"
  echo
  sudo mysql_secure_installation
fi

sudo mysql < db-setup.sql

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
echo "Now installing phpMyAdmin, be sure to select the lighttpd configuration!"
echo
read -p "Press ENTER to continue..." nothing

sudo apt install -y phpmyadmin
sudo apt purge -y apache2
sudo service lighttpd force-reload

sudo apt clean

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
echo "Installation is now complete. Here is the Sound Server Address"
echo "to add to your Mission Control settings page: $MAC"
echo
