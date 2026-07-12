param(
    [Parameter(Mandatory = $true)]
    [string]$Port,
    [string]$Output = "vision_frame.ppm",
    [int]$BaudRate = 500000,
    [int]$TimeoutMs = 1000,
    [int]$WaitSeconds = 0,
    [switch]$SaveCorrupt,
    [switch]$NoSwapRB,
    [switch]$SwapRB,
    [double]$RedScale = 1.0,
    [double]$GreenScale = 1.0,
    [double]$BlueScale = 1.0
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
        $offset += $Device.Read($data, $offset, $Count - $offset)
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

function Limit-Byte([double]$Value) {
    if ($Value -le 0) {
        return [byte]0
    }
    if ($Value -ge 255) {
        return [byte]255
    }
    return [byte][Math]::Round($Value)
}

function Wait-FrameMagic([System.IO.Ports.SerialPort]$Device, [byte[]]$Magic,
                         [DateTime]$Deadline) {
    $matched = 0
    while ($matched -lt $Magic.Length) {
        $value = Read-ByteOrTimeout $serial
        if ($null -eq $value) {
            if ([DateTime]::Now -ge $deadline) {
                throw ("Timed out waiting for VFRM on {0}. Check that the expected board UART port is selected and the RISC-V firmware is running." -f $Port)
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

try {
    $serial.Open()
    $magic = [Text.Encoding]::ASCII.GetBytes("VFRM")
    $deadline = if ($WaitSeconds -gt 0) {
        [DateTime]::Now.AddSeconds($WaitSeconds)
    } else {
        [DateTime]::MaxValue
    }
    $badFrames = 0

    Write-Host ("Waiting for VFRM on {0} at {1} 8N1..." -f $Port, $BaudRate)
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
            break
        }

        $badFrames++
        Write-Host ("Discarded corrupt frame seq={0}: expected {1:X8}, got {2:X8}" -f
            $sequence, $expectedChecksum, $actualChecksum)
        if ([DateTime]::Now -ge $deadline) {
            if ($SaveCorrupt) {
                [IO.File]::WriteAllBytes((Join-Path (Get-Location) ($Output + ".payload.bin")), $payload)
            }
            throw ("Timed out before receiving a clean frame; badFrames={0}; last seq={1} bank={2} flags={3} {4}x{5} payload={6} baud={7}" -f
                $badFrames, $sequence, $bank, $flags, $width, $height, $payloadBytes, $BaudRate)
        }
    }
} finally {
    if ($serial.IsOpen) {
        $serial.Close()
    }
}

$rgb888 = [byte[]]::new($width * $height * 3)
$outputOffset = 0
for ($offset = 0; $offset -lt $payload.Length; $offset += 2) {
    $pixel = ($payload[$offset] -shl 8) -bor $payload[$offset + 1]
    $r5 = ($pixel -shr 11) -band 0x1f
    $g6 = ($pixel -shr 5) -band 0x3f
    $b5 = $pixel -band 0x1f
    $r8 = ($r5 -shl 3) -bor ($r5 -shr 2)
    $g8 = ($g6 -shl 2) -bor ($g6 -shr 4)
    $b8 = ($b5 -shl 3) -bor ($b5 -shr 2)
    if (-not $NoSwapRB) {
        $tmp = $r8
        $r8 = $b8
        $b8 = $tmp
    }
    $rgb888[$outputOffset] = $r8
    $rgb888[$outputOffset + 1] = $g8
    $rgb888[$outputOffset + 2] = $b8
    $rgb888[$outputOffset] = Limit-Byte ($rgb888[$outputOffset] * $RedScale)
    $rgb888[$outputOffset + 1] = Limit-Byte ($rgb888[$outputOffset + 1] * $GreenScale)
    $rgb888[$outputOffset + 2] = Limit-Byte ($rgb888[$outputOffset + 2] * $BlueScale)
    $outputOffset += 3
}

$ppmHeader = [Text.Encoding]::ASCII.GetBytes("P6`n$width $height`n255`n")
$stream = [IO.File]::Create((Join-Path (Get-Location) $Output))
try {
    $stream.Write($ppmHeader, 0, $ppmHeader.Length)
    $stream.Write($rgb888, 0, $rgb888.Length)
} finally {
    $stream.Dispose()
}

Write-Host ("Saved {0}: seq={1} bank={2} {3}x{4} checksum={5:X8} swap_rb={6} scale={7}/{8}/{9}" -f
    $Output, $sequence, $bank, $width, $height, $actualChecksum,
    (-not $NoSwapRB), $RedScale, $GreenScale, $BlueScale)
