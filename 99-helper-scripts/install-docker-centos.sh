#!/usr/bin/env sh
#
# Execute this file with sudo
#   then log out of the host so that the group change can take effect
#   in the next time a session is started
#
#
#

yum update -y \
    && yum upgrade -y \
    && yum install -y yum-utils device-mapper-persistent-data lvm2 curl unzip ca-certificates git java-1.8.0-openjdk-devel

# for certbot
yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional \
    && yum install -y certbot
#certbot certonly --standalone -d example.com -d www.example.com --server https://acme-v02.api.letsencrypt.org/directory
#certbot certonly --standalone -d docker-centos.pingidentity.space

if grep "Amazon Linux" /etc/os-release  >/dev/null ; then
    amazon-linux-extras install -y docker
    service docker start

    for nvmeID in $( lsblk | awk '$1 ~ /^nvme/ && $1 !~ /nvme0/ {print $1}' ) ; do
        if test -n "${nvmeID}" ; then
            mkfs.ext4 /dev/${nvmeID}
            mkdir -p /fast/${nvmeID}
            mount /dev/${nvmeID} /fast/${nvmeID}
            chgrp -R docker /fast
            chmod -R 770 /fast
        fi
    done
    OS_USER=ec2-user
else
    # for docker
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
        && yum install -y docker-ce docker-ce-cli containerd.io \
        && systemctl start docker
        OS_USER=centos
fi
usermod -a -G docker ${OS_USER}
curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose
curl -L https://github.com/docker/machine/releases/download/v0.16.0/docker-machine-$(uname -s)-$(uname -m) -o /tmp/docker-machine &&
    install /tmp/docker-machine /usr/local/bin/docker-machine

curl -s -X POST -H 'Content-type: application/json' --data '{"text": "docker starting in scalr ('${HOSTNAME}')" }' https://hooks.slack.com/services/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

cat <<END >>/etc/security/limits.conf
${OS_USER} soft    nproc   16384
${OS_USER} hard    nproc   16384
${OS_USER} soft    nofile   65536
${OS_USER} hard    nofile   65536
END