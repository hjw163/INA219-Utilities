# INA219-Utilities
Collection of bash scripts to interface with the INA219's I2C Interface used by the Waveshare UPS HAT for Raspberry Pi.


Scripts:


Output current state of Configuration Register at address 0x00:
	
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


The i2c-tools package is required for the scripts to work:

	# apt update
	# apt install i2c-tools