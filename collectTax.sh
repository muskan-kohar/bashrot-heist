#!/bin/bash

direc="$(cd "$(dirname "$0")" && pwd)"

#creating a log file
touch logfile.txt



#checking the size of every directory in bashers path
dir="/home/bashers"
for name in $(yq -r '.roster.bashers[].username' "$direc/roster.yaml")
	do
		size=$(du -s "$dir/$name" 2>/dev/null| cut -f1)
		#checkking if the basher have more than 5MB of data
		if(( size > 5120)); then
			#saving log of 3 oldest files
			for file_name in $(ls -tr "$dir/$name" 2>/dev/null| head -n 3)
				do
				file_size=$(du -k "$dir/$name/$file_name" 2>/dev/null| cut -f1 )
                        	echo " $(date '+%Y-%m-%d %H:%M:%S')|$name|$file_size|$file_name " >> logfile.txt
				rm "$dir/$name/$file_name"
				done

		fi
	done


#setting permissions on the log file
chmod 700 logfile.txt
setfacl -m g:guards:rwx logfile.txt
setfacl -m g:wardens:rwx logfile.txt
