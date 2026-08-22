$localLove = Join-Path $PSScriptRoot "love\love.exe"
if (Test-Path $localLove) {
    Write-Host "Launching Breakout using portable Love2D..." -ForegroundColor Green
    Start-Process -FilePath $localLove -ArgumentList "`"$PSScriptRoot`""
    exit 0
}

$systemLove = "C:\Program Files\LOVE\love.exe"
if (Test-Path $systemLove) {
    Write-Host "Launching Breakout using system Love2D..." -ForegroundColor Green
    Start-Process -FilePath $systemLove -ArgumentList "`"$PSScriptRoot`""
    exit 0
}

love "$PSScriptRoot"
