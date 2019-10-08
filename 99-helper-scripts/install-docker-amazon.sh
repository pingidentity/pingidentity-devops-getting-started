#!/usr/bin/env sh
# this script must be executed as a privileged user

### Get latest packages
yum -y update
yum -y upgrade
yum -y install yum-utils device-mapper-persistent-data lvm2 dstat
amazon-linux-extras install -y docker
amazon-linux-extras enable corretto8
yum -y install java-1.8.0-amazon-corretto-devel
service docker start

usermod -a -G docker ec2-user

mkfs.ext4 /dev/nvme1n1 
mkdir /data
mount /dev/nvme1n1 /data
chmod 775 /data
chgrp docker /data

cat <<END >>/etc/sysctl.conf
vm.swappiness = 0
END

cat <<END >>/etc/security/limits.conf
* soft nofile 65536
* hard nofile 65536
* soft nproc 16384
* hard nproc 16384
END