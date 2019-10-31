            .module testsio
            ; tasza, 2019
			

            .include "../inc/ca80.inc"


            	.area _DATA 

user_stack_top	.equ .				; stos -> adresy w dół							
            	.ds 2				; data -> adresy w góre


            .area _CODE 			
main:
            ld  SP,#user_stack_top
            ld  HL,#welcome
            call PRINT
            .db 0x60
            ; setup SIO, channel B
            call sioInit
loop:            
            ;ld A,#'A'
            ;call putCharA
            ;ld A,#'a'
            ;call putCharA

			call getChar
			call putCharA


			jr 	loop

welcome:    ; rS-232
            .db 0x50, 0x6d, 0x40, 0x5b, 0x4f, 0x5b, EOM			
			
			
			;---------------------------------------------        
    
			. = main + 0x100

sioInit:
            ld A,#0
            out (SIO_A_CMD),A           ; WR0

            ld A,#1
            out (SIO_A_CMD),A           ; ustaw WR1 
            ld A,#0
            out (SIO_A_CMD),A           ; WR1 := 0
        
            ld  A,#4
            out (SIO_A_CMD),A           ; ustaw WR4        
            ld A,#(0x04|0x40)          ; weź baudy 9600 (bity B7,D6) nałóż 1 stop, no parity
                                        ; 0x80 - 9600, 0x40 - 19200
            out (SIO_A_CMD),A           ;
        
            ld  A,#3
            out (SIO_A_CMD),A           ; ustaw na WR3
            ld  A,#0xC1         ; 8 bit, Rx enable
            out (SIO_A_CMD),A
        
            ld  A,#5
            out (SIO_A_CMD),A           ; ustaw WR5
            ld  A,#0xEA         ; 8bit, Tx enable
            out (SIO_A_CMD),A   

     
            ret
       
			;---------------------------------------------       

			. = main + 0x200

       
putCharA:
            push AF     ; zabezpiecz znaczek
putCharA_wait:
            ld A,#0
            out (SIO_A_CMD),A            ; wybierz RR0 wskazanego kanału
            in  A,(SIO_A_CMD)           ; daj RR0
            bit 2,A             ; czy Transfer Buffer Empty? (D2==1)
            jr Z,putCharA_wait   ; to czekaj dalej
            pop AF          
            out (SIO_A_DAT),A           ; i wyślij
            ret             

			. = main + 0x300


getChar:
            ld A,#0
            out (SIO_A_CMD),A   ; RR0
            in  A,(SIO_A_CMD)   ; status
            and A,#1    ; sprawdź D0 Receive Character Available
            jr Z, getChar
            in  A,(SIO_A_DAT)   ; weź znaczek z RxD
            ret 
            
   			;---------------------------------------------                        

