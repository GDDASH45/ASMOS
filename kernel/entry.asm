BITS 32

global _start

section .text

_start:
    cli
    cld

    ; VGA text-mode memory
    mov edi, 0xB8000

    ; Clear the 80x25 screen
    mov ecx, 80 * 25
    mov ax, 0x0F20

.clear:
    mov [edi], ax
    add edi, 2
    loop .clear

    ; Print kernel message
    mov esi, kernel_message
    mov edi, 0xB8000

.print:
    lodsb
    test al, al
    jz .halt

    ; Character
    mov [edi], al

    ; White foreground, black background
    mov byte [edi + 1], 0x0F

    add edi, 2
    jmp .print

.halt:
    cli
    hlt
    jmp .halt

section .rodata

kernel_message db 'Hello from the ASMOS kernel!', 0