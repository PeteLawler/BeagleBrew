#!/bin/bash
#
# BeagleBrew Setup Script
# 
# type the following commands:
# chmod +x beaglebrew_setup.sh
# sudo ./beaglebrew_setup.sh
# sudo reboot
#

while true; do
    read -p "Do you wish to run apt-get update & apt-get upgrade?" yn
    case $yn in
        [Yy]* ) apt-get -y update; apt-get -y upgrade; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

#Install pip (package installer):
apt-get -y install python-setuptools
easy_install pip

#Install PySerial
pip install pyserial

#Install Python i2c and smbus
apt-get -y install python-smbus

#Install Flask
apt-get -y install python-dev
apt-get -y install libpcre3-dev
pip install Flask

cp beaglebrew.service /etc/systemd/system/.
chmod 755 /etc/systemd/system/beaglebrew.service
systemctl daemon-reload
systemctl disable beaglebrew.service

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
        [Yy]* ) reboot; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done


