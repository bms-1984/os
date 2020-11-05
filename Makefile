-include $(DEPFILES) $(TSTDEPFILES)

WARNINGS     	:= -Wall -Wextra -pedantic -Wshadow -Wpointer-arith -Wcast-align \
	           -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations   \
                   -Wredundant-decls -Wnested-externs -Winline -Wno-long-long    \
                   -Wconversion -Wstrict-prototypes

VERSION		:= 0.1.0

ARCH		?= x86_64
KERNELFILE	:= os.$(ARCH).elf
ARCHDIR		:= kernel/arch/$(ARCH)

IMGFILE   	:= os.$(ARCH)-$(VERSION).img
DISTFILE	:= os-$(VERSION).tar.gz
TXTFILE		:= $(KERNELFILE:.elf=.txt)

LDFLAGS         := -T $(ARCHDIR)/linker.ld -nostdlib -nostartfiles
CFLAGS       	:= $(WARNINGS) -fpic -ffreestanding -nostdlib -Ikernel/include -g -mno-red-zone 

OVMF            ?= /usr/share/ovmf/x64/OVMF.fd
CC		:= $(ARCH)-elf-gcc
LD		:= $(ARCH)-elf-ld
STRIP		:= $(ARCH)-elf-strip
READELF		:= $(ARCH)-elf-readelf

AUXFILES	:= Makefile config.in mkbootimg.json
PROJDIRS	:= kernel
FONTFILES	:= $(shell find $(PROJDIRS) -type f -name "*.psf")
SRCFILES	:= $(shell find $(PROJDIRS) -type f -name "*.c")
HDRFILES	:= $(shell find $(PROJDIRS) -type f -name "*.h")
OBJFILES	:= $(SRCFILES:.c=.o) $(FONTFILES:.psf=.o)
TESTFILES	:= $(SRCFILES:.c=_t)
DEPFILES	:= $(SRCFILES:.c=.d)
TESTDEPFILES	:= $(TESTFILES:%=%.d)
ALLFILES     	:= $(SRCFILES) $(HDRFILES) $(AUXFILES) $(FONTFILES)
TMPDIR		:= tmp
CLEANFILES	:= $(OBJFILES) $(DEPFILES) $(TESTDEPFILES) $(KERNELFILE) $(IMGFILE) $(DISTFILE) $(TXTFILE) $(TMPDIR)

.PHONY: all clean dist run debug run_noefi debug_noefi

all: $(IMGFILE) Makefile

$(KERNELFILE): $(OBJFILES)
	@$(LD) $(LDFLAGS) $^ -o $@
	@$(STRIP) -s -K mmio -K fb -K bootboot -K environment $@
	@$(READELF) -hls $@ > $(KERNELFILE:.elf=.txt)

kernel/font.o: $(FONTFILES)
	@$(LD) -r -b binary -o $@ $^

.o.c:
	@$(CC) $(CFLAGS) -MMD -MP -c $^ -o $@

$(IMGFILE): $(KERNELFILE)
	@mkbootimg check $^
	@mkdir -p $(TMPDIR)/sys
	@cp $^ $(TMPDIR)/sys/core
	@cd $(TMPDIR)
	@cp config.in $(TMPDIR)/sys/config
	@mkbootimg mkbootimg.json $@
	@echo Done.

clean:
	-@$(RM) -rf $(wildcard $(CLEANFILES))
	@echo All clean!

dist:
	@tar cJvf $(DISTFILE) $(ALLFILES)

debug: $(IMGFILE) Makefile $(OVMF)
	@qemu-system-$(ARCH) -bios $(OVMF) -s -S -m 1024 -drive file=$<,format=raw

run: $(IMGFILE) Makefile $(OVMF)
	@qemu-system-$(ARCH) -bios $(OVMF) -m 1024 -drive file=$<,format=raw

debug_noefi: $(IMGFILE) Makefile
	@qemu-system-$(ARCH) -s -S -m 1024 -drive file=$<,format=raw

run_noefi: $(IMGFILE) Makefile
	@qemu-system-$(ARCH) -m 1024 -drive file=$<,format=raw
