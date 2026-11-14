BITS 16
ORG 0x7C00

start:
    cli

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov [boot_drive], dl

    sti

    mov si, loading_message
    call print

    ; Load stage 2 and switch32 (sectors 2 and 3)
    xor ax, ax
    mov es, ax
    mov bx, 0x8000

    mov ah, 0x02
    mov al, 2
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [boot_drive]
    int 0x13

    jc disk_error

    mov dl, [boot_drive]
    jmp 0x0000:0x8000

disk_error:
    mov si, error_message
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

boot_drive db 0

loading_message db 'ASMOS: Loading boot stages...', 13, 10, 0
error_message db 'ASMOS: Disk read error!', 13, 10, 0

times 510 - ($ - $$) db 0
dw 0xAA55