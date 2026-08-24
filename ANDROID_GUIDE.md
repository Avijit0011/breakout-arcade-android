# Breakout Arcade - Android User Guide 📱

Play **Breakout Arcade** on any Android smartphone or tablet with full touchscreen controls, glassmorphic HUD pause button, smooth drag paddle movement, and stage select scrolling.

---

## 🚀 Play Options

### Option 1: Instant Play via LÖVE for Android App (Recommended - No Compilation Needed)

1. **Install LÖVE for Android**:
   - Download the **LÖVE for Android** app directly from [Love2D GitHub Releases](https://github.com/love2d/love-android/releases).
2. **Build or Download `BreakoutArcade.love`**:
   - Run `build_android.bat` or `.\build_android.ps1` on your PC.
   - The compiled package is located at `dist/BreakoutArcade.love` (and inside `dist/BreakoutArcade-Android.zip`).
3. **Transfer to Your Phone**:
   - Copy `BreakoutArcade.love` to your phone's Storage / Downloads folder via USB, Google Drive, Bluetooth, or messaging app.
4. **Launch & Play**:
   - Open your file manager on Android and tap **`BreakoutArcade.love`**.
   - Select **LÖVE** to open the file.
   - The game launches instantly in landscape widescreen with full touch controls!

---

### Option 2: Standalone APK Packaging (.apk)

To build a standalone APK installer (`BreakoutArcade.apk`) for distribution:

1. **Run Android Package Build**:
   ```cmd
   build_android.bat
   ```
   *This automatically generates `dist/BreakoutArcade.love` and places it inside `android/app/src/main/assets/game.love`.*

2. **Build APK via Android Studio / Gradle**:
   - Open the `android/` directory in **Android Studio**.
   - Or run Gradle from terminal:
     ```bash
     cd android
     ./gradlew assembleDebug
     ```
   - The standalone APK output will be created at:
     `android/app/build/outputs/apk/debug/app-debug.apk`

3. **Install on Android**:
   - Transfer `app-debug.apk` to your Android device and tap to install.

---

## 🎮 Touchscreen Controls Guide

| Action | Touch Control |
| :--- | :--- |
| **Move Paddle** | Drag finger left/right anywhere on screen (Paddle follows touch position). |
| **Serve Ball / Launch** | Tap anywhere on screen while in **SERVE** mode. |
| **Shoot Lasers** | Tap anywhere on screen when **LASER** power-up is active. |
| **Pause Game** | Tap the **`⏸️` HUD Pause Button** at top-right of screen. |
| **Scroll Stage List** | Drag finger up/down in the **SELECT STAGE** list. |
| **Select Menu Items** | Tap directly on any menu button (Start, Stage Select, Resume, Main Menu, Quit). |

---

## 🛠️ Requirements & Compatibility

- **Android Version**: Android 5.0 (API Level 21) or newer.
- **Screen Orientation**: Auto-locks to Landscape mode for full 1080p canvas scaling.
- **Audio & Sound**: Procedural synthesizer audio runs smoothly on all ARM / ARM64 Android devices.
