#!/bin/bash


BASE="/opt/Bashrot_vault"
#cleaning old links
rm -f "$BASE"/link_*


#creating a encoded file in an unknown directory
realFile=$(mktemp -d)/encoded.txt
echo "encoded file" > "$realFile"

#list of directories where links will point
mapfile -t randomdir < <(find / \
-path /proc -prune -o \
-path /sys -prune -o \
-path /dev -prune -o \
-path /run -prune -o \
-type d -print 2>/dev/null)

#selecting a random directory out of array of directories
if (( ${#randomdir[@]}==0 )); then
echo "no directories found!!"
exit 1
fi

#randomising link in  every 2700 seconds
while true
do

#cleaning old links
rm -f "$BASE"/link_*

#the simlink pointing to the file
real_one="link_$(( RANDOM % 6767 ))"
ln -s "$realFile" "$BASE/$real_one"


#creating 6767 simlinks to random diratories
i=0
while (( i < 6767 ))
do


dir="${randomdir[RANDOM % ${#randomdir[@]}]}"
if [[ "$BASE/link_${i}" != "$BASE/$real_one" ]]; then
ln -s "$dir" "$BASE/link_${i}"
fi
((i++))
done
sleep 2700
done
