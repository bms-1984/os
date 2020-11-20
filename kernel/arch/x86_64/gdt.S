/*
  gdt handling
  Written by Ben M. Sutter
  Available since version 0.1.0
  Last edited 11/17/2020
*/

	.arch   i386
	.data
	.align  4
gdt:
null   = . - gdt
	.quad   0
	.global code_0
code_0 = . - gdt
	.quad 	(1<<43) | (1<<44) | (1<<47) | (1<<53)
gdt_end:

gdt_reference:
	.word   (gdt_end - gdt - 1)
	.quad   gdt

	.text
	
	// void load_gdt(void);
	.global load_gdt
	.func   load_gdt, load_gdt
load_gdt:
	lgdt    gdt_reference
	ret
	.endfunc

	// void reload_segment_registers(void);
	.global reload_segment_registers
	.func   reload_segment_registers, reload_segment_registers
reload_segment_registers:
	pushq   $code_0
	pushq   $jump
	retfq
jump:
	movw    $0,    %ax
	movw    %ax,        %ds
	movw    %ax,        %es
	movw    %ax,        %fs
	movw    %ax,        %gs
	movw    %ax,        %ss
	ret
	.endfunc
