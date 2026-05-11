#!/bin/bash


direc="$(cd "$(dirname "$0")" && pwd)"

#making associative arrays
declare -A times
declare -A score
declare -A final_score
declare -A t_last
declare -A time_elapsed
declare -A rank_arr
declare -A movement

#reading heist logs and storing timestamps
while IFS='|' read -r names filename date
do
    time_sec=$(date -d "$date" +%s 2>/dev/null)

    if [[ -n "$time_sec" ]]; then
        times["$names"]+="$time_sec "
    fi
done < /var/log/heist.log


#finding latest basher
new_time=0
new_name=""

while IFS='|' read -r names filename date
do
    time_sec=$(date -d "$date" +%s 2>/dev/null)

    if (( time_sec > new_time )); then
        new_time=$time_sec
        new_name="$names"
    fi
done < /var/log/heist.log


#5 min activity window for each basher
for name in $(yq -r '.roster.bashers[].username' "$direc/roster.yaml")
do
    i=0
    entry=(${times[$name]})

    len=${#entry[@]}

    score["$name"]=0

    while (( i < len ))
    do
        j=$i
        count=0

        max=$(( ${entry[$i]} + 300 ))

        while (( j < len && entry[j] <= max ))
        do
            ((j++))
            ((count++))
        done

        if (( count > score[$name] )); then
            score["$name"]=$count
        fi

        ((i++))
    done


    #latest activity time
    if (( len > 0 )); then
        t_last["$name"]=${entry[$((len-1))]}
    else
        t_last["$name"]=0
    fi


    #time decay
    if (( t_last[$name] == 0 )); then
        time_elapsed["$name"]=0
    else
        time_elapsed["$name"]=$(( ( $(date +%s) - t_last[$name] ) / 300 ))
    fi


    #final score
    if [[ "$name" == "$new_name" ]]; then
        final_score["$name"]=$(( score[$name] + 10 - time_elapsed[$name] ))
    else
        final_score["$name"]=$(( score[$name] - time_elapsed[$name] ))
    fi


#preventing -ve values of scores
if (( ${final_score[$name]} < 0 )); then
	final_score[$name]=0
fi

done


#displaying leaderboard
i=1
echo "LEADER BOARD"
while read name score times
do
rank_arr[$name]+="$i "
((i++))
done < <( for name in "${!final_score[@]}"
	do
        	echo "$name ${final_score[$name]} ${t_last[$name]}"
	done | sort -k2 -nr -k3 -nr | head -3 )


#checking the movement per basher
for name in $(yq -r '.roster.bashers[].username' "$direc/roster.yaml")
do
#array of ranks
arr=( ${rank_arr[$name]} )
#size of the array of ranks of a particular bahser
size=${#arr[@]}
previous=$(( size-2 ))
last=$(( size-1 ))
if (( size>=2 )); then
movement[$name]=$(( arr[previous] - arr[last] ))
else
movement[$name]=0
fi
echo " $name ${movement[$name]} "
done





