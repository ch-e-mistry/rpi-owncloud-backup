# rpi-owncloud-backup

This is a little bash script to able to **make an offline backup** from a specific folder **to a plugged in disk(s)**.

For my specific case it s a solution to be able to make backup(s) by the customer from a Raspberry Pi used as an Owncloud server.

## Table of contents

- [rpi-owncloud-backup](#rpi-owncloud-backup)
  - [Table of contents](#table-of-contents)
  - [Theory Of Operation](#theory-of-operation)
  - [Implementation](#implementation)
    - [Implementation - Manual](#implementation---manual)
    - [Implementation - Automatic (ansible)](#implementation---automatic-ansible)
  - [Usage:](#usage)

## Theory Of Operation

In ideal case, script should be **scheduled by root's cron** to run at every minute. If no any disk was attached or the disk is not a backup disk or not run by root, the script will quit.

If disk (USB drive) was attached in time when script runs, the script checks that a specific file, described in script as **FILE** variable, is available on the visible disk(s)'s root.

If **Yes**, **backup process will be started** and depends on script's **COMPRESS** variable value, copy the **SOURCE** (path to backup) to the **BACKUP_FOLDER** aka mounted disk or compress  **SOURCE** and then copy compressed file to **BACKUP_FOLDER**.

If **no**, script will check the next available disk. If no any other available disk, script will exit as no any **backup disk**

**At the end as an indicator**, **power led** of Raspberry Pi **starts to blinking until you didn't remove the disk**. If you have multiple backup disks, will blink until the lastly attached backup disk was removed.

## Implementation

**Before** you start to implement the solution (no matter that it is an automatic or manual), **modify the script's variables** in [**backup.sh**](./backup.sh) to your needs. Defaults are fine for an Raspberry Pi Owncloud setup.

```bash
#VARIABLES
NOW=$(date +"%Y.%m.%d_%H_%M")                   # Actual time. It is used for backup time-stamp.
FILE="backup.disk"                              # Backup disk should contain this file on the root to be able to detected by script as destination aka backup disk.
SOURCE="/var/www/owncloud/data"                 # Source of backup. This folder will be copied to BACKUP_FOLDER.
BACKUP_FOLDER="/mnt/backup"                     # Destination of backup. This folder will contain the same files and folders as SOURCE.
RUNNING="${0}_RUNNING"                          # This is the lock file. If file is exist, means script is running (prevent concurrent running).
COMPRESS=""                                     # If vale is "YES" (case-sensitive), SOURCE will be compressed and copied to BACKUP_FOLDER instead of just copying.

```

### Implementation - Manual

It is not so hard to implement it by hand, simply **copy** [**backup.sh**](./backup.sh) **to any place in your Raspberry Pi** and **schedule** it by __root's cron__ like:

```
pi@raspberrypi:~ $ sudo su
root@raspberrypi:/home/pi# crontab -e
```

- **Add the following line** (runs at every minute):`* * * * * /bin/timeout -s 2 345600 /bin/bash /root/backup.sh >/dev/null 2>&1`
- Do not left to **modify the absolute path of your script** like: `/root/backup.sh`. It depends on you, where you put previously the script.

### Implementation - Automatic (ansible)

## Usage:
[![youtube_link](http://img.youtube.com/vi/GW3dK1QVUvA/0.jpg)](http://www.youtube.com/watch?v=GW3dK1QVUvA "Raspberry Pi backup")
