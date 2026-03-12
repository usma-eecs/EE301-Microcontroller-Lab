You will find a batch file named "autoflash.bat" as well as the library bundle for CircuitPython v10 ("adafruit-circuitpython-bundle-10.x-mpy-20251024.zip").

INSTRUCTIONS

1)	Double tap the reset button at the center of Bluefruit. The Neopixels should go through a flashing sequence before all turn steady green.

2)	Once the Neopixels have all turned steady green, double click on "autoflash.bat" and follow the instructions (if any shows up), and the program should automatically execute the following:

	a)	Install the latest bootloader;
	b)	Install CircuitPython 10.0.3;
	c)	Erase all existing files on the Bluefruit; and
	d)	Install the demo/diagnostics code in “diagnostics” along with the basic libraries to get the Circuit Playground going. All the libraries required for the AI105 activities are also included, since the cadets are not required to figure out the libraries in that course.

3)	For EE301, depending on the specifics of your code, you may need to install additional libraries found in the library bundle.