#!/bin/bash


#creating a harmmful command list
harmful=(
"rm[[:space:]]+-rf"
"(^|[[:space:]])(sudo|su)([[:space:]]|$)"
"mkfs"
"shutdown"
"reboot"
"nano[[:space:]]+/etc/passwd"
"cat[[:space:]]+/etc/shadow"
"useradd.*"
"usermod.*"
"chmod[[:space:]]+777"
"dd[[:space:]]+if="
"curl.*"
"wget.*"
"scp.*"
"ssh.*"
"find[[:space:]]+/home/wardens"
"ls[[:space:]]+/home/wardens"
"cd[[:space:]]+/home/wardens"
)


# penalty weights
declare -A penalty


penalty["rm[[:space:]]+-rf"]=10
penalty["mkfs"]=10
penalty["dd[[:space:]]+if="]=9
penalty["shutdown"]=8
penalty["reboot"]=8
penalty["(^|[[:space:]])(sudo|su)([[:space:]]|$)"]=7
penalty["useradd.*"]=7
penalty["usermod.*"]=7
penalty["nano[[:space:]]+/etc/passwd"]=9
penalty["cat[[:space:]]+/etc/shadow"]=10
penalty["chmod[[:space:]]+777"]=6
penalty["cd[[:space:]]+/home/wardens"]=3
penalty["ls[[:space:]]+/home/wardens"]=2
penalty["find[[:space:]]+/home/wardens"]=4
penalty["ssh.*"]=5
penalty["scp.*"]=5
penalty["wget.*"]=4
penalty["curl.*"]=4


#creating sub directory in wardens directory
mkdir -p /home/wardens/crimes


#checking if the basher has put any command which is dangerous
if groups "$USER" | grep -qw bashers; then
	grep -q "PROMPT_COMMAND='history -a; /path/to/theL_Penalty.sh'" "/home/${USER}/.bashrc" || echo "PROMPT_COMMAND='history -a; /path/to/theL_Penalty'" >> "/home/${USER}/.bashrc"
	cmd=$(history 1 | sed 's/^[ ]*[0-9]\+[ ]*//' )
	for harmcmd in "${harmful[@]}"
	do
		if [[ $cmd =~ $harmcmd ]]; then
		[[ -f "/home/wardens/crimes/${USER}_log.txt" ]] || sudo touch "/home/wardens/crimes/${USER}_log.txt"
		##giving penalty to the basher
			echo "$(date)|$USER|command:$cmd" >> "/home/wardens/crimes/${USER}_log.txt"
			#creating their score files
			[[ -f "/tmp/${USER}_scorefile.txt" ]] || echo "0" > "/tmp/${USER}_scorefile.txt"
			score=$(cat "/tmp/${USER}_scorefile.txt")
			score=$((penalty[$harmcmd] + score))
			echo "$score" > "/tmp/${USER}_scorefile.txt"
			if (( score > 15 )); then
				#punishing the basher
				sudo usermod -s /bin/rbash "$USER"
				( sleep 1800
				sudo usermod -s /bin/bash "$USER" ) &
			fi

		fi
	done
fi
