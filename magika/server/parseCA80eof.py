# wav file twisted interpreter
# #slowanawiatr, #wisniowysad, tasza (c) 2019
import sys, wave, struct

#consty
MAX_BIT_LEN 		= 350
DATA_BITS_PER_BYTE 	= 11
FRAME_LEN 			= MAX_BIT_LEN*DATA_BITS_PER_BYTE 




# srednia z zawartości kolejki
def getAvg ( arr ):
	a = 0
	for i in range (0,len(arr)):
		a = a + arr[i]
	return int(a/len(arr))




# przerobienie popiskiwan z CA80 na strumien 1&0
def convertWaveToBitStream ( w ):
	length = w.getnframes()
	fifo=[0,0,0,0,0,0,0,0,0,0]
	value=0
	avg=0
	digStream=[]
	for i in range( 0, length ):
		waveData = w.readframes(1)
		sample = int( waveData[ 0 ] )  # !?? # JDS :)

		if sample < 140 or sample > 160 :  # JDS :)
			value = 100
		else:
			value = 0
		fifo.pop(0)				# zdejmij z początku
		fifo.append( value )	# dodaj na koniec
		avg = getAvg( fifo )
		if avg > 10:					# JDS :) 
			digStream.append(1)
#			print(100)
		else:
			digStream.append(0)
#			print(0)
	return digStream;





# zwraca numer pierwszej probki nastepnego bajtu po 2 bitach ciszy
def searchSync( bits, start ):
	lastBit = 0
	sampleRise = start
	sampleFall = start
	for i in range ( start , len( bits ) ):
#		print (i)
		currentBit = bits[ i ];
		if currentBit != lastBit:
			#jest zbocze
			if currentBit == 0:
				# opadajace
				sampleFall = i
			else:
				# narastajace
				sampleRise = i
				stateLen = sampleRise - sampleFall
#				print (stateLen)
				if stateLen > 600:             # JDS :)             
#					print ("stop")
					break
			# end-if
		lastBit = currentBit
		# end-if
	# end-for
	return sampleRise





		
# zwraca zdekodowanego bajta
def readBitStream ( bits, start ):
	if len(bits)-start < FRAME_LEN:
		return 0x00	
	# iteruj po próbkach
	s1=0
	s2=0
	parts=[]
	stateCntr=0
	lenMax=max( len(bits), start + FRAME_LEN )
	for p in range(start, lenMax ):		
		s2 = bits[ p ]
		if s1 != s2:		# zmiana - dodaj bit
			parts.append( s2 )	
			stateCntr = 0;				

		if stateCntr > 250:	# dwa jednakowe bity, dodaj
			parts.append( s2 )	
			stateCntr = 0;
		stateCntr = stateCntr + 1
		s1=s2
	# end-for
	byte=0
	b=2
	### print (len(parts))
	for p in range (0,8):		
		if (parts[b] == 1)&(parts[b+1] == 0):
			byte = byte + pow (2, p)
		b = b + 2
	# enf-for			
	return byte


#---------------- main() -----------------

#waveFile = wave.open( '00.0000.sound.wav', 'r' )
waveFile = wave.open( sys.argv[1], 'r' )

stream = convertWaveToBitStream( waveFile )

syncPos = 0
bytesSyncPtr = []
while syncPos < len(stream):
	syncPos = searchSync( stream , syncPos + 100 )
	bytesSyncPtr.append( syncPos )

decodedBytes=[]
syncSkipped=0
# iteruj po znalezionych początkach bajtów
for i in range (0, len(bytesSyncPtr) ) :
	dataByte = readBitStream( stream, bytesSyncPtr[i] )
	if ( dataByte == 0xFD )|(syncSkipped==1):
		syncSkipped = 1
		decodedBytes.append( dataByte )
		if len(decodedBytes) == 7:  # masz co chesz, koniec
			break

# pokaz zdekodowaną ramkę
for i in range(0, len(decodedBytes)):
	print( hex(decodedBytes[i])[2:].zfill(2) +" ", end="" )

caName = decodedBytes[ 2 ]
caAddr = decodedBytes[ 4 ] + 0x100*decodedBytes[ 5 ]
print( " | ", end="" )
print( hex(caAddr)[2:].zfill(4)  + "," + hex(caName)[2:].zfill(2))


