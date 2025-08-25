#!/usr/bin/env bash

# shellcheck disable=SC2034
declare -A userVar=(
    ['i2cBus']='1'      #i2c Bus IO that is connected to the INA219
    ['chipAddr']='0x42' #address pointing to the specific INA219 device
    ['Rshunt']=0.1      # physical shunt resister value used in the circuit
    ['maxCurrent']=5    # maximum expected current output, for use in setting the calibration register
)