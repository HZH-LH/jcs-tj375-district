param(
    [Parameter(Mandatory = $true)]
    [string]$Port,
    [string]$OutputPrefix = "vision_frame",
    [int]$BaudRate = 500000,
    [int]$TimeoutMs = 1000,
    [int]$WaitSeconds = 20,
    [switch]$SaveCorrupt
)

$ErrorActionPreference = "Stop"

$serial = [System.IO.Ports.SerialPort]::new(
    $Port, $BaudRate, [System.IO.Ports.Parity]::None, 8,
    [System.IO.Ports.StopBits]::One
)
$serial.ReadTimeout = $TimeoutMs
$serial.ReadBufferSize = 1048576

function Read-ByteOrTimeout([System.IO.Ports.SerialPort]$Device) {
    try {
        return $Device.ReadByte()
    } catch [System.TimeoutException] {
        return $null
    }
}

function Read-Exact([System.IO.Ports.SerialPort]$Device, [int]$Count) {
    $data = [byte[]]::new($Count)
    $offset = 0
    while ($offset -lt $Count) {
        $read = $Device.Read($data, $offset, $Count - $offset)
        if ($read -le 0) {
            throw "Serial read returned no data before the requested block was complete."
        }
        $offset += $read
    }
    return $data
}

function Read-U16([byte[]]$Data, [int]$Offset) {
    return [BitConverter]::ToUInt16($Data, $Offset)
}

function Read-U32([byte[]]$Data, [int]$Offset) {
    return [BitConverter]::ToUInt32($Data, $Offset)
}

function Get-FrameChecksum([byte[]]$Payload) {
    [uint32]$checksum = 0
    for ($offset = 0; $offset -lt $Payload.Length; $offset += 4) {
        [uint32]$pixel0 = ([uint32]$Payload[$offset] -shl 8) -bor
            [uint32]$Payload[$offset + 1]
        [uint32]$pixel1 = ([uint32]$Payload[$offset + 2] -shl 8) -bor
            [uint32]$Payload[$offset + 3]
        [uint32]$word = $pixel0 -bor ($pixel1 -shl 16)
        [uint32]$rotated = [uint32]((([uint64]$checksum -shl 5) -bor
            ([uint64]$checksum -shr 27)) -band 0xffffffffL)
        $checksum = [uint32]($rotated -bxor $word)
    }
    return $checksum
}

function Wait-FrameMagic([System.IO.Ports.SerialPort]$Device, [byte[]]$Magic,
                         [DateTime]$Deadline) {
    $matched = 0
    while ($matched -lt $Magic.Length) {
        $value = Read-ByteOrTimeout $Device
        if ($null -eq $value) {
            if ([DateTime]::Now -ge $Deadline) {
                throw ("Timed out waiting for VFRM on {0}." -f $Port)
            }
            continue
        }

        if ($value -eq $Magic[$matched]) {
            $matched++
        } else {
            $matched = if ($value -eq $Magic[0]) { 1 } else { 0 }
        }
    }
}

$payloadPath = Join-Path (Get-Location) ($OutputPrefix + ".payload.bin")
$metaPath = Join-Path (Get-Location) ($OutputPrefix + ".meta.json")
$magic = [Text.Encoding]::ASCII.GetBytes("VFRM")
$deadline = if ($WaitSeconds -gt 0) {
    [DateTime]::Now.AddSeconds($WaitSeconds)
} else {
    [DateTime]::MaxValue
}
$badFrames = 0

try {
    $serial.Open()
    Write-Host ("Waiting for clean VFRM payload on {0} at {1} 8N1..." -f $Port, $BaudRate)

    while ($true) {
        Wait-FrameMagic $serial $magic $deadline
        $header = Read-Exact $serial 20
        $version = $header[0]
        $format = $header[1]
        $width = Read-U16 $header 2
        $height = Read-U16 $header 4
        $sequence = Read-U32 $header 6
        $payloadBytes = Read-U32 $header 10
        $headerChecksum = Read-U32 $header 14
        $bank = $header[18]
        $flags = $header[19]

        if ($version -ne 1 -or $format -ne 1 -or
            $payloadBytes -ne $width * $height * 2) {
            $badFrames++
            continue
        }

        $payload = Read-Exact $serial $payloadBytes
        $footer = Read-Exact $serial 4
        $expectedChecksum = Read-U32 $footer 0
        if (($flags -band 1) -eq 0) {
            $expectedChecksum = $headerChecksum
        }
        $actualChecksum = Get-FrameChecksum $payload

        if ($actualChecksum -eq $expectedChecksum) {
            [IO.File]::WriteAllBytes($payloadPath, $payload)
            $meta = [ordered]@{
                magic = "VFRM"
                version = $version
                format = "RGB565"
                width = $width
                height = $height
                sequence = $sequence
                payloadBytes = $payloadBytes
                bank = $bank
                flags = $flags
                checksum = ("{0:X8}" -f $actualChecksum)
                badFramesBeforeClean = $badFrames
                payloadEndian = "rgb565_big_endian_per_pixel"
                checksumWordOrder = "word = pixel0 | (pixel1 << 16)"
            }
            $meta | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $metaPath -Encoding ASCII
            Write-Host ("Saved payload {0} and meta {1}: seq={2} bank={3} {4}x{5} checksum={6:X8} badFrames={7}" -f
                $payloadPath, $metaPath, $sequence, $bank, $width, $height,
                $actualChecksum, $badFrames)
            break
        }

        $badFrames++
        Write-Host ("Discarded corrupt frame seq={0}: expected {1:X8}, got {2:X8}" -f
            $sequence, $expectedChecksum, $actualChecksum)

        if ($SaveCorrupt) {
            [IO.File]::WriteAllBytes(($payloadPath + ".corrupt"), $payload)
        }

        if ([DateTime]::Now -ge $deadline) {
            throw ("Timed out before receiving a clean payload; badFrames={0}; last seq={1} bank={2} flags={3} {4}x{5} payload={6} baud={7}" -f
                $badFrames, $sequence, $bank, $flags, $width, $height,
                $payloadBytes, $BaudRate)
        }
    }
} finally {
    if ($serial.IsOpen) {
        $serial.Close()
    }
}
