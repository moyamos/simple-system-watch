#!/bin/bash
DEBUG="0"

scriptPath=/home/ali/parsaspace/simple-system-watch
. ${scriptPath}/config.sh

checkRaidHealth()
{
    if [ "$(cat /proc/interrupts | grep arcmsr | wc -c)" != "0" ]
    then
        [ "$DEBUG" == "1" ] && echo Areca
	checkRes=$(sudo $arecaToolPath vsf info | grep 'Raid Set' | grep -cv 'Normal')
	return $checkRes
    fi
}

checkRaidHealth
raidCheckRes=$?
echo $raidCheckRes
