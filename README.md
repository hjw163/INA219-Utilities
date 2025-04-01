# INA219-Utilities
Collection of bash scripts to interface with the INA219's I2C Interface used by the Waveshare UPS HAT for Raspberry Pi.


# Prerequisites:

The i2c-tools package is required for the scripts to work:

	# apt update
	# apt install i2c-tools

# Installing:

Simply clone this repository to your local machine recursivly:

	$ git clone --recursive "https://github.com/hjw163/INA219-Utilities.git"

Execute scripts in the INA219-Utilities directory.
 
# Scripts:

The `readConfig.sh` script outputs the current state of Configuration Register at address 0x00:

    $ readConfig.sh
    
    reset: 0

    configuration:
        bus voltage range: 32V fullscale range
        Programmable Gain Amplifier: Mode3 (1/8x @±320mV)
    badc mode:
        sample mode: Single
        sample resolution: 12 bits
    sadc mode:
        sample mode: Single
        sample resolution: 12 bits
    monitoring:
        status: up
        operating mode: Continuous
        bus Voltage Monitoring: Active
        shunt Voltage Monitoring: Active


The `readData.sh` script outputs the state of Data Registers 0x01-0x04:
Script is incomplete and currently only outputs 
1.  Shunt voltage (R-0x01) @ PGA 1/8;
2.  Bus voiltage (R-0x02) @ 32V full-scale

    $ readConfig.sh

    Assume 32V full-scale & PGA 1/8

    Shunt:
    Voltage: -19.21mV
    Bus:
    Voltage: 8.16V

    Math:
    Calculation: Ready
    Result: Out of range

