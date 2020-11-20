/*
  idt handling
  Written by Ben M. Sutter
  Available since version 0.2.0
  Last edited 11/19/2020
*/

	.arch   i386
	.data
	.align  4

idt:
	.skip 50*16

idt_end:

idt_reference:
	.word   (idt_end - idt - 1)
	.quad   idt

	.text

	// void load_idt(void);
	.global load_idt
	.func   load_idt, load_idt
load_idt:
	lidt	idt_reference
	movq 	$isr0,   %rax
	mov     %ax,     idt
	movw	$code_0, idt + 2
	movw    $0x8e00, idt + 4
	shr 	$16, 	 %rax
	mov     %ax,	 idt + 6
	shr	$16,     %rax
	mov	%rax,	 idt + 8
	ret
	.endfunc

isr0:
	pushq 	%rax
	pushq	%rcx
	pushq	%rdx
	pushq 	%r8
	pushq	%r9
	pushq	%r10
	pushq	%r11
	cld
	call	exc0_handler
	popq	%r11
	popq	%r10
	popq	%r9
	popq	%r8
	popq	%rdx
	popq	%rcx
	popq	%rax
	iretq
	
