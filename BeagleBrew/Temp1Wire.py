#
# Copyright (c) 2012-2015 Stephen P. Smith
# Copyright (c) 2016 Peter Lawler <relwalretep@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining 
# a copy of this software and associated documentation files 
# (the "Software"), to deal in the Software without restriction, 
# including without limitation the rights to use, copy, modify, 
# merge, publish, distribute, sublicense, and/or sell copies of the Software, 
# and to permit persons to whom the Software is furnished to do so, 
# subject to the following conditions:

# The above copyright notice and this permission notice shall be included 
# in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

from subprocess import Popen, PIPE, call
import os

class Temp1Wire:
	numSensor = 0
	def __init__(self, tempSensorId):
		self.tempSensorId = tempSensorId
		self.sensorNum = Temp1Wire.numSensor
		Temp1Wire.numSensor += 1
		# Raspbian build in January 2015 (kernel 3.18.8 and higher) has changed the device tree.
		oldOneWireDir = "/sys/bus/w1/devices/w1_bus_master1/"
		newOneWireDir = "/sys/bus/w1/devices/"
		if os.path.exists(oldOneWireDir):
			self.oneWireDir = oldOneWireDir 
		else:
			self.oneWireDir = newOneWireDir
		print("Constructing 1W sensor %s"%(tempSensorId))

	def readTempC(self):
		temp_C = -99 # default to assuming a bad temp reading

		if os.path.exists(self.oneWireDir + self.tempSensorId + "/w1_slave"):
			pipe = Popen(["cat", self.oneWireDir + self.tempSensorId + "/w1_slave"], stdout=PIPE)
			result = pipe.communicate()[0]
			if (result.split('\n')[0].split(' ')[11] == "YES"):
			  temp_C = float(result.split("=")[-1])/1000 # temp in Celcius
		else:
			print("Sensor missing %s"%(self.oneWireDir + self.tempSensorId + "/w1_slave"))

		return temp_C
