#!/bin/bash
ssh-keyscan web-server1 >> ~/.ssh/known_hosts
ssh-keyscan web-server2 >> ~/.ssh/known_hosts
ssh-keyscan web-server3 >> ~/.ssh/known_hosts
ssh-keyscan ha-proxy >> ~/.ssh/known_hosts
                                            
