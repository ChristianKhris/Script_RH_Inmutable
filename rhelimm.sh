#!/bin/bash
listadiscos=$(lsblk)
scandisks=$(rescan-scsi-bus.sh)

echo "Scanning Disks....: $scandisks"

echo "List Disks : $listadiscos"

echo "****** Enter disk as example /dev/sdb ******: "
read
pvcreate $REPLY
vgcreate repoimm $REPLY
lvcreate -l 100%FREE --name repoveeam repoimm
mkfs.xfs -b size=4096 -m reflink=1,crc=1 /dev/repoimm/repoveeam
mkdir /repoveeam
mount /dev/repoimm/repoveeam /repoveeam
adduser veeamrepo
echo "****** Please Enter veeamrepo Password ******"
passwd veeamrepo
mkdir /repoveeam/backups
chown veeamrepo:veeamrepo /repoveeam/backups
chmod 700 /repoveeam/backups
UUID=$(blkid | grep repoimm-repoveeam |cut -f2 -d'='|cut -f2 -d'"')
echo "******Saving /etc/fstab as /etc/fstab.$$******"
/bin/cp -p /etc/fstab /etc/fstab.$$
echo "******Adding /repoveeam to /etc/fstab entry******"
echo "UUID=${UUID} /repoveeam xfs defaults 1 1" >> /etc/fstab
echo "******Please Add The New Repository with veeamrepo single-use credentiales in Veeam Backup & Replication******"
while [ 1 ]
do
        pid=`ps -fea | grep "veeamimmureposvc" | grep -v grep`
        echo $pid
        if [ "$pid" = "" ]
        then
                echo "******Veeam Process is not here...******"
                #exit
        else
                echo "******Veeam Process Detected continuing...******"
                echo "******Denying SSH /etc/ssh/sshd_config entry******"
                echo "DenyUsers veeamrepo" >> /etc/ssh/sshd_config
                echo "******Disable SSH? Enter 1 for YES or 2 for NO******"
                select yn in "Yes" "No"; do
                case $yn in
                Yes ) $(systemctl disable sshd && systemctl stop sshd); echo "SSH Service Disabled and Stopped, Please disconnect from SSH"; exit;;
                No ) exit;;
                esac
                done
                fi
        sleep 8
done
