            .module mgsclient

			;
			; magserver client, tasza (c) 2019
			; #slowanawiatr  #wisniowysad
			;

            .include "../../inc/ca80.inc"

            	.area _DATA 

user_stack_top	.equ .				; stos -> adresy w dół							
            	.ds 2				; data -> adresy w góre
folderName:		.ds 1				; identyfikator foldera				
fileName:		.ds 1				; identyfikator pliku

            .area _CODE 			
main:
            ld  SP,#user_stack_top
userInput:
			; pytanie o nazwe foldera  'FLd=____' 
			ld HL,#msgPromptFolder
			call PRINT
			.db 0x80
			call PARAM
			.db 0x40
			push HL			; nazwa foldera na bok
			; pytanie o nazwe programu '  File=__' 
			ld HL,#msgPromptFile
			call PRINT
			.db 0x80
			call PARAM
			.db 0x20
			ld B,L
			; jak [.] - powrot do `podaj folder`
			pop HL		; odzyskaj nazwe foldera, bilans stosu!
			jp NC,userInput
			; tu jest po [=], w DE folder, w B - prg.name, wyslij
			push HL
			ld HL,#msgSearchin
			call PRINT
			.db 0x80
			pop HL
			call ZEOF
			; i czekaj na plik z serwera, nazwa w B			
			call OMAG
			; w to miejsce bedzie powrót z error-handlera lub po wykonaniu `PROGRAMU` (z niego wracamy RET-em)
			; i tak w kołko
			jp main			
			; 
			; mega :) :) :) !!
			; http://www.uize.com/examples/seven-segment-display.html
			;
			; 'FLd=____'
msgPromptFolder:	
			.db 0x71,0x38,0x5e,0x48,0x00,0x00,0x00,0x00,EOM	            
			;
			;
			; ' FILE=__'
msgPromptFile:	
			.db 0x00,0x71,0x06,0x38,0x79,0x48,0x00,0x00,EOM	            
			;
			; 'SEArchin.'
msgSearchin:  
			.db 0x6d,0x79,0x77,0x50,0x58,0x74,0x10,0xD4,EOM
			;
delay:		; masakra , ale skuteczna
			ld B,#250
delay1:		halt
			halt
			halt
			halt
			halt
			djnz delay1
			ret

			.area CODE1 (ABS)
			;
			; handlery błędów zwracanych przez serwer
			;
			;
			.org 0x4100
errorHandler_GeneralErr:
			ld HL,#errGeneral
			call PRINT
			.db 0x80
			call delay
			ret
errGeneral:	; 'error'
			.db 0x79,0x50,0x50,0x5c,0x50,0x00,0x00,0x00,EOM
			;
			;			
			;
			.org 0x4150
errorHandler_FileNotFound:
			ld HL,#errNoFile
			call PRINT
			.db 0x80
			call delay
			ret
errNoFile:	; 'noFile'
			.db 0x54,0x5c,0x71,0x10,0x38,0x79,0x00,0x00,EOM
			;
			;
			;
			.org 0x4200
errorHandler_FolderNotFound:
			ld HL,#errNoFolder
			call PRINT
			.db 0x80
			call delay
			ret
errNoFolder:	;	'noFolder'
			.db 0x54,0x5c,0x71,0x5c,0x38,0x5e,0x79,0x50,EOM
			;

			; qniec
            
        
