#!/bin/bash
#"backup.sh"    Basic script to backup specific folder to usb disk drive.
#Target:        Backup specific folder. Defaults are configred to backup an Owncloud installation.
#Created at:    2021.01.15. Last modify: 2021.01.15
#Tested on:     Raspbian GNU/Linux 10 (buster)
#Tested with:   Raspberry Pi 3 model B
#Tested with:   Raspberry pi 4 (4GB)
#Simply run the script or schedule from cron. Root permission is required.

#INIT
echo 1 > /sys/class/leds/led1/brightness #PowerON POWER LED on rpi
backup_disk=""
#VARIABLES
NOW=$(date +"%Y.%m.%d_%H_%M")                   # Actual time. It is used for backup time-stamp.
FILE="backup.disk"                              # Backup disk should contain this file on the root to be able to detected by script as destination aka backup disk.
SOURCE="/var/www/owncloud/data"                 # Source of backup. This folder will be copied to BACKUP_FOLDER.
BACKUP_FOLDER="/mnt/backup"                     # Destination of backup. This folder will contain the same files and folders as SOURCE.
RUNNING="${0}_RUNNING"                          # This is the lock file. If file is exist, means script is running (prevent concurrent running).
COMPRESS=""                                     # If vale is "YES" (case-sensitive), SOURCE will be compressed and copied to BACKUP_FOLDER instead of just copying.

USED_COMMANDS=("grep" "echo" "cat" "sleep" "ls" "rm" "mount" "mkdir" "tar" "cp" "umount") #Used commands by script.
  for command in "${USED_COMMANDS[@]}"          #Check that all required commands are available.
        do
        type "$command" >/dev/null 2>&1 || { echo >&2 "Script can not be started. Required $command command. Aborting ..." exit 1; }
  done
#--------------------We_are_ROOT?----------------------#
if (( $EUID != 0 )); then
    echo "Please run as root!" | grep --color -E "\b(root|)\b|$"
    exit
fi
#------------------SCRIPT_IS_RUNNIG?-------------------#
if [ -f "$RUNNING" ]; then exit #Check if script is already running.
fi
touch "$RUNNING"
#MAIN
disks=($(ls /dev/sd* | grep '[0-9]'))
any_disk=$?
if [ $any_disk != 0 ] ; then
rm "$RUNNING" && echo "No any disk was found" && exit
fi
echo "Backup script was started"
for i in $(echo ${disks[@]}); do
        if [ ! -d "$BACKUP_FOLDER" ]; then
                mkdir $BACKUP_FOLDER
        else
                mount -t ntfs-3g "$i" $BACKUP_FOLDER
        fi
        if [ -f "$BACKUP_FOLDER/$FILE" ]; then
                echo 0 > /sys/class/leds/led1/brightness #Power off the power led - Backup process was started.
                if [ "$COMPRESS" == "YES" ]; then
                        tar -zcvf $BACKUP_FOLDER/"$NOW".tar.gz $SOURCE
                else
                        mkdir $BACKUP_FOLDER/"$NOW";
                        cp -rp $SOURCE $BACKUP_FOLDER/"$NOW"/
                fi
                sync "$i"
                backup_disk=$i
        fi
        umount $BACKUP_FOLDER
done
[[ -z $backup_disk ]] && rm "$RUNNING" && echo "No any backup disk was found" && exit
while [ -e "$backup_disk" ]; do
        echo 1 > /sys/class/leds/led1/brightness;
        sleep 0.5;
        echo 0 > /sys/class/leds/led1/brightness;
        sleep 0.5;
done
echo 1 > /sys/class/leds/led1/brightness
rm "$RUNNING" && echo "Backup was created" && exit