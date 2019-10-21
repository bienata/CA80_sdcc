        .module sio
        ;
SIO_BASE    .equ    0xE8        
SIO_A_DAT   .equ    SIO_BASE+0
SIO_B_DAT   .equ    SIO_BASE+1
SIO_A_CMD   .equ    SIO_BASE+2
SIO_B_CMD   .equ    SIO_BASE+3
        ;        
        .globl _putChar
        .globl _getChar        
        .globl _putStr
        .globl _sioInit        
        .globl _sioDTRA
        .globl _sioSetIrqHandlersTable;        
        .globl _sioIrqEnable;
        ;        
        .area   _DATA    
_rxdBuffer:
        .ds 128
        ;
        .area _CODE  
   
_putStr:
        ; translacja numer kanału->adres SIO
        ld IY,#2
        add IY,SP
        ld A,0(IY)      
        add A,#SIO_A_CMD 
        ld C,A          ; C - cmd wybranego kanału, data jest C-2
        ; adres napisu do wysłania
        ld L,1(IY)      ;low
        ld H,2(IY)      ;high
putStr_wait:        
        ld A,#0
        out(C),A            ; wybierz RR0 wskazanego kanału
        in  A,(C)           ; daj RR0
        bit 2,A             ; czy Transfer Buffer Empty? (D2==1)
        jr Z,putStr_wait
        dec C
        dec C               ; C wskazuje na DAT
        ld A,(HL)           ; weź znaczek z napisu
        cp #0               ; czy NULL?
        ret Z               ; tak, spadaj!
        out (C),A           ; wyślij znaczek
        inc C
        inc C               ; C wskazuje na CMD
        inc HL              ; prt++
        jr putStr_wait      ; i tak dalej
        ;
_putChar:   
        ld IY,#2
        add IY,SP
        ld A,0(IY)      ; numer kanału (0,1)
        add A,#SIO_A_CMD  ; SIO_A_CMD+0 lub SIO_A_CMD+1 czyli SIO_B_CMD
        ld C,A          ; będzie od teraz numerem portu        
        ; czekaj aż skończy poprzedni transfer
putChar_wait:        
        ld A,#0
        out(C),A            ; wybierz RR0 wskazanego kanału
        in  A,(C)           ; daj RR0
        bit 2,A             ; czy Transfer Buffer Empty? (D2==1)
        jr Z,putChar_wait   ; to czekaj dalej
        ; przerób _CMD na _DAT czyli C := C-2
        dec C
        dec C               ; w C jest adres portu danych :)                
        ld IY,#2
        add IY,SP
        ld A,1(IY)          ; weź znaczek
        out (C),A           ; i wyślij
        ret
        ;
        ;---------------------------------------
        ;
_getChar:   
        ld IY,#2
        add IY,SP
        ld A,0(IY)      ; numer kanału (0,1)
        add A,#SIO_A_CMD
        ld C,A          
        ; 
getChar_wait:        
        ld A,#0
        out (C),A   ; RR0
        in  A,(C)   ; status
        and A,#1    ; sprawdź D0 Receive Character Available
        jr Z, getChar_wait
        dec C
        dec C
        in  A,(C)   ; weź znaczek z RxD
        ld L,A      ; epilog 
        ret        
        ;
        ;---------------------------------------
        ;        
_sioInit:       
        ; sioInit (channel, bauds)
        ld IY,#2
        add IY,SP
        ld A,0(IY)      ; numer kanału (0,1)
        add A,#SIO_A_CMD  ; SIO_A_CMD+0 lub SIO_A_CMD+1 czyli SIO_B_CMD
        ld C,A          ; będzie od teraz numerem portu        
        ;
        ld A,#0
        out (C),A           ; WR0

        ld A,#1
        out (C),A           ; ustaw WR1 
        ld A,#0
        out (C),A           ; WR1 := 0
        
        ld  A,#4
        out (C),A           ; ustaw WR4        
        ld A,1(IY)          ; weź baudy (bity B7,D6)
        or A,#0x04          ; nałóż 1 stop, no parity
        out (C),A           ;
        
        ld  A,#3
        out (C),A           ; ustaw na WR3
        ld  A,#0xC1         ; 8 bit, Rx enable
        out (C),A
        
        ld  A,#5
        out (C),A           ; ustaw WR5
        ld  A,#0xEA         ; 8bit, Tx enable
        out (C),A        
        ret
        ;
        ;---------------------------------------
        ;
_sioDTRA:
        LD  A,#5
        OUT (SIO_A_CMD),A   ;SELECT WR5
        ld IY,#2
        add IY,SP
        ld A,0(IY)       
        cp #0
        jp  Z,sioDTRA_off
        ; on
        LD  A,#0xE8         ; 8bit Tx, enable
        OUT (SIO_A_CMD),A
        ret
sioDTRA_off:        
        LD  A,#0x68         ; 8bit Tx, enable
        OUT (SIO_A_CMD),A
        ret
        ;
        ;---------------------------------------
        ;
_sioSetIrqHandlersTable:
        ld  A,#2
        out (SIO_B_CMD),A   ; ustaw WR2 kan. B
        ld IY,#2
        add IY,SP
        ld A,0(IY)          ; dolny bajt adresu tab.irq
        out (SIO_B_CMD),A   ; nowy wektor
        ret;
        
_sioIrqEnable:
        ; 1100 1110
        ld IY,#2
        add IY,SP
        ld A,0(IY)          ; numer kanału (0,1)
        add A,#SIO_A_CMD    
        ld C,A          
        ;
        ld A,#1             ; WR1
        out (C),A
        ld A,1(IY)          ; maska na Tx / Rx      
        out (C),A        
        ret
        
        