TARGET 		= calo

# lokalizacja segmentu kodu (EPROM), do wyboru
# podstawka z bateryjkowa NVRAM 8kB
CODE_LOC	= 4000
DATA_LOC	= FF00

ASM_FILES 	= calo.s ../inc/strutils.s  

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

loadm:	
	$(CA80MEM) --port=/dev/ttyUSB0 --file=$(TARGET).hex --reset --verbose

clean:     
	rm -f *.hex *.ihx *.lst *.rst *.map *.lk *.noi *.rel *.sym | true
	cd ../inc ;	rm -f *.hex *.ihx *.lst *.rst *.map *.lk *.noi *.rel *.sym | true

	
cleanw:
	del *.hex
	del *.lst
	del *.rst
	del *.map
	del *.lk
	del *.noi
	del *.rel
	del *.sym
	
	
