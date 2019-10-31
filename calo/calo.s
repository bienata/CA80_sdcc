            .module calo        
            ; simple intel hex loader for CA80 and Z80-SIO
            ; tasza, 2019
			;
			; 19200,8,N,1, kanal A
			

            .include "../inc/ca80.inc"


SIO_DATA	.equ	SIO_A_DAT
SIO_COMMAND	.equ	SIO_A_CMD

            	.area _DATA 

user_stack_top	.equ .				; stos -> adresy w dół							
            	.ds 2				; data -> adresy w góre

rx_buffer:      .ds 80              ; rx buffer
rx_buffer_len   .equ  .-rx_buffer   ; buff size         


            

            .area _CODE 			
main:
            ld  SP,#user_stack_top
            ; setup SIO, channel A
            call sioInit
            ; napisz 'cALo'
            ld HL,#caloMessage
            call PRINT
            .db 0x44            
main_loadloop:
            call loadHex
            jr C,main_loaderError
            call checkCRC
            jr NZ,main_loaderError
            ; data czy EOF
            call isEOF
            jr Z,main_loaderDone
            call procHex
            jr C,main_loaderError
            call sendAck
            jr main_loadloop
main_loaderDone:
            call sendDone
            jp 0x0000                       
main_loaderError:
            call sendErr
            jp 0x0000           

            ; cALo 
caloMessage: 
            .db 0x58, 0x77, 0x38, 0x5c, 0xFF 

			;---------------------------------------------
            
checkCRC:
            ld HL,#rx_buffer        
            ld C,#00
checkCRC_loop:            
            call ascii2byte
            add C
            ld C,A
            inc HL
            inc HL              ; natepna para
            ld A,(HL)
            cp #0
            jr NZ,checkCRC_loop
            ld A,C
            cp #0               ; czy suma bajtów i CRC == 0?
            ret                 ; Z=1 -> OK,  Z=0 - lipa
              
			;---------------------------------------------
              
procHex:    ; process hex - wypakowanie danych
            ld HL,#rx_buffer
            ; +0, +1 - dlugosc
            call ascii2byte
            ld B,A              ; len w B !!!!
            ld HL,#rx_buffer+2  ; ustaw sie na adres                        
            call ascii2byte            
            cp #>calo_end        ; chronione strony, cała bieżąca
            jr C, procHex_err     ; `access violation`, exit
            ld D,A              ; HI address (DE)
            inc HL
            inc HL            
            call ascii2byte
            ld E,A              ; LO adress (DE)
            ; pokaż
            push DE
            pop HL
            call LADR
            .db 0x40
             ; przeskocz typ rekordu, ustaw na dane
            ld HL,#rx_buffer+8  ; ustaw sie na adres                         
            ; bierz kolejne dane
procHex_next:
            call ascii2byte     ; 
            ld (DE),A           ; 
            inc DE              ; pMem++
            inc HL              
            inc HL                          
            djnz procHex_next            
procHex_done:            
            scf
            ccf
            ret         ; OK -> CY=0
procHex_err:
            scf
            ret         ; lipa, CY=1
            
			;---------------------------------------------			
            
isEOF:
            ld HL,#rx_buffer+7
            ld A,(HL)
            cp #'1'
            ret     ;   Z==1 -> EOF
            
			;---------------------------------------------         
         
loadHex:
            ld HL,#rx_buffer
            ld B,#0x00          ; licznik znaków
loadHex_wait:
            call getChar
            cp #':'
            jr NZ, loadHex_wait
loadHex_load:            
            call getChar
            cp #13          ; CR precz
            jr Z,loadHex_load
            cp #10          ; LF - finito
            jr Z,loadHex_done
            ld (HL),A       ; do bufora
            inc HL          ; ptr++
            xor A
            ld (HL),A       ; zero na koniec
            inc B           ; i++
            ld A,#rx_buffer_len
            sub B
            jr C,loadHex_buffOver                        
            jr loadHex_load         ; i dalej
loadHex_done:            
            scf
            ccf
            ret         ; OK -> CY=0
loadHex_buffOver:
            scf
            ret         ; lipa, CY=1

            ;---------------------------------------------
            
sendAck:
            ld A,#'.'
            call putChar
            jr send_LF
sendDone:
            ld A,#'-'
            call putChar
            jr send_LF
sendErr:
            ld A,#'!'
            call putChar
send_LF:            
            ld A,#10
            call putChar
            ret

			;---------------------------------------------        
    
sioInit:
            xor a						  ; A := 0
            out (SIO_COMMAND),A           ; WR0

            ld A,#1
            out (SIO_COMMAND),A           ; ustaw WR1 
            xor a						  ; A := 0
            out (SIO_COMMAND),A           ; WR1 := 0
        
            ld  A,#4
            out (SIO_COMMAND),A           ; ustaw WR4        
            ld A,#(0x04|0x40)          ; weź baudy 9600 (bity B7,D6) nałóż 1 stop, no parity
                                        ; 0x80 - 9600, 0x40 - 19200
            out (SIO_COMMAND),A           ;
        
            ld  A,#3
            out (SIO_COMMAND),A           ; ustaw na WR3
            ld  A,#0xC1         ; 8 bit, Rx enable
            out (SIO_COMMAND),A
        
            ld  A,#5
            out (SIO_COMMAND),A           ; ustaw WR5
            ld  A,#0xEA         ; 8bit, Tx enable
            out (SIO_COMMAND),A        
            ret
       
			;---------------------------------------------       
       
putChar:
            push AF     ; zabezpiecz znaczek
putChar_wait:
            xor a						  ; A := 0
            out (SIO_COMMAND),A            ; wybierz RR0 wskazanego kanału
            in  A,(SIO_COMMAND)           ; daj RR0
            bit 2,A             ; czy Transfer Buffer Empty? (D2==1)
            jr Z,putChar_wait   ; to czekaj dalej
            pop AF          
            out (SIO_DATA),A           ; i wyślij
            ret             

			;---------------------------------------------                        

getChar:
            xor a						  ; A := 0
            out (SIO_COMMAND),A   ; RR0
            in  A,(SIO_COMMAND)   ; status
            and A,#1    ; sprawdź D0 Receive Character Available
            jr Z, getChar
            in  A,(SIO_DATA)   ; weź znaczek z RxD
            ret 

calo_end:	            
			; qniec
            
        
