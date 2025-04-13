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

Shunt voltage & Bus voltage reading should be usable without any configurations.

Current & Power readings require the i2c calibration register to be set, and the value of `maxCurrent` variable in `readData.sh` modified to reflect maximum expected current.

    $ readData.sh
    
    Shunt:
        Voltage: -6.330mV
    Bus:
        Voltage: 8.196V

    Math:
        Calculation: Ready
        Result: In range

    Calibration register: Not set, no Current/Power reading

    Current:
        Min limit (LSB): 152.587uA
        Max limit: 5A
        Value: 0A
    Power:
        Min limit (LSB): 3.051mW
        Max limit: 100W
        Value: 0W
