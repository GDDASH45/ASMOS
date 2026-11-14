BITS 16
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov si, boot_message
    call print

halt:
    cli
    hlt
    jmp halt

print:
    lodsb
    test al, al
    jz .done

    mov ah, 0x0E
    mov bh, 0x00
    int 0x10

    jmp print

.done:
    ret

boot_message db 'ASMOS bootloader started!', 13, 10, 0

times 510 - ($ - $$) db 0
dw 0xAA55