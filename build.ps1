# Breakout Arcade - Build Executable (.exe) Script
# Creates a standalone Windows .exe package in dist/BreakoutArcade/ and a release .zip file.

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.IO.Compression.FileSystem

$distDir = "$PSScriptRoot\dist"
$buildDir = "$distDir\BreakoutArcade"
$loveFile = "$distDir\BreakoutArcade.love"
$zipFile = "$distDir\BreakoutArcade-Windows.zip"

Write-Host "Building Breakout Arcade Windows Executable..." -ForegroundColor Cyan

# Stop any running game instances to prevent file lock errors
Get-Process -Name "love", "BreakoutArcade" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 300

# Ensure output directories exist & clean previous build
if (Test-Path $zipFile) { Remove-Item -Path $zipFile -Force }
if (Test-Path $loveFile) { Remove-Item -Path $loveFile -Force }
if (Test-Path $buildDir) { Remove-Item -Path $buildDir -Recurse -Force }

New-Item -ItemType Directory -Path $buildDir -Force | Out-Null

# 1. Create .love archive (main.lua, conf.lua, src/)
$tempZip = "$distDir\temp_game.zip"
if (Test-Path $tempZip) { Remove-Item -Path $tempZip -Force }

Compress-Archive -Path "$PSScriptRoot\main.lua", "$PSScriptRoot\conf.lua", "$PSScriptRoot\src" -DestinationPath $tempZip
Move-Item -Path $tempZip -Destination $loveFile -Force
Write-Host "[1/4] Created BreakoutArcade.love" -ForegroundColor Green

# 2. Fuse love.exe + BreakoutArcade.love -> BreakoutArcade.exe
$loveExe = "$PSScriptRoot\love\love.exe"
if (-not (Test-Path $loveExe)) {
    Write-Error "love.exe not found at $loveExe! Cannot construct executable."
    exit 1
}

$outputExe = "$buildDir\BreakoutArcade.exe"
cmd.exe /c "copy /b `"$loveExe`"+`"$loveFile`" `"$outputExe`"" | Out-Null
Write-Host "[2/4] Fused binary into BreakoutArcade.exe" -ForegroundColor Green

# 3. Copy required Love2D DLL dependencies & licenses
$requiredFiles = @("love.dll", "lua51.dll", "SDL2.dll", "OpenAL32.dll", "mpg123.dll", "msvcp120.dll", "msvcr120.dll")
foreach ($file in $requiredFiles) {
    $srcFile = "$PSScriptRoot\love\$file"
    if (Test-Path $srcFile) {
        Copy-Item -Path $srcFile -Destination $buildDir -Force
    } else {
        Write-Warning "Dependency missing: $file"
    }
}

if (Test-Path "$PSScriptRoot\love\license.txt") {
    Copy-Item -Path "$PSScriptRoot\love\license.txt" -Destination "$buildDir\LOVE-license.txt" -Force
}

# Create README.txt in build folder
$readmeContent = @"
Breakout Arcade - Standalone Windows Executable
===============================================

How to Play:
Double-click BreakoutArcade.exe to launch the game!

Controls:
- Move Paddle: Left / Right Arrow keys, A / D, or Mouse Movement
- Launch Ball / Fire Lasers: Spacebar, Enter, or Left Mouse Click
- Pause Game: P or Escape key
- Menu Select: Up / Down Arrow keys or Mouse
"@
Set-Content -Path "$buildDir\README.txt" -Value $readmeContent -Encoding UTF8
Write-Host "[3/4] Copied runtime DLLs & created README.txt" -ForegroundColor Green

# 4. Pack into release ZIP using .NET ZipFile
[System.IO.Compression.ZipFile]::CreateFromDirectory($buildDir, $zipFile)
Write-Host "[4/4] Created release zip: BreakoutArcade-Windows.zip" -ForegroundColor Green

Write-Host "`n==================================================" -ForegroundColor Yellow
Write-Host "BUILD COMPLETE SUCCESS!" -ForegroundColor Yellow
Write-Host "Executable location: $buildDir\BreakoutArcade.exe" -ForegroundColor Cyan
Write-Host "Zip file distribution: $zipFile" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Yellow
