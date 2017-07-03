#!/bin/bash

##########################################################################
# A script to install the BeagleBrew system
# Copyright (C) 1994-2017 Peter Lawler
# Snail mail: PO Box 195
#             Lindisfarne, Tasmania
#             AUSTRALIA 7015
# email:      relwalretep@gmail.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
##########################################################################

# Where to download misc things
DOWNLOAD_LOCATION=/var/tmp
INSTALL_LOCATION=/opt/BeagleBrew
BBDOTORG_OVERLAYS_GIT_LOCATION=https://github.com/BeagleBoard/bb.org-overlays.git

OS_ID=$(grep ID /etc/os-release |cut -f 2 -d =)
NOW=$(date +"%Y-%m-%d-%H-%M-%S")


check_dpkg () {
	LC_ALL=C dpkg --list | awk '{print $2}' | grep "^${pkg}" >/dev/null || deb_pkgs="${deb_pkgs}${pkg} "
}

if ! sudo -v; then
	echo "sudo privileges needed, exiting"
	exit
fi

echo "Testing for existing operations"
if [ "$(systemctl is-active beaglebrew)" = "active" ]; then
	echo "Stopping existing operations"
	sudo systemctl stop beaglebrew;
fi

if [ ! -f "$(which timedatectl)" ]; then
	echo "Setting time via ntpdate"
	sudo ntpdate pool.ntp.org
else
	echo "Setting time via timedatectl"
	sudo timedatectl set-ntp true
fi

echo "Checking for old install"
if [ -d "${INSTALL_LOCATION}" ]; then
	echo "Backing up old install"
	sudo mv -v "${INSTALL_LOCATION}" "${INSTALL_LOCATION}.${NOW}"
fi
mkdir "${INSTALL_LOCATION}"
if [ -d "${INSTALL_LOCATION}" ]; then
    echo "Creating ${INSTALL_LOCATION} failed"
    exit
fi
echo "-----------------------------------"

while true; do
	read -p "Do you wish to check for system updates? " yn
	case $yn in
		[Yy]* ) sudo apt --assume-yes update && sudo apt --assume-yes upgrade; break;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
done

# Install pip3 (package installer) and other needed packages
echo "Checking for support tools"
unset deb_pkgs
pkg="python3-setuptools"
check_dpkg
pkg="python3-dev"
check_dpkg
pkg="python3-smbus"
check_dpkg
pkg="libpcre3-dev"
check_dpkg
pkg="build-essential"
check_dpkg
pkg="python3-dev"
check_dpkg
pkg="python3-setuptools"
check_dpkg
pkg="python3-pip"
check_dpkg
pkg="python3-virtualenv"
check_dpkg
pkg="virtualenv"
check_dpkg
pkg="python3-flask"
check_dpkg
pkg="python3-smbus"
check_dpkg
pkg="python3-serial"
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
	sudo apt --assume-yes install "${deb_pkgs}"
	sudo apt clean
fi
echo "-----------------------------------"

echo "Establishing virtual environment"
virtualenv -p python3 "${INSTALL_LOCATION}"
if [ -f "${INSTALL_LOCATION}/bin/activate" ]; then
    # shellcheck source=/dev/null
    source "${INSTALL_LOCATION}/bin/activate"
else
    echo "Error activating virtual environment"
exit 1
fi


echo "Checking for Adafruit-BBIO"
if [ ! "$( pip3 list | cut -d \  -f 1 | grep ^Adafruit-BBIO$ )" ]; then
	echo "Installing Adafruit BBIO"
	pip3 install Adafruit-BBIO
else
	echo "Adafruit-BBIO already installed"
fi
echo "-----------------------------------"

echo "Testing for ${DOWNLOAD_LOCATION}"
if [ ! -d ${DOWNLOAD_LOCATION} ]; then
	echo "Creating ${DOWNLOAD_LOCATION}"
	mkdir -p ${DOWNLOAD_LOCATION}
fi
echo "-----------------------------------"

echo "Testing for ${DOWNLOAD_LOCATION}/bb.org-overlays/.git"
if [ -d ${DOWNLOAD_LOCATION}/bb.org-overlays/.git ]; then
	echo "Updating bb.org-overlays if necessary"
	git -C ${DOWNLOAD_LOCATION}/bb.org-overlays reset --hard HEAD
	git -C ${DOWNLOAD_LOCATION}/bb.org-overlays pull
else
	echo "Cloning bb.org-overlays"
	git -C ${DOWNLOAD_LOCATION} clone ${BBDOTORG_OVERLAYS_GIT_LOCATION}
fi
echo "-----------------------------------"

echo "Installing custom Dallas 1W overlay"
wget --continue --output-document ${DOWNLOAD_LOCATION}/bb.org-overlays/src/arm/PL-W1-P9.27-00A0.dts \
  https://raw.githubusercontent.com/PeteLawler/PL-BB-overlays/master/PL-W1-P9.27-00A0.dts
echo "Installing custom UART4 overlay"
wget --continue --output-document ${DOWNLOAD_LOCATION}/bb.org-overlays/src/arm/PL-UART4-00A0.dts \
  https://raw.githubusercontent.com/PeteLawler/PL-BB-overlays/master/PL-UART4-00A0.dts
echo "-----------------------------------"

echo "Testing for patched dtc"
if [ ! -L /usr/bin/dtc-v4.1.x ]; then
	echo "Installing patched dtc"
	bash -c "cd ${DOWNLOAD_LOCATION}/bb.org-overlays && ./dtc-overlay.sh"
fi
echo "-----------------------------------"

echo "Installing overlays"
bash -c "cd ${DOWNLOAD_LOCATION}/bb.org-overlays && ./install.sh"
echo "-----------------------------------"

echo "Installing systemd service"
sudo cp beaglebrew.service /etc/systemd/system/.
sudo chmod 644 /etc/systemd/system/beaglebrew.service
# use @ as a delimiter as INSTALL_LOCATION may contain the sed delimiter
sudo sed -i 's@INSTALL_LOCATION@'"$INSTALL_LOCATION"'@'g /etc/systemd/system/beaglebrew.service
sudo systemctl daemon-reload
sudo systemctl disable beaglebrew.service
echo "-----------------------------------"


echo "Checking for old logfiles"
if [ -d /var/log/beaglebrew/ ]; then
	echo "Backing up old logfiles"
	sudo mv /var/log/beaglebrew/ /var/log/beaglebrew.${NOW}
fi
echo "-----------------------------------"

echo "Checking for missing logrotate configuration"
if [ -f /etc/logrotate.d/beaglebrew ]; then
	echo "Installing logrotation"
	sudo bash -c "echo '/var/log/beaglebrew/* {
    rotate 5
    weekly
    notifempty
    compress
}
' > /etc/logrotate.d/beaglebrew "
fi
echo "-----------------------------------"

printf "Installing"
sudo cp -pvr BeagleBrew ${INSTALL_LOCATION}
printf "."
sudo bash -c "git log |head -1 > ${INSTALL_LOCATION}/beaglebrew-version.txt"
if [ ! -d /var/log/beaglebrew/ ]; then
	printf "."
	sudo mkdir -p /var/log/beaglebrew/
fi
printf "."

if [ ! "/etc/opt/beaglebrew_config.xml" -ef "/opt/BeagleBrew/beaglebrew_config.xml" ]; then
	sudo ln --symbolic --verbose /opt/BeagleBrew/beaglebrew_config.xml /etc/opt/
fi
printf ". done.\n"
echo "-----------------------------------"

while true; do
	read -p "Do you wish to automatically boot BeagleBrew? " yn
	case $yn in
		[Yy]* ) sudo systemctl enable beaglebrew.service;
		break;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
done
echo "-----------------------------------"

while true; do
	read -p "Reboot to complete installation? " yn
	case $yn in
		[Yy]* ) sudo systemctl reboot; break;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
done

