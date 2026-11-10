Add-Type -AssemblyName System.Drawing
$bitmap = New-Object System.Drawing.Bitmap 512,512
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.Clear([System.Drawing.Color]::FromArgb(13,19,30))
$gold = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(225,185,99))
$muted = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(37,49,66))
$green = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(86,209,158))
$red = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(242,121,103))
$pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(225,185,99)),8
$graphics.DrawEllipse($pen,28,28,456,456)
$font = New-Object System.Drawing.Font 'Segoe UI',82,([System.Drawing.FontStyle]::Bold),([System.Drawing.GraphicsUnit]::Pixel)
$format = New-Object System.Drawing.StringFormat
$format.Alignment = [System.Drawing.StringAlignment]::Center
$graphics.DrawString('PP',$font,$gold,([System.Drawing.RectangleF]::new(60,87,392,110)),$format)
foreach ($y in @(246,306,366)) { $graphics.FillRectangle($muted,104,$y,304,24) }
$graphics.FillRectangle($green,104,246,264,24)
$graphics.FillRectangle($gold,104,306,192,24)
$graphics.FillRectangle($red,104,366,120,24)
$graphics.DrawLine($pen,288,227,288,409)
$bitmap.Save((Join-Path $PSScriptRoot 'icon.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$format.Dispose()
$font.Dispose()
$pen.Dispose()
$red.Dispose()
$green.Dispose()
$muted.Dispose()
$gold.Dispose()
$graphics.Dispose()
$bitmap.Dispose()
