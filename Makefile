NASM := nasm
LD := ld
OBJCOPY := objcopy

NASMFLAGS := -f elf32
LDFLAGS := -m elf_i386 -T kernel/linker.ld

BUILD := build

KERNEL_SRC := $(shell find kernel -type f -name '*.asm')
KERNEL_OBJ := $(patsubst kernel/%.asm,$(BUILD)/kernel/%.o,$(KERNEL_SRC))

.PHONY: all clean

all: $(BUILD)/os.bin

# Boot sector
$(BUILD)/boot/boot.bin: boot/boot.asm
	@mkdir -p $(dir $@)
	@echo " NASM    $@"
	@$(NASM) -f bin $< -o $@

# Stage 2
$(BUILD)/boot/stage2.bin: boot/stage2.asm
	@mkdir -p $(dir $@)
	@echo " NASM    $@"
	@$(NASM) -f bin $< -o $@

# Protected-mode switch
$(BUILD)/boot/switch32.bin: boot/switch32.asm
	@mkdir -p $(dir $@)
	@echo " NASM    $@"
	@$(NASM) -f bin $< -o $@

# Kernel ELF32 objects
$(BUILD)/kernel/%.o: kernel/%.asm
	@mkdir -p $(dir $@)
	@echo " NASM    $@"
	@$(NASM) $(NASMFLAGS) $< -o $@

# Link kernel
$(BUILD)/kernel.elf: $(KERNEL_OBJ) kernel/linker.ld
	@mkdir -p $(dir $@)
	@echo " LD      $@"
	@$(LD) $(LDFLAGS) -o $@ $(KERNEL_OBJ)

# Convert kernel to a fixed 16 KiB disk area
$(BUILD)/kernel.bin: $(BUILD)/kernel.elf
	@echo " OBJCOPY $@"
	@$(OBJCOPY) -O binary $< $@
	@test "$$(stat -c%s $@)" -le 16384 || \
		{ echo "ERROR: Kernel exceeds 16 KiB"; rm -f $@; exit 1; }
	@truncate -s 16384 $@

# Final disk image
$(BUILD)/os.bin: \
	$(BUILD)/boot/boot.bin \
	$(BUILD)/boot/stage2.bin \
	$(BUILD)/boot/switch32.bin \
	$(BUILD)/kernel.bin
	@echo " CAT     $@"
	@cat $^ > $@

clean:
	@rm -rf $(BUILD)