/* ***************************************************************************** */
/* You can use this file to define the low-level hardware control fcts for       */
/* LED, button and LCD devices.                                                  */ 
/* Note that these need to be implemented in Assembler.                          */
/* You can use inline Assembler code, or use a stand-alone Assembler file.       */
/* Alternatively, you can implement all fcts directly in master-mind.c,          */  
/* using inline Assembler code there.                                            */
/* The Makefile assumes you define the functions here.                           */
/* ***************************************************************************** */


#ifndef	TRUE
#  define	TRUE	(1==1)
#  define	FALSE	(1==2)
#endif

#define	PAGE_SIZE		(4*1024)
#define	BLOCK_SIZE		(4*1024)

#define	INPUT			 0
#define	OUTPUT			 1

#define	LOW			 0
#define	HIGH			 1


// APP constants   ---------------------------------

// Wiring (see call to lcdInit in main, using BCM numbering)
// NB: this needs to match the wiring as defined in master-mind.c

#define STRB_PIN 24
#define RS_PIN   25
#define DATA0_PIN 23
#define DATA1_PIN 10
#define DATA2_PIN 27
#define DATA3_PIN 22

// -----------------------------------------------------------------------------
// includes 
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/types.h>
#include <time.h>

// -----------------------------------------------------------------------------
// prototypes

int failure (int fatal, const char *message, ...);

// -----------------------------------------------------------------------------
// Functions to implement here (or directly in master-mind.c)

/* this version needs gpio as argument, because it is in a separate file */
  /* ***  COMPLETE the code here, using inline Assembler  ***  */
  void digitalWrite(uint32_t *gpio, int pin, int value) {
    if (!gpio) {
        fprintf(stderr, "[ERROR] GPIO pointer is NULL in digitalWrite().\n");
        exit(EXIT_FAILURE);
    }

    asm volatile (
        "mov r2, #1            \n\t"
        "lsl r2, r2, %[pin]    \n\t"  // r2 = 1 << pin
        "cmp %[value], #0      \n\t"
        "strne r2, [%[gpio], #0x1C] \n\t" // GPSET0 (Offset 0x1C)
        "streq r2, [%[gpio], #0x28] \n\t" // GPCLR0 (Offset 0x28)
        :
        : [gpio] "r" (gpio), [pin] "r" (pin), [value] "r" (value)
        : "r2", "cc", "memory"
    );
}

void pinMode(uint32_t *gpio, int pin, int mode) {
    if (!gpio) {
        fprintf(stderr, "[ERROR] GPIO pointer is NULL in pinMode().\n");
        exit(EXIT_FAILURE);
    }

    int shift = (pin % 10) * 3;      // Each pin uses 3 bits
    int index = pin / 10;            // GPFSEL0 = index 0, GPFSEL1 = 1, etc.

    uint32_t mask = 0b111 << shift;               // Mask to clear the 3 bits
    uint32_t mode_val = (mode & 0b111) << shift;  // New mode bits

    asm volatile (
        "add r1, %[gpio], %[index]   \n\t"   // r1 = gpio + index
        "ldr r2, [r1]                \n\t"   // load current GPFSELx
        "bic r2, r2, %[mask]         \n\t"   // clear bits
        "orr r2, r2, %[mode_val]     \n\t"   // set new bits
        "str r2, [r1]                \n\t"   // write back
        :
        : [gpio] "r" (gpio), 
          [index] "r" (index * 4), 
          [mask] "r" (mask), 
          [mode_val] "r" (mode_val)
        : "r1", "r2", "memory"
    );
}





  /* ***  COMPLETE the code here, using inline Assembler  ***  */
  void writeLED(uint32_t *gpio, int led, int value) {
    digitalWrite(gpio,led,value);
}


int readButton(uint32_t *gpio, int button) {
    if (!gpio) {
        fprintf(stderr, "[ERROR] GPIO pointer is NULL in readButton().\n");
        exit(EXIT_FAILURE);
    }

    int state;
    asm volatile (
        "mov r3, #1              \n\t"
        "lsl r3, r3, %[button]   \n\t"  // r3 = 1 << button
        "ldr r2, [%[gpio], #0x34] \n\t"  // Correct GPLEV0 offset
        "and %[state], r2, r3    \n\t"
        "cmp %[state], #0        \n\t"
        "ite eq                  \n\t"
        "moveq %[state], #0      \n\t"
        "movne %[state], #1      \n\t"
        : [state] "=r" (state)
        : [gpio] "r" (gpio), [button] "r" (button)
        : "r2", "r3", "cc", "memory"
    );

    return state;
}






void waitForButton(uint32_t *gpio, int button) {
  /* ***  COMPLETE the code here, just C no Assembler; you can use readButton ***  */
      while (readButton(gpio, button) == LOW) {
        
    }
}




