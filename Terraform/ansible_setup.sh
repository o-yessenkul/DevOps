#!/bin/bash
sudo yum -y update
sudo yum install python3 -y
sudo yum install epel-release -y
sudo yum install -y ansible 
echo "192.168.1.40 web-server-1" >> /etc/hosts
echo "192.168.1.41 web-server-2" >> /etc/hosts
echo "192.168.1.42 web-server-3" >> /etc/hosts
echo "192.168.1.43 ha-proxy" >> /etc/hosts
echo "[ha-proxy]
ha-proxy 


[web-servers]
web-server-1
web-server-2 
web-server-3 " > /etc/ansible/hosts
