ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1             .module strutils
                              2 			
                              3 			; exported
                              4 			.globl ascii2byte            
                              5 			.globl char2bin
                              6 			
                              7             .area _CODE 			
                              8 
                              9             
   4100                      10 ascii2byte:     ; bin z dwóch kolejnych ascii wskazanych via HL
   4100 E5            [11]   11             push HL
   4101 C5            [11]   12             push BC
   4102 7E            [ 7]   13             ld A,(HL)
   4103 CD 14 41      [17]   14             call char2bin
   4106 0F            [ 4]   15             rrca                ; << 4
   4107 0F            [ 4]   16             rrca
   4108 0F            [ 4]   17             rrca
   4109 0F            [ 4]   18             rrca            
   410A 47            [ 4]   19             ld B,A              
   410B 23            [ 6]   20             inc HL
   410C 7E            [ 7]   21             ld A,(HL)
   410D CD 14 41      [17]   22             call char2bin
   4110 B0            [ 4]   23             or B
   4111 C1            [10]   24             pop BC
   4112 E1            [10]   25             pop HL
                             26             ;mamy bajta z dwóch ascii
   4113 C9            [10]   27             ret
                             28 
                             29 
                             30 			
                             31             
                             32             ; case-aware konwersja ASCII '0'..'f'/'F' na 0..F
                             33             ; 30...39 0-9 
                             34             ; 41...46 A-F    
                             35             ; 61...66 a-f
   4114                      36 char2bin:
                             37             ; czy > 60
   4114 FE 60         [ 7]   38             cp #0x60
   4116 30 07         [12]   39             jr NC,char2bin_lo
   4118 FE 40         [ 7]   40             cp #0x40
   411A 30 05         [12]   41             jr NC,char2bin_up            
                             42             ; digit
   411C D6 30         [ 7]   43             sub #'0'
   411E C9            [10]   44             ret
   411F                      45 char2bin_lo:
   411F D6 20         [ 7]   46             sub #0x20
   4121                      47 char2bin_up:
   4121 D6 37         [ 7]   48             sub #0x37
   4123 C9            [10]   49             ret
                             50             
                             51             
