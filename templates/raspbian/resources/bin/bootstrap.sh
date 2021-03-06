#!/bin/bash
echo "-------------------------------------------------------"
echo "rotating ssh keys"
echo "-------------------------------------------------------"
/usr/bin/yes | /usr/bin/ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
/usr/bin/yes | /usr/bin/ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
/usr/bin/yes | /usr/bin/ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa -b 521
/usr/bin/yes | /usr/bin/ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519
echo "-------------------------------------------------------"
echo "bring in the authorized keys if any"
echo "-------------------------------------------------------"
/bin/cat /cattlepi/config | /usr/bin/jq -r .config.ssh.pi.authorized_keys | grep -q null
if [ $? -ne 0 ]; then
    /bin/mkdir -p /home/pi/.ssh
    for key in $(/usr/bin/seq 1 $(/bin/cat /cattlepi/config | /usr/bin/jq '.config.ssh.pi.authorized_keys | length'))
    do 
        let idx=($key-1)
        /bin/echo "$(/bin/cat /cattlepi/config | /usr/bin/jq -r .config.ssh.pi.authorized_keys[$idx])" >> /home/pi/.ssh/authorized_keys
        /bin/chmod 0644 /home/pi/.ssh/authorized_keys
        /bin/chown -R pi:pi /home/pi/.ssh
    done
fi
echo "-------------------------------------------------------"
echo "running user code if any"
echo "-------------------------------------------------------"
/bin/cat /cattlepi/config | /usr/bin/jq -r .usercode | /usr/bin/base64 -d > /tmp/usercode.sh
if [ $? -eq 0 ]; then
    chmod +x /tmp/usercode.sh
    /tmp/usercode.sh
fi