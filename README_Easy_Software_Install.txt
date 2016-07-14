Simple Complete Beaglebone & BeagleBrew Software Installation from Windows
---------------------------------------------------------------------------

1) Google SDFormatter, Win32DiskImager and Putty and download them
2) Use SDFormatter to format SD card
3) Use Win32DiskImager to burn latest Beaglebone Debian Image from http://beagleboard.org/latest-images
4) When Beagle Bone boots up, use Pyrrt to log onto the Beaglebone and grow partition. Type: 'sudo /opt/tools/scripts/grow_partition.sh'
5) Reboot the Beaglebone 'sudo reboot'
6) Use Putty to log onto the Beaglebone
7) Update tools 'git -C /opt/scripts pull'
8) Update kernel 'sudo /opt/scripts/tools/update_kernel.sh'
9) Grab the BeagleBrew code. 'sudo git clone https://github.com/PeteLawler/BeagleBrew.git /var/www'
10) Make the install script executable. 'sudo chmod +x /var/www/BeagleBrew/beaglebrew_setup.sh'
11) Run the installer and follow the prompts. 'sudo /var/www/BeagleBrew/beaglebrew_setup.sh'
12) Edit the documented config.xml file in BeagleBrew directory to enter temp sensor ids and pins used for controlling a heating element. (The temp sensor id is located in the following directory: /sys/bus/w1/devices/).  Edit other options as desired.

Note: In BeagleBrew directory type 'sudo git fetch' to get the latest version. How to edit files as per step (12) is beyond the scope of this document.
