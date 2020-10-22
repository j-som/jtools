#! /bin/bash

if [ $# -ne 1 ];
then
        echo usage $0 Port, Port is a number
else
        echo closing $1
        firewall-cmd --zone=public --remove-port=$1/tcp --permanent
        firewall-cmd --reload
	echo now opening ports:
	firewall-cmd --zone=public --list-ports
fi

