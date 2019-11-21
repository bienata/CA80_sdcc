#!/bin/bash

# nagrywamy na karcie wbudowanej
audioLineIn="alsa_input.pci-0000_00_1b.0.analog-stereo"
# odtwarzamy na dodatkowym Blasterku
audioLineOut="alsa_output.pci-0000_04_00.0.analog-stereo"

while true
do
	echo "Waiting for CA80 EOF - remote file request"
	sox -e signed-integer -c 1 -r 44100 -t pulseaudio ${audioLineIn} input.wav silence 1 0.1 10%  1 0.1 10% vol 0.7
	echo "Got it, trying to process"
	response=`python3 parseCA80eof.py input.wav` 
	rm input.wav
	echo "Done"
	decodedBytes="${response%|*}"
	caEOFdata="${response#*|}"
	folderName=`echo "${caEOFdata%,*}" | xargs`
	appName="${caEOFdata#*,}"
	echo "Decoded raw bytes: ${decodedBytes}"
	echo ""
	banner ${caEOFdata}
	echo "Request for file [${appName}] from folder [${folderName}]"
	# jest taki folder?
	if [ -d "${folderName}" ]; then
  		echo "Folder ok, get file"
		listFiles=`ls -1 "${folderName}"/"${appName}"*.hex`
		# i lepiej aby nie było tam duplikatów....
		if [ -f "${listFiles}" ]; then
			echo "Found requested: ${listFiles}"
			# wydlub adres startu dla EOF-a, od 8 znaczka 4 sztuki :)
			eofAddr="${listFiles:8:4}"
			echo "Preparing outgoing data"			
			hex2wav -v -i ${listFiles} -n ${appName} -e ${eofAddr} -s 16 -o output.wav
			echo "Sending to client"			
			sox -v 4 output.wav -t pulseaudio ${audioLineOut}
			rm output.wav
			echo "Done"			
		else
	  		echo "No such file, rise CA80-4150 exception :)"
			# nazwa aplikacji ma byc jak w requescie, podstaw tylko adres handlera err
			# 4150 - no file
			hex2wav -v -n ${appName} -e 4150 -s 16 -o nofile.wav
			sox -v 4 nofile.wav -t pulseaudio ${audioLineOut}
			rm nofile.wav
		fi
	else
  		echo "No such folder, rise CA80-4200 exception :)"
		# nazwa aplikacji ma byc jak w requescie, podstaw tylko adres handlera err
		# 4200 - no folder
		hex2wav -v -n ${appName} -e 4200 -s 16 -o nofolder.wav
		sox -v 4 nofolder.wav -t pulseaudio ${audioLineOut}
		rm nofolder.wav
	fi
done


