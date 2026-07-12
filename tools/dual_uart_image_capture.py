#!/usr/bin/env python3
import argparse
import json
import struct
import sys
import time
from pathlib import Path

try:
    import serial
except ImportError as exc:
    raise SystemExit("pyserial is required: pip install pyserial") from exc


CAPTURE_MAGIC = b"\xA5\x5A"
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
        b = port.read(1)
        if not b:
            continue
        value = b[0]
        if value == magic[matched]:
            matched += 1
        else:
            matched = 1 if value == magic[0] else 0


def checksum_capture(payload):
    return sum(payload) & 0xFF


def checksum_riscv(payload):
    checksum = 0
    for offset in range(0, len(payload), 4):
        pixel0 = (payload[offset] << 8) | payload[offset + 1]
        pixel1 = (payload[offset + 2] << 8) | payload[offset + 3]
        word = pixel0 | (pixel1 << 16)
        checksum = (((checksum << 5) | (checksum >> 27)) & 0xFFFFFFFF) ^ word
    return checksum & 0xFFFFFFFF


def read_fpga_frame(port, deadline):
    wait_magic(port, CAPTURE_MAGIC, deadline)
    header = read_exact(port, 10, deadline)
    version = header[0]
    seq = header[1]
    width = (header[2] << 8) | header[3]
    height = (header[4] << 8) | header[5]
    fmt = header[6]
    payload_bytes = (header[7] << 8) | header[8]
    expected = header[9]
    if version != 1 or fmt != 0 or payload_bytes != width * height * 2:
        raise ValueError(
            f"bad FPGA header: version={version} fmt={fmt} "
            f"{width}x{height} payload={payload_bytes}"
        )
    payload = read_exact(port, payload_bytes, deadline)
    actual = checksum_capture(payload)
    if actual != expected:
        raise ValueError(f"FPGA checksum mismatch: expected {expected:02X}, got {actual:02X}")
    return {
        "source": "fpga",
        "sequence": seq,
        "width": width,
        "height": height,
        "payload": payload,
        "checksum": actual,
    }


def read_riscv_frame(port, deadline, skip_bad):
    bad = 0
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
            bad += 1
            if not skip_bad:
                raise ValueError(
                    f"bad RISC-V header: version={version} fmt={fmt} "
                    f"{width}x{height} payload={payload_bytes}"
                )
            continue
        payload = read_exact(port, payload_bytes, deadline)
        footer = read_exact(port, 4, deadline)
        expected = struct.unpack("<I", footer)[0] if (flags & 1) else header_checksum
        actual = checksum_riscv(payload)
        if actual == expected:
            return {
                "source": "riscv",
                "sequence": seq,
                "bank": bank,
                "flags": flags,
                "width": width,
                "height": height,
                "payload": payload,
                "checksum": actual,
                "bad_frames": bad,
            }
        bad += 1
        if not skip_bad:
            raise ValueError(f"RISC-V checksum mismatch: expected {expected:08X}, got {actual:08X}")


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


def write_ppm(path, width, height, rgb):
    with open(path, "wb") as f:
        f.write(f"P6\n{width} {height}\n255\n".encode("ascii"))
        f.write(rgb)


def main():
    parser = argparse.ArgumentParser(
        description="Capture one 160x90 diagnostic frame from FPGA-direct or RISC-V APB UART mode."
    )
    parser.add_argument("--port", required=True, help="Serial port, for example COM12")
    parser.add_argument("--baud", type=int, default=500000, help="UART baud rate")
    parser.add_argument("--mode", choices=("fpga", "riscv", "stop"), required=True)
    parser.add_argument("--output", default="vision_frame.ppm", help="Output PPM path")
    parser.add_argument("--timeout", type=float, default=20.0, help="Overall wait timeout in seconds")
    parser.add_argument("--no-swap-rb", action="store_true", help="Disable capture-compatible R/B swap in PPM conversion")
    parser.add_argument("--red-scale", type=float, default=1.0)
    parser.add_argument("--green-scale", type=float, default=1.0)
    parser.add_argument("--blue-scale", type=float, default=1.0)
    parser.add_argument("--save-payload", action="store_true", help="Save raw payload and JSON metadata beside output")
    parser.add_argument("--no-skip-bad", action="store_true", help="Fail on the first corrupt RISC-V frame")
    args = parser.parse_args()

    command = {"fpga": b"F", "riscv": b"R", "stop": b"S"}[args.mode]
    output = Path(args.output)

    with serial.Serial(args.port, args.baud, timeout=0.05, write_timeout=1.0) as port:
        port.reset_input_buffer()
        port.reset_output_buffer()
        port.write(command)
        port.flush()

        if args.mode == "stop":
            print(f"Sent stop command on {args.port}")
            return 0

        deadline = time.monotonic() + args.timeout
        if args.mode == "fpga":
            frame = read_fpga_frame(port, deadline)
        else:
            frame = read_riscv_frame(port, deadline, skip_bad=not args.no_skip_bad)

    rgb = rgb565_payload_to_rgb888(
        frame["payload"],
        swap_rb=not args.no_swap_rb,
        red_scale=args.red_scale,
        green_scale=args.green_scale,
        blue_scale=args.blue_scale,
    )
    write_ppm(output, frame["width"], frame["height"], rgb)

    meta = {k: v for k, v in frame.items() if k != "payload"}
    meta.update({
        "baud": args.baud,
        "swap_rb": not args.no_swap_rb,
        "red_scale": args.red_scale,
        "green_scale": args.green_scale,
        "blue_scale": args.blue_scale,
        "output": str(output),
    })
    if args.save_payload:
        payload_path = output.with_suffix(output.suffix + ".payload.bin")
        meta_path = output.with_suffix(output.suffix + ".meta.json")
        payload_path.write_bytes(frame["payload"])
        meta_path.write_text(json.dumps(meta, indent=2), encoding="utf-8")
        meta["payload_file"] = str(payload_path)
        meta["meta_file"] = str(meta_path)

    print(json.dumps(meta, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
