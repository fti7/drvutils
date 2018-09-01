#!/bin/bash

function displaytime {
  local T=$(($1*60*60))
  local Y=$((T/60/60/24/365))
  local D=$((T/60/60/24%365))
  local H=$((T/60/60%24))

  (( $Y > 0 )) && printf '%dy ' $Y
  (( $D > 0 )) && printf '%dd ' $D
}

#######

FORMAT="%-10s %-10s %-40s %-15s %-20s %-17s %-17s %-17s\n"


printf "$FORMAT" "Name" "Size" "Model" "Power_On_Hours" "Power_Cycle_Count" "Start_Stop_Count" "Load_Cycle_Count" "Temperature_Celsius"
echo "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

#for disk in sda sdb sdc sdd sde;
for rdisk in /dev/sd[a-z];
do

   disk=$(basename "$rdisk")
   OUT=$(/usr/sbin/smartctl -a "/dev/${disk}")

   NAME="/dev/${disk}"
   MODEL=$(cat "/sys/block/${disk}/device/wwid" | tr -s "[:blank:]" | sed -e 's/t10.ATA //')
   SIZE=$(fdisk -l /dev/${disk} | grep "^Disk /" | cut -f 1 -d ',' | cut -f 3- -d '/' | cut -f 2 -d ':' | sed 's/^ //')

   POWER_ON_HOURSx=$(echo "$OUT" | grep "Power_On_Hours" | awk '{print $10}')
   POWER_ON_HOURS=$(displaytime "$POWER_ON_HOURSx")

   POWER_CYCLE_COUNT=$(echo "$OUT" | grep "Power_Cycle_Count" | awk '{print $10}')      # HDD real Power on/off
   START_STOP_COUNT=$(echo "$OUT" | grep "Start_Stop_Count" | awk '{print $10}')        # HDD Spindle on/off

   TEMPERATURE_CELCIUS=$(echo "$OUT" | grep "Temperature_Celsius" | awk '{print $10}')
   LOAD_CYCLE_COUNT=$(echo "$OUT" | grep "Load_Cycle_Count" | awk '{print $10}')

   printf "$FORMAT" "$NAME" "$SIZE" "$MODEL" "$POWER_ON_HOURS" "$POWER_CYCLE_COUNT" "$START_STOP_COUNT" "$LOAD_CYCLE_COUNT" "$TEMPERATURE_CELCIUS"

done
