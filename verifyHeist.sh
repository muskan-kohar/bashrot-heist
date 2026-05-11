#!/bin/bash

direc="$(cd "$(dirname "$0")" && pwd)"
if ! groups | grep -qw wardens && [ "$( id -u  )" -ne 0 ];
then
echo "warning: not wardens group or root user"
exit 1
fi

#creating a log file
sudo touch /var/log/heist.log

#installing inotify tools
sudo apt update
sudo apt install inotify-tools -y 
#monitering each bashers directory
for name in $(yq -r '.roster.bashers[].username' "$direc/roster.yaml")
	do
	inotifywait -m -e close_write "/home/bashers/$name/Drop_Zone" | while read pathname action file_name
		do
		basher=$(echo "$pathname" | cut -d'/' -f4)
		while read content
                        do
			decode=$(echo "$content" | base64 --decode 2>/dev/null)
                        while read words
                        do
                        if [ "$decode" = "$words" ]; then
                        wall "$basher has cracked the level"
			echo "$basher|$file_name|$(date)" >> /var/log/heist.log
                        break 2
                        fi
                        done < slang.txt
                        done < "/home/bashers/$name/Drop_Zone/$file_name"

                done &

        done

wait


