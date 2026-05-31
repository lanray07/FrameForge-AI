Set-StrictMode -Version Latest
Add-Type -AssemblyName System.Drawing

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$OutputRoot = Join-Path $ProjectRoot "AppStoreAssets"
$IPhoneDir = Join-Path $OutputRoot "iPhone_6_5_Display"
$IPhoneJpegDir = Join-Path $OutputRoot "iPhone_6_5_Display_RGB_JPEG"
$IPadDir = Join-Path $OutputRoot "iPad_13_Display"
$IPadJpegDir = Join-Path $OutputRoot "iPad_13_Display_RGB_JPEG"
$ReviewDir = Join-Path $OutputRoot "SubscriptionReview"
$ReviewIPhoneJpegDir = Join-Path $OutputRoot "SubscriptionReview_iPhone_6_5_Display_JPEG"
$ReviewIPadDir = Join-Path $OutputRoot "SubscriptionReview_iPad_13_Display"
$SubImageDir = Join-Path $OutputRoot "SubscriptionImages"
$SubImageJpegDir = Join-Path $OutputRoot "SubscriptionImages_RGB_JPEG"

New-Item -ItemType Directory -Force -Path $IPhoneDir, $IPhoneJpegDir, $IPadDir, $IPadJpegDir, $ReviewDir, $ReviewIPhoneJpegDir, $ReviewIPadDir, $SubImageDir, $SubImageJpegDir | Out-Null

function Color-Hex {
    param(
        [string] $Hex,
        [int] $Alpha = 255
    )

    $clean = $Hex.TrimStart("#")
    $r = [Convert]::ToInt32($clean.Substring(0, 2), 16)
    $g = [Convert]::ToInt32($clean.Substring(2, 2), 16)
    $b = [Convert]::ToInt32($clean.Substring(4, 2), 16)
    [System.Drawing.Color]::FromArgb($Alpha, $r, $g, $b)
}

function New-Font {
    param(
        [float] $Size,
        [System.Drawing.FontStyle] $Style = [System.Drawing.FontStyle]::Regular
    )

    [System.Drawing.Font]::new("Segoe UI", $Size, $Style, [System.Drawing.GraphicsUnit]::Pixel)
}

function Save-Jpeg {
    param(
        [System.Drawing.Bitmap] $Bitmap,
        [string] $Path,
        [long] $Quality = 94
    )

    $rgb = [System.Drawing.Bitmap]::new($Bitmap.Width, $Bitmap.Height, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $rgb.SetResolution(72, 72)
    $g = [System.Drawing.Graphics]::FromImage($rgb)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Black)
    $g.DrawImage($Bitmap, 0, 0, $Bitmap.Width, $Bitmap.Height)
    $g.Dispose()

    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" } | Select-Object -First 1
    $encoderParams = [System.Drawing.Imaging.EncoderParameters]::new(1)
    $encoderParams.Param[0] = [System.Drawing.Imaging.EncoderParameter]::new([System.Drawing.Imaging.Encoder]::Quality, $Quality)
    $rgb.Save($Path, $codec, $encoderParams)
    $encoderParams.Dispose()
    $rgb.Dispose()
}

function New-RoundRectPath {
    param(
        [float] $X,
        [float] $Y,
        [float] $W,
        [float] $H,
        [float] $R
    )

    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $d = $R * 2
    $path.AddArc($X, $Y, $d, $d, 180, 90)
    $path.AddArc($X + $W - $d, $Y, $d, $d, 270, 90)
    $path.AddArc($X + $W - $d, $Y + $H - $d, $d, $d, 0, 90)
    $path.AddArc($X, $Y + $H - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    $path
}

function Fill-RoundRect {
    param(
        [System.Drawing.Graphics] $G,
        [float] $X,
        [float] $Y,
        [float] $W,
        [float] $H,
        [float] $R,
        [System.Drawing.Brush] $Brush
    )

    $path = New-RoundRectPath $X $Y $W $H $R
    $G.FillPath($Brush, $path)
    $path.Dispose()
}

function Stroke-RoundRect {
    param(
        [System.Drawing.Graphics] $G,
        [float] $X,
        [float] $Y,
        [float] $W,
        [float] $H,
        [float] $R,
        [System.Drawing.Pen] $Pen
    )

    $path = New-RoundRectPath $X $Y $W $H $R
    $G.DrawPath($Pen, $path)
    $path.Dispose()
}

function Draw-Text {
    param(
        [System.Drawing.Graphics] $G,
        [string] $Text,
        [float] $X,
        [float] $Y,
        [float] $W,
        [float] $H,
        [System.Drawing.Font] $Font,
        [System.Drawing.Color] $Color,
        [string] $Align = "Near"
    )

    $brush = [System.Drawing.SolidBrush]::new($Color)
    $format = [System.Drawing.StringFormat]::new()
    $format.Alignment = [System.Drawing.StringAlignment]::$Align
    $format.LineAlignment = [System.Drawing.StringAlignment]::Near
    $format.Trimming = [System.Drawing.StringTrimming]::EllipsisWord
    $rect = [System.Drawing.RectangleF]::new($X, $Y, $W, $H)
    $G.DrawString($Text, $Font, $brush, $rect, $format)
    $format.Dispose()
    $brush.Dispose()
}

function Draw-Glow {
    param(
        [System.Drawing.Graphics] $G,
        [float] $X,
        [float] $Y,
        [float] $W,
        [float] $H,
        [System.Drawing.Color] $Color,
        [int] $Steps = 11
    )

    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $path.AddEllipse($X, $Y, $W, $H)
    $brush = [System.Drawing.Drawing2D.PathGradientBrush]::new($path)
    $brush.CenterColor = $Color
    $brush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, $Color.R, $Color.G, $Color.B))
    $G.FillEllipse($brush, $X, $Y, $W, $H)
    $brush.Dispose()
    $path.Dispose()
}

function Draw-Background {
    param(
        [System.Drawing.Graphics] $G,
        [int] $W,
        [int] $H
    )

    $rect = [System.Drawing.Rectangle]::new(0, 0, $W, $H)
    $bg = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        $rect,
        (Color-Hex "#071018"),
        (Color-Hex "#160F1E"),
        72
    )
    $G.FillRectangle($bg, $rect)
    $bg.Dispose()

    Draw-Glow $G -X -240 -Y 120 -W 860 -H 860 -Color (Color-Hex "#13D8FF" 210)
    Draw-Glow $G -X 730 -Y 210 -W 740 -H 740 -Color (Color-Hex "#FFB457" 165)
    Draw-Glow $G -X 260 -Y 1690 -W 900 -H 800 -Color (Color-Hex "#9B5CFF" 140)

    $grainPen = [System.Drawing.Pen]::new((Color-Hex "#FFFFFF" 20), 1)
    for ($y = 0; $y -lt $H; $y += 44) {
        $G.DrawLine($grainPen, 0, $y, $W, $y + 18)
    }
    $grainPen.Dispose()
}

function Draw-BrandMark {
    param(
        [System.Drawing.Graphics] $G,
        [float] $X,
        [float] $Y,
        [float] $Scale = 1.0
    )

    $size = 72 * $Scale
    $bg = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        [System.Drawing.RectangleF]::new($X, $Y, $size, $size),
        (Color-Hex "#FFFFFF"),
        (Color-Hex "#16D7FF"),
        35
    )
    Fill-RoundRect $G $X $Y $size $size (18 * $Scale) $bg
    $bg.Dispose()

    $pen = [System.Drawing.Pen]::new((Color-Hex "#071018" 220), 5 * $Scale)
    $G.DrawLine($pen, $X + 20 * $Scale, $Y + 23 * $Scale, $X + 51 * $Scale, $Y + 23 * $Scale)
    $G.DrawLine($pen, $X + 20 * $Scale, $Y + 36 * $Scale, $X + 44 * $Scale, $Y + 36 * $Scale)
    $G.DrawLine($pen, $X + 20 * $Scale, $Y + 49 * $Scale, $X + 34 * $Scale, $Y + 49 * $Scale)
    $pen.Dispose()
}

function Draw-Panel {
    param(
        [System.Drawing.Graphics] $G,
        [float] $X,
        [float] $Y,
        [float] $W,
        [float] $H,
        [float] $R = 28,
        [int] $Alpha = 44
    )

    $brush = [System.Drawing.SolidBrush]::new((Color-Hex "#FFFFFF" $Alpha))
    Fill-RoundRect $G $X $Y $W $H $R $brush
    $brush.Dispose()
    $pen = [System.Drawing.Pen]::new((Color-Hex "#FFFFFF" 46), 2)
    Stroke-RoundRect $G $X $Y $W $H $R $pen
    $pen.Dispose()
}

function Draw-Pill {
    param(
        [System.Drawing.Graphics] $G,
        [string] $Text,
        [float] $X,
        [float] $Y,
        [float] $W,
        [float] $H,
        [System.Drawing.Color] $Fill,
        [System.Drawing.Color] $TextColor,
        [float] $FontSize = 24
    )

    $brush = [System.Drawing.SolidBrush]::new($Fill)
    Fill-RoundRect $G $X $Y $W $H ($H / 2) $brush
    $brush.Dispose()
    $font = New-Font $FontSize ([System.Drawing.FontStyle]::Bold)
    Draw-Text $G $Text ($X + 18) ($Y + 8) ($W - 36) ($H - 10) $font $TextColor "Center"
    $font.Dispose()
}

function Draw-PhoneFrame {
    param(
        [System.Drawing.Graphics] $G,
        [float] $X,
        [float] $Y,
        [float] $W,
        [float] $H,
        [scriptblock] $Content
    )

    $shadow = [System.Drawing.SolidBrush]::new((Color-Hex "#000000" 110))
    Fill-RoundRect $G ($X + 34) ($Y + 42) $W $H 78 $shadow
    $shadow.Dispose()

    $frame = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        [System.Drawing.RectangleF]::new($X, $Y, $W, $H),
        (Color-Hex "#2F3B48"),
        (Color-Hex "#05070B"),
        92
    )
    Fill-RoundRect $G $X $Y $W $H 78 $frame
    $frame.Dispose()

    $screenX = $X + 28
    $screenY = $Y + 32
    $screenW = $W - 56
    $screenH = $H - 64
    $screenBrush = [System.Drawing.SolidBrush]::new((Color-Hex "#071018"))
    Fill-RoundRect $G $screenX $screenY $screenW $screenH 58 $screenBrush
    $screenBrush.Dispose()

    $clipPath = New-RoundRectPath $screenX $screenY $screenW $screenH 58
    $oldClip = $G.Clip
    $G.SetClip($clipPath)
    & $Content $G $screenX $screenY $screenW $screenH
    $G.Clip = $oldClip
    $oldClip.Dispose()
    $clipPath.Dispose()

    $notchBrush = [System.Drawing.SolidBrush]::new((Color-Hex "#020307"))
    Fill-RoundRect $G ($X + $W / 2 - 72) ($Y + 36) 144 34 17 $notchBrush
    $notchBrush.Dispose()

    $stroke = [System.Drawing.Pen]::new((Color-Hex "#FFFFFF" 42), 2)
    Stroke-RoundRect $G $X $Y $W $H 78 $stroke
    $stroke.Dispose()
}

function Draw-AppHeader {
    param(
        [System.Drawing.Graphics] $G,
        [float] $X,
        [float] $Y,
        [float] $W,
        [string] $Title,
        [string] $Kicker = "FrameForge AI"
    )

    $kickerFont = New-Font 18 ([System.Drawing.FontStyle]::Bold)
    $titleFont = New-Font 36 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $G $Kicker ($X + 34) ($Y + 58) ($W - 68) 28 $kickerFont (Color-Hex "#13D8FF")
    Draw-Text $G $Title ($X + 34) ($Y + 92) ($W - 68) 86 $titleFont (Color-Hex "#FFFFFF")
    $kickerFont.Dispose()
    $titleFont.Dispose()
}

function Draw-MetricCard {
    param(
        [System.Drawing.Graphics] $G,
        [float] $X,
        [float] $Y,
        [float] $W,
        [string] $Value,
        [string] $Label,
        [System.Drawing.Color] $Accent
    )

    Draw-Panel $G $X $Y $W 148 24 38
    $valueFont = New-Font 38 ([System.Drawing.FontStyle]::Bold)
    $labelFont = New-Font 19
    Draw-Text $G $Value ($X + 22) ($Y + 28) ($W - 44) 48 $valueFont (Color-Hex "#FFFFFF")
    Draw-Text $G $Label ($X + 22) ($Y + 82) ($W - 44) 44 $labelFont (Color-Hex "#B9C7D6")
    $dot = [System.Drawing.SolidBrush]::new($Accent)
    $G.FillEllipse($dot, $X + $W - 42, $Y + 30, 16, 16)
    $dot.Dispose()
    $valueFont.Dispose()
    $labelFont.Dispose()
}

function Draw-PhoneDashboard {
    param($G, $X, $Y, $W, $H)

    Draw-Background $G ([int]($X + $W)) ([int]($Y + $H))
    Draw-AppHeader $G $X $Y $W "Your launch-ready screenshot studio" "Founder / App Store Screenshots"
    Draw-MetricCard $G ($X + 34) ($Y + 220) (($W - 86) / 2) "128" "Exports" (Color-Hex "#13D8FF")
    Draw-MetricCard $G ($X + 52 + (($W - 86) / 2)) ($Y + 220) (($W - 86) / 2) "12" "Voice Prompts" (Color-Hex "#FFB457")

    $sectionFont = New-Font 25 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $G "Quick Actions" ($X + 34) ($Y + 408) ($W - 68) 42 $sectionFont (Color-Hex "#FFFFFF")

    $actions = @(
        @("AI Beautifier", "Premium padding"),
        @("App Store Set", "6.5 inch exports"),
        @("Voice Design", "Speak edits"),
        @("Batch Create", "Creator workflow")
    )
    $tileW = ($W - 90) / 2
    for ($i = 0; $i -lt $actions.Count; $i++) {
        $col = $i % 2
        $row = [Math]::Floor($i / 2)
        $tx = $X + 34 + $col * ($tileW + 22)
        $ty = $Y + 464 + $row * 168
        Draw-Panel $G $tx $ty $tileW 142 24 36
        $accent = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.RectangleF]::new($tx + 18, $ty + 18, 54, 54), (Color-Hex "#13D8FF"), (Color-Hex "#A46CFF"), 45)
        Fill-RoundRect $G ($tx + 18) ($ty + 18) 54 54 16 $accent
        $accent.Dispose()
        $fontA = New-Font 22 ([System.Drawing.FontStyle]::Bold)
        $fontB = New-Font 17
        Draw-Text $G $actions[$i][0] ($tx + 18) ($ty + 82) ($tileW - 36) 32 $fontA (Color-Hex "#FFFFFF")
        Draw-Text $G $actions[$i][1] ($tx + 18) ($ty + 112) ($tileW - 36) 24 $fontB (Color-Hex "#AEBBCC")
        $fontA.Dispose()
        $fontB.Dispose()
    }

    Draw-Text $G "AI Suggestions" ($X + 34) ($Y + 828) ($W - 68) 42 $sectionFont (Color-Hex "#FFFFFF")
    Draw-Panel $G ($X + 34) ($Y + 890) ($W - 68) 118 24 42
    $suggestFont = New-Font 22
    Draw-Text $G "Create an App Store before-and-after set from your latest build." ($X + 64) ($Y + 920) ($W - 128) 68 $suggestFont (Color-Hex "#D9E8F6")
    $suggestFont.Dispose()
    $sectionFont.Dispose()
}

function Draw-PhoneVoice {
    param($G, $X, $Y, $W, $H)

    Draw-Background $G ([int]($X + $W)) ([int]($Y + $H))
    Draw-AppHeader $G $X $Y $W "Speak the design you want" "Voice Assistant"

    Draw-Panel $G ($X + 34) ($Y + 230) ($W - 68) 250 30 42
    $micBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.RectangleF]::new($X + $W / 2 - 72, $Y + 262, 144, 144), (Color-Hex "#13D8FF"), (Color-Hex "#FFB457"), 30)
    Fill-RoundRect $G ($X + $W / 2 - 72) ($Y + 262) 144 144 72 $micBrush
    $micBrush.Dispose()
    $micPen = [System.Drawing.Pen]::new((Color-Hex "#071018"), 8)
    $G.DrawEllipse($micPen, $X + $W / 2 - 22, $Y + 292, 44, 74)
    $G.DrawLine($micPen, $X + $W / 2, $Y + 366, $X + $W / 2, $Y + 400)
    $G.DrawLine($micPen, $X + $W / 2 - 34, $Y + 400, $X + $W / 2 + 34, $Y + 400)
    $micPen.Dispose()

    $voiceFont = New-Font 23 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $G "Listening for a premium layout prompt" ($X + 70) ($Y + 426) ($W - 140) 38 $voiceFont (Color-Hex "#FFFFFF") "Center"
    $voiceFont.Dispose()

    Draw-Panel $G ($X + 34) ($Y + 530) ($W - 68) 178 28 46
    $bubbleFont = New-Font 26
    Draw-Text $G '"Make this launch graphic calmer, cleaner, and App Store-ready."' ($X + 62) ($Y + 568) ($W - 124) 92 $bubbleFont (Color-Hex "#FFFFFF")
    $bubbleFont.Dispose()

    $sectionFont = New-Font 25 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $G "Assistant Suggestions" ($X + 34) ($Y + 770) ($W - 68) 42 $sectionFont (Color-Hex "#FFFFFF")

    $tips = @("Move the headline above the device.", "Increase screenshot scale by 12%.", "Use a calmer background for exports.")
    for ($i = 0; $i -lt $tips.Count; $i++) {
        $ty = $Y + 828 + $i * 118
        Draw-Panel $G ($X + 34) $ty ($W - 68) 92 22 34
        $dot = [System.Drawing.SolidBrush]::new((Color-Hex "#13D8FF"))
        $G.FillEllipse($dot, $X + 60, $ty + 36, 18, 18)
        $dot.Dispose()
        $tipFont = New-Font 22
        Draw-Text $G $tips[$i] ($X + 96) ($ty + 28) ($W - 140) 40 $tipFont (Color-Hex "#D9E8F6")
        $tipFont.Dispose()
    }
    $sectionFont.Dispose()
}

function Draw-PhoneBuilder {
    param($G, $X, $Y, $W, $H)

    Draw-Background $G ([int]($X + $W)) ([int]($Y + $H))
    Draw-AppHeader $G $X $Y $W "App Store screenshot set" "App Store Builder"

    $previewBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.RectangleF]::new($X + 34, $Y + 220, $W - 68, 360), (Color-Hex "#FFFFFF" 230), (Color-Hex "#13D8FF" 170), 45)
    Fill-RoundRect $G ($X + 34) ($Y + 220) ($W - 68) 360 34 $previewBrush
    $previewBrush.Dispose()
    $insideFont = New-Font 30 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $G "FrameForge AI" ($X + 72) ($Y + 258) ($W - 144) 48 $insideFont (Color-Hex "#071018")
    Draw-Text $G "Launch visuals that feel ready before review." ($X + 72) ($Y + 310) ($W - 144) 96 (New-Font 23) (Color-Hex "#102033")

    $phoneMini = [System.Drawing.SolidBrush]::new((Color-Hex "#071018"))
    Fill-RoundRect $G ($X + 256) ($Y + 382) 132 164 28 $phoneMini
    $phoneMini.Dispose()

    $sectionFont = New-Font 25 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $G "Templates" ($X + 34) ($Y + 646) ($W - 68) 42 $sectionFont (Color-Hex "#FFFFFF")

    $templates = @(
        @("Modern", "Clean product launch"),
        @("Premium", "Dark luxury set"),
        @("Gaming", "High-energy previews"),
        @("AI Apps", "Prompt-first layouts")
    )
    for ($i = 0; $i -lt $templates.Count; $i++) {
        $ty = $Y + 704 + $i * 112
        Draw-Panel $G ($X + 34) $ty ($W - 68) 88 22 35
        $fontA = New-Font 24 ([System.Drawing.FontStyle]::Bold)
        $fontB = New-Font 18
        Draw-Text $G $templates[$i][0] ($X + 66) ($ty + 20) 180 34 $fontA (Color-Hex "#FFFFFF")
        Draw-Text $G $templates[$i][1] ($X + 250) ($ty + 24) 220 34 $fontB (Color-Hex "#AEBBCC")
        $fontA.Dispose()
        $fontB.Dispose()
    }

    Draw-Pill $G "6.5 inch" ($X + 34) ($Y + 1168) 128 48 (Color-Hex "#13D8FF" 210) (Color-Hex "#061018") 20
    Draw-Pill $G "5.5 inch" ($X + 176) ($Y + 1168) 128 48 (Color-Hex "#FFFFFF" 42) (Color-Hex "#FFFFFF") 20
    Draw-Pill $G "iPad" ($X + 318) ($Y + 1168) 94 48 (Color-Hex "#FFFFFF" 42) (Color-Hex "#FFFFFF") 20
    $sectionFont.Dispose()
}

function Draw-PhonePaywall {
    param(
        $G,
        [float] $X,
        [float] $Y,
        [float] $W,
        [float] $H,
        [string] $Highlight = "Pro Creator"
    )

    Draw-Background $G ([int]($X + $W)) ([int]($Y + $H))
    Draw-AppHeader $G $X $Y $W "Upgrade" "FrameForge AI"

    $plans = @(
        @{ Title = "Free"; Price = "GBP 0"; Body = "Limited exports, basic templates, watermark" },
        @{ Title = "Pro Creator"; Price = "GBP 9.99 monthly"; Body = "Unlimited exports, premium templates, App Store generator, AI assistant, voice input" },
        @{ Title = "Pro Yearly"; Price = "GBP 79.99 yearly"; Body = "Best value for creators shipping every month" },
        @{ Title = "Agency Pro"; Price = "GBP 29.99 monthly"; Body = "Brand kits, batch exports, advanced templates, white-label exports" }
    )

    for ($i = 0; $i -lt $plans.Count; $i++) {
        $plan = $plans[$i]
        $ty = $Y + 220 + $i * 246
        $isHighlight = $plan.Title -eq $Highlight
        if ($isHighlight) {
            $brush = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.RectangleF]::new($X + 34, $ty, $W - 68, 220), (Color-Hex "#13D8FF" 90), (Color-Hex "#FFB457" 70), 45)
            Fill-RoundRect $G ($X + 34) $ty ($W - 68) 220 30 $brush
            $brush.Dispose()
        }
        Draw-Panel $G ($X + 34) $ty ($W - 68) 220 30 ($(if ($isHighlight) { 66 } else { 40 }))
        $titleFont = New-Font 29 ([System.Drawing.FontStyle]::Bold)
        $priceFont = New-Font 23 ([System.Drawing.FontStyle]::Bold)
        $bodyFont = New-Font 18
        Draw-Text $G $plan.Title ($X + 66) ($ty + 26) ($W - 132) 42 $titleFont (Color-Hex "#FFFFFF")
        Draw-Text $G $plan.Price ($X + 66) ($ty + 72) ($W - 132) 34 $priceFont (Color-Hex "#13D8FF")
        Draw-Text $G $plan.Body ($X + 66) ($ty + 112) ($W - 132) 54 $bodyFont (Color-Hex "#B9C7D6")
        Draw-Pill $G ("Choose " + $plan.Title) ($X + 66) ($ty + 166) 250 42 ($(if ($isHighlight) { Color-Hex "#FFFFFF" 235 } else { Color-Hex "#FFFFFF" 46 })) ($(if ($isHighlight) { Color-Hex "#071018" } else { Color-Hex "#FFFFFF" })) 18
        $titleFont.Dispose()
        $priceFont.Dispose()
        $bodyFont.Dispose()
    }
}

function Draw-PhoneExport {
    param($G, $X, $Y, $W, $H)

    Draw-Background $G ([int]($X + $W)) ([int]($Y + $H))
    Draw-AppHeader $G $X $Y $W "Export Center" "Batch-ready assets"

    Draw-Pill $G "Share latest export" ($X + 34) ($Y + 220) ($W - 68) 62 (Color-Hex "#13D8FF" 230) (Color-Hex "#071018") 24

    $formats = @(
        @("PNG", "Transparent and full-bleed"),
        @("JPG", "Compressed social exports"),
        @("PDF", "Presentation-ready"),
        @("App Store Set", "6.7, 6.5, 5.5 inch"),
        @("Social Sizes", "Square, portrait, story")
    )

    for ($i = 0; $i -lt $formats.Count; $i++) {
        $ty = $Y + 330 + $i * 128
        Draw-Panel $G ($X + 34) $ty ($W - 68) 98 22 38
        $icon = [System.Drawing.SolidBrush]::new((Color-Hex "#13D8FF" 48))
        Fill-RoundRect $G ($X + 58) ($ty + 22) 54 54 16 $icon
        $icon.Dispose()
        $fontA = New-Font 25 ([System.Drawing.FontStyle]::Bold)
        $fontB = New-Font 18
        Draw-Text $G $formats[$i][0] ($X + 132) ($ty + 18) 220 34 $fontA (Color-Hex "#FFFFFF")
        Draw-Text $G $formats[$i][1] ($X + 132) ($ty + 53) 300 30 $fontB (Color-Hex "#AEBBCC")
        $fontA.Dispose()
        $fontB.Dispose()
    }

    Draw-Panel $G ($X + 34) ($Y + 1015) ($W - 68) 162 28 42
    $endFont = New-Font 24 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $G "One design. Every launch channel." ($X + 66) ($Y + 1056) ($W - 132) 42 $endFont (Color-Hex "#FFFFFF")
    Draw-Text $G "Keep product, social, and App Store visuals consistent from a single workspace." ($X + 66) ($Y + 1100) ($W - 132) 54 (New-Font 18) (Color-Hex "#B9C7D6")
    $endFont.Dispose()
}

function Draw-IPadFrame {
    param(
        [System.Drawing.Graphics] $G,
        [float] $X,
        [float] $Y,
        [float] $W,
        [float] $H,
        [scriptblock] $Content
    )

    $shadow = [System.Drawing.SolidBrush]::new((Color-Hex "#000000" 115))
    Fill-RoundRect $G ($X + 42) ($Y + 52) $W $H 74 $shadow
    $shadow.Dispose()

    $frame = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        [System.Drawing.RectangleF]::new($X, $Y, $W, $H),
        (Color-Hex "#334150"),
        (Color-Hex "#05070B"),
        88
    )
    Fill-RoundRect $G $X $Y $W $H 74 $frame
    $frame.Dispose()

    $screenX = $X + 34
    $screenY = $Y + 38
    $screenW = $W - 68
    $screenH = $H - 76
    $screenBrush = [System.Drawing.SolidBrush]::new((Color-Hex "#071018"))
    Fill-RoundRect $G $screenX $screenY $screenW $screenH 48 $screenBrush
    $screenBrush.Dispose()

    $clipPath = New-RoundRectPath $screenX $screenY $screenW $screenH 48
    $oldClip = $G.Clip
    $G.SetClip($clipPath)
    & $Content $G $screenX $screenY $screenW $screenH
    $G.Clip = $oldClip
    $oldClip.Dispose()
    $clipPath.Dispose()

    $camera = [System.Drawing.SolidBrush]::new((Color-Hex "#020307"))
    $G.FillEllipse($camera, $X + $W / 2 - 13, $Y + 13, 26, 26)
    $camera.Dispose()

    $stroke = [System.Drawing.Pen]::new((Color-Hex "#FFFFFF" 42), 3)
    Stroke-RoundRect $G $X $Y $W $H 74 $stroke
    $stroke.Dispose()
}

function Draw-IPadShell {
    param(
        [System.Drawing.Graphics] $G,
        [float] $X,
        [float] $Y,
        [float] $W,
        [float] $H,
        [string] $Active
    )

    $screenRect = [System.Drawing.RectangleF]::new($X, $Y, $W, $H)
    $screenBg = [System.Drawing.Drawing2D.LinearGradientBrush]::new($screenRect, (Color-Hex "#071018"), (Color-Hex "#191020"), 60)
    $G.FillRectangle($screenBg, $screenRect)
    $screenBg.Dispose()
    Draw-Glow $G ($X - 180) ($Y + 40) 520 520 (Color-Hex "#13D8FF" 145)
    Draw-Glow $G ($X + $W - 320) ($Y + $H - 360) 620 620 (Color-Hex "#9B5CFF" 120)

    $sidebarW = 320
    $sidebar = [System.Drawing.SolidBrush]::new((Color-Hex "#FFFFFF" 30))
    Fill-RoundRect $G ($X + 28) ($Y + 28) $sidebarW ($H - 56) 38 $sidebar
    $sidebar.Dispose()
    $sidebarPen = [System.Drawing.Pen]::new((Color-Hex "#FFFFFF" 40), 2)
    Stroke-RoundRect $G ($X + 28) ($Y + 28) $sidebarW ($H - 56) 38 $sidebarPen
    $sidebarPen.Dispose()

    Draw-BrandMark $G ($X + 68) ($Y + 70) 0.66
    $brandFont = New-Font 23 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $G "FrameForge" ($X + 134) ($Y + 82) 170 34 $brandFont (Color-Hex "#FFFFFF")
    $brandFont.Dispose()

    $nav = @("Dashboard", "Studio", "App Store", "Voice", "Export", "Upgrade")
    for ($i = 0; $i -lt $nav.Count; $i++) {
        $ny = $Y + 180 + $i * 78
        $isActive = $nav[$i] -eq $Active
        if ($isActive) {
            $activeBrush = [System.Drawing.SolidBrush]::new((Color-Hex "#13D8FF" 56))
            Fill-RoundRect $G ($X + 58) $ny 250 52 18 $activeBrush
            $activeBrush.Dispose()
        }
        $font = New-Font 22 ($(if ($isActive) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }))
        Draw-Text $G $nav[$i] ($X + 84) ($ny + 13) 190 28 $font ($(if ($isActive) { Color-Hex "#FFFFFF" } else { Color-Hex "#AEBBCC" }))
        $font.Dispose()
    }

    $miniFont = New-Font 19
    Draw-Text $G "Voice input enabled" ($X + 68) ($Y + $H - 154) 230 28 $miniFont (Color-Hex "#13D8FF")
    Draw-Text $G "Mock AI ready" ($X + 68) ($Y + $H - 116) 230 28 $miniFont (Color-Hex "#AEBBCC")
    $miniFont.Dispose()
}

function Draw-IPadTitle {
    param(
        [System.Drawing.Graphics] $G,
        [float] $X,
        [float] $Y,
        [float] $W,
        [string] $Kicker,
        [string] $Title
    )

    $kickerFont = New-Font 22 ([System.Drawing.FontStyle]::Bold)
    $titleFont = New-Font 48 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $G $Kicker $X $Y $W 34 $kickerFont (Color-Hex "#13D8FF")
    Draw-Text $G $Title $X ($Y + 42) $W 72 $titleFont (Color-Hex "#FFFFFF")
    $kickerFont.Dispose()
    $titleFont.Dispose()
}

function Draw-IPadSmallCard {
    param(
        [System.Drawing.Graphics] $G,
        [float] $X,
        [float] $Y,
        [float] $W,
        [float] $H,
        [string] $Title,
        [string] $Body,
        [string] $Badge = ""
    )

    Draw-Panel $G $X $Y $W $H 26 38
    $titleFont = New-Font 27 ([System.Drawing.FontStyle]::Bold)
    $bodyFont = New-Font 20
    Draw-Text $G $Title ($X + 28) ($Y + 26) ($W - 56) 38 $titleFont (Color-Hex "#FFFFFF")
    Draw-Text $G $Body ($X + 28) ($Y + 72) ($W - 56) ($H - 92) $bodyFont (Color-Hex "#B9C7D6")
    if ($Badge.Length -gt 0) {
        Draw-Pill $G $Badge ($X + $W - 156) ($Y + 24) 122 38 (Color-Hex "#13D8FF" 210) (Color-Hex "#061018") 16
    }
    $titleFont.Dispose()
    $bodyFont.Dispose()
}

function Draw-IPadDashboard {
    param($G, $X, $Y, $W, $H)

    Draw-IPadShell $G $X $Y $W $H "Dashboard"
    $contentX = $X + 392
    $contentY = $Y + 80
    $contentW = $W - 444
    Draw-IPadTitle $G $contentX $contentY $contentW "Founder / App Store Screenshots" "Your launch-ready screenshot studio"

    $metricY = $contentY + 164
    $metricW = ($contentW - 54) / 3
    Draw-IPadSmallCard $G $contentX $metricY $metricW 160 "128" "Exports created" "Live"
    Draw-IPadSmallCard $G ($contentX + $metricW + 27) $metricY $metricW 160 "34" "Templates used" ""
    Draw-IPadSmallCard $G ($contentX + 2 * ($metricW + 27)) $metricY $metricW 160 "12" "Voice prompts" ""

    $sectionFont = New-Font 30 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $G "Recent Projects" $contentX ($metricY + 220) $contentW 42 $sectionFont (Color-Hex "#FFFFFF")
    Draw-IPadSmallCard $G $contentX ($metricY + 282) ($contentW * 0.48) 180 "Launch Week Kit" "6 screenshots using Dark Luxury templates for a product launch."
    Draw-IPadSmallCard $G ($contentX + $contentW * 0.52) ($metricY + 282) ($contentW * 0.48) 180 "App Store Preview" "5.5-inch and 6.5-inch drafts with premium device framing."

    Draw-Text $G "Trending Templates" $contentX ($metricY + 520) $contentW 42 $sectionFont (Color-Hex "#FFFFFF")
    $templates = @("Launch Hero", "Luxury App Store", "Founder Carousel")
    for ($i = 0; $i -lt $templates.Count; $i++) {
        $tx = $contentX + $i * (($contentW - 52) / 3 + 26)
        $tw = ($contentW - 52) / 3
        $cardBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.RectangleF]::new($tx, $metricY + 584, $tw, 250), (Color-Hex "#FFFFFF" 220), (Color-Hex "#13D8FF" 142), 45)
        Fill-RoundRect $G $tx ($metricY + 584) $tw 250 30 $cardBrush
        $cardBrush.Dispose()
        $tFont = New-Font 26 ([System.Drawing.FontStyle]::Bold)
        Draw-Text $G $templates[$i] ($tx + 28) ($metricY + 768) ($tw - 56) 38 $tFont (Color-Hex "#071018")
        $tFont.Dispose()
    }

    Draw-Text $G "AI Suggestions" $contentX ($metricY + 900) $contentW 42 $sectionFont (Color-Hex "#FFFFFF")
    Draw-IPadSmallCard $G $contentX ($metricY + 960) $contentW 144 "Create an App Store before-and-after set." "Turn the latest product screen into a review-ready launch asset with cleaner hierarchy and premium spacing."
    $sectionFont.Dispose()
}

function Draw-IPadVoice {
    param($G, $X, $Y, $W, $H)

    Draw-IPadShell $G $X $Y $W $H "Voice"
    $contentX = $X + 392
    $contentY = $Y + 80
    $contentW = $W - 444
    Draw-IPadTitle $G $contentX $contentY $contentW "Voice input technology" "Speak edits into the design studio"

    Draw-Panel $G $contentX ($contentY + 170) ($contentW * 0.58) 460 34 42
    $micBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.RectangleF]::new($contentX + 70, $contentY + 240, 170, 170), (Color-Hex "#13D8FF"), (Color-Hex "#FFB457"), 30)
    Fill-RoundRect $G ($contentX + 70) ($contentY + 240) 170 170 85 $micBrush
    $micBrush.Dispose()
    $micFont = New-Font 34 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $G "Listening..." ($contentX + 280) ($contentY + 252) 360 54 $micFont (Color-Hex "#FFFFFF")
    Draw-Text $G '"Make this launch graphic calmer, cleaner, and App Store-ready."' ($contentX + 280) ($contentY + 324) 440 120 (New-Font 25) (Color-Hex "#D9E8F6")
    $micFont.Dispose()

    Draw-Panel $G ($contentX + $contentW * 0.62) ($contentY + 170) ($contentW * 0.38) 460 34 42
    $tipFont = New-Font 28 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $G "Assistant Queue" ($contentX + $contentW * 0.62 + 34) ($contentY + 212) ($contentW * 0.38 - 68) 44 $tipFont (Color-Hex "#FFFFFF")
    $tips = @("Move the headline above the device.", "Increase screenshot scale by 12%.", "Use a calmer export background.")
    for ($i = 0; $i -lt $tips.Count; $i++) {
        Draw-IPadSmallCard $G ($contentX + $contentW * 0.62 + 34) ($contentY + 284 + $i * 112) ($contentW * 0.38 - 68) 88 $tips[$i] "" ""
    }
    $tipFont.Dispose()

    Draw-Panel $G $contentX ($contentY + 700) $contentW 360 34 40
    $flowFont = New-Font 30 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $G "Humanized creative flow" ($contentX + 38) ($contentY + 742) $contentW 44 $flowFont (Color-Hex "#FFFFFF")
    Draw-Text $G "Voice prompts feed the AI assistant, caption assistant, beautifier, and design studio so creators can move quickly without losing tone." ($contentX + 38) ($contentY + 800) ($contentW - 76) 92 (New-Font 24) (Color-Hex "#B9C7D6")
    Draw-Pill $G "AI Beautifier" ($contentX + 38) ($contentY + 930) 214 54 (Color-Hex "#13D8FF" 215) (Color-Hex "#061018") 20
    Draw-Pill $G "Captions" ($contentX + 276) ($contentY + 930) 154 54 (Color-Hex "#FFFFFF" 42) (Color-Hex "#FFFFFF") 20
    Draw-Pill $G "App Store Sets" ($contentX + 454) ($contentY + 930) 226 54 (Color-Hex "#FFFFFF" 42) (Color-Hex "#FFFFFF") 20
    $flowFont.Dispose()
}

function Draw-IPadBuilder {
    param($G, $X, $Y, $W, $H)

    Draw-IPadShell $G $X $Y $W $H "App Store"
    $contentX = $X + 392
    $contentY = $Y + 80
    $contentW = $W - 444
    Draw-IPadTitle $G $contentX $contentY $contentW "App Store screenshot builder" "Compose store-ready screenshot sets"

    $canvasW = $contentW * 0.64
    Draw-Panel $G $contentX ($contentY + 170) $canvasW 780 38 40
    $canvasBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.RectangleF]::new($contentX + 42, $contentY + 218, $canvasW - 84, 680), (Color-Hex "#FFFFFF" 235), (Color-Hex "#13D8FF" 155), 45)
    Fill-RoundRect $G ($contentX + 42) ($contentY + 218) ($canvasW - 84) 680 34 $canvasBrush
    $canvasBrush.Dispose()
    $canvasTitle = New-Font 42 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $G "FrameForge AI" ($contentX + 86) ($contentY + 280) ($canvasW - 172) 64 $canvasTitle (Color-Hex "#071018")
    Draw-Text $G "Launch visuals that feel ready before review." ($contentX + 86) ($contentY + 354) ($canvasW - 172) 94 (New-Font 28) (Color-Hex "#102033")
    $miniX = $contentX + 310
    $miniY = $contentY + 488
    $miniShadow = [System.Drawing.SolidBrush]::new((Color-Hex "#000000" 90))
    Fill-RoundRect $G ($miniX + 26) ($miniY + 30) 230 470 42 $miniShadow
    $miniShadow.Dispose()
    $miniFrame = [System.Drawing.SolidBrush]::new((Color-Hex "#071018"))
    Fill-RoundRect $G $miniX $miniY 230 470 44 $miniFrame
    $miniFrame.Dispose()
    $miniScreen = [System.Drawing.SolidBrush]::new((Color-Hex "#120D1D"))
    Fill-RoundRect $G ($miniX + 18) ($miniY + 22) 194 426 32 $miniScreen
    $miniScreen.Dispose()
    $miniNotch = [System.Drawing.SolidBrush]::new((Color-Hex "#020307"))
    Fill-RoundRect $G ($miniX + 69) ($miniY + 30) 92 24 12 $miniNotch
    $miniNotch.Dispose()
    Draw-Text $G "App Store Set" ($miniX + 38) ($miniY + 88) 154 62 (New-Font 22 ([System.Drawing.FontStyle]::Bold)) (Color-Hex "#FFFFFF") "Center"
    Draw-Pill $G "6.5" ($miniX + 44) ($miniY + 180) 56 36 (Color-Hex "#13D8FF" 220) (Color-Hex "#061018") 15
    Draw-Pill $G "iPad" ($miniX + 110) ($miniY + 180) 78 36 (Color-Hex "#FFFFFF" 44) (Color-Hex "#FFFFFF") 14
    Draw-Text $G "Clean callouts" ($miniX + 38) ($miniY + 260) 154 34 (New-Font 18) (Color-Hex "#B9C7D6") "Center"
    $canvasTitle.Dispose()

    $panelX = $contentX + $canvasW + 34
    $panelW = $contentW - $canvasW - 34
    Draw-Panel $G $panelX ($contentY + 170) $panelW 780 38 40
    $inspectorFont = New-Font 30 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $G "Inspector" ($panelX + 34) ($contentY + 220) ($panelW - 68) 44 $inspectorFont (Color-Hex "#FFFFFF")
    Draw-IPadSmallCard $G ($panelX + 34) ($contentY + 296) ($panelW - 68) 130 "Template" "Premium"
    Draw-IPadSmallCard $G ($panelX + 34) ($contentY + 456) ($panelW - 68) 130 "Output" "iPad + iPhone"
    Draw-IPadSmallCard $G ($panelX + 34) ($contentY + 616) ($panelW - 68) 130 "Review" "Safe callouts"
    $inspectorFont.Dispose()

    Draw-Pill $G "6.5 inch" $contentX ($contentY + 1010) 160 56 (Color-Hex "#13D8FF" 215) (Color-Hex "#061018") 20
    Draw-Pill $G "13 inch iPad" ($contentX + 186) ($contentY + 1010) 214 56 (Color-Hex "#FFFFFF" 42) (Color-Hex "#FFFFFF") 20
    Draw-Pill $G "Subscription review" ($contentX + 426) ($contentY + 1010) 286 56 (Color-Hex "#FFFFFF" 42) (Color-Hex "#FFFFFF") 20
}

function Draw-IPadPlans {
    param(
        $G,
        $X,
        $Y,
        $W,
        $H,
        [string] $HighlightPlan = "Agency Pro"
    )

    Draw-IPadShell $G $X $Y $W $H "Upgrade"
    $contentX = $X + 392
    $contentY = $Y + 80
    $contentW = $W - 444
    Draw-IPadTitle $G $contentX $contentY $contentW "Premium plans" "Creator tools for launch-day assets"

    $plans = @(
        @{ Title = "Free"; Price = "GBP 0"; Body = "Limited exports and basic templates." },
        @{ Title = "Pro Creator"; Price = "GBP 9.99 monthly"; Body = "Unlimited exports, premium templates, App Store generator, AI assistant, and voice input." },
        @{ Title = "Pro Yearly"; Price = "GBP 79.99 yearly"; Body = "Annual Pro access for creators shipping every month." },
        @{ Title = "Agency Pro"; Price = "GBP 29.99 monthly"; Body = "Brand kits, batch exports, advanced templates, and white-label exports." }
    )

    for ($i = 0; $i -lt $plans.Count; $i++) {
        $col = $i % 2
        $row = [Math]::Floor($i / 2)
        $cardW = ($contentW - 34) / 2
        $x0 = $contentX + $col * ($cardW + 34)
        $y0 = $contentY + 188 + $row * 360
        if ($plans[$i].Title -eq $HighlightPlan) {
            $highlight = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.RectangleF]::new($x0, $y0, $cardW, 320), (Color-Hex "#13D8FF" 80), (Color-Hex "#FFB457" 80), 45)
            Fill-RoundRect $G $x0 $y0 $cardW 320 34 $highlight
            $highlight.Dispose()
        }
        Draw-Panel $G $x0 $y0 $cardW 320 34 42
        $titleFont = New-Font 34 ([System.Drawing.FontStyle]::Bold)
        $priceFont = New-Font 25 ([System.Drawing.FontStyle]::Bold)
        $bodyFont = New-Font 22
        Draw-Text $G $plans[$i].Title ($x0 + 36) ($y0 + 34) ($cardW - 72) 48 $titleFont (Color-Hex "#FFFFFF")
        Draw-Text $G $plans[$i].Price ($x0 + 36) ($y0 + 96) ($cardW - 72) 38 $priceFont (Color-Hex "#13D8FF")
        Draw-Text $G $plans[$i].Body ($x0 + 36) ($y0 + 150) ($cardW - 72) 88 $bodyFont (Color-Hex "#B9C7D6")
        Draw-Pill $G ("Choose " + $plans[$i].Title) ($x0 + 36) ($y0 + 252) 260 48 (Color-Hex "#FFFFFF" 46) (Color-Hex "#FFFFFF") 18
        $titleFont.Dispose()
        $priceFont.Dispose()
        $bodyFont.Dispose()
    }

    Draw-IPadSmallCard $G $contentX ($contentY + 950) $contentW 150 "Transparent review flow" "Pricing and purchase buttons are shown before checkout, with all subscription levels grouped clearly."
}

function Draw-IPadExport {
    param($G, $X, $Y, $W, $H)

    Draw-IPadShell $G $X $Y $W $H "Export"
    $contentX = $X + 392
    $contentY = $Y + 80
    $contentW = $W - 444
    Draw-IPadTitle $G $contentX $contentY $contentW "Export everywhere" "One asset system for every channel"

    Draw-Panel $G $contentX ($contentY + 176) ($contentW * 0.48) 770 34 40
    $queueFont = New-Font 30 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $G "Export Queue" ($contentX + 36) ($contentY + 226) 360 44 $queueFont (Color-Hex "#FFFFFF")
    $formats = @("PNG - Full bleed", "JPG - Social launch", "PDF - Presentation", "App Store Set", "Story and carousel")
    for ($i = 0; $i -lt $formats.Count; $i++) {
        Draw-IPadSmallCard $G ($contentX + 36) ($contentY + 306 + $i * 110) ($contentW * 0.48 - 72) 84 $formats[$i] "" ""
    }
    $queueFont.Dispose()

    $previewX = $contentX + $contentW * 0.52
    $previewW = $contentW * 0.48
    Draw-Panel $G $previewX ($contentY + 176) $previewW 770 34 40
    $previewBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.RectangleF]::new($previewX + 42, $contentY + 236, $previewW - 84, 430), (Color-Hex "#FFFFFF" 230), (Color-Hex "#A46CFF" 155), 35)
    Fill-RoundRect $G ($previewX + 42) ($contentY + 236) ($previewW - 84) 430 34 $previewBrush
    $previewBrush.Dispose()
    $pFont = New-Font 40 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $G "Launch Week Kit" ($previewX + 82) ($contentY + 296) ($previewW - 164) 58 $pFont (Color-Hex "#071018")
    Draw-Text $G "Store, social, and client-ready in one pass." ($previewX + 82) ($contentY + 374) ($previewW - 164) 92 (New-Font 27) (Color-Hex "#102033")
    Draw-Pill $G "Ready to share" ($previewX + 82) ($contentY + 570) 240 56 (Color-Hex "#071018" 230) (Color-Hex "#FFFFFF") 20
    Draw-IPadSmallCard $G ($previewX + 42) ($contentY + 704) ($previewW - 84) 168 "Consistency check" "FrameForge keeps screenshots, social posts, and client assets aligned across exports."
    $pFont.Dispose()
}

function Save-IPadShot {
    param(
        [string] $FileName,
        [string] $Kicker,
        [string] $Headline,
        [string] $Body,
        [string] $Type
    )

    $W = 2048
    $H = 2732
    $bmp = [System.Drawing.Bitmap]::new($W, $H)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    Draw-Background $g $W $H

    Draw-BrandMark $g 132 112 1.0
    $brandFont = New-Font 38 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $g "FrameForge AI" 228 134 440 52 $brandFont (Color-Hex "#FFFFFF")
    $brandFont.Dispose()
    Draw-Pill $g $Kicker 132 256 440 68 (Color-Hex "#FFFFFF" 42) (Color-Hex "#FFFFFF") 24

    $headlineFont = New-Font 78 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $g $Headline 132 364 1784 190 $headlineFont (Color-Hex "#FFFFFF")
    $headlineFont.Dispose()
    $bodyFont = New-Font 38
    Draw-Text $g $Body 138 580 1360 96 $bodyFont (Color-Hex "#C8D5E2")
    $bodyFont.Dispose()
    Draw-Pill $g "iPad 13 inch" 1576 592 248 66 (Color-Hex "#13D8FF" 220) (Color-Hex "#061018") 24

    switch ($Type) {
        "dashboard" {
            Draw-IPadFrame $g 306 730 1436 1868 ${function:Draw-IPadDashboard}
        }
        "voice" {
            Draw-IPadFrame $g 306 730 1436 1868 ${function:Draw-IPadVoice}
        }
        "builder" {
            Draw-IPadFrame $g 306 730 1436 1868 ${function:Draw-IPadBuilder}
        }
        "plans" {
            Draw-IPadFrame $g 306 730 1436 1868 ${function:Draw-IPadPlans}
        }
        "export" {
            Draw-IPadFrame $g 306 730 1436 1868 ${function:Draw-IPadExport}
        }
    }

    $outPath = Join-Path $IPadDir $FileName
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $jpegName = [System.IO.Path]::ChangeExtension($FileName, ".jpg")
    Save-Jpeg $bmp (Join-Path $IPadJpegDir $jpegName)
    $g.Dispose()
    $bmp.Dispose()
}

function Save-SubscriptionReviewIPadShot {
    param(
        [string] $FileName,
        [string] $Highlight,
        [string] $ProductId
    )

    $W = 2048
    $H = 2732
    $bmp = [System.Drawing.Bitmap]::new($W, $H)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    Draw-Background $g $W $H

    Draw-BrandMark $g 132 112 1.0
    $brandFont = New-Font 38 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $g "FrameForge AI" 228 134 440 52 $brandFont (Color-Hex "#FFFFFF")
    $brandFont.Dispose()

    Draw-Pill $g "Subscription review" 132 256 430 68 (Color-Hex "#FFFFFF" 42) (Color-Hex "#FFFFFF") 24
    $headlineFont = New-Font 78 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $g "$Highlight purchase screen" 132 364 1784 100 $headlineFont (Color-Hex "#FFFFFF")
    $headlineFont.Dispose()
    $bodyFont = New-Font 36
    Draw-Text $g "This screenshot clearly shows the subscription tier, pricing, benefits, and purchase button for App Review." 138 488 1390 96 $bodyFont (Color-Hex "#C8D5E2")
    $bodyFont.Dispose()
    Draw-Pill $g $ProductId 132 620 520 60 (Color-Hex "#FFFFFF" 42) (Color-Hex "#FFFFFF") 22
    Draw-Pill $g "iPad 13 inch" 1576 620 248 60 (Color-Hex "#13D8FF" 220) (Color-Hex "#061018") 24

    Draw-IPadFrame $g 306 730 1436 1868 { param($G, $X, $Y, $W, $H) Draw-IPadPlans $G $X $Y $W $H $Highlight }

    $outPath = Join-Path $ReviewIPadDir $FileName
    Save-Jpeg $bmp $outPath
    $g.Dispose()
    $bmp.Dispose()
}

function Draw-Callout {
    param(
        [System.Drawing.Graphics] $G,
        [string] $Title,
        [string] $Body,
        [float] $X,
        [float] $Y,
        [float] $W
    )

    Draw-Panel $G $X $Y $W 156 30 54
    $titleFont = New-Font 28 ([System.Drawing.FontStyle]::Bold)
    $bodyFont = New-Font 20
    Draw-Text $G $Title ($X + 28) ($Y + 24) ($W - 56) 38 $titleFont (Color-Hex "#FFFFFF")
    Draw-Text $G $Body ($X + 28) ($Y + 66) ($W - 56) 64 $bodyFont (Color-Hex "#B9C7D6")
    $titleFont.Dispose()
    $bodyFont.Dispose()
}

function Save-AppStoreShot {
    param(
        [string] $FileName,
        [string] $Kicker,
        [string] $Headline,
        [string] $Body,
        [string] $Type,
        [string] $CalloutTitle,
        [string] $CalloutBody
    )

    $W = 1242
    $H = 2688
    $bmp = [System.Drawing.Bitmap]::new($W, $H)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    Draw-Background $g $W $H

    Draw-BrandMark $g 88 120 0.86
    $brandFont = New-Font 30 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $g "FrameForge AI" 174 140 360 46 $brandFont (Color-Hex "#FFFFFF")
    $brandFont.Dispose()

    Draw-Pill $g $Kicker 88 250 360 58 (Color-Hex "#FFFFFF" 40) (Color-Hex "#FFFFFF") 21

    $headlineFont = New-Font 78 ([System.Drawing.FontStyle]::Bold)
    Draw-Text $g $Headline 88 338 1066 220 $headlineFont (Color-Hex "#FFFFFF")
    $headlineFont.Dispose()

    $bodyFont = New-Font 30
    Draw-Text $g $Body 92 592 900 92 $bodyFont (Color-Hex "#C8D5E2")
    $bodyFont.Dispose()

    Draw-Callout $g $CalloutTitle $CalloutBody 92 2184 474
    Draw-Pill $g "iPhone 6.5 inch" 676 2222 252 58 (Color-Hex "#13D8FF" 215) (Color-Hex "#061018") 22
    Draw-Pill $g "Voice input ready" 944 2222 224 58 (Color-Hex "#FFFFFF" 42) (Color-Hex "#FFFFFF") 20

    switch ($Type) {
        "dashboard" {
            Draw-PhoneFrame $g 358 790 540 1240 ${function:Draw-PhoneDashboard}
        }
        "voice" {
            Draw-PhoneFrame $g 358 790 540 1240 ${function:Draw-PhoneVoice}
        }
        "builder" {
            Draw-PhoneFrame $g 358 790 540 1240 ${function:Draw-PhoneBuilder}
        }
        "paywall" {
            Draw-PhoneFrame $g 358 790 540 1240 { param($G, $X, $Y, $W, $H) Draw-PhonePaywall $G $X $Y $W $H "Pro Creator" }
        }
        "export" {
            Draw-PhoneFrame $g 358 790 540 1240 ${function:Draw-PhoneExport}
        }
    }

    $outPath = Join-Path $IPhoneDir $FileName
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $jpegName = [System.IO.Path]::ChangeExtension($FileName, ".jpg")
    Save-Jpeg $bmp (Join-Path $IPhoneJpegDir $jpegName)
    $g.Dispose()
    $bmp.Dispose()
}

function Save-SubscriptionReviewShot {
    param(
        [string] $FileName,
        [string] $Highlight,
        [string] $ProductId
    )

    $W = 1242
    $H = 2688
    $bmp = [System.Drawing.Bitmap]::new($W, $H)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    Draw-Background $g $W $H
    Draw-PhoneFrame $g 266 180 710 1630 { param($G, $X, $Y, $W, $H) Draw-PhonePaywall $G $X $Y $W $H $Highlight }

    $labelFont = New-Font 46 ([System.Drawing.FontStyle]::Bold)
    $bodyFont = New-Font 28
    Draw-Text $g "Subscription review screenshot" 150 1908 942 60 $labelFont (Color-Hex "#FFFFFF") "Center"
    Draw-Text $g "$Highlight appears on the Upgrade screen with clear pricing and a purchase button." 190 1990 862 90 $bodyFont (Color-Hex "#C8D5E2") "Center"
    Draw-Pill $g $ProductId 288 2118 666 60 (Color-Hex "#FFFFFF" 44) (Color-Hex "#FFFFFF") 22

    $outPath = Join-Path $ReviewDir $FileName
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $jpegName = [System.IO.Path]::ChangeExtension($FileName, ".jpg")
    Save-Jpeg $bmp (Join-Path $ReviewIPhoneJpegDir $jpegName)
    $g.Dispose()
    $bmp.Dispose()
}

function Save-SubscriptionImage {
    param(
        [string] $FileName,
        [string] $Title,
        [string] $Price,
        [string] $Body,
        [string] $AccentHex
    )

    $W = 1024
    $H = 1024
    $bmp = [System.Drawing.Bitmap]::new($W, $H)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    Draw-Background $g $W $H

    $accent = Color-Hex $AccentHex
    Draw-Glow $g -120 -80 620 620 $accent 10
    Draw-Panel $g 96 116 832 792 64 52
    Draw-BrandMark $g 156 174 1.05

    $titleFont = New-Font 64 ([System.Drawing.FontStyle]::Bold)
    $priceFont = New-Font 38 ([System.Drawing.FontStyle]::Bold)
    $bodyFont = New-Font 30
    Draw-Text $g $Title 156 320 712 104 $titleFont (Color-Hex "#FFFFFF")
    Draw-Text $g $Price 156 452 712 58 $priceFont (Color-Hex "#13D8FF")
    Draw-Text $g $Body 156 552 712 150 $bodyFont (Color-Hex "#D4E0EC")
    Draw-Pill $g "FrameForge AI" 156 770 284 58 (Color-Hex "#FFFFFF" 42) (Color-Hex "#FFFFFF") 22

    $outPath = Join-Path $SubImageDir $FileName
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $jpegName = [System.IO.Path]::ChangeExtension($FileName, ".jpg")
    Save-Jpeg $bmp (Join-Path $SubImageJpegDir $jpegName)
    $g.Dispose()
    $bmp.Dispose()
}

Save-AppStoreShot "01_launch_ready_studio_1242x2688.png" `
    "For founders and creators" `
    "Turn rough captures into launch-ready visuals." `
    "A focused screenshot studio for App Store sets, social launches, device mockups, captions, and export workflows." `
    "dashboard" `
    "Human-first workflow" `
    "Built for real launch days, not blank-canvas busywork."

Save-AppStoreShot "02_voice_design_assistant_1242x2688.png" `
    "Voice input technology" `
    "Say the edit. FrameForge shapes the asset." `
    "Use natural voice prompts to guide layouts, captions, beautification, and AI design suggestions." `
    "voice" `
    "Less typing" `
    "Describe the outcome in plain language and keep moving."

Save-AppStoreShot "03_app_store_builder_1242x2688.png" `
    "App Store screenshot builder" `
    "Create store-ready sets without layout wrestling." `
    "Choose a premium template, frame your product, and prepare screenshots for multiple App Store sizes." `
    "builder" `
    "Made for review" `
    "Clean callouts, device framing, and consistent product story."

Save-AppStoreShot "04_premium_plans_1242x2688.png" `
    "Pro creator tools" `
    "Unlock premium workflows when you are ready to ship." `
    "Go from basic exports to unlimited creator tools, App Store generation, AI assistance, voice input, and agency workflows." `
    "paywall" `
    "Clear plans" `
    "Monthly, yearly, and agency options are shown before purchase."

Save-AppStoreShot "05_export_everywhere_1242x2688.png" `
    "Launch asset export" `
    "One workspace for every channel you publish to." `
    "Export polished PNG, JPG, PDF, App Store sets, and social sizes from a consistent creative system." `
    "export" `
    "Ready to share" `
    "Keep product visuals aligned across store, social, and client work."

Save-IPadShot "01_ipad_launch_ready_studio_2048x2732.png" `
    "For founders and creators" `
    "Build launch-ready visual systems on iPad." `
    "Plan, polish, and export screenshot sets from a spacious workspace designed for serious product launches." `
    "dashboard"

Save-IPadShot "02_ipad_voice_design_assistant_2048x2732.png" `
    "Voice input technology" `
    "Speak premium design direction into the studio." `
    "Use natural prompts to guide layouts, captions, beautification, and review-ready presentation." `
    "voice"

Save-IPadShot "03_ipad_app_store_builder_2048x2732.png" `
    "App Store screenshot builder" `
    "Compose store assets with canvas and inspector controls." `
    "Frame product screens, tune callouts, and prepare consistent App Store and social screenshots." `
    "builder"

Save-IPadShot "04_ipad_premium_plans_2048x2732.png" `
    "Pro creator tools" `
    "Show clear premium plans before purchase." `
    "Monthly, yearly, and agency options are presented with transparent pricing and workflow benefits." `
    "plans"

Save-IPadShot "05_ipad_export_everywhere_2048x2732.png" `
    "Launch asset export" `
    "Export one product story across every channel." `
    "Prepare PNG, JPG, PDF, App Store sets, social sizes, and client-ready assets from one workspace." `
    "export"

Save-SubscriptionReviewShot "agency_pro_monthly_review_1242x2688.png" "Agency Pro" "frameforge.agency.monthly"
Save-SubscriptionReviewShot "pro_creator_monthly_review_1242x2688.png" "Pro Creator" "frameforge.pro.monthly"
Save-SubscriptionReviewShot "pro_creator_yearly_review_1242x2688.png" "Pro Yearly" "frameforge.pro.yearly"

Save-SubscriptionReviewIPadShot "agency_pro_monthly_review_2048x2732.jpg" "Agency Pro" "frameforge.agency.monthly"
Save-SubscriptionReviewIPadShot "pro_creator_monthly_review_2048x2732.jpg" "Pro Creator" "frameforge.pro.monthly"
Save-SubscriptionReviewIPadShot "pro_creator_yearly_review_2048x2732.jpg" "Pro Yearly" "frameforge.pro.yearly"

Save-SubscriptionImage "agency_pro_monthly_1024.png" "Agency Pro" "GBP 29.99 monthly" "Brand kits, batch exports, advanced templates, and white-label exports for client work." "#FFB457"
Save-SubscriptionImage "pro_creator_monthly_1024.png" "Pro Creator" "GBP 9.99 monthly" "Unlimited exports, premium templates, App Store generator, AI assistant, and voice input." "#13D8FF"
Save-SubscriptionImage "pro_creator_yearly_1024.png" "Pro Yearly" "GBP 79.99 yearly" "The same Pro Creator tools with annual billing for creators shipping every month." "#A46CFF"

$manifest = @'
# FrameForge AI App Store Assets

Generated by `Tools/Generate-AppStoreAssets.ps1`.

## App Store screenshots

Use these for the iPhone 6.5-inch Display upload area in App Store Connect:

- `iPhone_6_5_Display/01_launch_ready_studio_1242x2688.png`
- `iPhone_6_5_Display/02_voice_design_assistant_1242x2688.png`
- `iPhone_6_5_Display/03_app_store_builder_1242x2688.png`
- `iPhone_6_5_Display/04_premium_plans_1242x2688.png`
- `iPhone_6_5_Display/05_export_everywhere_1242x2688.png`

Each file is 1242 x 2688 PNG.

For App Store Connect uploads, prefer the flattened RGB JPEG versions if PNG uploads show red validation errors:

- `iPhone_6_5_Display_RGB_JPEG/01_launch_ready_studio_1242x2688.jpg`
- `iPhone_6_5_Display_RGB_JPEG/02_voice_design_assistant_1242x2688.jpg`
- `iPhone_6_5_Display_RGB_JPEG/03_app_store_builder_1242x2688.jpg`
- `iPhone_6_5_Display_RGB_JPEG/04_premium_plans_1242x2688.jpg`
- `iPhone_6_5_Display_RGB_JPEG/05_export_everywhere_1242x2688.jpg`

## iPad screenshots

Use these for the iPad 13-inch Display upload area in App Store Connect:

- `iPad_13_Display/01_ipad_launch_ready_studio_2048x2732.png`
- `iPad_13_Display/02_ipad_voice_design_assistant_2048x2732.png`
- `iPad_13_Display/03_ipad_app_store_builder_2048x2732.png`
- `iPad_13_Display/04_ipad_premium_plans_2048x2732.png`
- `iPad_13_Display/05_ipad_export_everywhere_2048x2732.png`

Each file is 2048 x 2732 PNG.

Flattened RGB JPEG versions are also generated:

- `iPad_13_Display_RGB_JPEG/01_ipad_launch_ready_studio_2048x2732.jpg`
- `iPad_13_Display_RGB_JPEG/02_ipad_voice_design_assistant_2048x2732.jpg`
- `iPad_13_Display_RGB_JPEG/03_ipad_app_store_builder_2048x2732.jpg`
- `iPad_13_Display_RGB_JPEG/04_ipad_premium_plans_2048x2732.jpg`
- `iPad_13_Display_RGB_JPEG/05_ipad_export_everywhere_2048x2732.jpg`

## Subscription review screenshots

Use these in the Review Information Screenshot field for each subscription:

- `SubscriptionReview/agency_pro_monthly_review_1242x2688.png`
- `SubscriptionReview/pro_creator_monthly_review_1242x2688.png`
- `SubscriptionReview/pro_creator_yearly_review_1242x2688.png`

If App Store Connect rejects the iPhone-sized PNG for the subscription review field, use the iPad 13-inch JPEG files instead:

- `SubscriptionReview_iPad_13_Display/agency_pro_monthly_review_2048x2732.jpg`
- `SubscriptionReview_iPad_13_Display/pro_creator_monthly_review_2048x2732.jpg`
- `SubscriptionReview_iPad_13_Display/pro_creator_yearly_review_2048x2732.jpg`

Flattened iPhone 6.5-inch JPEG versions are also available:

- `SubscriptionReview_iPhone_6_5_Display_JPEG/agency_pro_monthly_review_1242x2688.jpg`
- `SubscriptionReview_iPhone_6_5_Display_JPEG/pro_creator_monthly_review_1242x2688.jpg`
- `SubscriptionReview_iPhone_6_5_Display_JPEG/pro_creator_yearly_review_1242x2688.jpg`

## Optional subscription images

Use these only if you want the optional 1024 x 1024 subscription promotional image:

- `SubscriptionImages/agency_pro_monthly_1024.png`
- `SubscriptionImages/pro_creator_monthly_1024.png`
- `SubscriptionImages/pro_creator_yearly_1024.png`

For App Store Connect uploads, prefer the flattened RGB JPEG versions to avoid alpha-channel rejection:

- `SubscriptionImages_RGB_JPEG/agency_pro_monthly_1024.jpg`
- `SubscriptionImages_RGB_JPEG/pro_creator_monthly_1024.jpg`
- `SubscriptionImages_RGB_JPEG/pro_creator_yearly_1024.jpg`
'@

Set-Content -LiteralPath (Join-Path $OutputRoot "README.md") -Value $manifest -Encoding UTF8

Write-Host "Generated assets in $OutputRoot"
