TARGET 		= mgsclient

APP_ID		= FF

# lokalizacja segmentu kodu (EPROM), do wyboru
# podstawka z bateryjkowa NVRAM 8kB
CODE_LOC	= 4000
DATA_LOC	= FF00

ASM_FILES 	= mgsclient.s 

AOBJ_FILES 	= $(ASM_FILES:%.s=%.rel)
OBJ_FILES 	= $(AOBJ_FILES) 

#ladowarka do pamięci	
CA80MEM		=ca80mem
CALO		=calo

AS      	= sdasz80 
AS_FLAGS 	= -g -l -s -z -w

LD      	= sdldz80
LD_FLAGS 	= -m -w -u -i 

all: $(TARGET)

#linkowanie
$(TARGET): $(OBJ_FILES)
	$(LD) $(LD_FLAGS) -b _CODE=0x$(CODE_LOC) -b _DATA=0x$(DATA_LOC) $(TARGET) $(OBJ_FILES)
	packihx $(TARGET).ihx > $(TARGET).hex
	rm $(TARGET).ihx
	
#assemblacja	
%.rel: %.s
	$(AS) $(AS_FLAGS) -o $@  $^


tape:
	hex2wav -v -i $(TARGET).hex -n $(APP_ID) -e $(CODE_LOC) -s 8 -o $(TARGET).wav
	#ffmpeg -i $(TARGET).wav -hide_banner -y -vn -ar 44100 -ac 2 -b:a 192k $(TARGET).mp3
	#rm $(TARGET).wav

play:
	@echo "\n\n"
	@echo "Press  [6][$(APP_ID)][=] on CA80 and be patient..."
	@echo "\n\n"
	sox -v 4 $(TARGET).wav -t pulseaudio alsa_output.pci-0000_04_00.0.analog-stereo
	
loadm:	
	$(CA80MEM) --port=/dev/ttyUSB0 --file=$(TARGET).hex --reset --verbose

clean:     
	rm -f -f *.hex *.ihx *.lst *.rst *.map *.lk *.noi *.rel *.sym *.mp3 *.wav | true
	cd ../inc ;	rm -f *.hex *.ihx *.lst *.rst *.map *.lk *.noi *.rel *.sym *.mp3 *.wav | true

	
cleanw:
	del *.hex
	del *.lst
	del *.rst
	del *.map
	del *.lk
	del *.noi
	del *.rel
	del *.sym
	
	
