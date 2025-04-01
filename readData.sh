#!/usr/bin/env bash


#i2cdetect i2cdump i2cget i2cset i2c-stub-from-dump  i2ctransfer

set -e

scriptDir="$(dirname "$(realpath "${0}")")"

hash i2cget
hash "${scriptDir}/tobase"

i2cBus='1'
chipAddr='0x42'
shuntAddr='0x01'
busAddr='0x02'

CYN='\e[1;36m' #cyan
NC='\e[0m' #noColor
RED='\e[1;31m' #red
GRN='\e[1;32m' #green

echo

echo 'Assume 32V full-scale & PGA 1/8'

echo

#shunt
echo -e "${RED}Shunt:${NC}"
shuntRaw=$(i2cget -y "${i2cBus}" "${chipAddr}" "${shuntAddr}" i 2 | sed 's/ 0x//')
shuntDec=$(( shuntRaw << 48 >> 48 ))
shuntVolt=$(echo "scale=2; ${shuntDec}/100" | bc -l | sed -r 's#^(\-)?\.#\10.#' )
echo -e "    ${CYN}Voltage:${NC} ${shuntVolt}mV"

#bus
echo -e "${RED}Bus:${NC}"
busRaw=$(i2cget -y "${i2cBus}" "${chipAddr}" "${busAddr}" i 2 | sed 's/ 0x//')
busDec=$(( busRaw >> 3 ))
busVolt=$(echo "scale=2; ${busDec}*4/1000" | bc -l | sed -r 's#^(\-)?\.#\10.#' )

echo -e "    ${CYN}Voltage:${NC} ${busVolt}V"

echo

##For future use in power/current reading
echo -e "${RED}Math:${NC}"
CNVR=$(( (busRaw >> 1) & 0x01 ))
CNVRtxt=$( [[ "${CNVR}" == 1 ]] && echo "${GRN}Ready${NC}" || echo "${RED}Calculating${NC}"  )
OVF=$(( busRaw & 0x01 ))
OVFtxt=$( [[ "${OVF}" == 1 ]] && echo "${GRN}In range${NC}" || echo "${RED}Out of range${NC}" )

echo -e "    ${CYN}Calculation:${NC} ${CNVRtxt}"
echo -e "    ${CYN}Result:${NC} ${OVFtxt}"

echo