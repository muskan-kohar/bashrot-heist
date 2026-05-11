#!/bin/bash

#terminating generateLore background process
pkill -f generateLore 2>/dev/null || pkill -9 -f generateLore 2>/dev/null

#removing files from  bashers directory
sudo find /home/bashers -type f -exec rm -f {} \;


#wiping bashrot_vault
sudo rm -rf /opt/Bashrot_vault
sudo mkdir -p /opt/Bashrot_vault

#resetting ACL permissions
sudo setfacl -b -R /opt/Bashrot_vault
