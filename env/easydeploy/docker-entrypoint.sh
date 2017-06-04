#!/bin/sh
set -e

#Disable StrictHostKeyChecking in order to automaically add keys to known_hosts
tee /root/.ssh/config <<EOF
Host deployer
    Hostname 172.18.1.5
    StrictHostKeyChecking no
Host easydeploy_server
    Hostname 172.18.1.4
    StrictHostKeyChecking no
EOF

#Move pub key to remote server in order to login
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

eval `ssh-agent -s`
chmod 600 /root/.ssh/*


exec "$@"
