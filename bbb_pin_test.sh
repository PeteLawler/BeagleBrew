#!/bin/bash

# bbb_pintest.sh - a quick shell script to test BBB GPIO pins
# Copyright (C) yyyy Peter Lawler
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

SLEEP_PERIOD=0.1
for PIN_NUMBER in "66" "67" "68" "69"; do
	echo ${f};
	sudo bash -c "echo 'echo $PIN_NUMBER > /sys/class/gpio/export' && echo '$PIN_NUMBER' > /sys/class/gpio/export"
	sleep $SLEEP_PERIOD
	sudo bash -c "echo 'echo out > /sys/class/gpio/gpio$PIN_NUMBER/direction' && echo 'out' > /sys/class/gpio/gpio$PIN_NUMBER/direction"
	sleep $SLEEP_PERIOD
	sudo bash -c "echo 'echo 0 > /sys/class/gpio/gpio$PIN_NUMBER/value' && echo '0' > /sys/class/gpio/gpio$PIN_NUMBER/value"
	sleep $SLEEP_PERIOD
	sudo bash -c "echo 'echo 1 > /sys/class/gpio/gpio$PIN_NUMBER/value' && echo '1' > /sys/class/gpio/gpio$PIN_NUMBER/value"
	sleep $SLEEP_PERIOD
	sudo bash -c "echo 'echo in > /sys/class/gpio/gpio$PIN_NUMBER/direction' && echo 'in' > /sys/class/gpio/gpio$PIN_NUMBER/direction"
	sleep $SLEEP_PERIOD
	sudo bash -c "echo 'echo $PIN_NUMBER > /sys/class/gpio/unexport' && echo '$PIN_NUMBER' > /sys/class/gpio/unexport"
	sleep $SLEEP_PERIOD
done

