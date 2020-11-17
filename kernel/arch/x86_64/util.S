/*
  utility functions
  Written by Ben M. Sutter
  Available since version 0.1.0
  Last edited 11/17/2020
*/

	.arch   i386
	.text
	
	// void halt_processor();
	.global halt_processor
	.func   halt_processor, halt_processor
halt_processor:
	hlt
	ret
	.endfunc

	// void disable_interrupts();
	.global disable_interrupts
	.func   disable_interrupts, disable_interrupts
disable_interrupts:
	cli
	ret
	.endfunc
	
	// void enable_interrupts();
	.global enable_interrupts
	.func   enable_interrupts, enable_interrupts
enable_interrupts:
	sti
	ret
	.endfunc
