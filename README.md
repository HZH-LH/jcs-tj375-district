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

The source now defaults to the experimental BRAM double-buffer path:

```text
CSI RX (4 x RAW8 per cycle)
  -> marker-aware RAW BRAM FIFO
  -> 32-to-16-bit burst serializer (2 x RAW8 per cycle)
  -> Debayer
  -> color/brightness processing
  -> 2x spatial downsample
  -> 960x540 RGB565 BRAM ping-pong buffers
  -> exact 2x nearest-neighbor display expansion
  -> DSI TX
```

`BRAM_VIDEO_PATH` is enabled in `src/top.v`. In this mode the two FPGA
framebuffer AXI masters and their AXI interconnect are not instantiated, and
the FPGA DDR AXI0 outputs are held idle. The Hard SoC may still initialize and
use DDR through its fixed interface.

The previous DDR framebuffer path remains available as a compile-time
reference by disabling `BRAM_VIDEO_PATH` and enabling `FRAME_BUFFER`:

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

The RAW FIFO stores 32 KiB and preserves frame/line markers. The two RGB565
frame banks consume approximately 16.59 Mbit. TJ375 provides 27.53 Mbit of
embedded RAM, leaving the remaining RAM for CSI/DSI IP and Debayer line
buffers. All new memories are explicitly marked `syn_ramstyle="block_ram"`.

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

The BRAM test build reports these additional UART fields:

- `q=XXXX`: RAW serializer FIFO occupancy.
- `ba=X`: at least one complete RGB565 frame is available for display.
- `be=OU`: RAW FIFO overflow and frame-capture error flags.
- `oc`: RAW FIFO overflow count.
- `uc`: skipped or incomplete capture-frame count.
- `rc`: completed display-bank swap count.
- `fi/fo`: complete captured-frame and DSI timing-frame counters.
- `ax=00000`: expected in BRAM mode; any `1` means FPGA DDR traffic remains.
- `rr=X`: hardened RISC-V reset release state.
- `gm=LLLL/MMMM/XXXX/TTTTT`: measured camera-side geometry for the last
  complete input frame: active-line count, minimum DE clocks per line,
  maximum DE clocks per line, and total DE clocks. For the assumed 1920x1080
  two-pixels-per-clock stream, the expected value is
  `gm=0438/03C0/03C0/FD200`.

UART2 also accepts single-character commands at 1 Mbps without rebuilding:

- `C`: BRAM double-buffer camera display (default).
- `B`: internal color bars.
- `W`: full white.
- `D`: Debayer `DE` mask.
- `R`: direct CSI RAW diagnostic view.
- `F`: serialized RAW diagnostic view.
- `T`: autonomous deterministic RGB565 BRAM fill/read test. It ignores CSI
  frame markers and camera pixels, fills one complete 960x540 bank with
  sequential addresses, freezes the write port, then swaps at a DSI frame
  boundary.

## Mandatory Evidence-Driven Debugging

All hardware debugging in this project must follow an evidence-first process.
A visible symptom such as a black screen, stripes, noise, or a frozen image is
not a root cause. Do not modify reset logic, clocks, pixel ordering, buffering,
or interfaces based only on the appearance of the screen.

The required workflow for every fault is:

1. State the competing hypotheses before editing functional RTL.
2. Identify UART fields or selectable display modes that produce different
   results for those hypotheses.
3. If the current bitstream cannot distinguish them, modify only diagnostic
   instrumentation and build one diagnostic bitstream.
4. Record the diagnostic version, selected mode, screen result, and at least
   ten consecutive UART lines. For timing or reset faults, the capture must
   span the relevant transition such as `rr=0` to `rr=1`.
5. Use the evidence to eliminate hypotheses explicitly.
6. Modify functional RTL only when the evidence identifies one specific stage
   or one testable cause.
7. After the fix, repeat the same diagnostic test and compare counters against
   the pre-fix result.
8. Commit only after synthesis succeeds and the intended hardware behavior is
   verified.

Strict prohibitions:

- Do not guess a root cause from screen appearance alone.
- Do not make several unrelated functional changes in one diagnostic build.
- Do not change known-good DSI timing, PLL routing, reset polarity, or camera
  configuration unless a direct measurement implicates that subsystem.
- Do not treat sticky `seen` bits as proof of correct frame dimensions, rate,
  ordering, or data integrity.
- Do not call a fault fixed because a test pattern works; use the test pattern
  only to establish which downstream stages are healthy.
- If evidence still supports multiple causes, the next change must improve
  observability rather than alter the video path.

Each debug handoff must include this compact evidence record:

```text
Diagnostic version:
Hardware/bitstream:
Observed symptom:
Hypotheses under test:
UART fields and display modes used:
Measured result:
Causes eliminated:
Single remaining cause, or next instrumentation required:
```

Current stage-isolation meanings:

- `B` or `W` correct proves panel initialization, DSI packetization, lane
  output, and fixed display timing are operational.
- `ax=00000` before and after `rr=1` proves the FPGA video path is not issuing
  DDR AXI0 transactions; unchanged behavior across `rr` isolates RISC-V from
  the current display fault.
- Bounded `q` with `oc=0000` proves the RAW FIFO is not overflowing, but does
  not prove frame and line markers are correct.
- `T` uses an autonomous sequential writer and does not consume CSI `VS/DE`,
  camera pixels, or camera-derived write coordinates. After one complete bank
  is written, its write port remains idle; the bank is swapped only at a DSI
  frame boundary and then passes through the same BRAM read and 2x expansion
  path as `C`. A clean `T` with a corrupt `C` isolates the fault to the camera
  capture/downsample/write-control side. A corrupt, unstable `T` isolates the
  fault to BRAM storage, bank selection, read addressing, or output alignment.
- Hardware diagnostic `v6` produced a stable autonomous `T` image with three
  clean vertical color regions and regular horizontal intensity bands. This
  eliminates the frozen-frame BRAM storage/read/display path from the current
  camera-display fault. Diagnostic `v7` therefore measures the camera-side
  frame geometry before any functional capture change is allowed.
- Diagnostic `v7` measured a constant `FD200` valid words per frame, exactly
  `960 * 1080`, while individual `rgb_de` high bursts were only `0002` through
  `001A` clocks and about `D2AA` bursts occurred per frame. Therefore
  `rgb_de` gaps are not physical line boundaries. The BRAM writer must count
  960 valid words per logical line and must never increment the line number on
  every `rgb_de` falling edge.
- Diagnostic `v8` applies only that evidence-backed correction to the camera
  BRAM writer. Re-test `C`, `T`, and the `gm` field before any further video
  change.
- Diagnostic `v8` restored recognizable camera geometry but retained regular
  colored vertical striping. Inspection then found that
  `raw_burst_serializer` marked every rising edge of bursty CSI `rx_out_de` as
  a physical line start. Those false markers make the Debayer line buffer
  restart on every short burst. Diagnostic `v9` marks a line only after each
  480 valid RAW4 input words, producing 960 RAW2 words per 1920-pixel line.
- Diagnostic `v9` reduced false line segmentation to exactly 32 DE bursts per
  physical line (`8700 = 1080 * 32`) but did not eliminate it. The FIFO level
  repeatedly reached zero because output began before a complete line was
  buffered. Diagnostic `vA` (version 10) waits for all 480 RAW4 words at the
  first line and for the remaining 479 words at every held line marker, then
  emits 960 RAW2 words continuously to the Debayer.
- Diagnostic `vB` (version 11) adds one-build color mapping isolation. UART
  commands `0` through `5` select the map and return to camera mode: `0` raw
  Debayer with no top-level correction/brightness, `1` current capture/Demo
  processing, `2` swap R/B, `3` swap R/G, `4` swap G/B, and `5` map RGB to
  GBR. The UART `cm=X` field records the active selection. Compare the same
  red, green, blue, white, yellow, and black references in every mode before
  choosing a permanent map.
- `R` and `F` do not use panel-compatible frame timing. A black result in these
  modes does not prove CSI or RAW serialization has failed; rely on their UART
  activity fields for those stages.

The display uses the original known-good 1920x1080 DSI timing. Each stored
960x540 pixel is repeated as a 2x2 block. This does not restore discarded
detail; effective image resolution is 960x540. Ping-pong buffering lets the
30 fps camera update one bank while the 60 fps display repeatedly reads the
other bank, without using external DDR.

Expected first BRAM-path hardware test:

1. `q` remains bounded, a complete frame is captured, and `ba` changes to `1`.
2. Approximately five seconds later `rr` changes from `0` to `1`.
3. `ax` remains `00000` and video remains active after RISC-V release.
4. Stable operation has `be=00`, `oc=uc=0000`, and `rc` increasing near 30/s.
5. `fi` should increase near 30/s and `fo` near 59/s.

This BRAM path is not yet hardware-verified. The previous committed revision
`8a6b93a` is the reproducible DDR-conflict baseline.

## Next Modification Direction

Do not continue trying to make the display and Hard SoC share the same DDR framebuffer path. The next implementation should remove DDR only from the display path while retaining the known-good CSI, Debayer, color processing, and DSI modules.

Recommended implementation sequence:

1. Build and test UART diagnostic version `v6` without changing IP or
   Interface Designer.
2. Confirm `B` and `W` still display correctly, then compare `T` with `C`.
3. Record at least ten consecutive UART lines spanning the `rr=0` to `rr=1`
   transition, plus the screen behavior.
4. A healthy capture has bounded `q`, `ba=1`, `be=00`, `oc=uc=0000`, `fi`
   increasing near 30/s, `fo` near 59/s, and `rc` near 30/s.
5. If `ba` remains zero, inspect `fi/uc`. If `ba=1` but C is corrupt, compare
   `T` with `C` to isolate camera-derived writes from the BRAM display path.
6. After stable video survives RISC-V release, connect RISC-V AXI Master 0 to
   a dedicated dual-port BRAM window.
7. Add the 160x90 RGB565 downscaler as a passive tap from the stable display stream.
8. Use ping-pong or triple small-image buffers in BRAM, publish only complete
   frames, and expose frame sequence/status registers.
9. Let RISC-V copy the latest complete BRAM image into DDR before running CNN inference.

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
