ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1             .module mgsclient
                              2 
                              3 			;
                              4 			; magserver client, tasza (c) 2019
                              5 			; #slowanawiatr  #wisniowysad
                              6 			;
                              7 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                              8             .include "../../inc/ca80.inc"
                              1 			; CA80 stałe systemowe
                              2 			; tasza, 2019
                              3 
                     00E8     4 SIO_BASE    .equ    0xE8        
                     00E8     5 SIO_A_DAT   .equ    SIO_BASE+0
                     00E9     6 SIO_B_DAT   .equ    SIO_BASE+1
                     00EA     7 SIO_A_CMD   .equ    SIO_BASE+2
                     00EB     8 SIO_B_CMD   .equ    SIO_BASE+3
                              9             
                     00E0    10 USER8255	.equ	0xE0
                     00E0    11 PA			.equ	USER8255+0
                     00E1    12 PB			.equ	USER8255+1
                     00E2    13 PC			.equ	USER8255+2
                     00E3    14 CTRL		.equ	USER8255+3
                             15 						
                             16 
                     00F8    17 Z80CTC      .equ    0xF8		
                     00F8    18 CTC_CH0     .equ    Z80CTC+0
                     00F9    19 CTC_CH1     .equ    Z80CTC+1
                     00FA    20 CTC_CH2     .equ    Z80CTC+2
                     00FB    21 CTC_CH3     .equ    Z80CTC+3
                             22 
                             23 
                     FFF7    24 CYF0	    .equ	0xFFF7
                     FFF8    25 CYF1	    .equ	0xFFF8
                     FFF9    26 CYF2	    .equ	0xFFF9
                     FFFA    27 CYF3	    .equ	0xFFFA
                     FFFB    28 CYF4	    .equ	0xFFFB
                     FFFC    29 CYF5	    .equ	0xFFFC
                     FFFD    30 CYF6	    .equ	0xFFFD
                     FFFE    31 CYF7	    .equ	0xFFFE
                             32 			
                     0010    33 CLR		    .equ	0x0010	; CLR - kasowanie wyswietlacza
                     0018    34 LBYTE	    .equ	0x0018	; LBYTE - wyswietlenie Aku w HEX
                     0020    35 LADR        .equ 	0x0020   ; LADR - wyswietlenie HL w HEX
                     022D    36 CZAS	    .equ	0x022D	; CZAS - pokazuje czas/date
                     01AB    37 COM		    .equ	0x01AB	; COM - pokazuje znak 7-seg z rejestru C
                     01D4    38 PRINT	    .equ	0x01D4	; PRINT - drukuje komunikat z (HL)
                     0213    39 EXPR        .equ 	0x0213   ; EXPR - pobranie ciagu liczb 16bit na stos
                     FFC3    40 CSTS        .equ 	0xFFC3   ; CSTS - test czy klawisz nacisniety
                     FFC6    41 CI          .equ 	0xFFC6   ; CI - pobranie znaku z klawiatury
                     01E0    42 CO          .equ 	0x01E0   ; CO - wyswietlenie cyfry hex
                     0007    43 TI          .equ 	0x0007   ; TI - pobranie znaku z echem
                     01F4    44 PARAM       .equ 	0x01F4   ; PARAM - pobranie liczby 16-bit do HL z echem
                     023B    45 HILO        .equ 	0x023b   ; HILO - iterator, HL++, CY = !(DE >= HL)
                             46 
                     071B    47 OMAG		.equ	0x071B		; odczyt z magnetofonu, w B - nazwa pliku
                     0626    48 ZMAG		.equ 	0x0626		; zapis na mag, HL,DE - pocz/kon, B - nazwa
                     067B    49 ZEOF		.equ 	0x067B		; zapis EOF na mag, B - nazwa, HL - adres wejscia
                             50 
                             51 
                     00FF    52 EOM         .equ 	0xFF 
                             53 
                             54 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 3.
Hexadecimal [16-Bits]



                             55 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 4.
Hexadecimal [16-Bits]



                              9 
                             10             	.area _DATA 
                             11 
                     0000    12 user_stack_top	.equ .				; stos -> adresy w dół							
   FF00                      13             	.ds 2				; data -> adresy w góre
   FF02                      14 folderName:		.ds 1				; identyfikator foldera				
   FF03                      15 fileName:		.ds 1				; identyfikator pliku
                             16 
                             17             .area _CODE 			
   4000                      18 main:
   4000 31 00 FF      [10]   19             ld  SP,#user_stack_top
   4003                      20 userInput:
                             21 			; pytanie o nazwe foldera  'FLd=____' 
   4003 21 31 40      [10]   22 			ld HL,#msgPromptFolder
   4006 CD D4 01      [17]   23 			call PRINT
   4009 80                   24 			.db 0x80
   400A CD F4 01      [17]   25 			call PARAM
   400D 40                   26 			.db 0x40
   400E E5            [11]   27 			push HL			; nazwa foldera na bok
                             28 			; pytanie o nazwe programu '  File=__' 
   400F 21 3A 40      [10]   29 			ld HL,#msgPromptFile
   4012 CD D4 01      [17]   30 			call PRINT
   4015 80                   31 			.db 0x80
   4016 CD F4 01      [17]   32 			call PARAM
   4019 20                   33 			.db 0x20
   401A 45            [ 4]   34 			ld B,L
                             35 			; jak [.] - powrot do `podaj folder`
   401B E1            [10]   36 			pop HL		; odzyskaj nazwe foldera, bilans stosu!
   401C D2 03 40      [10]   37 			jp NC,userInput
                             38 			; tu jest po [=], w DE folder, w B - prg.name, wyslij
   401F E5            [11]   39 			push HL
   4020 21 43 40      [10]   40 			ld HL,#msgSearchin
   4023 CD D4 01      [17]   41 			call PRINT
   4026 80                   42 			.db 0x80
   4027 E1            [10]   43 			pop HL
   4028 CD 7B 06      [17]   44 			call ZEOF
                             45 			; i czekaj na plik z serwera, nazwa w B			
   402B CD 1B 07      [17]   46 			call OMAG
                             47 			; w to miejsce bedzie powrót z error-handlera lub po wykonaniu `PROGRAMU` (z niego wracamy RET-em)
                             48 			; i tak w kołko
   402E C3 00 40      [10]   49 			jp main			
                             50 			; 
                             51 			; mega :) :) :) !!
                             52 			; http://www.uize.com/examples/seven-segment-display.html
                             53 			;
                             54 			; 'FLd=____'
   4031                      55 msgPromptFolder:	
   4031 71 38 5E 48 00 00    56 			.db 0x71,0x38,0x5e,0x48,0x00,0x00,0x00,0x00,EOM	            
        00 00 FF
                             57 			;
                             58 			;
                             59 			; ' FILE=__'
   403A                      60 msgPromptFile:	
   403A 00 71 06 38 79 48    61 			.db 0x00,0x71,0x06,0x38,0x79,0x48,0x00,0x00,EOM	            
        00 00 FF
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 5.
Hexadecimal [16-Bits]



                             62 			;
                             63 			; 'SEArchin.'
   4043                      64 msgSearchin:  
   4043 6D 79 77 50 58 74    65 			.db 0x6d,0x79,0x77,0x50,0x58,0x74,0x10,0xD4,EOM
        10 D4 FF
                             66 			;
   404C                      67 delay:		; masakra , ale skuteczna
   404C 06 FA         [ 7]   68 			ld B,#250
   404E 76            [ 4]   69 delay1:		halt
   404F 76            [ 4]   70 			halt
   4050 76            [ 4]   71 			halt
   4051 76            [ 4]   72 			halt
   4052 76            [ 4]   73 			halt
   4053 10 F9         [13]   74 			djnz delay1
   4055 C9            [10]   75 			ret
                             76 
                             77 			.area CODE1 (ABS)
                             78 			;
                             79 			; handlery błędów zwracanych przez serwer
                             80 			;
                             81 			;
   4100                      82 			.org 0x4100
   4100                      83 errorHandler_GeneralErr:
   4100 21 0B 41      [10]   84 			ld HL,#errGeneral
   4103 CD D4 01      [17]   85 			call PRINT
   4106 80                   86 			.db 0x80
   4107 CD 4C 40      [17]   87 			call delay
   410A C9            [10]   88 			ret
   410B                      89 errGeneral:	; 'error'
   410B 79 50 50 5C 50 00    90 			.db 0x79,0x50,0x50,0x5c,0x50,0x00,0x00,0x00,EOM
        00 00 FF
                             91 			;
                             92 			;			
                             93 			;
   4150                      94 			.org 0x4150
   4150                      95 errorHandler_FileNotFound:
   4150 21 5B 41      [10]   96 			ld HL,#errNoFile
   4153 CD D4 01      [17]   97 			call PRINT
   4156 80                   98 			.db 0x80
   4157 CD 4C 40      [17]   99 			call delay
   415A C9            [10]  100 			ret
   415B                     101 errNoFile:	; 'noFile'
   415B 54 5C 71 10 38 79   102 			.db 0x54,0x5c,0x71,0x10,0x38,0x79,0x00,0x00,EOM
        00 00 FF
                            103 			;
                            104 			;
                            105 			;
   4200                     106 			.org 0x4200
   4200                     107 errorHandler_FolderNotFound:
   4200 21 0B 42      [10]  108 			ld HL,#errNoFolder
   4203 CD D4 01      [17]  109 			call PRINT
   4206 80                  110 			.db 0x80
   4207 CD 4C 40      [17]  111 			call delay
   420A C9            [10]  112 			ret
   420B                     113 errNoFolder:	;	'noFolder'
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



   420B 54 5C 71 5C 38 5E   114 			.db 0x54,0x5c,0x71,0x5c,0x38,0x5e,0x79,0x50,EOM
        79 50 FF
                            115 			;
                            116 
                            117 			; qniec
                            118             
                            119         
