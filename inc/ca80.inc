			; CA80 stałe systemowe
			; tasza, 2019

SIO_BASE    .equ    0xE8        
SIO_A_DAT   .equ    SIO_BASE+0
SIO_B_DAT   .equ    SIO_BASE+1
SIO_A_CMD   .equ    SIO_BASE+2
SIO_B_CMD   .equ    SIO_BASE+3
            
USER8255	.equ	0xE0
PA			.equ	USER8255+0
PB			.equ	USER8255+1
PC			.equ	USER8255+2
CTRL		.equ	USER8255+3
						

Z80CTC      .equ    0xF8		
CTC_CH0     .equ    Z80CTC+0
CTC_CH1     .equ    Z80CTC+1
CTC_CH2     .equ    Z80CTC+2
CTC_CH3     .equ    Z80CTC+3


CYF0	    .equ	0xFFF7
CYF1	    .equ	0xFFF8
CYF2	    .equ	0xFFF9
CYF3	    .equ	0xFFFA
CYF4	    .equ	0xFFFB
CYF5	    .equ	0xFFFC
CYF6	    .equ	0xFFFD
CYF7	    .equ	0xFFFE
			
CLR		    .equ	0x0010	; CLR - kasowanie wyswietlacza
LBYTE	    .equ	0x0018	; LBYTE - wyswietlenie Aku w HEX
LADR        .equ 	0x0020   ; LADR - wyswietlenie HL w HEX
CZAS	    .equ	0x022D	; CZAS - pokazuje czas/date
COM		    .equ	0x01AB	; COM - pokazuje znak 7-seg z rejestru C
PRINT	    .equ	0x01D4	; PRINT - drukuje komunikat z (HL)
EXPR        .equ 	0x0213   ; EXPR - pobranie ciagu liczb 16bit na stos
CSTS        .equ 	0xFFC3   ; CSTS - test czy klawisz nacisniety
CI          .equ 	0xFFC6   ; CI - pobranie znaku z klawiatury
CO          .equ 	0x01E0   ; CO - wyswietlenie cyfry hex
TI          .equ 	0x0007   ; TI - pobranie znaku z echem
PARAM       .equ 	0x01F4   ; PARAM - pobranie liczby 16-bit do HL z echem
HILO        .equ 	0x023b   ; HILO - iterator, HL++, CY = !(DE >= HL)

EOM         .equ 	0xFF 



