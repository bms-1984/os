/*
  utility header
  Written by Ben M. Sutter
  Available since version 0.2.0
  Last edited 11/17/2020
*/

#ifndef UTIL_H
#define UTIL_H

extern void halt_processor(void);
extern void disable_interrupts(void);
extern void enable_interrupts(void);
void outb(uint16_t port, uint8_t val);
uint8_t inb(uint16_t port);
void io_wait(void);

#endif
