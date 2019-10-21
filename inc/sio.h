#ifndef __SIO_H__
    #define __SIO_H__

extern unsigned char rxdBuffer[]; // 128 znaczków
// RxTx clk = 307200Hz
#define B19200  0x40    // x16
#define B9600   0x80    // x32
#define B4800   0xC0    // x64
#define B300    0xC0    // x64
#define B38400  0x00    // x 1


#define IRQ_RX      0x1C    // D4=1,D3=1, INT on All Rx Characters (Parity Does Not Affect Vector)
#define IRQ_TX      0x02    // D1=1 Tx INT Enable
#define IRQ_NONE    0x00    // D2=1 INT affects vect

__sfr __at 0xE8 SIO_A_DAT;
__sfr __at 0xE9 SIO_B_DAT;   
__sfr __at 0xEA SIO_A_CMD;   
__sfr __at 0xEB SIO_B_CMD;

extern void sioInit(unsigned char /*nChannel*/, unsigned char /*bauds*/); 
extern unsigned char putChar(unsigned char /*nChannel*/, unsigned char /*anyChar*/ );
extern unsigned char putStr(unsigned char /*nChannel*/, unsigned char */*pMessage*/ ); 
extern void sioDTRA(unsigned char /*newDTR*/ );
extern unsigned char getChar(unsigned char /*nChannel*/ ); 

extern void sioSetIrqHandlersTable(unsigned char loAddr);
extern void sioIrqEnable(unsigned char/*channel*/, unsigned char /* Tx,Rx*/);
#endif // of __SIO_H__
