#!/bin/sh
set -e

#setting to `StrictHostKeyChecking no` will allow to not ask for adding the
#remote ip to `known_hosts`
tee /root/.ssh/config <<EOF
Host deployer
    Hostname 172.18.1.5
    StrictHostKeyChecking no
Host easydeploy_server
    Hostname 172.18.1.4
    StrictHostKeyChecking no
EOF

cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

eval `ssh-agent -s`
chmod 600 /root/.ssh/*


exec "$@"
