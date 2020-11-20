/*
  gdt header
  Written by Ben M. Sutter
  Available since version 0.2.0
  Last edited 11/17/2020
*/

#ifndef GDT_H
#define GDT_H

extern void load_gdt(void);
extern void reload_segment_registers(void);

#endif
