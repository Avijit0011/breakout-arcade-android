# Breakout Arcade - Android Packaging & APK Build Script
# Creates dist/BreakoutArcade.love, dist/BreakoutArcade-Android.zip, and populates android/app/src/main/assets/game.love

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.IO.Compression.FileSystem

$distDir = "$PSScriptRoot\dist"
$loveFile = "$distDir\BreakoutArcade.love"
$androidZip = "$distDir\BreakoutArcade-Android.zip"
$androidAssetsDir = "$PSScriptRoot\android\app\src\main\assets"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Building Breakout Arcade Android Package..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Ensure output directory exists & clean old build artifacts
if (-not (Test-Path $distDir)) { New-Item -ItemType Directory -Path $distDir -Force | Out-Null }
if (Test-Path $loveFile) { Remove-Item -Path $loveFile -Force }
if (Test-Path $androidZip) { Remove-Item -Path $androidZip -Force }

# 2. Package game source into BreakoutArcade.love (.zip archive format for Love2D)
$tempZip = "$distDir\temp_game.zip"
if (Test-Path $tempZip) { Remove-Item -Path $tempZip -Force }

Compress-Archive -Path "$PSScriptRoot\main.lua", "$PSScriptRoot\conf.lua", "$PSScriptRoot\src" -DestinationPath $tempZip
Move-Item -Path $tempZip -Destination $loveFile -Force
Write-Host "[1/3] Created dist/BreakoutArcade.love package." -ForegroundColor Green

# 3. Copy game.love into Android Gradle assets directory
if (-not (Test-Path $androidAssetsDir)) {
    New-Item -ItemType Directory -Path $androidAssetsDir -Force | Out-Null
}
Copy-Item -Path $loveFile -Destination "$androidAssetsDir\game.love" -Force
Write-Host "[2/3] Synced assets to android/app/src/main/assets/game.love." -ForegroundColor Green

# 4. Create Android Release ZIP bundle containing BreakoutArcade.love and ANDROID_GUIDE.md
$tempAndroidBundle = "$distDir\BreakoutArcade-Android"
if (Test-Path $tempAndroidBundle) { Remove-Item -Path $tempAndroidBundle -Recurse -Force }
New-Item -ItemType Directory -Path $tempAndroidBundle -Force | Out-Null

Copy-Item -Path $loveFile -Destination "$tempAndroidBundle\BreakoutArcade.love" -Force
if (Test-Path "$PSScriptRoot\ANDROID_GUIDE.md") {
    Copy-Item -Path "$PSScriptRoot\ANDROID_GUIDE.md" -Destination "$tempAndroidBundle\ANDROID_GUIDE.md" -Force
}

[System.IO.Compression.ZipFile]::CreateFromDirectory($tempAndroidBundle, $androidZip)
Remove-Item -Path $tempAndroidBundle -Recurse -Force
Write-Host "[3/3] Created release bundle dist/BreakoutArcade-Android.zip." -ForegroundColor Green

Write-Host "`n==================================================" -ForegroundColor Yellow
Write-Host "ANDROID BUILD COMPLETE SUCCESS!" -ForegroundColor Yellow
Write-Host "Love2D Package: $loveFile" -ForegroundColor Cyan
Write-Host "Android Bundle Zip: $androidZip" -ForegroundColor Cyan
Write-Host "Android Assets: $androidAssetsDir\game.love" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Yellow
