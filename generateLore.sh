#!/bin/bash

#creating the slang file
touch slang.txt
cat > slang.txt << EOF
Cap
Flex
Rizz
Bet
Sus
Ghosting
Delulu
Cringe
Toxic
Aura
Sigma
EOF


#ket say bad words are Cap Flex Delulu Cringe Toxic 
bad_word=(Cap Flex Delulu Cringe Toxic)

#creaing a clrean file
touch clean.txt


#replacing all the bad words to arterisk
while read -r theword 
do
new_word="$theword"
for bad in "${bad_word[@]}" 
	do

	if [[ "$theword" == "${bad}" ]]; then
		new_word=""
		#getting to the the no of characters in the choosen word
		length=${#theword}
		until [[ $length == 0 ]]
			do 
			new_word="*$new_word"
			((length--))

			done 
	break		
	fi
	done

	
		 echo "$new_word">>clean.txt

done < slang.txt



#selecting a randon word from the slang.txt each 30 second
sudo mkdir -p /opt/Bashrot_vault
sudo touch /opt/Bashrot_vault/newfile.txt
while true 
do
word=$(shuf -n 1 slang.txt)
echo "$word" | base64 | sudo tee -a /opt/Bashrot_vault/newfile.txt >/dev/null

sleep 30
done


