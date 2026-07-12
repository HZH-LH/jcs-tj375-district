param(
    [string]$Meta = "vision_frame.meta.json",
    [string]$Payload = "vision_frame.payload.bin",
    [string]$Output = "vision_frame_tuned.ppm",
    [double]$RedScale = 1.0,
    [double]$GreenScale = 1.0,
    [double]$BlueScale = 1.0,
    [switch]$SwapRB,
    [switch]$LittleEndian
)

$ErrorActionPreference = "Stop"

function Limit-Byte([double]$Value) {
    if ($Value -le 0) {
        return [byte]0
    }
    if ($Value -ge 255) {
        return [byte]255
    }
    return [byte][Math]::Round($Value)
}

$metaObject = Get-Content -LiteralPath $Meta -Raw | ConvertFrom-Json
$width = [int]$metaObject.width
$height = [int]$metaObject.height
$payloadBytes = [IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $Payload))
$expectedBytes = $width * $height * 2

if ($payloadBytes.Length -ne $expectedBytes) {
    throw ("Payload length mismatch: got {0}, expected {1} for {2}x{3} RGB565." -f
        $payloadBytes.Length, $expectedBytes, $width, $height)
}

$rgb888 = [byte[]]::new($width * $height * 3)
$outOffset = 0

for ($offset = 0; $offset -lt $payloadBytes.Length; $offset += 2) {
    if ($LittleEndian) {
        $pixel = ([uint32]$payloadBytes[$offset]) -bor
            ([uint32]$payloadBytes[$offset + 1] -shl 8)
    } else {
        $pixel = ([uint32]$payloadBytes[$offset] -shl 8) -bor
            ([uint32]$payloadBytes[$offset + 1])
    }

    $r5 = ($pixel -shr 11) -band 0x1f
    $g6 = ($pixel -shr 5) -band 0x3f
    $b5 = $pixel -band 0x1f

    $r8 = ($r5 -shl 3) -bor ($r5 -shr 2)
    $g8 = ($g6 -shl 2) -bor ($g6 -shr 4)
    $b8 = ($b5 -shl 3) -bor ($b5 -shr 2)

    if ($SwapRB) {
        $tmp = $r8
        $r8 = $b8
        $b8 = $tmp
    }

    $rgb888[$outOffset] = Limit-Byte ($r8 * $RedScale)
    $rgb888[$outOffset + 1] = Limit-Byte ($g8 * $GreenScale)
    $rgb888[$outOffset + 2] = Limit-Byte ($b8 * $BlueScale)
    $outOffset += 3
}

$ppmHeaderText = "P6" + [char]10 + $width + " " + $height + [char]10 + "255" + [char]10
$ppmHeader = [Text.Encoding]::ASCII.GetBytes($ppmHeaderText)
$stream = [IO.File]::Create((Join-Path (Get-Location) $Output))
try {
    $stream.Write($ppmHeader, 0, $ppmHeader.Length)
    $stream.Write($rgb888, 0, $rgb888.Length)
} finally {
    $stream.Dispose()
}

$endianName = if ($LittleEndian) { "little" } else { "big" }
Write-Host ("Saved {0}: {1}x{2}, swap_rb={3}, endian={4}, scale={5}/{6}/{7}" -f
    $Output, $width, $height, $SwapRB.IsPresent, $endianName,
    $RedScale, $GreenScale, $BlueScale)
