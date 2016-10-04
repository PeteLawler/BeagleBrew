#!/bin/bash
#
# BeagleBrew Setup Script
# 
# type the following commands:
# chmod +x beaglebrew_setup.sh
# sudo ./beaglebrew_setup.sh
# sudo reboot

# Where to download misc things
DOWNLOAD_LOCATION=/var/tmp
INSTALL_LOCATION=/opt/BeagleBrew
ADAFRUIT_PYTHON_GIT_LOCATION=https://github.com/adafruit/adafruit-beaglebone-io-python.git
BBDOTORG_OVERLAYS_GIT_LOCATION=https://github.com/RobertCNelson/bb.org-overlays.git
OS_ID=$(grep ID /etc/os-release |cut -f 2 -d =)

check_dpkg () {
	LC_ALL=C dpkg --list | awk '{print $2}' | grep "^${pkg}" >/dev/null || deb_pkgs="${deb_pkgs}${pkg} "
}

if ! sudo -v; then
	echo "sudo privileges needed, exiting"
	exit
fi

if [ ! -f `which timedatectl` ]; then
	echo "Setting time via ntpdate"
	sudo ntpdate pool.ntp.org
else
	echo "Setting time via timedatectl"
	sudo timedatectl set-ntp true
fi

while true; do
	read -p "Do you wish to check for system updates? " yn
	case $yn in
		[Yy]* ) sudo apt --assume-yes update && sudo apt --assume-yes upgrade; break;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
done

#Install pip (package installer) and other needed packages
echo "Checking for support tools"
unset deb_pkgs
pkg="python-setuptools"
check_dpkg
pkg="python-dev"
check_dpkg
pkg="python-smbus"
check_dpkg
pkg="libpcre3-dev"
check_dpkg
pkg="build-essential"
check_dpkg
pkg="python-dev"
check_dpkg
pkg="python-setuptools"
check_dpkg
pkg="python-pip"
check_dpkg
pkg="python-smbus"
check_dpkg
pkg="python-serial"
check_dpkg
pkg="bash-completion"
check_dpkg
pkg="bison"
check_dpkg
pkg="build-essential"
check_dpkg
pkg="curl"
check_dpkg
pkg="flex"
check_dpkg
pkg="git"
check_dpkg
pkg="git-core"
check_dpkg
pkg="man"
check_dpkg

if [ "${deb_pkgs}" ] ; then
	echo "Installing: ${deb_pkgs}"
	sudo apt update
	sudo apt --assume-yes install ${deb_pkgs}
	sudo apt clean
fi
echo "-----------------------------------"

echo "Checking for pip"
if [ ! -x $( which pip ) ]; then
	echo "Installing pip"
	sudo easy_install pip
else
	echo "pip already installed"
fi
echo "-----------------------------------"

echo "Checking for Flask"
if [ ! $( pip list | cut -d \  -f 1 | grep ^Flask$ ) ]; then
	echo "Installing Flask"
	sudo pip install Flask
else
	echo "Flask already installed"
fi
echo "-----------------------------------"

echo "Checking for Adafruit_BBIO"
if [ ! $( pip list | cut -d \  -f 1 | grep ^Adafruit_BBIO$ ) ]; then
	echo "Installing Adafruit BBIO"
	sudo pip install Adafruit_BBIO
else
	echo "Adafruit_BBIO already installed"
fi

echo "-----------------------------------"

echo "Installing systemd service"
sudo cp beaglebrew.service /etc/systemd/system/.
sudo chmod 644 /etc/systemd/system/beaglebrew.service
# use @ as a delimiter as INSTALL_LOCATION may contain the sed delimiter
sudo sed -i 's@INSTALL_LOCATION@'"$INSTALL_LOCATION"'@'g /etc/systemd/system/beaglebrew.service
sudo systemctl daemon-reload
sudo systemctl disable beaglebrew.service

echo "Checking for old install"

if [ -L /etc/opt/beaglebrew_config.xml ]; then
	echo "Removing config"
	sudo rm /etc/opt/beaglebrew_config.xml
fi

if [ -d /opt/BeagleBrew ]; then
	echo "Removing existing install"
	sudo rm -fr /opt/BeagleBrew
fi

if [ -d /var/log/beaglebrew/ ]; then
	echo "Removing logfiles"
	sudo rm -fr /var/log/beaglebrew/
fi

if [ -f /etc/logrotate.d/beaglebrew/ ]; then
	echo "Installing logrotation"
	sudo bash -c "echo '/var/log/beaglebrew/* {
        rotate 5
        weekly
        notifempty
        compress
}
' > /etc/logrotate.d/beaglebrew "
fi

printf "Installing"
sudo cp -pvr BeagleBrew ${INSTALL_LOCATION}
printf "."
if [ ! -d /var/log/beaglebrew/ ]; then
	printf "."
	sudo mkdir -p /var/log/beaglebrew/
fi
printf "."
sudo ln -s /opt/BeagleBrew/beaglebrew_config.xml /etc/opt/
printf ". done.\n
"


while true; do
	read -p "Do you wish to automatically boot BeagleBrew? " yn
	case $yn in
		[Yy]* ) sudo systemctl enable beaglebrew.service;
		break;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
done

while true; do
	read -p "Reboot to complete installation? " yn
	case $yn in
		[Yy]* ) sudo systemctl reboot; break;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
done

