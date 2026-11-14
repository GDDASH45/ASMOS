BITS 16
ORG 0x8000

stage2_start:
    cli

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9000

    ; Save BIOS boot drive
    mov [boot_drive], dl

    sti
    cld

    mov si, stage2_message
    call print

    ; Reset floppy disk
    mov dl, [boot_drive]
    xor ah, ah
    int 0x13
    jc disk_error

    ; Read first 18 kernel sectors
    ; Destination: 0x1000:0000 (physical 0x10000)
    mov ax, 0x1000
    mov es, ax
    xor bx, bx

    mov ah, 0x02
    mov al, 18
    mov ch, 0
    mov cl, 4
    mov dh, 0
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

    ; Read remaining 14 kernel sectors
    ; Destination: 0x1000:2400 (physical 0x12400)
    mov ax, 0x1000
    mov es, ax
    mov bx, 18 * 512

    mov ah, 0x02
    mov al, 14
    mov ch, 0
    mov cl, 1
    mov dh, 1
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

    ; Enable A20
    in al, 0x92
    or al, 0x02
    and al, 0xFE
    out 0x92, al

    mov si, kernel_loaded_message
    call print

    ; Enter protected-mode switch at physical 0x8200
    jmp 0x0000:0x8200

disk_error:
    ; Preserve BIOS error status
    mov [disk_status], ah

    mov si, error_message
    call print

    mov al, [disk_status]
    call print_hex

    mov si, newline
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

print_hex:
    push ax
    push bx

    mov bl, al

    shr al, 4
    call print_digit

    mov al, bl
    and al, 0x0F
    call print_digit

    pop bx
    pop ax
    ret

print_digit:
    cmp al, 9
    jbe .number

    add al, 'A' - 10
    jmp .output

.number:
    add al, '0'

.output:
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    ret

boot_drive db 0
disk_status db 0

stage2_message db 'ASMOS: Stage 2 loaded.', 13, 10, 0
kernel_loaded_message db 'ASMOS: Kernel loaded.', 13, 10, 0
error_message db 'ASMOS: Kernel disk read failed! Status: ', 0
newline db 13, 10, 0

times 512 - ($ - $$) db 0