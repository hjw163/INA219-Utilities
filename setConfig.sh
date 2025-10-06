#!/usr/bin/env bash

# calibration=(0.04096/(currentLSB*Rshunt))
# currentLSB=(MaxExpectedCurrent/(2^15))
# powerLSB=(20*currentLSB)

set -e

scriptDir="$(dirname "$(realpath "${0}")")"

# shellcheck source=SCRIPTDIR/userVars.cfg.sh
source "${scriptDir}/userVars.cfg.sh"

currentLSB=$( bc <<< "${userVar['maxCurrent']} / (2^15)" )
echo "${userVar['maxCurrent']}"
powerLSB=$( bc <<< "20*${currentLSB}" )
calibration=$( bc <<< "0.04096 / (${currentLSB}*${userVar['Rshunt']})" )
echo "${userVar['Rshunt']}"
echo "curent: ${currentLSB}"
echo "power: ${powerLSB}"
echo "calibration: ${calibration}"