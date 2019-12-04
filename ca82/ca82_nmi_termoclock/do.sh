#!/bin/bash
APP="ca82_nmi_termoclock"
rm *.hex *.ihx *.lst *.rel *.bin *.map *.lk *.asm *.noi
sdasz80 -g -l -o crt0ca82.rel crt0ca82.s
sdcc --verbose -mz80 -c ${APP}.c
sdcc --verbose -mz80 --data-loc 0x8000 --no-std-crt0 -o ${APP}.ihx crt0ca82.rel ${APP}.rel
packihx ${APP}.ihx > ${APP}.hex
objcopy -Iihex -Obinary ${APP}.hex ${APP}.bin



