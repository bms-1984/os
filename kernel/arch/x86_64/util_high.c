/*
  C-level utility functions
  Written by Ben M. Sutter
  Available since version 0.1.0
  Last edited 11/17/2020
*/

#include "stdint.h"
#include "util.h"

void outb(uint16_t port, uint8_t val) {
    asm volatile ( "outb %0, %1" : : "a"(val), "Nd"(port) );
}

uint8_t inb(uint16_t port) {
    uint8_t ret;
    asm volatile ( "inb %1, %0" : "=a"(ret) : "Nd"(port) );
    return ret;
}

void io_wait(void) {
     asm volatile ( "outb %%al, $0x80" : : "a"(0) );
}
