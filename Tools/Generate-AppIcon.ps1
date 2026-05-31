Set-StrictMode -Version Latest
Add-Type -AssemblyName System.Drawing

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$IconDir = Join-Path $ProjectRoot "FrameForgeAI/Assets.xcassets/AppIcon.appiconset"
New-Item -ItemType Directory -Force -Path $IconDir | Out-Null

function Color-Hex {
    param([string] $Hex, [int] $Alpha = 255)
    $clean = $Hex.TrimStart("#")
    [System.Drawing.Color]::FromArgb(
        $Alpha,
        [Convert]::ToInt32($clean.Substring(0, 2), 16),
        [Convert]::ToInt32($clean.Substring(2, 2), 16),
        [Convert]::ToInt32($clean.Substring(4, 2), 16)
    )
}

function New-RoundRectPath {
    param([float] $X, [float] $Y, [float] $W, [float] $H, [float] $R)
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $d = $R * 2
    $path.AddArc($X, $Y, $d, $d, 180, 90)
    $path.AddArc($X + $W - $d, $Y, $d, $d, 270, 90)
    $path.AddArc($X + $W - $d, $Y + $H - $d, $d, $d, 0, 90)
    $path.AddArc($X, $Y + $H - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    $path
}

function Save-Icon {
    param([string] $FileName, [int] $Size)

    $bmp = [System.Drawing.Bitmap]::new($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $bmp.SetResolution(72, 72)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear((Color-Hex "#071018"))

    $rect = [System.Drawing.RectangleF]::new(0, 0, $Size, $Size)
    $bg = [System.Drawing.Drawing2D.LinearGradientBrush]::new($rect, (Color-Hex "#071018"), (Color-Hex "#161024"), 62)
    $g.FillRectangle($bg, $rect)
    $bg.Dispose()

    $cyan = [System.Drawing.SolidBrush]::new((Color-Hex "#13D8FF" 190))
    $orange = [System.Drawing.SolidBrush]::new((Color-Hex "#FFB457" 150))
    $purple = [System.Drawing.SolidBrush]::new((Color-Hex "#8B5CFF" 145))
    $g.FillEllipse($cyan, -0.18 * $Size, 0.08 * $Size, 0.72 * $Size, 0.72 * $Size)
    $g.FillEllipse($orange, 0.55 * $Size, 0.18 * $Size, 0.58 * $Size, 0.58 * $Size)
    $g.FillEllipse($purple, 0.18 * $Size, 0.58 * $Size, 0.74 * $Size, 0.74 * $Size)
    $cyan.Dispose()
    $orange.Dispose()
    $purple.Dispose()

    $cardX = 0.22 * $Size
    $cardY = 0.2 * $Size
    $cardW = 0.56 * $Size
    $cardH = 0.6 * $Size
    $cardPath = New-RoundRectPath $cardX $cardY $cardW $cardH (0.13 * $Size)
    $cardBrush = [System.Drawing.SolidBrush]::new((Color-Hex "#F4FEFF" 230))
    $g.FillPath($cardBrush, $cardPath)
    $cardBrush.Dispose()

    $pen = [System.Drawing.Pen]::new((Color-Hex "#071018"), [Math]::Max(2, 0.04 * $Size))
    $cap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.StartCap = $cap
    $pen.EndCap = $cap
    $x1 = 0.34 * $Size
    $g.DrawLine($pen, $x1, 0.36 * $Size, 0.66 * $Size, 0.36 * $Size)
    $g.DrawLine($pen, $x1, 0.5 * $Size, 0.58 * $Size, 0.5 * $Size)
    $g.DrawLine($pen, $x1, 0.64 * $Size, 0.48 * $Size, 0.64 * $Size)
    $pen.Dispose()
    $cardPath.Dispose()

    $bmp.Save((Join-Path $IconDir $FileName), [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

$icons = @(
    @{ Name = "Icon-20@2x.png"; Size = 40 },
    @{ Name = "Icon-20@3x.png"; Size = 60 },
    @{ Name = "Icon-29@2x.png"; Size = 58 },
    @{ Name = "Icon-29@3x.png"; Size = 87 },
    @{ Name = "Icon-40@2x.png"; Size = 80 },
    @{ Name = "Icon-40@3x.png"; Size = 120 },
    @{ Name = "Icon-60@2x.png"; Size = 120 },
    @{ Name = "Icon-60@3x.png"; Size = 180 },
    @{ Name = "Icon-20-ipad.png"; Size = 20 },
    @{ Name = "Icon-20-ipad@2x.png"; Size = 40 },
    @{ Name = "Icon-29-ipad.png"; Size = 29 },
    @{ Name = "Icon-29-ipad@2x.png"; Size = 58 },
    @{ Name = "Icon-40-ipad.png"; Size = 40 },
    @{ Name = "Icon-40-ipad@2x.png"; Size = 80 },
    @{ Name = "Icon-76-ipad.png"; Size = 76 },
    @{ Name = "Icon-76-ipad@2x.png"; Size = 152 },
    @{ Name = "Icon-83.5-ipad@2x.png"; Size = 167 },
    @{ Name = "Icon-1024.png"; Size = 1024 }
)

foreach ($icon in $icons) {
    Save-Icon $icon.Name $icon.Size
}

Write-Host "Generated AppIcon set in $IconDir"
