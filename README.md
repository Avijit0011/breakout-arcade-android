# Breakout Arcade Android 📱🎮 (LÖVE 2D & Lua)

A feature-rich, arcade-quality **Breakout Arcade** game built specifically for **Android** using **LÖVE (Love2D)** and **Lua**. Features multi-touch drag controls, interactive HUD touch pause button, glassmorphic UI design, procedural sound synthesis, 10 handcrafted level stages, 7 power-ups, and automated Android APK build pipelines.

![Android](https://img.shields.io/badge/Platform-Android-brightgreen?style=for-the-badge&logo=android)
![Love2D](https://img.shields.io/badge/LÖVE-11.5-pink?style=for-the-badge&logo=lua)
![Lua](https://img.shields.io/badge/Lua-5.1%20%2F%20LuaJIT-blue?style=for-the-badge&logo=lua)
![Resolution](https://img.shields.io/badge/Resolution-1080p%20Landscape-brightgreen?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---

## 🌟 Key Features

- 📱 **Multi-Touch & Touchscreen Controls**:
  - Drag finger left/right anywhere on screen for smooth paddle positioning.
  - Tap screen to launch ball in **SERVE** mode or fire **LASER** blasters.
  - Interactive **HUD Touch Pause button (`⏸️`)** at top-right of screen.
  - Touch drag-scrolling for the Stage Selection list.
- 📦 **Automated Android Packaging & APK Build Pipeline**:
  - 1-Click build script (`build.bat` / `build.ps1`) generating `dist/BreakoutArcade.love` and syncing `android/app/src/main/assets/game.love`.
  - Full Gradle project setup in `android/` to build standalone `.apk` installers via Android Studio or `./gradlew assembleDebug`.
- 🎼 **Procedural Soothing Background Music**:
  - Lush, relaxing ambient chord progression (**Cmaj7 → Am9 → Fmaj7 → G6**) synthesized on-the-fly.
  - Zero external `.mp3` or `.wav` music files required.
- 🎨 **Glassmorphic Visuals**: Dark space starfield backdrop, glowing card modals, dynamic screen shake, hit squish/stretch animations, vignette/scanline shaders, and floating score popups.
- 🎵 **Procedural Sound Effects Synthesizer**: Synthesizes all audio wave samples (bounce, brick shatter, steel chime, explosion, laser zap, power-up chime, fanfare) at runtime.
- 🧱 **5 Unique Brick Types**: Normal, 3-hit Tough, Indestructible Steel (+500 clear bonus), Explosive TNT chain reactions, and Powerup Bricks.
- ⚡ **7 Power-Up Abilities**: Multiball (3x), Expanded Paddle, Laser Cannons, Fireball Meteor, Safety Net, Extra Life, and 2x Score Multiplier.
- 🗺️ **10 Handcrafted Level Maps**: Handcrafted arcade stages from *Rainbow Arcade* to *Chaos Gauntlet*.

---

## 📁 Project Structure

```
breakout-arcade-android/
├── conf.lua           # Love2D window configuration (1920x1080 canvas, touch enabled)
├── main.lua           # Main game loop, state manager, touch input & rendering
├── build.ps1          # Automated PowerShell 1-click Android .love & APK asset builder
├── build.bat          # 1-click Batch launcher for Android build script
├── ANDROID_GUIDE.md   # Android deployment & installation guide
├── android/           # Standalone Android Gradle APK project setup
├── dist/              # Output directory for BreakoutArcade.love and release zips
├── README.md          # Project documentation
└── src/
    ├── constants.lua  # Touch HUD pause bounds, colors & virtual resolution
    ├── sounds.lua     # Procedural sound & soothing background music synthesizer
    ├── visuals.lua    # Starfields, playfield grids, scanlines & glass visual effects
    ├── particle.lua   # Particle explosion engine, screen shake & floating score text
    ├── brick.lua      # Multi-type brick entities & procedural crack rendering
    ├── powerup.lua    # Powerup capsules & collection logic
    ├── paddle.lua     # Paddle entity, squish animation & laser cannons
    ├── ball.lua       # Ball circle-AABB collisions, speed scaling & fireball
    ├── levels.lua     # Handcrafted 5-stage level map generator
    └── ui.lua         # Glassmorphic HUD, stage selector & state screens
```

---

## 🚀 How to Run & Build for Android

### Method 1: Instant Play via LÖVE for Android App (No Compilation)
1. Install **LÖVE for Android** from the [Google Play Store](https://play.google.com/store/apps/details?id=org.love2d.android) or GitHub.
2. Run `build.bat` or `.\build.ps1` to compile `dist/BreakoutArcade.love`.
3. Transfer `BreakoutArcade.love` to your Android device and tap to open it in **LÖVE**.

### Method 2: Standalone APK Packaging (.apk)
1. Run `build.bat` (this syncs `android/app/src/main/assets/game.love`).
2. Open the `android/` directory in **Android Studio**.
3. Build & Install: `./gradlew assembleDebug` or click **Run** in Android Studio to install `app-debug.apk` directly on your device.

See [ANDROID_GUIDE.md](file:///x:/breakout%20-%20Copy/ANDROID_GUIDE.md) for full instructions!

---

## 🎮 Touchscreen Controls Guide

| Action | Touchscreen Gesture |
| :--- | :--- |
| **Move Paddle** | Drag finger left / right anywhere on screen |
| **Launch Ball / Fire Lasers** | Tap anywhere on screen |
| **Pause Game** | Tap **`⏸️` HUD Pause Button** at top-right |
| **Scroll Stage List** | Drag finger up / down in Stage Select list |
| **Select Menu Choice** | Tap directly on any menu button |
| **Quit Game** | Tap **Quit Game** button in menu |

---

## 📜 License

Distributed under the MIT License. Feel free to use, modify, and build upon this codebase!
