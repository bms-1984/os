/*
  kernel entry
  Written by Ben M. Sutter
  Available since version 0.1.0
  Last edited 11/17/2020
*/

#include <stdint.h>
#include "bootboot.h"
#include "kscreen.h"
#include "gdt.h"
#include "util.h"

void _start(void);
extern unsigned char environment[4096];

void _start(void)
{
  disable_interrupts();
  load_gdt();
  reload_segment_registers();
  print_string("Hello");
  while (1) { halt_processor(); }
}


