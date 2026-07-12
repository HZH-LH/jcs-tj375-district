#!/usr/bin/env python3
import argparse
import csv
import json
import struct
import sys
import time
import zlib
from pathlib import Path

try:
    import serial
except ImportError as exc:
    raise SystemExit("pyserial is required: pip install pyserial") from exc


RISCV_MAGIC = b"VFRM"


def read_exact(port, count, deadline):
    data = bytearray()
    while len(data) < count:
        if time.monotonic() >= deadline:
            raise TimeoutError(f"timeout while reading {count} bytes")
        chunk = port.read(count - len(data))
        if chunk:
            data.extend(chunk)
    return bytes(data)


def wait_magic(port, magic, deadline):
    matched = 0
    while matched < len(magic):
        if time.monotonic() >= deadline:
            raise TimeoutError(f"timed out waiting for magic {magic!r}")
        data = port.read(1)
        if not data:
            continue
        value = data[0]
        if value == magic[matched]:
            matched += 1
        else:
            matched = 1 if value == magic[0] else 0


def checksum_riscv(payload):
    checksum = 0
    for offset in range(0, len(payload), 4):
        pixel0 = (payload[offset] << 8) | payload[offset + 1]
        pixel1 = (payload[offset + 2] << 8) | payload[offset + 3]
        word = pixel0 | (pixel1 << 16)
        checksum = (((checksum << 5) | (checksum >> 27)) & 0xFFFFFFFF) ^ word
    return checksum & 0xFFFFFFFF


def read_riscv_frame(port, timeout):
    deadline = time.monotonic() + timeout
    bad_frames = 0
    while True:
        wait_magic(port, RISCV_MAGIC, deadline)
        header = read_exact(port, 20, deadline)
        version = header[0]
        fmt = header[1]
        width, height = struct.unpack_from("<HH", header, 2)
        seq, payload_bytes, header_checksum = struct.unpack_from("<III", header, 6)
        bank = header[18]
        flags = header[19]

        if version != 1 or fmt != 1 or payload_bytes != width * height * 2:
            bad_frames += 1
            continue

        payload = read_exact(port, payload_bytes, deadline)
        footer = read_exact(port, 4, deadline)
        expected = struct.unpack("<I", footer)[0] if (flags & 1) else header_checksum
        actual = checksum_riscv(payload)
        if actual == expected:
            return {
                "sequence": seq,
                "bank": bank,
                "flags": flags,
                "width": width,
                "height": height,
                "payload": payload,
                "checksum": actual,
                "bad_frames": bad_frames,
            }
        bad_frames += 1


def clamp_byte(value):
    if value <= 0:
        return 0
    if value >= 255:
        return 255
    return int(round(value))


def rgb565_payload_to_rgb888(payload, swap_rb, red_scale, green_scale, blue_scale):
    rgb = bytearray((len(payload) // 2) * 3)
    out = 0
    for offset in range(0, len(payload), 2):
        pixel = (payload[offset] << 8) | payload[offset + 1]
        r5 = (pixel >> 11) & 0x1F
        g6 = (pixel >> 5) & 0x3F
        b5 = pixel & 0x1F
        r8 = (r5 << 3) | (r5 >> 2)
        g8 = (g6 << 2) | (g6 >> 4)
        b8 = (b5 << 3) | (b5 >> 2)
        if swap_rb:
            r8, b8 = b8, r8
        rgb[out] = clamp_byte(r8 * red_scale)
        rgb[out + 1] = clamp_byte(g8 * green_scale)
        rgb[out + 2] = clamp_byte(b8 * blue_scale)
        out += 3
    return bytes(rgb)


def png_chunk(chunk_type, data):
    return (
        struct.pack(">I", len(data)) +
        chunk_type +
        data +
        struct.pack(">I", zlib.crc32(chunk_type + data) & 0xFFFFFFFF)
    )


def write_png(path, width, height, rgb):
    if len(rgb) != width * height * 3:
        raise ValueError("RGB byte count does not match image dimensions")

    rows = bytearray()
    stride = width * 3
    for y in range(height):
        rows.append(0)  # PNG filter type 0
        start = y * stride
        rows.extend(rgb[start:start + stride])

    ihdr = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    data = (
        b"\x89PNG\r\n\x1a\n" +
        png_chunk(b"IHDR", ihdr) +
        png_chunk(b"IDAT", zlib.compress(bytes(rows), level=6)) +
        png_chunk(b"IEND", b"")
    )
    path.write_bytes(data)


def find_next_index(output_dir, prefix):
    max_index = -1
    for path in output_dir.glob(f"{prefix}_*.png"):
        stem = path.stem
        suffix = stem[len(prefix) + 1:]
        if suffix.isdigit():
            max_index = max(max_index, int(suffix))
    return max_index + 1


def append_manifest(manifest_path, row):
    exists = manifest_path.exists()
    with manifest_path.open("a", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "index", "filename", "timestamp", "uart_sequence", "bank",
                "width", "height", "checksum", "bad_frames"
            ],
        )
        if not exists:
            writer.writeheader()
        writer.writerow(row)


def save_frame(frame, output_dir, manifest_path, index, args):
    if frame["width"] != 160 or frame["height"] != 90:
        raise ValueError(f"expected 160x90, got {frame['width']}x{frame['height']}")

    rgb = rgb565_payload_to_rgb888(
        frame["payload"],
        swap_rb=not args.no_swap_rb,
        red_scale=args.red_scale,
        green_scale=args.green_scale,
        blue_scale=args.blue_scale,
    )

    filename = f"{args.prefix}_{index:0{args.digits}d}.png"
    image_path = output_dir / filename
    write_png(image_path, frame["width"], frame["height"], rgb)

    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    row = {
        "index": index,
        "filename": filename,
        "timestamp": timestamp,
        "uart_sequence": frame["sequence"],
        "bank": frame["bank"],
        "width": frame["width"],
        "height": frame["height"],
        "checksum": f"{frame['checksum']:08X}",
        "bad_frames": frame["bad_frames"],
    }
    append_manifest(manifest_path, row)

    if args.save_meta_json:
        meta = dict(row)
        meta.update({
            "baud": args.baud,
            "swap_rb": not args.no_swap_rb,
            "red_scale": args.red_scale,
            "green_scale": args.green_scale,
            "blue_scale": args.blue_scale,
            "trigger": args.trigger,
        })
        image_path.with_suffix(".json").write_text(
            json.dumps(meta, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )

    print(f"[{timestamp}] saved {image_path} seq={frame['sequence']} checksum={frame['checksum']:08X}")


def send_capture_command(port, command):
    if not command:
        return
    port.write(command.encode("ascii"))
    port.flush()


def main():
    parser = argparse.ArgumentParser(
        description="Collect 160x90 PNG dataset images from the RISC-V APB BRAM UART stream."
    )
    parser.add_argument("--port", required=True, help="Serial port, for example COM12")
    parser.add_argument("--output-dir", required=True, help="Folder used to save PNG images")
    parser.add_argument("--baud", type=int, default=500000)
    parser.add_argument(
        "--trigger",
        choices=("enter", "interval"),
        default="enter",
        help="enter: save one image after each Enter key press; interval: save periodically.",
    )
    parser.add_argument("--interval", type=float, default=6.0, help="Seconds between saved images in interval mode")
    parser.add_argument(
        "--command",
        default="R",
        help="ASCII command sent before each capture in enter mode. Use an empty string to disable.",
    )
    parser.add_argument("--count", type=int, default=0, help="Stop after N images; 0 means run until Ctrl+C")
    parser.add_argument("--prefix", default="img", help="Filename prefix, e.g. red_block or cube")
    parser.add_argument("--start-index", type=int, default=None, help="Override the next image index")
    parser.add_argument("--digits", type=int, default=5, help="Zero padding width for image sequence numbers")
    parser.add_argument("--timeout", type=float, default=20.0)
    parser.add_argument("--no-swap-rb", action="store_true")
    parser.add_argument("--red-scale", type=float, default=1.0)
    parser.add_argument("--green-scale", type=float, default=1.0)
    parser.add_argument("--blue-scale", type=float, default=1.0)
    parser.add_argument("--save-meta-json", action="store_true", help="Save one JSON metadata file per image")
    args = parser.parse_args()

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    manifest_path = output_dir / "manifest.csv"
    next_index = args.start_index if args.start_index is not None else find_next_index(output_dir, args.prefix)
    saved = 0
    next_save_time = time.monotonic()

    print(f"Collecting RISC-V frames on {args.port} at {args.baud} baud")
    if args.trigger == "enter":
        print(f"Saving one PNG per Enter key press to {output_dir}")
        print(f"Before each capture the script sends UART command: {args.command!r}")
        print("Press Enter to capture, type q then Enter to stop.")
    else:
        print(f"Saving one PNG every {args.interval:.2f}s to {output_dir}")
        print("Press Ctrl+C to stop.")

    try:
        with serial.Serial(args.port, args.baud, timeout=0.05, write_timeout=1.0) as port:
            port.reset_input_buffer()
            port.reset_output_buffer()
            port.write(b"R")
            port.flush()

            if args.trigger == "enter":
                while args.count == 0 or saved < args.count:
                    text = input(f"[{next_index:0{args.digits}d}] Enter=capture, q=quit > ").strip().lower()
                    if text in ("q", "quit", "exit"):
                        break

                    port.reset_input_buffer()
                    send_capture_command(port, args.command)
                    frame = read_riscv_frame(port, args.timeout)
                    save_frame(frame, output_dir, manifest_path, next_index, args)
                    saved += 1
                    next_index += 1
            else:
                while args.count == 0 or saved < args.count:
                    frame = read_riscv_frame(port, args.timeout)
                    now = time.monotonic()
                    if now < next_save_time:
                        continue

                    save_frame(frame, output_dir, manifest_path, next_index, args)
                    saved += 1
                    next_index += 1
                    next_save_time = now + args.interval
    except KeyboardInterrupt:
        print("\nStopped by user.")
        return 0

    print(f"Done. Saved {saved} images.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
