#!/bin/bash

scriptPath=/home/ali/parsaspace/simple-system-watch
. ${scriptPath}/url_enc_dec.sh
. ${scriptPath}/config.sh
. ${scriptPath}/diskCheck.sh

sendTelegramMsg()
{
    if [ "${telegramSendMethod}" = "direct" ]
    then
        str="https://api.telegram.org/bot${telegramToken}/sendMessage?chat_id=${telegramChatId}&parse_mode=html&text=${1}"
    else
        str="${telegramProxyUrl}?token=${telegramToken}&chatId=${telegramChatId}&text=$1"
    fi
    curl -X GET "${str}"  -H 'cache-control: no-cache' &> /dev/null
}

if [ $checkStorageSpace = on ]
then
    # check all storages for available space
    storageLogStr=""
    lenStorageList=${#storageList[@]}
    for (( i=0; i<=$((lenStorageList-1)); i++ ))
    do 
        storageAvail=`df -BG | grep -w ${storageList[$i]} | awk '{print $4}'` #assumed in Gigabyte
        storageAvail=${storageAvail:-9999999G} # if the storage is not available set a big number for it
        storageAvail=${storageAvail:: -1} # remove last char maybe "G"
        [ "$DEBUG" = "1" ] && echo $i ${storageList[$i]} ${storageAvailLimit[$i]} $storageAvail
        storageLogStr="$storageLogStr ${storageList[$i]}: ${storageAvail}G"
        if [ $storageAvail -lt ${storageAvailLimit[$i]} ]
        then
            notification="${storageList[$i]} storage space critically low! Avail: ${storageAvail}G"
            encmsg=$(urlencode "$server $notification")
        
            sendTelegramMsg ${encmsg}
        fi
    done
fi

if [ $checkRAIDHealth = on ]
then
    raidHealthLogStr="RAID set: OK"
    # check RAID health
    checkRaidHealth
    raidCheckRes=$?
    if [ ${raidCheckRes} -gt 0 ]
    then
        notification="RAID Set is degraded."
        encmsg=$(urlencode "$server $notification")
        
        sendTelegramMsg ${encmsg}
	raidHealthLogStr="RAID set: Degraded"
    fi
fi

if [ $checkMemory = on ]
then
    memAvail=`free -g | grep Mem | awk '{print $7}'` 
    memLogStr="memAvail: ${memAvail}G"
    if [ $memAvail -lt $memAvailLimit ]
    then
        notification="available memory critically low! Avail: ${memAvail}G"
        encmsg=$(urlencode "$server $notification")
    
        sendTelegramMsg ${encmsg}
    fi
fi

if [ $checkLoadAvg = on ]
then
     fifteenMinLoadAvg=`cat /proc/loadavg | awk '{print $3}' | awk -F. '{print $1}'`
     loadAvgLogStr="15 minutes load avg: ${fifteenMinLoadAvg}"
     cpuCount=`cat /proc/cpuinfo | grep processor | tail -n 1 | awk '{print $3}'`
     
     if [ $fifteenMinLoadAvg -gt $cpuCount ]
     then
         notification="CPU shortage! 15 minutes load avg: ${fifteenMinLoadAvg}"
         encmsg=$(urlencode "$server $notification")
     
         sendTelegramMsg ${encmsg}
     fi
fi

if [ $presenting = on ]
then
    if [ "`date +%H`" = ${presentingTimeSlot} ]
    then
        notification=" Present."
        encmsg=$(urlencode "$server $notification")
    
        sendTelegramMsg ${encmsg}
    fi
fi

echo "`date`$storageLogStr $memLogStr $loadAvgLogStr $raidHealthLogStr" >> ${scriptPath}/log.txt
