/*
  pic handling
  Written by Ben M. Sutter
  Available since version 0.2.0
  Last edited 11/19/2020
*/

#include <stdint.h>
#include "util.h"
#include "pic.h"

void remap_pic(int offset1, int offset2)
{
	unsigned char a1, a2;
 
	a1 = inb(PIC1_DATA);                       
	a2 = inb(PIC2_DATA);
 
	outb(PIC1_COMMAND, ICW1_INIT | ICW1_ICW4); 
	io_wait();
	outb(PIC2_COMMAND, ICW1_INIT | ICW1_ICW4);
	io_wait();
	outb(PIC1_DATA, offset1);
	io_wait();
	outb(PIC2_DATA, offset2);
	io_wait();
	outb(PIC1_DATA, 4);  
	io_wait();
	outb(PIC2_DATA, 2);  
	io_wait();
 
	outb(PIC1_DATA, ICW4_8086);
	io_wait();
	outb(PIC2_DATA, ICW4_8086);
	io_wait();
 
	outb(PIC1_DATA, a1); 
	outb(PIC2_DATA, a2);
}
