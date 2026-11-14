BITS 16
ORG 0x8200

switch_to_32:
    cli

    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:protected_mode

BITS 32

protected_mode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x90000

    ; Copy the 16 KiB kernel to its linked address
    cld
    mov esi, 0x10000
    mov edi, 0x100000
    mov ecx, 4096
    rep movsd

    ; Jump to kernel entry
    jmp 0x08:0x100000

align 8

gdt_start:
    dq 0x0000000000000000
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

times 512 - ($ - $$) db 0