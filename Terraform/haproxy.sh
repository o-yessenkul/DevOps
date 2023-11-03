#!/bin/bash
sudo yum -y update
echo "192.168.1.40 Web-Server1" >> /etc/hosts
echo "192.168.1.41 Web-Server2" >> /etc/hosts
echo "192.168.1.42 Web-Server3" >> /etc/hosts
echo "192.168.1.43 Ha-Proxy" >> /etc/hosts