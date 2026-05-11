#!/bin/bash



#summing up the size of each bahsers 
awk -F '|' '{ sum[$2]+=$3 }

	END {

		for (user in sum)

			print sum[user] "-" user

	}'  logfile.txt | sort -nr

# ron expression to run this for 5 min on sat and fri
# */5 * * * 5,6 /home/bashers/leaderBoard.sh
