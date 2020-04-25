#!/bin/bash

server="[SERVER_NAME]"
presentingTimeSlot="10"
DEBUG="0"

storageList=("/" "/home")
storageAvailLimit=(50 10) # Threshold for each entry of the storageList ; Gigabyte is assumed

memAvailLimit=5 # G is assumed

telegramSendMethod="direct"
telegramChatId=<CHAT-ID>
telegramToken="<TOKEN>"
telegramProxyUrl="http://<PROXY-URL>/telegram.php"
arecaToolPath="<areca_raid_tool_path>"
megaSASToolPath="<MegaCli_tool_path>"
