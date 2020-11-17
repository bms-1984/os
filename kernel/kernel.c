/*
  kernel entry
  Written by Ben M. Sutter
  Available since version 0.1.0
  Last edited 11/5/2020
*/

#include <stdint.h>
#include "bootboot.h"
#include "kscreen.h"

void _start(void);

extern unsigned char environment[4096];
extern void load_gdt(void);
extern void reload_segment_registers(void);
extern void halt_processor(void);
extern void disable_interrupts(void);
extern void enable_interrupts(void);

void _start(void)
{
  disable_interrupts();
  load_gdt();
  reload_segment_registers();
  print_string("Hello");
  while (1) { halt_processor(); }
}


