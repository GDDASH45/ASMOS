# ASMOS

**ASMOS** is an experimental operating system written in NASM assembly.

## Features

- NASM-based bootloader.
- ELF32 kernel.
- Flat binary bootloader (`.bin`).
- ELF32 kernel linking.
- `objcopy` kernel binary conversion.
- Makefile-based build system.
- Recursive assembly source discovery.

## Project Structure

```text
ASMOS/
├── Makefile
├── README.md
├── boot/
│   └── boot.asm
├── kernel/
│   ├── linker.ld
│   ├── entry.asm
│   └── main.asm
└── build/
```

## Requirements

- NASM
- GNU Make
- GNU Binutils (`ld`, `objcopy`)
- ELF32 support

## Building

Clone the repository and enter its directory.

Build ASMOS:

```bash
make
```

Clean generated files:

```bash
make clean
```

## Build Process

The Makefile performs these operations:

1. Discovers NASM source files inside `boot/`.
2. Compiles bootloader sources into flat `.bin` files.
3. Discovers NASM source files inside `kernel/`.
4. Compiles kernel sources into ELF32 object files.
5. Links kernel objects into `kernel.elf`.
6. Uses `objcopy` to convert `kernel.elf` into `kernel.bin`.
7. Combines the bootloader binaries and kernel binary into `os.bin`.

## Output

Generated files are stored in `build/`.

| File | Description |
|---|---|
| `boot/*.bin` | Bootloader binaries |
| `kernel/*.o` | ELF32 kernel objects |
| `kernel.elf` | Linked ELF32 kernel |
| `kernel.bin` | Flat kernel binary |
| `os.bin` | Combined OS image |

## License

ASMOS is licensed under the [MIT License](LICENSE).