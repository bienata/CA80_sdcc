            .module strutils
			
			; exported
			.globl ascii2byte            
			.globl char2bin
			
            .area _CODE 			

            
ascii2byte:     ; bin z dwóch kolejnych ascii wskazanych via HL
            push HL
            push BC
            ld A,(HL)
            call char2bin
            rrca                ; << 4
            rrca
            rrca
            rrca            
            ld B,A              
            inc HL
            ld A,(HL)
            call char2bin
            or B
            pop BC
            pop HL
            ;mamy bajta z dwóch ascii
            ret


			
            
            ; case-aware konwersja ASCII '0'..'f'/'F' na 0..F
            ; 30...39 0-9 
            ; 41...46 A-F    
            ; 61...66 a-f
char2bin:
            ; czy > 60
            cp #0x60
            jr NC,char2bin_lo
            cp #0x40
            jr NC,char2bin_up            
            ; digit
            sub #'0'
            ret
char2bin_lo:
            sub #0x20
char2bin_up:
            sub #0x37
            ret
            
            
