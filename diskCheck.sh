#!/bin/bash

scriptPath=/home/ali/parsaspace/simple-system-watch
. ${scriptPath}/config.sh

checkRaidHealth()
{
    if [ "$(cat /proc/interrupts | grep arcmsr | wc -c)" != "0" ]
    then
        [ "$DEBUG" == "1" ] && echo Areca
	checkRes=$($arecaToolPath vsf info | tail -n +3 | head -n -2 | grep -cv 'Normal')
	return $checkRes
    fi

    if [ "$(cat /proc/interrupts | grep megasas | wc -c)" != "0" ]
    then
        [ "$DEBUG" == "1" ] && echo MegaCLI
	checkRes=$($megaSASToolPath -LDInfo -Lall -aALL | egrep -i 'State|Permission' | grep -cv Optimal)
	return $checkRes
    fi
}

#checkRaidHealth
#raidCheckRes=$?
#echo $raidCheckRes
