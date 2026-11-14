BITS 16
ORG 0x8000

stage2_start:
    cli

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9000

    sti
    cld

    mov si, stage2_message
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
    mov bh, 0
    int 0x10

    jmp print

.done:
    ret

stage2_message db 'ASMOS stage 2 loaded!', 13, 10, 0
