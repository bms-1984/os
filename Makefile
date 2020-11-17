# makefile
# Written by Ben M. Sutter
# Available since version 0.1.0
# Last edited 11/17/2020

WARNINGS     	?= -Wall -pedantic

VERSION		:= 0.1.0
NAME		:= os

ARCH		?= x86_64
KERNELFILE	:= $(NAME).$(ARCH).elf
ARCHDIR		:= kernel/arch/$(ARCH)

IMGFILE   	:= $(NAME).$(ARCH)-$(VERSION).img
DISTFILE	:= $(NAME)-$(VERSION).tar.xz
TXTFILE		:= $(KERNELFILE:.elf=.txt)

LDFLAGS         := -T $(ARCHDIR)/linker.ld -nostdlib -nostartfiles
LIBS		:= -lgcc
DEBUG		?= -g
CFLAGS       	:= $(WARNINGS) -fpic -ffreestanding -nostdlib -Ikernel/include -mno-red-zone $(DEBUG) -mno-sse -mno-sse2 -mno-mmx
QEMUFLAGS	:= -m 1024 -enable-kvm

OVMF            ?= /usr/share/ovmf/x64/OVMF.fd
CC		:= $(ARCH)-elf-gcc
LD		:= $(ARCH)-elf-ld
STRIP		:= $(ARCH)-elf-strip
READELF		:= $(ARCH)-elf-readelf

AUXFILES	:= Makefile config.in mkbootimg.json
PROJDIRS	:= kernel
FONTFILES	:= $(shell find $(PROJDIRS) -type f -name "*.psf")
SRCFILES	:= $(shell find $(PROJDIRS) -type f -name "*.c")
ASRCFILES	:= $(shell find $(PROJDIRS) -type f -name "*.S")
HDRFILES	:= $(shell find $(PROJDIRS) -type f -name "*.h")
OBJFILES	:= $(SRCFILES:.c=.o) $(FONTFILES:.psf=.o) $(ASRCFILES:.S=.o)
DEPFILES	:= $(SRCFILES:.c=.d) $(ASRCFILES:.S=.d)
ALLFILES     	:= $(SRCFILES) $(HDRFILES) $(AUXFILES) $(FONTFILES) $(ASRCFILES)
TMPDIR		:= tmp
CLEANFILES	:= $(OBJFILES) $(DEPFILES) $(KERNELFILE) $(IMGFILE) \
			$(DISTFILE) $(TXTFILE) $(TMPDIR) $(shell find . -type f -name "*~")

-include $(DEPFILES)

.PHONY: all clean dist run debug run_noefi debug_noefi

all: $(IMGFILE) Makefile

$(KERNELFILE): $(OBJFILES)
	@$(LD) $(LDFLAGS) $^ -o $@
	@$(STRIP) -s -K mmio -K fb -K bootboot -K environment $@
	@$(READELF) -hls $@ > $(TXTFILE)

kernel/font.o: $(FONTFILES)
	@$(LD) -r -b binary -o $@ $^

%.o: %.c
	@$(CC) $(CFLAGS) -MMD -MP -c $^ -o $@ $(LIBS)

%.o: %.S
	@$(CC) $(CFLAGS) -MMD -MP -c $^ -o $@ $(LIBS)

$(IMGFILE): $(KERNELFILE)
	@mkbootimg check $^
	@mkdir -p $(TMPDIR)/sys
	@cp $^ $(TMPDIR)/sys/core
	@cd $(TMPDIR)
	@cp config.in $(TMPDIR)/sys/config
	@mkbootimg mkbootimg.json $@
	$(info All done!)

clean:
	-@$(RM) -rf $(wildcard $(CLEANFILES))
	$(info All clean!)

dist:
	@mkdir -p $(NAME)-$(VERSION)/kernel
	@cp -R $(wildcard $(AUXFILES)) $(NAME)-$(VERSION)
	@cp -R $(wildcard $(SRCFILES) $(FONTFILES) kernel/arch kernel/include) $(NAME)-$(VERSION)/kernel
	@tar cJf $(DISTFILE) $(NAME)-$(VERSION)
	@$(RM) -rf $(NAME)-$(VERSION)
	$(info All packed!)

debug: $(IMGFILE) Makefile $(OVMF)
	@qemu-system-$(ARCH) -bios $(OVMF) -s -S $(QEMUFLAGS)  -drive file=$<,format=raw

run: $(IMGFILE) Makefile $(OVMF)
	@qemu-system-$(ARCH) -bios $(OVMF) $(QEMUFLAGS) -drive file=$<,format=raw

debug_noefi: $(IMGFILE) Makefile
	@qemu-system-$(ARCH) -s -S $(QEMUFLAGS) -drive file=$<,format=raw

run_noefi: $(IMGFILE) Makefile
	@qemu-system-$(ARCH) $(QEMUFLAGS) -drive file=$<,format=raw
