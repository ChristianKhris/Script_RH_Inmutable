#!/bin/bash
listadiscos=$(lsblk)
scandisks=$(rescan-scsi-bus.sh)

echo "Scanning Disks....: $scandisks"

echo "List Disks : $listadiscos"

echo "****** Enter disk as example /dev/sdb ******: "
read
pvcreate $REPLY
vgcreate repoimmsql $REPLY
lvcreate -l 100%FREE --name  repoimmsql
mkfs.xfs -b size=4096 -m reflink=1,crc=1 /dev/repoimmsql/
mkdir /repoveeamaql
mount /dev/repoimmsql/repoveeamaql /repoveeamaql
adduser veeamrepo
echo "****** Please Enter veeamrepo Password ******"
passwd veeamrepo
mkdir /repoveeam/backupsql
chown veeamrepo:veeamrepo /repoveeam/backupsql
chmod 700 /repoveeam/backupsql
UUID=$(blkid | grep repoimmsql-repoveeamaql |cut -f2 -d'='|cut -f2 -d'"')
echo "******Saving /etc/fstab as /etc/fstab.$$******"
/bin/cp -p /etc/fstab /etc/fstab.$$
echo "******Adding /repoveeamaql to /etc/fstab entry******"
echo "UUID=${UUID} /repoveeamaql xfs defaults 1 1" >> /etc/fstab
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
