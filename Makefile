-include $(DEPFILES) $(TSTDEPFILES)

WARNINGS     	:= -Wall -Wextra -pedantic -Wshadow -Wpointer-arith -Wcast-align \
	           -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations   \
                   -Wredundant-decls -Wnested-externs -Winline -Wno-long-long    \
                   -Wconversion -Wstrict-prototypes

VERSION		:= 0.1.0
IMGFILE   	:= os-$(VERSION).img

ARCH		?= x86_64
KERNELFILE	:= os.$(ARCH).elf
ARCHDIR		:= kernel/arch/$(ARCH)

LDFLAGS         := -T $(ARCHDIR)/linker.ld -nostdlib
CFLAGS       	:= $(WARNINGS) -fpic -ffreestanding -nostdlib -Ikernel/include -g -mno-red-zone 

OVMF            ?= /usr/share/ovmf/OVMF.fd
CC		:= $(ARCH)-elf-gcc
LD		:= $(ARCH)-elf-ld
STRIP		:= $(ARCH)-elf-strip
READELF		:= $(ARCH)-elf-readelf

AUXFILES	:= Makefile bios.bin
PROJDIRS	:= kernel
SRCFILES	:= $(shell find $(PROJDIRS) -type f -name "\*.c")
HDRFILES	:= $(shell find $(PROJDIRS) -type f -name "\*.h")
OBJFILES	:= $(SRCFILES:.c=.o)
TESTFILES	:= $(SRCFILES:.c=_t)
DEPFILES	:= $(SRCFILES:.c=.d)
TESTDEPFILES	:= $(TESTFILES:%=%.d)
ALLFILES     	:= $(SRCFILES) $(HDRFILES) $(AUXFILES) kernel/font.psf

.PHONY: all clean dist run debug run_noefi debug_noefi

all: $(IMGFILE) Makefile

$(KERNELFILE): $(OBJFILES) kernel/font.o
	@$(LD) $(LDFLAGS) $^ -o $@
	@$(STRIP) -s -K mmio -K fb -K bootboot -K environment $@
	@$(READELF) -hls $@ > $(KERNELFILE:.elf=.txt)

kernel/font.o: kernel/font.psf
	@$(LD) -r -b binary -o $@ $^

.o.c:
	@$(CC) $(CFLAGS) -MMD -MP -c $^ -o $@

$(IMGFILE): $(KERNELFILE)
	@mkbootimg check $^
	@mkdir -p tmp/sys
	@cp $^ tmp/sys/core
	@cd tmp
	@cp config.in tmp/sys/config
	@mkbootimg mkbootimg.json $@
	@echo Done.

clean:
	-@$(RM) -rf $(wildcard $(OBJFILES) $(DEPFILES) $(TESTDEPFILES) $(KERNELFILE) $(IMGFILE) os-$(VERSION).tar.gz $(KERNELFILE:.elf=.txt) tmp kernel/font.o)
	@echo All clean!

dist:
	@tar cJvf os-$(VERSION).tar.gz $(ALLFILES)

debug: $(IMGFILE) Makefile $(OVMF)
	@qemu-system-$(ARCH) -bios $(OVMF) -s -S -m 1024 -drive file=$<,format=raw

run: $(IMGFILE) Makefile $(OVMF)
	@qemu-system-$(ARCH) -bios $(OVMF) -m 1024 -drive file=$<,format=raw

debug_noefi: $(IMGFILE) Makefile
	@qemu-system-$(ARCH) -s -S -m 1024 -drive file=$<,format=raw

run_noefi: $(IMGFILE) Makefile
	@qemu-system-$(ARCH) -m 1024 -drive file=$<,format=raw
