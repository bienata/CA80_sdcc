#ifndef __CA80SYS_H__
    #define __CA80SYS_H__

#define LOBYTE(w) ((unsigned short)(w)&0xFF )
#define HIBYTE(w) (((unsigned short)(w)>>8)&0xFF)

#define NO_KEY      0xFF    
#define HALT()      __asm__ ("halt")
#define EI()        __asm__ ("ei")
#define DI()        __asm__ ("di")
#define IM2()       __asm__ ("im 2")
#define PWYS(digitsused/*8-1*/,startfrom/*7-0*/)  ((digitsused<<4)|startfrom)


#define IRQ_CTC_CH0             0
#define IRQ_CTC_CH1             1
#define IRQ_CTC_CH2             2
#define IRQ_CTC_CH3             3
// 4,5,6,7 - empty words f.f.u
#define IRQ_SIO_CHB_TxEmpty     8
#define IRQ_SIO_CHB_ExtChange   9
#define IRQ_SIO_CHB_RxAvailable 10
#define IRQ_SIO_CHB_SpecialCond 11
#define IRQ_SIO_CHA_TxEmpty     12
#define IRQ_SIO_CHA_ExtChange   13
#define IRQ_SIO_CHA_RxAvailable 14
#define IRQ_SIO_CHA_SpecialCond 15

extern unsigned short irqHandlersTable[]; // 4 CTC, 4 NULL, 4 SIO-B, 4 SIO-A

//-- CTC ----------------------------- 

__sfr __at 0xF8 USER_CTC_CHAN0;
__sfr __at 0xF9 USER_CTC_CHAN1;   
__sfr __at 0xFA USER_CTC_CHAN2;   
__sfr __at 0xFB USER_CTC_CHAN3;   

#define CTC_INTERRUPT_ENABLED   1<<7
#define CTC_INTERRUPT_DISABLED  0

#define CTC_COUNTER_MODE        1<<6
#define CTC_TIMER_MODE          0

#define CTC_PRESCALER_256       1<<5    // TIMER only
#define CTC_PRESCALER_16        0
#define CTC_PRESCALER_ANY       0       // don't care

#define CTC_TRG_RISING_EDGE         1<<4    
#define CTC_TRG_FALLING_EDGE        0

#define CTC_TIMER_START_PULSE           1<<3    // TIMER only
#define CTC_TIMER_START_AUTO    0
#define CTC_TIMER_START_ANY     0

#define CTC_NEXT_BYTE_CONST     1<<2
#define CTC_NO_NEXT_BYTE        0

#define CTC_SOFTWARE_RESET      1<<1
#define CTC_CONTINUE_RUN        0

#define CTC_CRTL_BYTE(b7,b6,b5,b4,b3,b2,b1) (b7|b6|b5|b4|b3|b2|b1|1)

//-- 8255 uzytkownika --------------------------
#define USER8255_PA_ADDR        0xE0
#define USER8255_PB_ADDR        0xE1
#define USER8255_PC_ADDR        0xE2
#define USER8255_CTRL_ADDR      0xE3

__sfr __at USER8255_PA_ADDR     USER8255_PA;
__sfr __at USER8255_PB_ADDR     USER8255_PB;
__sfr __at USER8255_PC_ADDR     USER8255_PC;
__sfr __at USER8255_CTRL_ADDR   USER8255_CTRL;

// ustawianie trybu pracy  B7 = 1
#define P8255_GROUP_A_MODE_0                0
#define P8255_GROUP_A_MODE_1                1<<5
#define P8255_GROUP_A_MODE_2                1<<6

#define P8255_PA_INPUT              1<<4
#define P8255_PA_OUTPUT             0

#define P8255_PC74_INPUT            1<<3
#define P8255_PC74_OUTPUT           0

#define P8255_GROUP_B_MODE_0                0
#define P8255_GROUP_B_MODE_1                1<<2

#define P8255_PB_INPUT              1<<1
#define P8255_PB_OUTPUT             0

#define P8255_PC30_INPUT            1
#define P8255_PC30_OUTPUT           0

#define P8255_MODE_CTRL_BYTE(b65,b4,b3,b2,b1,b0)    (1<<7|b65|b4|b3|b2|b1|b0)

//operacje bitowe B7=0
#define P8255_BIT_SET               1
#define P8255_BIT_RESET             0

#define P8255_PC_BIT_CTRL(b321,newstate)    (((b321&0x7)<<1)|(0x1&newstate))

//---------------------------------

extern unsigned char keyPressed(void);
extern unsigned char getKey(void);    

extern void setIrqHandlersTable(unsigned char /*irqMapHighAddress*/); 

extern unsigned char sysCLR(unsigned char /*PWYS*/); 
extern unsigned char sysLBYTE(unsigned char /*PWYS*/, unsigned char /*byte*/);
extern unsigned char sysLADR(unsigned char /*PWYS*/, unsigned short /*word*/);
extern unsigned char sysPRINT(unsigned char /*PWYS*/, unsigned short /*ptr*/);



#endif // of __CA80SYS_H__