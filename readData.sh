#!/usr/bin/env bash


#i2cdetect i2cdump i2cget i2cset i2c-stub-from-dump  i2ctransfer

set -e

scriptDir="$(dirname "$(realpath "${0}")")"

hash i2cget
hash "${scriptDir}/tobase"
hash sed

maxCurrent=5 #to be set to maximum expected current

currentLSB=$( bc -l <<< "${maxCurrent}/(2^15)" )
powerLSB=$( bc -l <<< "20*${currentLSB}" )
maxPower=$( bc -l <<< "20*${maxCurrent}" )

i2cBus='1'
chipAddr='0x42'
shuntAddr='0x01'
busAddr='0x02'
powerAddr='0x03'
currAddr='0x04'
caliAddr='0x05'

CYN='\e[1;36m' #cyan
NC='\e[0m' #noColor
RED='\e[1;31m' #red
GRN='\e[1;32m' #green

##config set in 0x00 register dosent seem to affect shunt & bus register voltage scaling...

scale () {
    local scale="${3}"
    local calc="${2}"
    local val="${1}"
    echo "scale=${scale}; ${val}${calc}" | bc -l | sed -r 's#^(\-)?\.#\10.#'
}

regGetRaw () {
    local fromAddr="${1}"
    i2cget -y "${i2cBus}" "${chipAddr}" "${fromAddr}" i 2 | sed 's/ 0x//'
}

echo

#shunt
echo -e "${RED}Shunt:${NC}"
shuntRaw=$(regGetRaw "${shuntAddr}")
shuntDec=$((shuntRaw << 48 >> 48))
shuntVolt=$(scale "${shuntDec}" '*10/1000' 3)
echo -e "    ${CYN}Voltage:${NC} ${shuntVolt}mV"

#bus
echo -e "${RED}Bus:${NC}"
busRaw=$(regGetRaw "${busAddr}")
busDec=$(( busRaw >> 3 ))
busVolt=$(scale "${busDec}" '*4/1000' 3)
echo -e "    ${CYN}Voltage:${NC} ${busVolt}V"

echo

echo -e "${RED}Math:${NC}"
CNVR=$(( (busRaw >> 1) & 0x01 ))
CNVRtxt=$( [[ "${CNVR}" == 1 ]] && echo "${GRN}Ready${NC}" || echo "${RED}Calculating${NC}"  )
OVF=$(( busRaw & 0x01 ))
OVFtxt=$( [[ "${OVF}" == 0 ]] && echo "${GRN}In range${NC}" || echo "${RED}Out of range${NC}" )
echo -e "    ${CYN}Calculation:${NC} ${CNVRtxt}"
echo -e "    ${CYN}Result:${NC} ${OVFtxt}"

echo

calibration=$(regGetRaw "${caliAddr}")
if [[ "${calibration}" == 0x0000 ]]; then
    CalibrationTxt="${CYN}Calibration register:${NC} ${RED}Not set, no Current/Power reading${NC}"
else
    CalibrationTxt="${CYN}Calibration Value:${NC} ${CalibrationTxt}"
fi
echo -e "${CalibrationTxt}"

echo

#current
echo -e "${RED}Current:${NC}"
currRaw=$(regGetRaw "${currAddr}")
currDec=$(( currRaw << 48 ))
currAmp=$(scale "${currDec}" "*${currentLSB}*1000/1" 3)
echo -e "    ${CYN}Min limit (LSB):${NC} $(scale "${currentLSB}" "*(1000^2)/1" 3)uA"
echo -e "    ${CYN}Max limit:${NC} ${maxCurrent}A"
echo -e "    ${CYN}Value:${NC} ${currAmp}A"

#power
echo -e "${RED}Power:${NC}"
powerRaw=$(regGetRaw "${powerAddr}")
powerDec=$(( powerRaw << 48 ))
powerWatt=$(scale "${powerDec}" "*${powerLSB}*1000/1" 3)
echo -e "    ${CYN}Min limit (LSB):${NC} $(scale "${powerLSB}" "*1000/1" 3)mW"
echo -e "    ${CYN}Max limit:${NC} ${maxPower}W"
echo -e "    ${CYN}Value:${NC} ${powerWatt}W"

echo