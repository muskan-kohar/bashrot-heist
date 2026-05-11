#!/bin/bash


#creatinng the secure vault
sudo mkdir -p /opt/Bashrot_vault

#setting not permisstion to anyone except owner
sudo chown root:root /opt/Bashrot_vault
sudo chmod 710 /opt/Bashrot_vault


#giving special permissions to wardena and guards
sudo setfacl -m g:wardens:rwx /opt/Bashrot_vault
sudo setfacl -m g:guards:rwx /opt/Bashrot_vault
sudo setfacl -m g:bashers:--- /opt/Bashrot_vault


#creating a hiddensubdirectory inside the vault
sudo mkdir -p /opt/Bashrot_vault/.hidden_sub

#allowing bashers to enter in the hidden subdirectory
sudo setfacl -m g:bashers:--x /opt/Bashrot_vault/.hidden_sub

