#!/bin/bash
sudo yum -y update
echo "192.168.1.40 web-server-1" >> /etc/hosts
echo "192.168.1.41 web-server-2" >> /etc/hosts
echo "192.168.1.42 web-server-3" >> /etc/hosts
echo "192.168.1.43 ha-proxy" >> /etc/hosts