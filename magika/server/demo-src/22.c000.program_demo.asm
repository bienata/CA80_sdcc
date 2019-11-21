        .cr z80                     
        .tf ../bbbb/22.c000.program_demo.hex,int   
        .lf 22.c000.program_demo.lst
        .sf 22.c000.program_demo.sym       
        .in ca80.inc                
ADDR_LO .eq 0
ADDR_HI .eq 1               
        .sm code                    ; 
        .or $c000                   ; U12/C000
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
        .dw message2
        .dw message1 
messageTableLength  .eq $-messageTable/2
		;
message1:
        .db     $01,$01,$01, $01, $01, $01, $01, $01, EOM        
message2:
        .db     $40,$40,$40, $40, $40, $40, $40, $40, EOM        
message3:
        .db     $08,$08,$08, $08, $08, $08, $08, $08, EOM        
        ;
delay:  push    BC
        push    AF
        ld      B,$FF
.delay        
        halt            ; 2ms
		halt
        djnz    .delay  ; while( --B )
        pop     AF
        pop     BC
        ret

		;
        
