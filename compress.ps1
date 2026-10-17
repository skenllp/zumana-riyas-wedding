Add-Type -AssemblyName System.Drawing

$srcPath = Join-Path $PSScriptRoot "assets\og.jpg"
$destPath = Join-Path $PSScriptRoot "assets\og.jpg"

if (Test-Path $srcPath) {
    $bytes = [System.IO.File]::ReadAllBytes($srcPath)
    $ms = New-Object System.IO.MemoryStream(,$bytes)
    $orig = [System.Drawing.Image]::FromStream($ms)

    $targetWidth = 1200
    $targetHeight = 630

    $bmp = New-Object System.Drawing.Bitmap($targetWidth, $targetHeight)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

    $g.DrawImage($orig, 0, 0, $targetWidth, $targetHeight)

    $jpegEncoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.FormatDescription -eq "JPEG" }
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    # Quality 75 produces crystal clear text while keeping file size ~100-140KB, well under WhatsApp's 300KB limit
    $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]75)

    $outMs = New-Object System.IO.MemoryStream
    $bmp.Save($outMs, $jpegEncoder, $encoderParams)
    
    $outBytes = $outMs.ToArray()
    [System.IO.File]::WriteAllBytes($destPath, $outBytes)

    Write-Host ("Compressed og.jpg successfully. Original size: " + $bytes.Length + " bytes. New size: " + $outBytes.Length + " bytes (" + [math]::Round($outBytes.Length / 1KB, 1) + " KB)")

    $g.Dispose()
    $bmp.Dispose()
    $orig.Dispose()
    $ms.Dispose()
    $outMs.Dispose()
} else {
    Write-Error "assets\og.jpg not found"
}
