/*
  kernel entry
  Written by Ben M. Sutter
  Available since version 0.1.0
  Last edited 11/19/2020
*/

#include <stdint.h>
#include "bootboot.h"
#include "kscreen.h"
#include "gdt.h"
#include "util.h"
#include "pic.h"
#include "idt.h"

void _start(void);
extern unsigned char environment[4096];

void _start(void)
{
  disable_interrupts();
  load_gdt();
  reload_segment_registers();
  print_string("Hello");
  load_idt();
  remap_pic(0x20, 0x28);
  enable_interrupts();
  while (1) { halt_processor(); }
}


