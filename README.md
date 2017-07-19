[![Build Status](https://travis-ci.org/PeteLawler/BeagleBrew.svg?branch=master)](https://travis-ci.org/PeteLawler/BeagleBrew)

# Beaglebone Black Temperature Controller

## This is a fork in progress of Steven Smith's [Raspberry Pi Temperature Controller](https://github.com/steve71/RasPiBrew)

***This fork no longer works with RPi.***

> Note: Software is [X11 Licensed](http://directory.fsf.org/wiki/License:X11) (aka MIT)

----------

This software is designed to operate on a [BeagleBone Black](http://beagleboard.org/black), a low powered open source single board computer. More information on this hardware can be found on the [BeagleBone Black eWiki](http://elinux.org/Beagleboard:BeagleBoneBlack) page.

It is designed to be run on the [Debian Stable](https://debian.org) operating system and utilises [Python3](https://www.python.org/), [Bootstrap](https://getbootstrap.com/), [jQuery](https://jquery.com), [Flot](http://www.flotcharts.org/), and [ToggleSwitch](https://ghinda.net/css-toggle-switch/)

WARNING: This software uses an unsafe threaded web server. It is highly recommended in production to place it behind a proper WSGI compliant web server such as nginx, lighttpd or Apache. Once this is done, remove the 'threaded=True' call from app.run.

---------

# Beaglebone Black Brewing Controller

## Control a Water Heater Wirelessly over a Web Interface

This program will control an electric heating element in a vessel to set temperatures and regulate boil.  All status included temperature is sent back wirelessly approx. every second.  The duty cycle and temperature is plotted in real time.  A Type C PID algorithm has been successfully implemented to automatically control the heating element when the desired temperature is set.

For Flask html template, see templates/beaglebrew.html.  The config.xml file explains how to setup for one, two or three vessels.  The number of vessels and GPIO switches can easily be expanded in the software. 

On the client side jQuery and various plugins can be used to display data such as line charts and gauges. Mouse overs on the temperature plot will show the time and temp for the individual points.  It is currently working in a Firefox Browser.

On the hardware, it uses [Adafruit's BBIO Python](https://github.com/adafruit/adafruit-beaglebone-io-python) library. The Adafruit Library seems to work 'best' by using the PIN NAME, as per the [BeableBone Black System Reference Manual] (https://github.com/CircuitCo/BeagleBone-Black/raw/master/BBB_SRM.pdf)

The PID algorithm was translated from C code to Python.  The C code was from "PID Controller Calculus with full C source source code" by Emile van de Logt
An explanation on how to tune it is from the following web site:
[http://www.vandelogt.nl/nl_regelen_pid.php](http://www.vandelogt.nl/nl_regelen_pid.php)

The PID can be tuned very simply via the Ziegler-Nichols open loop method.  Just follow the directions in the controller interface screen, highlight the sloped line in the temperature plot and the parameters are automatically calculated.  After tuning with the Ziegler-Nichols method the parameters still needed adjustment because there was an overshoot of about 2 degrees in a development system. The original developer did not want the temperature to go past the setpoint since it takes a long time to come back down. Therefore, the parameters were adjusted to eliminate the overshoot.  For this particular system the Ti term was more than doubled and the Td parameter was set to about a quarter of the open loop calculated value.  Also a simple moving average was used on the temperature data that was fed to the PID controller to help improve performance.  Tuning the parameters via the Integral of Time weighted Absolute Error (ITAE-Load) would provide the best results as described on van de Logt's website above.

---------
## Install

The ultimate plan is to make this an installable python package, however for now please use the beaglebrew3_setup.sh script. 
