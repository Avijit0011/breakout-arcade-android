# Breakout Arcade 🎮 (LÖVE 2D & Lua)

A feature-rich, arcade-quality **Breakout** game built from scratch using the **LÖVE (Love2D)** framework and **Lua**. Features glassmorphic UI design, procedural sound and music synthesis, particle explosion systems, handcrafted level stages, extensive power-ups, and native Windows executable building.

![Love2D](https://img.shields.io/badge/LÖVE-11.5-pink?style=for-the-badge&logo=lua)
![Lua](https://img.shields.io/badge/Lua-5.1%20%2F%20LuaJIT-blue?style=for-the-badge&logo=lua)
![Resolution](https://img.shields.io/badge/Resolution-1080p%20Full%20HD-brightgreen?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---

## 🌟 Key Features

- 🖥️ **1080p Full HD & Display Mode Switcher**:
  - Runs natively at **1920x1080 Full HD** resolution.
  - Interactive **Fullscreen & Windowed mode switcher** directly from the Main Menu and Pause Menu.
  - **`F11`** or **`Alt + Enter`** global shortcut to toggle display mode at any time.
  - Automatic persistent display settings (`settings.dat`).
- 🎼 **Procedural Soothing Background Music**:
  - Lush, relaxing ambient chord progression (**Cmaj7 → Am9 → Fmaj7 → G6**) synthesized at runtime with warm detuned pads, sub-bass, and shimmering arpeggios.
  - Zero external `.mp3` or `.wav` music files required.
  - Press **`M`** at any time to mute or unmute music.
- 🎨 **Glassmorphic Arcade Visuals**: Dark space starfield backdrop, glowing card modals, dynamic screen shake, hit squish/stretch animations, vignette/scanline shaders, and floating score popups.
- 🎵 **Procedural Sound Effects Synthesizer**: Synthesizes all audio wave samples (bounce, brick shatter, steel chime, explosion, laser zap, power-up chime, fanfare) on-the-fly.
- 📦 **1-Click Standalone Windows Executable Compiler**:
  - Automated PowerShell (`build.ps1`) and Batch (`build.bat`) build scripts.
  - Generates standalone `BreakoutArcade.exe` and release `BreakoutArcade-Windows.zip` ready for distribution.
- 🧱 **5 Unique Brick Types**:
  - **Normal Bricks**: 1-hit colorful tier bricks.
  - **Tough Bricks**: 2–3 hits with procedural visual crack overlays.
  - **Unbreakable Steel Bricks**: Indestructible until clearable bricks are destroyed (+500 score bonus).
  - **Explosive TNT Bricks**: Triggers radial chain reactions destroying nearby bricks.
  - **Powerup Bricks**: Guaranteed power-up drop when broken.
- ⚡ **7 Power-Up Abilities**:
  - 🟢 **Multiball (3x)**: Spawns 2 extra active balls in play.
  - 🟦 **Expanded Paddle**: Widens paddle width by +50%.
  - 🟥 **Laser Cannons**: Mounts dual laser blasters to paddle (shoot with Spacebar / Click).
  - ⚡ **Fireball**: Meteor ball that pierces through bricks without bouncing back.
  - 🛡️ **Safety Net**: Glowing bottom shield that saves lost balls once.
  - ❤️ **Extra Life**: Restores 1 life heart.
  - 💰 **2x Score Multiplier**: Doubles points scored for 15 seconds.
- 🗺️ **5 Handcrafted Level Maps**:
  1. *Rainbow Arcade*
  2. *Crystal Pyramid*
  3. *Retro Invader*
  4. *Diamond Fortress*
  5. *Chaos Core*
- 🕹️ **Dual Controls & Responsive Canvas**: Supports keyboard (Arrow keys / A-D / Space) and mouse controls with automatic letterbox viewport scaling.
- 🏆 **Persistence & Combo Chains**: Automatic high score saving (`highscore.dat`), display settings saving (`settings.dat`), and combo multiplier chain system.

---

## 📁 Project Structure

```
breakout/
├── conf.lua           # Love2D window configuration (1920x1080 1080p, resizable)
├── main.lua           # Main game loop, state manager, keyboard & rendering
├── build.ps1          # Automated PowerShell 1-click .exe compiler script
├── build.bat          # Windows File Explorer 1-click build launcher
├── run.ps1            # Windows 1-click PowerShell launcher script
├── run.bat            # Windows 1-click Batch launcher script
├── README.md          # Project documentation
└── src/
    ├── constants.lua  # Color palette, virtual resolution & physics parameters
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

## 🚀 How to Run & Build `.exe`

### 1. Standalone Executable (.exe)
You can launch the compiled game directly by running:
- **Executable**: `dist/BreakoutArcade/BreakoutArcade.exe`
- **ZIP Release**: `dist/BreakoutArcade-Windows.zip` (shareable standalone zip)

### 2. Rebuilding the `.exe`
If you make modifications to the source code and want to rebuild the `.exe` package, run:
```powershell
.\build.ps1
```
or double-click `build.bat` in File Explorer.

### 3. Windows 1-Click Launchers (Development Mode)
Run either script in your terminal or double-click in File Explorer:
```powershell
.\run.ps1
```
or
```cmd
.\run.bat
```

### 4. Standard LÖVE 2D CLI
If you have [LÖVE](https://love2d.org/) installed globally:
```bash
love .
```

---

## 🎮 Controls

| Action | Keyboard | Mouse |
| :--- | :--- | :--- |
| **Move Paddle** | Left / Right Arrows or `A` / `D` | Move Cursor |
| **Launch Ball / Fire Lasers** | `Spacebar` or `Enter` | Left Click |
| **Pause Game** | `P` or `Escape` | — |
| **Toggle Soothing Music** | `M` | Mute / Unmute Music |
| **Toggle Fullscreen / Window** | `F11` or `Alt + Enter` | Click Display Button in Menu |
| **Menu Navigation** | Up / Down Arrows or `W` / `S` | Move Cursor |
| **Confirm Menu Choice** | `Enter` or `Spacebar` | Left Click |
| **Quit Game** | `Escape` in menus or select `Quit` | Click Quit Button |

---

## 📜 License

Distributed under the MIT License. Feel free to use, modify, and build upon this codebase!
