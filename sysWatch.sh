#!/bin/bash

scriptPath=/home/mos/mos/simpleSysWatch
. ${scriptPath}/url_enc_dec.sh
. ${scriptPath}/config.sh

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

# check all storages for available space
storageLogStr=""
lenStorageList=${#storageList[@]}
for (( i=0; i<=$((lenStorageList-1)); i++ ))
do 
    storageAvail=`df -BG | grep -w ${storageList[$i]} | awk '{print $4}'` #assumed in Gigabyte
    storageAvail=${storageAvail:-9999999G} # if the storage is not available set a big number for it
    storageAvail=${storageAvail:: -1} # remove last char maybe "G"
    [ "$DEBUG" = "1" ] && echo $i ${storageList[$i]} ${storageAvailLimit[$i]} $storageAvail
    storageLogStr="$storageLogStr ${storageList[$i]}: ${storageAvail}G "
    if [ $storageAvail -lt ${storageAvailLimit[$i]} ]
    then
        notification="${storageList[$i]} storage space critically low! Avail: ${storageAvail}G"
        encmsg=$(urlencode "$server $notification")
    
        sendTelegramMsg ${encmsg}
    fi
done

memAvail=`free -g | grep Mem | awk '{print $7}'` 
if [ $memAvail -lt $memAvailLimit ]
then
    notification="available memory critically low! Avail: ${memAvail}G"
    encmsg=$(urlencode "$server $notification")

    sendTelegramMsg ${encmsg}
fi

fifteenMinLoadAvg=`cat /proc/loadavg | awk '{print $3}' | awk -F. '{print $1}'`
cpuCount=`cat /proc/cpuinfo | grep processor | tail -n 1 | awk '{print $3}'`

if [ $fifteenMinLoadAvg -gt $cpuCount ]
then
    notification="CPU shortage! 15 minutes load avg: ${fifteenMinLoadAvg}"
    encmsg=$(urlencode "$server $notification")

    sendTelegramMsg ${encmsg}
fi

if [ "`date +%H`" = ${presentingTimeSlot} ]
then
    notification=" Present."
    encmsg=$(urlencode "$server $notification")

    sendTelegramMsg ${encmsg}
fi

echo "`date` $storageLogStr memAvail: ${memAvail}G 15 minutes load avg: ${fifteenMinLoadAvg}" >> ${scriptPath}/log.txt
