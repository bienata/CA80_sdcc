;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.5.0 #9253 (Apr  3 2018) (Linux)
; This file was generated Wed Dec  4 20:27:15 2019
;--------------------------------------------------------
	.module ca82_nmi_termoclock
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _getTLC1549
	.globl _dlr1414putStr
	.globl _NMI_handler
	.globl _updateClock
	.globl _sprintf
	.globl _nmiCntr
	.globl _tenths
	.globl _seconds
	.globl _minutes
	.globl _hours
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
_USER8255_PA	=	0x00e0
_USER8255_PB	=	0x00e1
_USER8255_PC	=	0x00e2
_USER8255_CTRL	=	0x00e3
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
_hours::
	.ds 1
_minutes::
	.ds 1
_seconds::
	.ds 1
_tenths::
	.ds 1
_nmiCntr::
	.ds 1
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;ca82_nmi_termoclock.c:26: void updateClock(void) {
;	---------------------------------
; Function updateClock
; ---------------------------------
_updateClock::
;ca82_nmi_termoclock.c:27: tenths++;
	ld	hl, #_tenths+0
	inc	(hl)
;ca82_nmi_termoclock.c:28: if ( tenths == 10 ) {
	ld	a,(#_tenths + 0)
	sub	a, #0x0A
	ret	NZ
;ca82_nmi_termoclock.c:29: tenths = 0;
	ld	hl,#_tenths + 0
	ld	(hl), #0x00
;ca82_nmi_termoclock.c:30: seconds++;
	ld	hl, #_seconds+0
	inc	(hl)
;ca82_nmi_termoclock.c:31: if ( seconds == 60 ) {
	ld	a,(#_seconds + 0)
	sub	a, #0x3C
	ret	NZ
;ca82_nmi_termoclock.c:32: seconds = 0;
	ld	hl,#_seconds + 0
	ld	(hl), #0x00
;ca82_nmi_termoclock.c:33: minutes++;
	ld	hl, #_minutes+0
	inc	(hl)
;ca82_nmi_termoclock.c:34: if ( minutes == 60 ) {
	ld	a,(#_minutes + 0)
	sub	a, #0x3C
	ret	NZ
;ca82_nmi_termoclock.c:35: minutes = 0;
	ld	hl,#_minutes + 0
	ld	(hl), #0x00
;ca82_nmi_termoclock.c:36: hours++;
	ld	hl, #_hours+0
	inc	(hl)
;ca82_nmi_termoclock.c:37: if ( hours == 24 ) {
	ld	a,(#_hours + 0)
	sub	a, #0x18
	ret	NZ
;ca82_nmi_termoclock.c:38: hours = 0;
	ld	hl,#_hours + 0
	ld	(hl), #0x00
	ret
;ca82_nmi_termoclock.c:48: void NMI_handler(void) __interrupt __critical {    
;	---------------------------------
; Function NMI_handler
; ---------------------------------
_NMI_handler::
	push	af
	push	bc
	push	de
	push	hl
	push	iy
;ca82_nmi_termoclock.c:49: nmiCntr++;
	ld	hl, #_nmiCntr+0
	inc	(hl)
;ca82_nmi_termoclock.c:50: if ( nmiCntr == 40 ) {
	ld	a,(#_nmiCntr + 0)
	sub	a, #0x28
	jr	NZ,00103$
;ca82_nmi_termoclock.c:51: nmiCntr = 0;
	ld	hl,#_nmiCntr + 0
	ld	(hl), #0x00
;ca82_nmi_termoclock.c:52: updateClock(); // co 100 ms.
	call	_updateClock
00103$:
	pop	iy
	pop	hl
	pop	de
	pop	bc
	pop	af
	retn
;ca82_nmi_termoclock.c:58: void dlr1414putStr( char *pS ) {
;	---------------------------------
; Function dlr1414putStr
; ---------------------------------
_dlr1414putStr::
	push	ix
	ld	ix,#0
	add	ix,sp
	dec	sp
;ca82_nmi_termoclock.c:59: char *p = pS;
	ld	e,4 (ix)
	ld	d,5 (ix)
;ca82_nmi_termoclock.c:61: while ( *p && (n >= 0) ) {
	ld	bc,#0x0013
00102$:
	ld	a,(de)
	ld	h,a
	or	a, a
	jr	Z,00105$
	bit	7, b
	jr	NZ,00105$
;ca82_nmi_termoclock.c:62: USER8255_PA = *p;
	ld	a,h
	out	(_USER8255_PA),a
;ca82_nmi_termoclock.c:63: USER8255_PB	= n;
	ld	-1 (ix), c
	ld	a, c
	out	(_USER8255_PB),a
;ca82_nmi_termoclock.c:64: USER8255_PB	= 0x20 + n;
	ld	a,c
	add	a, #0x20
	out	(_USER8255_PB),a
;ca82_nmi_termoclock.c:65: USER8255_PB	= n;
	ld	a,-1 (ix)
	out	(_USER8255_PB),a
;ca82_nmi_termoclock.c:66: p++;
	inc	de
;ca82_nmi_termoclock.c:67: --n;
	dec	bc
	jr	00102$
00105$:
	inc	sp
	pop	ix
	ret
;ca82_nmi_termoclock.c:73: unsigned short getTLC1549( void ) {
;	---------------------------------
; Function getTLC1549
; ---------------------------------
_getTLC1549::
;ca82_nmi_termoclock.c:74: unsigned short out = 0;
	ld	bc,#0x0000
;ca82_nmi_termoclock.c:76: USER8255_PC = 0;	// CLK=0, /CS=0
	ld	a,#0x00
	out	(_USER8255_PC),a
;ca82_nmi_termoclock.c:77: for ( n = 0; n < 10; n++ ) {
	ld	d,#0x00
00102$:
;ca82_nmi_termoclock.c:78: out = out << 1;
	sla	c
	rl	b
;ca82_nmi_termoclock.c:79: out = out | ( USER8255_PC & 0x80 ? 1 : 0 );
	in	a,(_USER8255_PC)
	rlca
	jr	NC,00106$
	ld	h,#0x01
	jr	00107$
00106$:
	ld	h,#0x00
00107$:
	ld	l,#0x00
	ld	a,c
	or	a, h
	ld	c,a
	ld	a,b
	or	a, l
	ld	b,a
;ca82_nmi_termoclock.c:80: USER8255_PC = 2; // CLK=1, /CS=0
	ld	a,#0x02
	out	(_USER8255_PC),a
;ca82_nmi_termoclock.c:81: USER8255_PC = 0; // CLK=0, /CS=0
	ld	a,#0x00
	out	(_USER8255_PC),a
;ca82_nmi_termoclock.c:77: for ( n = 0; n < 10; n++ ) {
	inc	d
	ld	a,d
	sub	a, #0x0A
	jr	C,00102$
;ca82_nmi_termoclock.c:83: USER8255_PC = 1;	// CLK=0, /CS=1	
	ld	a,#0x01
	out	(_USER8255_PC),a
;ca82_nmi_termoclock.c:84: return out;
	ld	l, c
	ld	h, b
	ret
;ca82_nmi_termoclock.c:89: void main( void ) {
;	---------------------------------
; Function main
; ---------------------------------
_main::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-51
	add	hl,sp
	ld	sp,hl
;ca82_nmi_termoclock.c:95: unsigned char lastSecond = 0;
	ld	c,#0x00
;ca82_nmi_termoclock.c:100: USER8255_CTRL = 0x88; // PC74-in, reszta-out
	ld	a,#0x88
	out	(_USER8255_CTRL),a
;ca82_nmi_termoclock.c:101: USER8255_PA = 0x00;
	ld	a,#0x00
	out	(_USER8255_PA),a
;ca82_nmi_termoclock.c:102: USER8255_PB = 0x00;
	ld	a,#0x00
	out	(_USER8255_PB),a
;ca82_nmi_termoclock.c:103: USER8255_PC = 0x01; //  /CS=1, CLK=0
	ld	a,#0x01
	out	(_USER8255_PC),a
;ca82_nmi_termoclock.c:106: while( 1 ) {
00105$:
;ca82_nmi_termoclock.c:108: if ( lastSecond != seconds ) {
	ld	a,(#_seconds + 0)
	sub	a, c
	jr	Z,00105$
;ca82_nmi_termoclock.c:109: lastSecond = seconds;
	ld	hl,#_seconds + 0
	ld	c, (hl)
;ca82_nmi_termoclock.c:111: idx = lastSecond % READINGS_NUM;
	push	bc
	ld	a,#0x0A
	push	af
	inc	sp
	ld	a,c
	push	af
	inc	sp
	call	__moduchar
	pop	af
	pop	bc
	ld	d,l
;ca82_nmi_termoclock.c:112: adcReadings[ idx ] = getTLC1549();
	ld	hl,#0x0015
	add	hl,sp
	ld	-8 (ix),l
	ld	-7 (ix),h
	ld	l,d
	ld	h,#0x00
	add	hl, hl
	ld	e,-8 (ix)
	ld	d,-7 (ix)
	add	hl,de
	push	hl
	push	bc
	call	_getTLC1549
	ld	d,l
	ld	e,h
	pop	bc
	pop	hl
	ld	(hl),d
	inc	hl
	ld	(hl),e
;ca82_nmi_termoclock.c:114: adcAvg = 0;
	ld	iy,#0x0000
;ca82_nmi_termoclock.c:115: for (idx = 0; idx < READINGS_NUM; idx++ ) {
	ld	b,#0x00
00107$:
;ca82_nmi_termoclock.c:116: adcAvg += adcReadings[ idx ];
	ld	l,b
	ld	h,#0x00
	add	hl, hl
	ld	e,-8 (ix)
	ld	d,-7 (ix)
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	add	iy, de
;ca82_nmi_termoclock.c:115: for (idx = 0; idx < READINGS_NUM; idx++ ) {
	inc	b
	ld	a,b
	sub	a, #0x0A
	jr	C,00107$
;ca82_nmi_termoclock.c:118: adcAvg /= READINGS_NUM;
	push	bc
	ld	hl,#0x000A
	push	hl
	push	iy
	call	__divsint
	pop	af
	pop	af
	pop	bc
;ca82_nmi_termoclock.c:121: temp = (adcAvg*4 - 500)/10; // dla Uref MCP1541 (4.096)
	add	hl, hl
	add	hl, hl
	ld	a,l
	add	a,#0x0C
	ld	l,a
	ld	a,h
	adc	a,#0xFE
	ld	h,a
	push	bc
	ld	de,#0x000A
	push	de
	push	hl
	call	__divsint
	pop	af
	pop	af
	pop	bc
	ex	de,hl
;ca82_nmi_termoclock.c:122: colon = seconds % 2 ? ':' : ' ';
	ld	hl,#_seconds+0
	bit	0, (hl)
	jr	Z,00111$
	ld	b,#0x3A
	jr	00112$
00111$:
	ld	b,#0x20
00112$:
;ca82_nmi_termoclock.c:123: sprintf( sText, "%02d:%02d%c%02d outd. %+2d'C", hours, minutes, colon, seconds, temp );
	ld	a,(#_seconds + 0)
	ld	-8 (ix),a
	ld	-7 (ix),#0x00
	ld	-6 (ix),b
	ld	a,b
	rla
	sbc	a, a
	ld	-5 (ix),a
	ld	a,(#_minutes + 0)
	ld	-10 (ix),a
	ld	-9 (ix),#0x00
	ld	a,(#_hours + 0)
	ld	-2 (ix),a
	ld	-1 (ix),#0x00
	ld	hl,#0x0000
	add	hl,sp
	ld	-4 (ix),l
	ld	-3 (ix),h
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	push	bc
	push	de
	ld	e,-8 (ix)
	ld	d,-7 (ix)
	push	de
	ld	e,-6 (ix)
	ld	d,-5 (ix)
	push	de
	ld	e,-10 (ix)
	ld	d,-9 (ix)
	push	de
	ld	e,-2 (ix)
	ld	d,-1 (ix)
	push	de
	ld	de,#___str_0
	push	de
	push	hl
	call	_sprintf
	ld	hl,#14
	add	hl,sp
	ld	sp,hl
	pop	bc
;ca82_nmi_termoclock.c:124: dlr1414putStr( SPACES );
	ld	hl,#___str_1+0
	push	bc
	push	hl
	call	_dlr1414putStr
	pop	af
	pop	bc
;ca82_nmi_termoclock.c:125: dlr1414putStr( sText );
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	push	bc
	push	hl
	call	_dlr1414putStr
	pop	af
	pop	bc
	jp	00105$
___str_0:
	.ascii "%02d:%02d%c%02d outd. %+2d'C"
	.db 0x00
___str_1:
	.ascii "                    "
	.db 0x00
	.area _CODE
	.area _INITIALIZER
__xinit__hours:
	.db #0x00	; 0
__xinit__minutes:
	.db #0x00	; 0
__xinit__seconds:
	.db #0x00	; 0
__xinit__tenths:
	.db #0x00	; 0
__xinit__nmiCntr:
	.db #0x00	; 0
	.area _CABS (ABS)
