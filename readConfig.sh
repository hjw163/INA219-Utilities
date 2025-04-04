#!/usr/bin/env bash

#i2cdetect i2cdump i2cget i2cset i2c-stub-from-dump  i2ctransfer

#       15      14      13      12      11      10      9       8       7       6       5       4       3       2       1       0
#       RST     —       BRNG    PG1     PG0     BADC4   BADC3   BADC2   BADC1   SADC4   SADC3   SADC2   SADC1   MODE3   MODE2   MODE1
#       R/W-0   R/W-0   R/W-1   R/W-1   R/W-1   R/W-0   R/W-0   R/W-1   R/W-1   R/W-0   R/W-0   R/W-1   R/W-1   R/W-1   R/W-1   R/W-1

set -e

scriptDir="$(dirname "$(realpath "${0}")")"

hash i2cget
hash "${scriptDir}/tobase"

if [[ "${1}" == '-q' ]]; then
    exec 8>&1
    exec 1>/dev/null
fi

i2cBus='1'
chipAddr='0x42'
dataAddr='0x00'

reg=$( i2cget -y "${i2cBus}" "${chipAddr}" "${dataAddr}" i 2 | sed 's/ 0x//' | "${scriptDir}/tobase" 2 )

reset="${reg:0:1}"
brng="0b${reg:2:1}"
pga="0b${reg:3:2}"
badc="0b${reg:5:4}"
sadc="0b${reg:9:4}"
mode="0b${reg:13:3}"

CYN='\e[1;36m' #cyan
NC='\e[0m' #noColor
RED='\e[1;31m' #red

echo

echo -e "${CYN}reset:${NC} ${reset}"
echo
echo -e "${RED}configuration:${NC}"

busVR=$(echo "${brng}" | "${scriptDir}/tobase" 2)
busVrange=$( [[ "${busVR}" == 1 ]] && echo "16V fullscale range" || echo "32V fullscale range" )
echo -e "   ${CYN}bus voltage range:${NC} ${busVrange}"

pgaMode=$( echo "${pga}" | "${scriptDir}/tobase" 10 )
pgaRange=(
    '1x @ ±40mV'
    '1/2x @ ±80mV'
    '1/4x @ ±160mV'
    '1/8x @±320mV'
)

echo -e "   ${CYN}Programmable Gain Amplifier:${NC} Mode${pgaMode} (${pgaRange[${pgaMode}]})"

declare -A parseADCregRtn
parseADCreg () {
    local mode="${1:0:1}"
    local data2; data2=$(echo "0b${1:2:2}" | "${scriptDir}/tobase" 10)
    local data3; data3=$(echo "0b${1:1:3}" | "${scriptDir}/tobase" 10)

    if [[ "${mode}" == 0 ]]; then
        local modeTxt="Single"
        local modeVal="$(( 9+data2 )) bits"
    else
        local modeTxt="Averaging"
        local modeVal="$(( 2^data3 ))x16bit samples"
    fi

    # shellcheck disable=SC2034
    parseADCregRtn=(
        ["mode"]="${modeTxt}"
        ["resolution"]="${modeVal}"
    )
}

#BADC
badcMode=$(echo "${badc}" | "${scriptDir}/tobase" 2)
badcMode=${badcMode:4:4}
# ADC bit 4             0/1 [mode/sample set]
# 1x mode set (0)               (9 + <2bitNum>)bits mode
# Avg sample set (1)    (2^<3bitNum>)sample values

parseADCreg "${badcMode}"
declare -n badcGet=parseADCregRtn

echo -e "${RED}badc mode:${NC}"
echo -e "   ${CYN}sample mode:${NC} ${badcGet['mode']}"
echo -e "   ${CYN}sample resolution:${NC} ${badcGet['resolution']}"

#SADC
sadcMode=$(echo "${sadc}" | "${scriptDir}/tobase" 2)
sadcMode=${sadcMode:4:4}

parseADCreg "${sadcMode}"
declare -n sadcGet=parseADCregRtn

echo -e "${RED}sadc mode:${NC}"
echo -e "   ${CYN}sample mode:${NC} ${sadcGet['mode']}"
echo -e "   ${CYN}sample resolution:${NC} ${sadcGet['resolution']}"

declare -A parseModeRegRtn
parseModeReg () {
    local mode; mode=$( [[ "${1:0:1}" == 1 ]] && echo "Continuous" || echo "Triggered" )
    local shunt="${1:2:1}"
    local bus="${1:1:1}"
    local status="up"

    if [[ "${1:2:2}" == 0 ]]; then
        status=$( [[ ${1:0:1} == 1 ]] && echo "Power-down" || echo "ADC off (disabled)" )
    fi

    # shellcheck disable=SC2034
    parseModeRegRtn=(
        ["mode"]="${mode}"
        ["shunt"]="${shunt}"
        ["bus"]="${bus}"
        ["status"]="${status}"
    )
}

oprMode=$(echo "${mode}" | "${scriptDir}/tobase" 2)
oprMode="${oprMode:5:3}"
parseModeReg "${oprMode}"
declare -n oprModeGet=parseModeRegRtn

busStatus=$([[ "${oprModeGet['bus']}" == 1 ]] && echo "Active" || echo "Inactive")
shuntStatus=$([[ "${oprModeGet['shunt']}" == 1 ]] && echo "Active" || echo "Inactive")

echo -e "${RED}monitoring:${NC}"
echo -e "   ${CYN}status:${NC} ${oprModeGet['status']}"
echo -e "   ${CYN}operating mode:${NC} ${oprModeGet['mode']}"
echo -e "   ${CYN}bus Voltage Monitoring:${NC} ${busStatus}"
echo -e "   ${CYN}shunt Voltage Monitoring:${NC} ${shuntStatus}"

echo

if [[ "${1}" == '-q' ]]; then
    exec 1>&8
    exec 8>&-
fi
