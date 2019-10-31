ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1             .module testsio
                              2             ; tasza, 2019
                              3 			
                              4 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                              5             .include "../inc/ca80.inc"
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
                     00FF    47 EOM         .equ 	0xFF 
                             48 
                             49 
                             50 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 3.
Hexadecimal [16-Bits]



                              6 
                              7 
                              8             	.area _DATA 
                              9 
                     0000    10 user_stack_top	.equ .				; stos -> adresy w dół							
   FF00                      11             	.ds 2				; data -> adresy w góre
                             12 
   FF02                      13 rx_buffer:      .ds 80              ; rx buffer
                     0050    14 rx_buffer_len   .equ  .-rx_buffer   ; buff size         
                             15 
                             16 
                             17             
                             18 
                             19             .area _CODE 			
   5000                      20 main:
   5000 31 00 FF      [10]   21             ld  SP,#user_stack_top
   5003 21 15 50      [10]   22             ld  HL,#welcome
   5006 CD D4 01      [17]   23             call PRINT
   5009 50                   24             .db 0x50
                             25             ; setup SIO, channel B
   500A CD 00 51      [17]   26             call sioInit
   500D                      27 loop:            
                             28             ;ld A,#'A'
                             29             ;call putCharA
                             30             ;ld A,#'a'
                             31             ;call putCharA
                             32 
   500D CD 00 53      [17]   33 			call getChar
   5010 CD 00 52      [17]   34 			call putCharA
                             35 
                             36 
   5013 18 F8         [12]   37 			jr 	loop
                             38 
   5015 30 6C 20 5B 4F 5B    39 welcome:    .db 0x30, 0x6c, 0x20, 0x5b, 0x4f, 0x5b, EOM			
        FF
                             40 			
                             41 			
                             42 			;---------------------------------------------        
                             43     
                     0100    44 			. = main + 0x100
                             45 
   5100                      46 sioInit:
   5100 3E 00         [ 7]   47             ld A,#0
   5102 D3 EA         [11]   48             out (SIO_A_CMD),A           ; WR0
                             49 
   5104 3E 01         [ 7]   50             ld A,#1
   5106 D3 EA         [11]   51             out (SIO_A_CMD),A           ; ustaw WR1 
   5108 3E 00         [ 7]   52             ld A,#0
   510A D3 EA         [11]   53             out (SIO_A_CMD),A           ; WR1 := 0
                             54         
   510C 3E 04         [ 7]   55             ld  A,#4
   510E D3 EA         [11]   56             out (SIO_A_CMD),A           ; ustaw WR4        
   5110 3E 44         [ 7]   57             ld A,#(0x04|0x40)          ; weź baudy 9600 (bity B7,D6) nałóż 1 stop, no parity
                             58                                         ; 0x80 - 9600, 0x40 - 19200
   5112 D3 EA         [11]   59             out (SIO_A_CMD),A           ;
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 4.
Hexadecimal [16-Bits]



                             60         
   5114 3E 03         [ 7]   61             ld  A,#3
   5116 D3 EA         [11]   62             out (SIO_A_CMD),A           ; ustaw na WR3
   5118 3E C1         [ 7]   63             ld  A,#0xC1         ; 8 bit, Rx enable
   511A D3 EA         [11]   64             out (SIO_A_CMD),A
                             65         
   511C 3E 05         [ 7]   66             ld  A,#5
   511E D3 EA         [11]   67             out (SIO_A_CMD),A           ; ustaw WR5
   5120 3E EA         [ 7]   68             ld  A,#0xEA         ; 8bit, Tx enable
   5122 D3 EA         [11]   69             out (SIO_A_CMD),A   
                             70 
                             71      
   5124 C9            [10]   72             ret
                             73        
                             74 			;---------------------------------------------       
                             75 
                     0200    76 			. = main + 0x200
                             77 
                             78        
   5200                      79 putCharA:
   5200 F5            [11]   80             push AF     ; zabezpiecz znaczek
   5201                      81 putCharA_wait:
   5201 3E 00         [ 7]   82             ld A,#0
   5203 D3 EA         [11]   83             out (SIO_A_CMD),A            ; wybierz RR0 wskazanego kanału
   5205 DB EA         [11]   84             in  A,(SIO_A_CMD)           ; daj RR0
   5207 CB 57         [ 8]   85             bit 2,A             ; czy Transfer Buffer Empty? (D2==1)
   5209 28 F6         [12]   86             jr Z,putCharA_wait   ; to czekaj dalej
   520B F1            [10]   87             pop AF          
   520C D3 E8         [11]   88             out (SIO_A_DAT),A           ; i wyślij
   520E C9            [10]   89             ret             
                             90 
                     0300    91 			. = main + 0x300
                             92 
                             93 
   5300                      94 getChar:
   5300 3E 00         [ 7]   95             ld A,#0
   5302 D3 EA         [11]   96             out (SIO_A_CMD),A   ; RR0
   5304 DB EA         [11]   97             in  A,(SIO_A_CMD)   ; status
   5306 E6 01         [ 7]   98             and A,#1    ; sprawdź D0 Receive Character Available
   5308 28 F6         [12]   99             jr Z, getChar
   530A DB E8         [11]  100             in  A,(SIO_A_DAT)   ; weź znaczek z RxD
   530C C9            [10]  101             ret 
                            102             
                            103    			;---------------------------------------------                        
                            104 
