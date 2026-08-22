# Breakout Arcade 🎮 (LÖVE 2D & Lua)

A feature-rich, arcade-quality **Breakout** game built from scratch using the **LÖVE (Love2D)** framework and **Lua**. Features glassmorphic UI design, procedural sound synthesis, particle explosion systems, handcrafted level stages, and extensive power-ups.

![Love2D](https://img.shields.io/badge/LÖVE-11.5-pink?style=for-the-badge&logo=lua)
![Lua](https://img.shields.io/badge/Lua-5.1%20%2F%20LuaJIT-blue?style=for-the-badge&logo=lua)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---

## 🌟 Key Features

- 🎨 **Glassmorphic Arcade Visuals**: Dark space starfield backdrop, glowing card modals, dynamic screen shake, hit squish/stretch animations, and floating score popups.
- 🎵 **Procedural Sound Synthesizer**: Generates all audio wave samples (bounce, brick shatter, steel chime, explosion, laser zap, power-up chime, fanfare) at runtime without external `.wav` or `.mp3` files.
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
- 🏆 **Persistence & Combo Chains**: Automatic high score saving (`highscore.dat`) and combo multiplier chain system.

---

## 📁 Project Structure

```
breakout/
├── conf.lua           # Love2D window configuration (1280x720, resizable)
├── main.lua           # Main game loop, state manager & rendering
├── run.bat            # Windows 1-click Batch launcher script
├── run.ps1            # Windows 1-click PowerShell launcher script
├── README.md          # Project documentation
└── src/
    ├── constants.lua  # Color palette, virtual resolution & physics parameters
    ├── sounds.lua     # Procedural sound synthesizer (newSoundData)
    ├── particle.lua   # Particle explosion engine, starfield & floating score text
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
