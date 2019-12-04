//---------------------------------------------------
// CA82 DLR1414 zegarotermometr-demo, tasza (c) 2019
// budowa bin: do.sh 
// ładowanie:  cp -v ca82_nmi_termoclock.bin /dev/usb/lp1
//---------------------------------------------------
#include <stdio.h>
#include <stdlib.h>

__sfr __at 0xE0 USER8255_PA;
__sfr __at 0xE1 USER8255_PB;
__sfr __at 0xE2 USER8255_PC;
__sfr __at 0xE3 USER8255_CTRL;

// obszar zegara RTC odliczanego w NMI
unsigned char hours = 0;
unsigned char minutes = 0;
unsigned char seconds = 0;
unsigned char tenths = 0;
unsigned char nmiCntr = 0;

#define READINGS_NUM	10
#define SPACES			"                    "

//---------------------------------------------------

void updateClock(void) {
	tenths++;
	if ( tenths == 10 ) {
		tenths = 0;
		seconds++;
		if ( seconds == 60 ) {
			seconds = 0;
			minutes++;
			if ( minutes == 60 ) {
				minutes = 0;
				hours++;
				if ( hours == 24 ) {
					hours = 0;
				}
			}
		}
	}
}

//---------------------------------------------------

// co 2.5 ms (400 na sekundę)
void NMI_handler(void) __interrupt __critical {    
	nmiCntr++;
	if ( nmiCntr == 40 ) {
		nmiCntr = 0;
		updateClock(); // co 100 ms.
	}	
}

//---------------------------------------------------

void dlr1414putStr( char *pS ) {
	char *p = pS;
	int n = 19;
	while ( *p && (n >= 0) ) {
		USER8255_PA = *p;
		USER8255_PB	= n;
		USER8255_PB	= 0x20 + n;
		USER8255_PB	= n;
		p++;
		--n;
    }
}

//---------------------------------------------------

unsigned short getTLC1549( void ) {
	unsigned short out = 0;
	unsigned char n;
	USER8255_PC = 0;	// CLK=0, /CS=0
	for ( n = 0; n < 10; n++ ) {
		out = out << 1;
		out = out | ( USER8255_PC & 0x80 ? 1 : 0 );
		USER8255_PC = 2; // CLK=1, /CS=0
		USER8255_PC = 0; // CLK=0, /CS=0
	}
	USER8255_PC = 1;	// CLK=0, /CS=1	
	return out;
}

//---------------------------------------------------

void main( void ) {

	int adcReadings[ READINGS_NUM ];
	char sText[ 21 ];
	int temp;
	int adcAvg;
	unsigned char lastSecond = 0;
	unsigned char idx = 0;
	char colon; 

	// ustawienia portu uzytkownika
	USER8255_CTRL = 0x88; // PC74-in, reszta-out
	USER8255_PA = 0x00;
	USER8255_PB = 0x00;
	USER8255_PC = 0x01; //  /CS=1, CLK=0

	// i tak w kółko	
	while( 1 ) {
		// obliczaj T co sekundę
		if ( lastSecond != seconds ) {
			lastSecond = seconds;
			// odswież kolejke pomiarow
			idx = lastSecond % READINGS_NUM;
			adcReadings[ idx ] = getTLC1549();
			// wylicz średnią za ostatnie 10 sekund
			adcAvg = 0;
			for (idx = 0; idx < READINGS_NUM; idx++ ) {
				adcAvg += adcReadings[ idx ];
			}
			adcAvg /= READINGS_NUM;

			// TEST	adcAvg = adcAvg - 135;		
			temp = (adcAvg*4 - 500)/10; // dla Uref MCP1541 (4.096)
			colon = seconds % 2 ? ':' : ' ';
			sprintf( sText, "%02d:%02d%c%02d outd. %+2d'C", hours, minutes, colon, seconds, temp );
			dlr1414putStr( SPACES );
			dlr1414putStr( sText );
		}
	}
}
// fin

