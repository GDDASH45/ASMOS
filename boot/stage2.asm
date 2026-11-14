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

    mov [boot_drive], dl

    mov si, stage2_message
    call print

    ; Read the kernel using BIOS LBA extensions
    mov si, disk_packet
    mov dl, [boot_drive]
    mov ah, 0x42
    int 0x13

    jc disk_error

    ; Enable the A20 line
    in al, 0x92
    or al, 0x02
    and al, 0xFE
    out 0x92, al

    ; Enter the protected-mode switch
    jmp 0x0000:0x8200

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

stage2_message db 'ASMOS: Loading kernel...', 13, 10, 0
error_message db 'ASMOS: Kernel disk read failed!', 13, 10, 0

align 4
disk_packet:
    db 0x10
    db 0
    dw 32
    dw 0x0000
    dw 0x1000
    dq 3

times 512 - ($ - $$) db 0