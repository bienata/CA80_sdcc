        .cr z80                     
        .tf ../cccc/33.8000.program_demo.hex,int   
        .lf 33.8000.program_demo.lst
        .sf 33.8000.program_demo.sym       
        .in ca80.inc                

ADDR_LO .eq 0
ADDR_HI .eq 1               

        .sm code                    ; 

        .or $8000                   ; 
		;
.begin	
        ld IX,messageTable          ; adres tabeli komunikatów
        ld B,messageTableLength     ; licznik komunikatów 
.loop        
		ld L,(IX+ADDR_LO)                 ; do HL adres wybranego via wskaznik 
        ld H,(IX+ADDR_HI)                 ; z IX komunikatu w kolejności LSB, MSB 
		call PRINT                  ; pokaż znaki
		.db $80                     ; na cały wyświetlacz
		call delay                  ; opóznienie
        inc IX                      ;
        inc IX                      ; IX += 2 kolejny wskaźnik       		
        djnz .loop                  ; while(--licznik)    		
		;
		ret
		;
messageTable:
        .dw message1 
        .dw message2
        .dw message3
        .dw message4 
        .dw message5
        .dw message6
        .dw message7
        .dw message8
        .dw message7 
        .dw message6
        .dw message5
        .dw message4 
        .dw message3
        .dw message2
        .dw message1
messageTableLength  .eq $-messageTable/2
		;
message1:
        .db     $5c,$00,$00, $00, $00, $00, $00, $00, EOM        
message2:
        .db     $00,$5c,$00, $00, $00, $00, $00, $00, EOM        
message3:
        .db     $00,$00, $5c,$00, $00, $00, $00, $00, EOM        
message4:
        .db     $00,$00, $00, $5c,$00, $00, $00, $00, EOM        
message5:
        .db     $00,$00, $00, $00, $5c,$00, $00, $00, EOM        
message6:
        .db     $00,$00, $00, $00, $00, $5c,$00, $00, EOM        
message7:
        .db     $00,$00, $00, $00, $00, $00,$5c, $00, EOM        
message8:
        .db     $00,$00, $00, $00, $00, $00, $00, $5c,EOM        
        ;
delay:  push    BC
        push    AF
        ld      B,$FF
.delay        
        halt            ; 2ms
        djnz    .delay  ; while( --B )
        pop     AF
        pop     BC
        ret

		;
        
