#!/bin/bash

let chk_system=1

function daemon_status() {
    if [[ `systemctl status $1 | grep "Active:"` =~ "(running)" ]]; then
        echo "$1: active"
    else
        echo "$1: deactive"
        let chk_system=chk_system=0
    fi
}

clear

daemon_status httpd
daemon_status mysqld
echo ''
echo "Permit Services: `firewall-cmd --list-services`"
echo "Permit Ports: `firewall-cmd --list-ports`"
echo ''

if [[ `firewall-cmd --list-ports` != *80/tcp* ]] && [[ `firewall-cmd --list-services` != *http* ]]; then
   let chk_system=chk_system=0
fi

if [[ $chk_system = 0 ]]; then
    echo 'Restart httpd' && systemctl restart httpd && echo "success"
    echo 'Restart mysqld' && systemctl restart mysqld && echo "success"
    echo 'Add http service in firewalld' && firewall-cmd --add-service=http --permanent 2>/dev/null
    echo 'Restart firewalld' && firewall-cmd --reload
    echo ''
fi

echo '...Process Done'
