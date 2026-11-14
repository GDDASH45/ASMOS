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

    ; Print loading message
    mov si, loading_message
    call print

    ; Reset disk
    xor ah, ah
    mov dl, [boot_drive]
    int 0x13

    ; Load stage 2 from sector 2
    mov ax, 0x0000
    mov es, ax
    mov bx, 0x8000

    mov ah, 0x02        ; BIOS read sectors
    mov al, 1           ; Read one sector
    mov ch, 0           ; Cylinder 0
    mov cl, 2           ; Sector 2
    mov dh, 0           ; Head 0
    mov dl, [boot_drive]
    int 0x13

    jc disk_error

    ; Jump to stage 2
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

loading_message db 'ASMOS: Loading stage 2...', 13, 10, 0
error_message db 'ASMOS: Disk read error!', 13, 10, 0

times 510 - ($ - $$) db 0
dw 0xAA55
