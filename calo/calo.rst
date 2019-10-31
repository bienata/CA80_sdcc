ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1             .module calo        
                              2             ; simple intel hex loader for CA80 and Z80-SIO
                              3             ; tasza, 2019
                              4 			;
                              5 			; 19200,8,N,1, kanal A
                              6 			
                              7 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                              8             .include "../inc/ca80.inc"
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



                              9 
                             10 
                     00E8    11 SIO_DATA	.equ	SIO_A_DAT
                     00EA    12 SIO_COMMAND	.equ	SIO_A_CMD
                             13 
                             14             	.area _DATA 
                             15 
                     0000    16 user_stack_top	.equ .				; stos -> adresy w dół							
   FF00                      17             	.ds 2				; data -> adresy w góre
                             18 
   FF02                      19 rx_buffer:      .ds 80              ; rx buffer
                     0050    20 rx_buffer_len   .equ  .-rx_buffer   ; buff size         
                             21 
                             22 
                             23             
                             24 
                             25             .area _CODE 			
   4000                      26 main:
   4000 31 00 FF      [10]   27             ld  SP,#user_stack_top
                             28             ; setup SIO, channel A
   4003 CD C3 40      [17]   29             call sioInit
                             30             ; napisz 'cALo'
   4006 21 32 40      [10]   31             ld HL,#caloMessage
   4009 CD D4 01      [17]   32             call PRINT
   400C 44                   33             .db 0x44            
   400D                      34 main_loadloop:
   400D CD 82 40      [17]   35             call loadHex
   4010 38 1A         [12]   36             jr C,main_loaderError
   4012 CD 37 40      [17]   37             call checkCRC
   4015 20 15         [12]   38             jr NZ,main_loaderError
                             39             ; data czy EOF
   4017 CD 7B 40      [17]   40             call isEOF
   401A 28 0A         [12]   41             jr Z,main_loaderDone
   401C CD 4C 40      [17]   42             call procHex
   401F 38 0B         [12]   43             jr C,main_loaderError
   4021 CD AA 40      [17]   44             call sendAck
   4024 18 E7         [12]   45             jr main_loadloop
   4026                      46 main_loaderDone:
   4026 CD B1 40      [17]   47             call sendDone
   4029 C3 00 00      [10]   48             jp 0x0000                       
   402C                      49 main_loaderError:
   402C CD B8 40      [17]   50             call sendErr
   402F C3 00 00      [10]   51             jp 0x0000           
                             52 
                             53             ; cALo 
   4032                      54 caloMessage: 
   4032 58 77 38 5C FF       55             .db 0x58, 0x77, 0x38, 0x5c, 0xFF 
                             56 
                             57 			;---------------------------------------------
                             58             
   4037                      59 checkCRC:
   4037 21 02 FF      [10]   60             ld HL,#rx_buffer        
   403A 0E 00         [ 7]   61             ld C,#00
   403C                      62 checkCRC_loop:            
   403C CD 00 41      [17]   63             call ascii2byte
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 4.
Hexadecimal [16-Bits]



   403F 81            [ 4]   64             add C
   4040 4F            [ 4]   65             ld C,A
   4041 23            [ 6]   66             inc HL
   4042 23            [ 6]   67             inc HL              ; natepna para
   4043 7E            [ 7]   68             ld A,(HL)
   4044 FE 00         [ 7]   69             cp #0
   4046 20 F4         [12]   70             jr NZ,checkCRC_loop
   4048 79            [ 4]   71             ld A,C
   4049 FE 00         [ 7]   72             cp #0               ; czy suma bajtów i CRC == 0?
   404B C9            [10]   73             ret                 ; Z=1 -> OK,  Z=0 - lipa
                             74               
                             75 			;---------------------------------------------
                             76               
   404C                      77 procHex:    ; process hex - wypakowanie danych
   404C 21 02 FF      [10]   78             ld HL,#rx_buffer
                             79             ; +0, +1 - dlugosc
   404F CD 00 41      [17]   80             call ascii2byte
   4052 47            [ 4]   81             ld B,A              ; len w B !!!!
   4053 21 04 FF      [10]   82             ld HL,#rx_buffer+2  ; ustaw sie na adres                        
   4056 CD 00 41      [17]   83             call ascii2byte            
   4059 FE 41         [ 7]   84             cp #>calo_end        ; chronione strony, cała bieżąca
   405B 38 1C         [12]   85             jr C, procHex_err     ; `access violation`, exit
   405D 57            [ 4]   86             ld D,A              ; HI address (DE)
   405E 23            [ 6]   87             inc HL
   405F 23            [ 6]   88             inc HL            
   4060 CD 00 41      [17]   89             call ascii2byte
   4063 5F            [ 4]   90             ld E,A              ; LO adress (DE)
                             91             ; pokaż
   4064 D5            [11]   92             push DE
   4065 E1            [10]   93             pop HL
   4066 CD 20 00      [17]   94             call LADR
   4069 40                   95             .db 0x40
                             96              ; przeskocz typ rekordu, ustaw na dane
   406A 21 0A FF      [10]   97             ld HL,#rx_buffer+8  ; ustaw sie na adres                         
                             98             ; bierz kolejne dane
   406D                      99 procHex_next:
   406D CD 00 41      [17]  100             call ascii2byte     ; 
   4070 12            [ 7]  101             ld (DE),A           ; 
   4071 13            [ 6]  102             inc DE              ; pMem++
   4072 23            [ 6]  103             inc HL              
   4073 23            [ 6]  104             inc HL                          
   4074 10 F7         [13]  105             djnz procHex_next            
   4076                     106 procHex_done:            
   4076 37            [ 4]  107             scf
   4077 3F            [ 4]  108             ccf
   4078 C9            [10]  109             ret         ; OK -> CY=0
   4079                     110 procHex_err:
   4079 37            [ 4]  111             scf
   407A C9            [10]  112             ret         ; lipa, CY=1
                            113             
                            114 			;---------------------------------------------			
                            115             
   407B                     116 isEOF:
   407B 21 09 FF      [10]  117             ld HL,#rx_buffer+7
   407E 7E            [ 7]  118             ld A,(HL)
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 5.
Hexadecimal [16-Bits]



   407F FE 31         [ 7]  119             cp #'1'
   4081 C9            [10]  120             ret     ;   Z==1 -> EOF
                            121             
                            122 			;---------------------------------------------         
                            123          
   4082                     124 loadHex:
   4082 21 02 FF      [10]  125             ld HL,#rx_buffer
   4085 06 00         [ 7]  126             ld B,#0x00          ; licznik znaków
   4087                     127 loadHex_wait:
   4087 CD F4 40      [17]  128             call getChar
   408A FE 3A         [ 7]  129             cp #':'
   408C 20 F9         [12]  130             jr NZ, loadHex_wait
   408E                     131 loadHex_load:            
   408E CD F4 40      [17]  132             call getChar
   4091 FE 0D         [ 7]  133             cp #13          ; CR precz
   4093 28 F9         [12]  134             jr Z,loadHex_load
   4095 FE 0A         [ 7]  135             cp #10          ; LF - finito
   4097 28 0C         [12]  136             jr Z,loadHex_done
   4099 77            [ 7]  137             ld (HL),A       ; do bufora
   409A 23            [ 6]  138             inc HL          ; ptr++
   409B AF            [ 4]  139             xor A
   409C 77            [ 7]  140             ld (HL),A       ; zero na koniec
   409D 04            [ 4]  141             inc B           ; i++
   409E 3E 50         [ 7]  142             ld A,#rx_buffer_len
   40A0 90            [ 4]  143             sub B
   40A1 38 05         [12]  144             jr C,loadHex_buffOver                        
   40A3 18 E9         [12]  145             jr loadHex_load         ; i dalej
   40A5                     146 loadHex_done:            
   40A5 37            [ 4]  147             scf
   40A6 3F            [ 4]  148             ccf
   40A7 C9            [10]  149             ret         ; OK -> CY=0
   40A8                     150 loadHex_buffOver:
   40A8 37            [ 4]  151             scf
   40A9 C9            [10]  152             ret         ; lipa, CY=1
                            153 
                            154             ;---------------------------------------------
                            155             
   40AA                     156 sendAck:
   40AA 3E 2E         [ 7]  157             ld A,#'.'
   40AC CD E6 40      [17]  158             call putChar
   40AF 18 0C         [12]  159             jr send_LF
   40B1                     160 sendDone:
   40B1 3E 2D         [ 7]  161             ld A,#'-'
   40B3 CD E6 40      [17]  162             call putChar
   40B6 18 05         [12]  163             jr send_LF
   40B8                     164 sendErr:
   40B8 3E 21         [ 7]  165             ld A,#'!'
   40BA CD E6 40      [17]  166             call putChar
   40BD                     167 send_LF:            
   40BD 3E 0A         [ 7]  168             ld A,#10
   40BF CD E6 40      [17]  169             call putChar
   40C2 C9            [10]  170             ret
                            171 
                            172 			;---------------------------------------------        
                            173     
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



   40C3                     174 sioInit:
   40C3 AF            [ 4]  175             xor a						  ; A := 0
   40C4 D3 EA         [11]  176             out (SIO_COMMAND),A           ; WR0
                            177 
   40C6 3E 01         [ 7]  178             ld A,#1
   40C8 D3 EA         [11]  179             out (SIO_COMMAND),A           ; ustaw WR1 
   40CA AF            [ 4]  180             xor a						  ; A := 0
   40CB D3 EA         [11]  181             out (SIO_COMMAND),A           ; WR1 := 0
                            182         
   40CD 3E 04         [ 7]  183             ld  A,#4
   40CF D3 EA         [11]  184             out (SIO_COMMAND),A           ; ustaw WR4        
   40D1 3E 44         [ 7]  185             ld A,#(0x04|0x40)          ; weź baudy 9600 (bity B7,D6) nałóż 1 stop, no parity
                            186                                         ; 0x80 - 9600, 0x40 - 19200
   40D3 D3 EA         [11]  187             out (SIO_COMMAND),A           ;
                            188         
   40D5 3E 03         [ 7]  189             ld  A,#3
   40D7 D3 EA         [11]  190             out (SIO_COMMAND),A           ; ustaw na WR3
   40D9 3E C1         [ 7]  191             ld  A,#0xC1         ; 8 bit, Rx enable
   40DB D3 EA         [11]  192             out (SIO_COMMAND),A
                            193         
   40DD 3E 05         [ 7]  194             ld  A,#5
   40DF D3 EA         [11]  195             out (SIO_COMMAND),A           ; ustaw WR5
   40E1 3E EA         [ 7]  196             ld  A,#0xEA         ; 8bit, Tx enable
   40E3 D3 EA         [11]  197             out (SIO_COMMAND),A        
   40E5 C9            [10]  198             ret
                            199        
                            200 			;---------------------------------------------       
                            201        
   40E6                     202 putChar:
   40E6 F5            [11]  203             push AF     ; zabezpiecz znaczek
   40E7                     204 putChar_wait:
   40E7 AF            [ 4]  205             xor a						  ; A := 0
   40E8 D3 EA         [11]  206             out (SIO_COMMAND),A            ; wybierz RR0 wskazanego kanału
   40EA DB EA         [11]  207             in  A,(SIO_COMMAND)           ; daj RR0
   40EC CB 57         [ 8]  208             bit 2,A             ; czy Transfer Buffer Empty? (D2==1)
   40EE 28 F7         [12]  209             jr Z,putChar_wait   ; to czekaj dalej
   40F0 F1            [10]  210             pop AF          
   40F1 D3 E8         [11]  211             out (SIO_DATA),A           ; i wyślij
   40F3 C9            [10]  212             ret             
                            213 
                            214 			;---------------------------------------------                        
                            215 
   40F4                     216 getChar:
   40F4 AF            [ 4]  217             xor a						  ; A := 0
   40F5 D3 EA         [11]  218             out (SIO_COMMAND),A   ; RR0
   40F7 DB EA         [11]  219             in  A,(SIO_COMMAND)   ; status
   40F9 E6 01         [ 7]  220             and A,#1    ; sprawdź D0 Receive Character Available
   40FB 28 F7         [12]  221             jr Z, getChar
   40FD DB E8         [11]  222             in  A,(SIO_DATA)   ; weź znaczek z RxD
   40FF C9            [10]  223             ret 
                            224 
   4100                     225 calo_end:	            
                            226 			; qniec
                            227             
                            228         
