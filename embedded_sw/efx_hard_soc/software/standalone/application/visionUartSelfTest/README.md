# Vision UART Self Test

This standalone program is used to prove that the hard RISC-V subsystem can run
independently from the video DDR/display path.

## What It Uses

- CPU: hard Sapphire/QCRV32, hart 0 only.
- Memory: SoC internal RAM at `0xF9000000`, size `0x4000`.
- Peripheral: UART0 only.
- UART setting: `115200 8N1`.

It does not touch video DDR, the framebuffer, interrupts, APB video registers, or
the future small-image BRAM path.

## Build

Run from this directory:

```powershell
$env:Path='D:\Efinity\efinity-riscv-ide-2025.2\toolchain\bin;D:\Efinity\efinity-riscv-ide-2025.2\build_tools\bin;' + $env:Path
& 'D:\Efinity\efinity-riscv-ide-2025.2\build_tools\bin\make.exe' BSP=efinix/EfxSapphireSoc
```

Important output files:

- `build/visionUartSelfTest.elf`
- `build/visionUartSelfTest.bin`
- `build/visionUartSelfTest.hex`
- `build/visionUartSelfTest.map`

The ELF is linked by `default_i.ld`, so its load address is the SoC internal RAM.

## Expected UART Output

After the program is loaded and executed, the terminal should repeatedly show:

```text
Vision hard RISC-V UART self-test
Build: internal RAM, UART0 only
UART base: 0xE8010000
Internal RAM base: 0xF9000000, size: 0x00004000
mhartid: 0
Expected serial: 115200 8N1
[alive] count=0 mcycle=0x...
[alive] count=1 mcycle=0x...
```

If the video display remains correct while this heartbeat prints, the video path
and hard RISC-V path are sufficiently independent for the next BRAM-window step.
