#!/bin/bash
#creating users and groups
sudo groupadd -f bashers
sudo groupadd -f wardens
sudo groupadd -f guards



direc="$(cd "$(dirname "$0")" && pwd)"

for name in $(yq -r ".roster.bashers[].username" "$direc/roster.yaml");
do
HOME_DIR="/home/bashers/$name"
id "$name" &>/dev/null || sudo useradd -m -d "/home/bashers/$name" -g "bashers" "$name"
sudo usermod -aG "bashers" "$name"
   if [[ ! -d "$HOME_DIR" ]]; then
        sudo mkdir -p "$HOME_DIR"
        sudo chown "$name:$name" "$HOME_DIR"
    fi
sudo cp /etc/skel/.bashrc $HOME_DIR/.bashrc
sudo chown $name:$name $HOME_DIR/.bashrc
done

for name in $(yq -r ".roster.wardens[].username" "$direc/roster.yaml");
do
HOME_DIR="/home/wardens/$name"
id "$name" &>/dev/null || sudo useradd -m -d "/home/wardens/$name" -g "wardens" "$name"
sudo usermod -aG "wardens" "$name"
   if [[ ! -d "$HOME_DIR" ]]; then
        sudo mkdir -p "$HOME_DIR"
        sudo chown "$name:$name" "$HOME_DIR"
    fi
sudo cp /etc/skel/.bashrc $HOME_DIR/.bashrc
sudo chown $name:$name $HOME_DIR/.bashrc
done

for name in $(yq -r ".roster.guards[].username" "$direc/roster.yaml");
do
HOME_DIR="/home/guards/$name"
id "$name" &>/dev/null || sudo useradd -m -d "/home/guards/$name" -g "guards" "$name"
sudo usermod -aG "guards" "$name"
   if [[ ! -d "$HOME_DIR" ]]; then
        sudo mkdir -p "$HOME_DIR"
        sudo chown "$name:$name" "$HOME_DIR"
    fi
sudo cp /etc/skel/.bashrc $HOME_DIR/.bashrc
sudo chown $name:$name $HOME_DIR/.bashrc
done

#installing access to acl commants
sudo apt install -y acl

#creating directories and sub directories for each  player
BasherDIR="/home/bashers"
for name in  $(yq -r '.roster.bashers[].username' "$direc/roster.yaml");
 do 
sudo mkdir -p "$BasherDIR/$name/Drop_Zone"
sudo chown -R "$name":"bashers" "$BasherDIR/$name"
sudo chown -R "$name":"bashers" "$BasherDIR/$name/Drop_Zone"
sudo chown "$name:$name" "/home/$name/.bashrc"
#locking password authentication for bashers
sudo passwd -l "$name"
sudo chmod 755 "$BasherDIR"
sudo chmod 755 "$BasherDIR/$name"
#allowing guards to enter into bashers directory
sudo setfacl -m g:guards:x "$BasherDIR"
sudo setfacl -m g:guards:rx "$BasherDIR/$name"
sudo setfacl -m g:guards:rx "$BasherDIR/$name/Drop_Zone" 


#appending alias in each bashers .bashrc file
grep -qxF 'alias oops="clear"' /home/bashers/${name}/.bashrc || echo 'alias oops="clear"' | sudo tee -a /home/bashers/${name}/.bashrc >/dev/null
grep -qxF 'alias tapka="kill"' /home/bashers/${name}/.bashrc || echo 'alias tapka="kill"' | sudo tee -a /home/bashers/${name}/.bashrc >/dev/null
grep -qxF 'alias coffee="cd"' /home/bashers/${name}/.bashrc || echo 'alias coffee="cd"' | sudo tee -a /home/bashers/${name}/.bashrc >/dev/null
done

sudo apt install jp2a -y
#creating avatars for each member
for group in bashers guards wardens
do
yq -r ".roster.${group}[] | \"\(.image_url) \(.username)\"" "$direc/roster.yaml" | while read -r url name
do
curl -fsSL -o image_"${name}".jpg  "$url"
if file --mime-type "image_${name}.jpg" | grep -q "image/"
        then
            jp2a "image_${name}.jpg" | sudo tee "/home/$group/.${name}.avatar.txt"
        fi
grep  -qxF "cat /home/$group/.${name}.avatar.txt" "/home/$group/$name/.bashrc" || 
echo "cat /home/$group/.${name}.avatar.txt"  >> "/home/$group/$name/.bashrc" >/dev/null
done 
done

#creating directories for each guard
GuardDIR="/home/guards"
for name in $(yq -r ".roster.guards[].username" "$direc/roster.yaml");
do
sudo mkdir -p "$GuardDIR/$name"
sudo chown "$name":"guards" "$GuardDIR/$name"

#disabling access to guard directories from others
sudo chmod 700 "$GuardDIR/$name"
done


sudo apt install openssh-server -y
#enforcing user to do ssh authentication only
if ! grep -q "^Match group bashers" /etc/ssh/sshd_config
then
    echo -e "\nMatch group bashers
    PasswordAuthentication no
    AuthenticationMethods publickey" | sudo tee -a /etc/ssh/sshd_config > /dev/null
fi
