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

set -e -o pipefail

# Where to download misc things
DOWNLOAD_LOCATION=/var/tmp
INSTALL_LOCATION=/opt/BeagleBrew3
BBDOTORG_OVERLAYS_GIT_LOCATION=https://github.com/BeagleBoard/bb.org-overlays.git

OS_ID="$(grep ID /etc/os-release |cut -f 2 -d =)"
NOW="$(date +'%Y-%m-%d-%H-%M-%S')"
USERID="$(id -u)"
GROUPID="$(id -g)"


check_dpkg () {
	LC_ALL=C dpkg --list | awk '{print $2}' | grep "^${pkg}" >/dev/null || deb_pkgs="${deb_pkgs}${pkg} "
}

if ! sudo -v; then
	echo "sudo privileges needed, exiting"
	exit
fi

echo "Testing for existing operations"
if [ "$(systemctl is-active beaglebrew)" = "active" ]; then
	echo "Stopping beaglebrew operations"
	sudo systemctl stop beaglebrew;
fi
if [ "$(systemctl is-active beaglebrew3)" = "active" ]; then
	echo "Stopping beaglebrew3 operations"
	sudo systemctl stop beaglebrew3;
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
sudo mkdir "${INSTALL_LOCATION}"
if [ ! -d "${INSTALL_LOCATION}" ]; then
    echo "Creating ${INSTALL_LOCATION} failed"
    exit
fi
sudo chown --verbose "${USERID}":"${GROUPID}" "${INSTALL_LOCATION}"
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
deb_pkgs=""
pkg="python3-setuptools"
check_dpkg
pkg="python3-dev"
check_dpkg
#pkg="python3-smbus"
#check_dpkg
pkg="python3-flask"
check_dpkg
pkg="python3-setuptools"
check_dpkg
pkg="python3-pip"
check_dpkg
pkg="python3-virtualenv"
check_dpkg
pkg="python3-venv"
check_dpkg
pkg="virtualenv"
check_dpkg
pkg="build-essential"
check_dpkg
pkg="bash-completion"
check_dpkg
pkg="bison"
check_dpkg
pkg="libpcre3-dev"
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
pkg="bb-cape-overlays"
check_dpkg

if [ "${deb_pkgs}" ] ; then
	echo "Installing: ${deb_pkgs}"
	sudo apt update
    # shellshock disable=SC2086
	sudo apt --assume-yes install ${deb_pkgs}
	sudo apt clean
fi
echo "-----------------------------------"

echo "Establishing virtual environment in ${INSTALL_LOCATION}"
# for python 3.6
# python3 -m venv "${INSTALL_LOCATION}"
# still using python 3.5 in some plaes
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

echo "Checking for pyserial"
if [ ! "$( pip3 list | cut -d \  -f 1 | grep ^pyserial$ )" ]; then
	echo "Installing pyserial"
	pip3 install pyserial
else
	echo "pyserial already installed"
fi
echo "-----------------------------------"

echo "Checking for queuelib"
if [ ! "$( pip3 list | cut -d \  -f 1 | grep ^queuelib$ )" ]; then
	echo "Installing queuelib"
	pip3 install queuelib
else
	echo "queuelibalready installed"
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

echo "Removing all device tree files"
rm -vfr "${DOWNLOAD_LOCATION}"/bb.org-overlays/src/arm/*

echo "Installing custom Dallas 1W overlay"
wget --continue --output-document ${DOWNLOAD_LOCATION}/bb.org-overlays/src/arm/PL-W1-P9.27-00A0.dts \
  https://raw.githubusercontent.com/PeteLawler/PL-BB-overlays/master/PL-W1-P9.27-00A0.dts
echo "Installing custom UART4 overlay"
wget --continue --output-document ${DOWNLOAD_LOCATION}/bb.org-overlays/src/arm/PL-UART4-00A0.dts \
  https://raw.githubusercontent.com/PeteLawler/PL-BB-overlays/master/PL-UART4-00A0.dts
echo "-----------------------------------"

echo "Installing overlays"
bash -c "cd ${DOWNLOAD_LOCATION}/bb.org-overlays && ./install.sh"
echo "-----------------------------------"

echo "Installing systemd service"
sudo cp beaglebrew3.service /etc/systemd/system/.
sudo chmod 644 /etc/systemd/system/beaglebrew3.service
# use @ as a delimiter as INSTALL_LOCATION may contain the sed delimiter
sudo sed -i 's@INSTALL_LOCATION@'"$INSTALL_LOCATION"'@'g /etc/systemd/system/beaglebrew3.service
sudo systemctl daemon-reload
sudo systemctl disable beaglebrew3.service
echo "-----------------------------------"


echo "Checking for old logfiles"
if [ -d /var/log/beaglebrew3/ ]; then
	echo "Backing up old logfiles"
	sudo mv /var/log/beaglebrew3/ /var/log/beaglebrew3.${NOW}
fi
echo "-----------------------------------"

echo "Checking for missing logrotate configuration"
if [ -f /etc/logrotate.d/beaglebrew3 ]; then
	echo "Installing logrotation"
	sudo bash -c "echo '/var/log/beaglebrew3/* {
    rotate 5
    weekly
    notifempty
    compress
}
' > /etc/logrotate.d/beaglebrew3 "
fi
echo "-----------------------------------"

printf "Installing"
sudo cp -pvr BeagleBrew3 ${INSTALL_LOCATION}
printf "."
sudo bash -c "git log |head -1 > ${INSTALL_LOCATION}/beaglebrew3-version.txt"
if [ ! -d /var/log/beaglebrew3/ ]; then
	printf "."
	sudo mkdir -p /var/log/beaglebrew3/
fi
printf "."

if [ -L "/etc/opt/beaglebrew3_config.xml" ]; then
    sudo mv "/etc/opt/beaglebrew3_config.xml" "/etc/opt/beaglebrew3_config.xml.${NOW}"
fi
if [ ! "/etc/opt/beaglebrew3_config.xml" -ef "/${INSTALL_LOCATION}/BeagleBrew3/beaglebrew3_config.xml" ]; then
	sudo ln --symbolic --verbose /${INSTALL_LOCATION}/BeagleBrew3/beaglebrew3_config.xml /etc/opt/
fi
printf ". done.\n"
echo "-----------------------------------"

while true; do
	read -p "Do you wish to automatically boot BeagleBrew? " yn
	case $yn in
		[Yy]* ) sudo systemctl enable beaglebrew3.service;
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

