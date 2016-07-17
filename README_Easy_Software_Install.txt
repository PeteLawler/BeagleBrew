Simple Complete Beaglebone & BeagleBrew Software Installation from Windows
---------------------------------------------------------------------------

1)  Google SDFormatter, Win32DiskImager and Putty and download them
2)  Use SDFormatter to format SD card
3)  Use Win32DiskImager to burn latest Beaglebone Debian Image from http://beagleboard.org/latest-images
4)  When Beagle Bone boots up, use Pyrrt to log onto the Beaglebone and grow partition. Type: 'sudo /opt/tools/scripts/grow_partition.sh'
5)  Reboot the Beaglebone 'sudo reboot'
6)  Use Putty to log onto the Beaglebone
7)  Update tools 'git -C /opt/scripts pull'
8)  Update kernel 'sudo /opt/scripts/tools/update_kernel.sh'
9)  Setup overlays, paying particular attention to the Dallas 1W overlay (BB-W1-P9.12-00A0).
. 'mkdir  ~/Downloads/bb.org-overlays'
. 'git clone https://github.com/beagleboard/bb.org-overlays ~/Downloads/bb.org-overlays
. 'cd  ~/Downloads/bb.org-overlays'
. './dtc-overlay.sh && ./install.sh'
. 'sudo bash -c "echo 'cape_enable=bone_capemgr.enable_partno=BB-W1-P9.12-00A0 >> /boot/uEnv.txt"''
10) Grab the BeagleBrew code. 'sudo git clone https://github.com/PeteLawler/BeagleBrew.git /var/www'
11) Make the install script executable. 'sudo chmod +x /var/www/BeagleBrew/beaglebrew_setup.sh'
12) Run the installer and follow the prompts. 'sudo /var/www/BeagleBrew/beaglebrew_setup.sh'
13) Edit the documented config.xml file in BeagleBrew directory to enter temp sensor ids and pins used for controlling a heating element.

If you were not supplied with the ID with your unit, connect it and read the device id located in the /sys/bus/w1/devices/ directory.

Note: In BeagleBrew directory type 'sudo git fetch' to get the latest version. How to edit files as per step (13) is beyond the scope of this document.
