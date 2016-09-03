#!/bin/bash
#
# BeagleBrew Setup Script
# 
# type the following commands:
# chmod +x beaglebrew_setup.sh
# sudo ./beaglebrew_setup.sh
# sudo reboot
#

if ! id | grep -q root; then
	echo "must be run as root"
	exit
fi

while true; do
	read -p "Do you wish to run apt-get update & apt-get upgrade?" yn
	case $yn in
		[Yy]* ) apt-get -y update; apt-get -y upgrade; break;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
done

#Install pip (package installer) and other needed packages
apt-get -y install python-setuptools python-dev python-smbus libpcre3-dev

easy_install pip

pip install Flask

cp beaglebrew.service /etc/systemd/system/.
chmod 755 /etc/systemd/system/beaglebrew.service
sed -i s/INSTALL_LOCATION/\\/opt\\/BeagleBrew/g /etc/systemd/system/beaglebrew.service
systemctl daemon-reload
systemctl disable beaglebrew.service

cp -pvrn BeagleBrew /opt/.
mkdir -p /var/log/beaglebrew/
ln -s /opt/BeagleBrew/beaglebrew_config.xml /etc/opt/

while true; do
	read -p "Do you wish to automatically boot BeagleBrew?" yn
	case $yn in
		[Yy]* ) systemctl enable beaglebrew.service;
		break;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
done

while true; do
	read -p "Reboot to complete installation?" yn
	case $yn in
		[Yy]* ) systemctl reboot; break;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
done

