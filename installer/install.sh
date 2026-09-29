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
echo "                 Larry's Command & Control"
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

sudo apt install -y hostapd dnsmasq lighttpd php php-common php-fpm php-curl php-mysql mariadb-server mariadb-client
sudo apt --fix-broken install -y
sudo apt autoremove -y

sudo systemctl stop hostapd dnsmasq
sudo systemctl unmask hostapd dnsmasq # Armbian sometimes masks dnsmasq

sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
sudo systemctl disable --now wpa_supplicant NetworkManager 2>/dev/null || true

sudo cp -f ./hostname /etc/hostname; sudo chmod 644 /etc/hostname
sudo cp -f ./10-ethernet-only.yaml /etc/netplan/10-ethernet-only.yaml; sudo chmod 600 /etc/netplan/10-ethernet-only.yaml
sudo cp -f ./30-wlan0-ap.network /etc/systemd/network/30-wlan0-ap.network; sudo chmod 644 /etc/systemd/network/30-wlan0-ap.network
sudo cp -f ./hostapd.conf /etc/hostapd/hostapd.conf; sudo chmod 644 /etc/hostapd/hostapd.conf
sudo cp -f ./lcc-ap.conf /etc/dnsmasq.d/lcc-ap.conf; sudo chmod 644 /etc/dnsmasq.d/lcc-ap.conf

sudo mkdir -p /etc/systemd/resolved.conf.d
sudo cp -f ./lcc.conf /etc/systemd/resolved.conf.d/lcc.conf; sudo chmod 644 /etc/systemd/resolved.conf.d/lcc.conf

sudo netplan apply

sudo systemctl restart systemd-networkd

echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' | sudo tee /etc/default/hostapd
echo "net.ipv4.ip_forward=0" | sudo tee /etc/sysctl.d/99-no-forward.conf

sudo sysctl -p /etc/sysctl.d/99-no-forward.conf

sudo systemctl daemon-reload
sudo systemctl enable --now hostapd dnsmasq
sudo systemctl restart hostapd dnsmasq

PHPversion=$(php --version | sed -n 's/^PHP \([0-9]\+\.[0-9]\+\).*/\1/p')
sudo systemctl enable lighttpd.service
sudo systemctl start lighttpd.service
sudo lighttpd-enable-mod fastcgi
sudo lighttpd-enable-mod fastcgi-php
sudo cp -f ./15-fastcgi-php.conf /etc/lighttpd/conf-available/15-fastcgi-php.conf; sudo chmod 644 /etc/lighttpd/conf-available/15-fastcgi-php.conf
sudo sed -i "s/7.4/$PHPversion/g" /etc/lighttpd/conf-available/15-fastcgi-php.conf
sudo chown -R www-data:www-data /var/log/lighttpd
sudo systemctl restart lighttpd.service

sudo rm -f /var/www/html/index.lighttpd.html
sudo cp -f ./webroot/* /var/www/html
cd /var/www/html
sudo tar -xzvf bootstrap.tar.gz
sudo rm -f bootstrap.tar.gz
sudo tar -xzvf js.tar.gz
sudo rm -f js.tar.gz
cd -
sudo chown -R www-data:www-data /var/www/html
sudo chmod g+w -R /var/www/html
sudo usermod -a -G www-data pi
ln -s /var/www/html /home/pi/webroot

sudo mkdir -p /usr/share/lcc
sudo cp -f ./undercarriage/* /usr/share/lcc
sudo chmod +x /usr/share/lcc/*
sudo chown -R www-data:www-data /usr/share/lcc
sudo chmod g+w -R /usr/share/lcc
ln -s /usr/share/lcc /home/pi/undercarriage

sudo systemctl enable mariadb > /dev/null 2>&1
sudo systemctl start mariadb > /dev/null 2>&1

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
echo "                 Larry's Command & Control"
echo
echo "Time to secure the MySQL server, you will want to answer Yes to all questions"
echo "EXCEPT for the one about using a Unix socket for authentication. Just be sure"
echo "to set the root password to one that you can remember, simple is fine. Keep in"
echo "mind that this system isn't designed to for inbound internet access, you don't"
echo "have to worry about anything too complicated. THIS IS NOT A PUBLIC WEB SERVER!"
echo

which mysql_secure_installation > /dev/null 2>&1
if [ $? -eq 0 ]; then
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
echo "                 Larry's Command & Control"
echo
echo "Now installing phpMyAdmin, be sure to select the lighttpd configuration!"
echo
read -p "Press ENTER to continue..." nothing

sudo apt install -y phpmyadmin
sudo apt purge -y apache2
sudo service lighttpd force-reload

sudo apt clean

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
echo "                 Larry's Command & Control"
echo
echo "Installation is now complete, but you still need to create the CRON job that"
echo "runs the undercarriage of the system."
echo
echo "Run 'sudo crontab -e' and paste the line of text below into the editor & save."
echo
echo "* * * * * /usr/share/lcc/cronjob"
echo
echo "Please restart your computer after creating the CRON job."
echo
