#!/bin/bash
listadiscos=$(lsblk)
scandisks=$(rescan-scsi-bus.sh)

echo "Scanning Disks....: $scandisks"

echo "List Disks : $listadiscos"

echo "****** Enter disk as example /dev/sdb ******: "
read
pvcreate $REPLY
vgcreate repoimm2 $REPLY
lvcreate -l 100%FREE --name repoveeam2 repoimm2
mkfs.xfs -b size=4096 -m reflink=1,crc=1 /dev/repoimm2/repoveeam2
mkdir /repoveeam2
mount /dev/repoimm2/repoveeam2 /repoveeam2
mkdir /repoveeam2/backups2
chown veeamrepo:veeamrepo /repoveeam2/backups2
chmod 700 /repoveeam2/backups2
UUID=$(blkid | grep repoimm2-repoveeam2 |cut -f2 -d'='|cut -f2 -d'"')
echo "******Saving /etc/fstab as /etc/fstab.$$******"
/bin/cp -p /etc/fstab /etc/fstab.$$
echo "******Adding /repoveeam2 to /etc/fstab entry******"
echo "UUID=${UUID} /repoveeam2 xfs defaults 1 1" >> /etc/fstab
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