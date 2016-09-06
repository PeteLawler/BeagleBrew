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

check_dpkg () {
	LC_ALL=C dpkg --list | awk '{print $2}' | grep "^${pkg}" >/dev/null || deb_pkgs="${deb_pkgs}${pkg} "
}

if ! sudo -v; then
	echo "sudo privileges needed, exiting"
	exit
fi

if [ ! -f `which timedatectl` ]; then
	echo "Setting time via ntpdate"
	ntpdate pool.ntp.org
else
	echo "Setting time via timedatectl"
	timedatectl set-ntp true
fi

while true; do
	read -p "Do you wish to check for system updates? " yn
	case $yn in
		[Yy]* ) apt --assume-yes update && apt --assume-yes upgrade; break;;
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

easy_install pip

pip install Flask # See https://github.com/adafruit/adafruit-beaglebone-io-python/issues/107 why we can't install Adafruit's BBIO via pypi here...

if [ ! -d ${DOWNLOAD_LOCATION} ]; then
	mkdir -p ${DOWNLOAD_LOCATION}
fi
if [ -d ${DOWNLOAD_LOCATION}/adafruit-beaglebone-io-python/.git ]; then
	echo "Updating adafruit-beaglebone-io-python if necessary"
	git -C ${DOWNLOAD_LOCATION}/adafruit-beaglebone-io-python pull
else
	git -C ${DOWNLOAD_LOCATION} clone ${ADAFRUIT_PYTHON_GIT_LOCATION}
fi
bash -c "cd ${DOWNLOAD_LOCATION}/adafruit-beaglebone-io-python/ && python setup.py install"

if [ -d ${DOWNLOAD_LOCATION}/bb.org-overlays/.git ]; then
	echo "Updating bb.org-overlays if necessary"
	git -C ${DOWNLOAD_LOCATION}/bb.org-overlays pull
else
	git -C ${DOWNLOAD_LOCATION} clone ${BBDOTORG_OVERLAYS_GIT_LOCATION}
fi
if [ ! -L /usr/bin/dtc-v4.1.x ]; then
	bash -c "cd ${DOWNLOAD_LOCATION}/bb.org-overlays && ./dtc-overlay.sh"
fi
bash -c "cd ${DOWNLOAD_LOCATION}/bb.org-overlays && ./install.sh"

cp beaglebrew.service /etc/systemd/system/.
chmod 644 /etc/systemd/system/beaglebrew.service
# use @ as a delimiter as INSTALL_LOCATION may contain the sed delimiter
sed -i 's@INSTALL_LOCATION@'"$INSTALL_LOCATION"'@'g /etc/systemd/system/beaglebrew.service
systemctl daemon-reload
systemctl disable beaglebrew.service

if [ -L /etc/opt/beaglebrew_config.xml ]; then
	echo "Removing config"
	rm /etc/opt/beaglebrew_config.xml
fi
if [ -d /opt/BeagleBrew ]; then
	echo "Removing existing install"
	rm -fr /opt/BeagleBrew
fi
if [ -d /var/log/beaglebrew/ ]; then
	echo "Removing logfiles"
	rm -fr /var/log/beaglebrew/
fi
echo "Installing..."
cp -pvr BeagleBrew ${INSTALL_LOCATION}
if [ ! -d /var/log/beaglebrew/ ]; then
	mkdir -p /var/log/beaglebrew/
fi
ln -s /opt/BeagleBrew/beaglebrew_config.xml /etc/opt/

while true; do
	read -p "Do you wish to automatically boot BeagleBrew? " yn
	case $yn in
		[Yy]* ) systemctl enable beaglebrew.service;
		break;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
done

while true; do
	read -p "Reboot to complete installation? " yn
	case $yn in
		[Yy]* ) systemctl reboot; break;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
done

