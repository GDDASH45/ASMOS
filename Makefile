NASM := nasm
LD := ld
OBJCOPY := objcopy

NASMFLAGS := -f elf32
LDFLAGS := -m elf_i386 -T kernel/linker.ld

BUILD := build

BOOT_SRC := $(shell find boot -type f -name '*.asm')
KERNEL_SRC := $(shell find kernel -type f -name '*.asm')

BOOT_BIN := $(patsubst boot/%.asm,$(BUILD)/boot/%.bin,$(BOOT_SRC))
KERNEL_OBJ := $(patsubst kernel/%.asm,$(BUILD)/kernel/%.o,$(KERNEL_SRC))

.PHONY: all clean

all: $(BUILD)/os.bin

# Bootloader: flat binary
$(BUILD)/boot/%.bin: boot/%.asm
	@mkdir -p $(dir $@)
	@echo " NASM    $@"
	@$(NASM) -f bin $< -o $@

# Kernel: ELF32 objects
$(BUILD)/kernel/%.o: kernel/%.asm
	@mkdir -p $(dir $@)
	@echo " NASM    $@"
	@$(NASM) $(NASMFLAGS) $< -o $@

# Link kernel into ELF32
$(BUILD)/kernel.elf: $(KERNEL_OBJ)
	@echo " LD      $@"
	@$(LD) $(LDFLAGS) -o $@ $^

# Convert ELF32 kernel into flat binary
$(BUILD)/kernel.bin: $(BUILD)/kernel.elf
	@echo " OBJCOPY $@"
	@$(OBJCOPY) -O binary $< $@

# Final OS image
$(BUILD)/os.bin: $(BOOT_BIN) $(BUILD)/kernel.bin
	@cat $(BOOT_BIN) $(BUILD)/kernel.bin > $@

clean:
	@rm -rf $(BUILD)
