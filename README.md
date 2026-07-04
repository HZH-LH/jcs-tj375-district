# TJ375 Single-Channel Vision and RISC-V Project

This repository is a versioned, deployable snapshot of the TJ375 single-channel CSI camera, MIPI DSI display, and hardened RISC-V integration project. It contains the Efinity project, RTL, generated IP configuration, RISC-V sources and build outputs, and final FPGA programming files.

## Final Design Goal

The display path and the RISC-V processing path must be operationally independent. A failure or stall in either path must not stop the other path.

Target architecture:

```text
CSI camera
  -> CSI receiver
  -> BRAM line buffer / elastic FIFO
  -> Debayer
  -> green-channel correction
  -> brightness enhancement
  -> MIPI DSI display

Stable video-stream tap
  -> 160x90 RGB565 downscaler
  -> dual-port BRAM
  -> RISC-V AXI Master 0
  -> RISC-V copies the small image to its DDR region
  -> CNN processing
```

Design rules:

- The display path must not depend on RISC-V software, RISC-V DDR traffic, or the small-image path.
- The FPGA display path should not use the shared DDR controller in the final architecture.
- RISC-V may use DDR for software, model weights, working memory, and CNN input.
- The FPGA-to-RISC-V exchange boundary is dual-port BRAM, not the video framebuffer DDR.
- The small-image module is a passive stream consumer and must never backpressure the display path.
- Only one camera and one DSI display channel are required.

## Current Implemented Architecture

The current revision still uses the original DDR framebuffer path:

```text
CSI RX
  -> raw video stream
  -> triple-buffer framebuffer in LPDDR4
  -> Debayer
  -> color/brightness processing
  -> DSI TX
```

Relevant parameters in `src/top.v`:

- Resolution: 1920x1080
- Stored pixel width: 16 bits
- Frame buffers: 3
- Minimum storage per frame: approximately 4.15 MB
- Triple-buffer storage per active channel: approximately 12.44 MB

A complete 1080p framebuffer cannot be moved directly into on-chip BRAM. The final display path must use camera-synchronous streaming plus a small BRAM line buffer instead of a BRAM full-frame buffer.

## Verified Hardware Results

The following behavior has been reproduced on hardware:

- CSI RX produces active synchronization and changing non-zero raw pixel data.
- The LPDDR4 framebuffer and Debayer produce valid non-zero pixels while the hardened RISC-V is held in reset.
- The MIPI DSI physical layer, panel initialization, lane output, and display timing are functional.
- The screen displays the live camera image correctly while RISC-V reset is asserted.
- Green correction and brightness enhancement match the reference `2ChMIPICSI_2ChMIPIDSI_Demo_Test` parameters:
  - Green channel scale: 62.5 percent (`G - G/4 - G/8`)
  - RGB brightness scale: 200 percent
  - Values saturate at 255
- FPGA DDR AXI diagnostics are healthy while RISC-V is reset: `ax=11111 er=00 rn=1`.
- Releasing the hardened RISC-V immediately stops the DDR-backed display path.
- Delaying RISC-V release until five seconds after video startup does not solve the issue.
- Embedding a 784-byte UART heartbeat program entirely in the 16 KB On-Chip RAM does not solve the issue.

This proves that the failure is not caused only by RISC-V software being linked into DDR. Releasing the Hard SoC activates its fixed external-memory/DDR Target1 path, which interferes with the FPGA video framebuffer on DDR AXI0 in the current integration.

## Current Diagnostic Behavior

`src/top.v` currently:

- Waits for DDR configuration and both DSI `pixel_data_en` signals.
- Holds RISC-V in reset for another five seconds.
- Releases RISC-V and reports the release state as `rr=1` on the diagnostic UART.
- Uses the corrected camera RGB stream as the fixed DSI source (`md=C`).

Expected behavior of the committed bitstream:

1. The camera image appears while `rr=0`.
2. Approximately five seconds later `rr` changes to `1`.
3. The screen stops updating or becomes blank because the shared DDR path stalls.

This bitstream is intentionally preserved as the reproducible diagnostic baseline for the DDR conflict.

## Next Modification Direction

Do not continue trying to make the display and Hard SoC share the same DDR framebuffer path. The next implementation should remove DDR only from the display path while retaining the known-good CSI, Debayer, color processing, and DSI modules.

Recommended implementation sequence:

1. Restore a stable test baseline by holding RISC-V in reset during video-path development.
2. Add a build-time option that bypasses `frame_buffer`, the video AXI interconnect, and FPGA DDR AXI0 for the active display channel.
3. Connect the CSI stream to Debayer and DSI using the camera stream synchronization (`vs/hs/de`) and the existing processing clock.
4. Verify direct CSI-to-DSI display with no DDR transactions from the FPGA.
5. If direct streaming shows phase jitter or short underflow, insert a 4-to-8-line BRAM elastic FIFO.
6. Add FIFO occupancy, overflow, and underflow counters. Recover only at a frame boundary; never emit a partially shifted frame.
7. Release RISC-V and verify that video remains stable while RISC-V uses DDR.
8. Connect RISC-V AXI Master 0 to a dedicated dual-port BRAM window.
9. Add the 160x90 RGB565 downscaler as a passive tap from the stable display stream.
10. Use ping-pong or triple small-image buffers in BRAM, publish only complete frames, and expose frame sequence/status registers.
11. Let RISC-V copy the latest complete BRAM image into DDR before running CNN inference.

If camera and DSI timing cannot remain stable with line buffering, the fallback is to reduce the buffered display resolution. Do not attempt to store a full 1080p frame in BRAM, and do not route the FPGA small-image writer back through the conflicting DDR AXI0 path.

## UART Notes

- FPGA diagnostic UART: 1 Mbps, currently mirrored to the project `uart1_txd` and `uart2_txd` outputs.
- RISC-V UART0 firmware: 115200 baud.
- Current RISC-V UART0 assignment in `mem_test.peri.xml` is TX package pin E9 and RX package pin E10.
- The official Ti375C529 devkit example uses the opposite UART direction assignment. Confirm the board schematic before relying on UART0 output; do not guess or swap pins without verification.

## Programming and Test Procedure

Always program this project through JTAG. Never use SPI programming.

Deployable artifacts:

- FPGA bitstream: `outflow/mem_test.bit`
- FPGA programming image: `outflow/mem_test.hex`
- OCR RISC-V firmware: `embedded_sw/efx_hard_soc/software/standalone/uart/ocrUartHeartbeat/build/`

Basic hardware test:

1. Generate the Efinity IP only when IP settings have changed.
2. Build the FPGA project and confirm that `outflow/mem_test.bit` is updated.
3. Program `mem_test.bit` through JTAG.
4. Monitor the FPGA diagnostic UART at 1 Mbps.
5. Confirm live video and healthy AXI status before RISC-V release.
6. Record the exact screen and UART transition when `rr` changes.

RISC-V build outputs (`.elf`, `.hex`, `.bin`, `.map`) and final FPGA images are committed intentionally. A checked-out revision must retain the exact artifacts used for that hardware test.

## Reference Projects

- `video_primary`: known-good original video/DDR/DSI reference.
- `capture` and `2ChMIPICSI_2ChMIPIDSI_Demo_Test`: reference for CSI/DSI behavior and color/brightness parameters.
- Efinity `Ti375C529_devkit` Hard SoC example: reference for QCRV32 clocks, reset, OCR firmware, and UART configuration.

When comparing against references, copy the working video structure exactly unless a documented resource conflict requires adaptation. Do not optimize or rename unrelated logic during display-path recovery.
