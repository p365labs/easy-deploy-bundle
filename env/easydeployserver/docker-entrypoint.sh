#!/bin/sh
set -e

#echo -n "172.18.1.5 "| cat - /root/.ssh/id_rsa.pub >> /etc/ssh/known_hosts
#echo -n "172.18.1.4 "| cat - /root/.ssh/id_rsa.pub >> /etc/ssh/known_hosts
#echo "|1|ttyJ2606fbsNKVXhwDQpKHznFec=|xU/GuwAPgnr6AN35xMf3Zl4b0Q4= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBAYfCrIDj5UjkMDl5R3L8sLAZC3cerD3vB56C0x0ZV5/lO834wxQOLf2mcRoGzZJPIMKFldraAz2UStOnHUFdpQ=" >> /root/.ssh/known_hosts
#echo "|1|Cof7IIlBiD6yi2tVOzZNetxSxD0=|fkWVfr5SdpJ67h7Mq+Ia4mnUSCw= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBAYfCrIDj5UjkMDl5R3L8sLAZC3cerD3vB56C0x0ZV5/lO834wxQOLf2mcRoGzZJPIMKFldraAz2UStOnHUFdpQ=" >> /etc/ssh/known_hosts

#ssh-keyscan -t rsa 172.18.1.4 >> /root/.ssh/known_hosts
#ssh-keyscan -t rsa 172.18.1.5 >> /root/.ssh/known_hosts


#ssh -oStrictHostKeyChecking=no 172.18.1.4 uptime
#ssh -oStrictHostKeyChecking=no 172.18.1.5 uptime


# ~/.ssh/config


tee /root/.ssh/config <<EOF
Host deployer
    Hostname 172.18.1.5
    StrictHostKeyChecking no
Host easydeploy_server
    Hostname 172.18.1.4
    StrictHostKeyChecking no
EOF

#cat << EOF > /root/.ssh/config
#Host deployer
#    Hostname 172.18.1.5
#    StrictHostKeyChecking no
#Host easydeploy_server
#    Hostname 172.18.1.4
#    StrictHostKeyChecking no
#EOF


cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

eval `ssh-agent -s`
chmod 600 /root/.ssh/*


exec "$@"
