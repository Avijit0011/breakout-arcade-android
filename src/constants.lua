local Constants = {}

Constants.VIRTUAL_WIDTH = 1280
Constants.VIRTUAL_HEIGHT = 720

-- Wall & Playfield boundaries
Constants.PLAYFIELD_X = 30
Constants.PLAYFIELD_Y = 60
Constants.PLAYFIELD_WIDTH = 1220
Constants.PLAYFIELD_HEIGHT = 650

-- Color Palette (RGB 0.0 - 1.0 for LÖVE 11+)
Constants.COLORS = {
    BACKGROUND      = {0.03, 0.02, 0.08, 1.0},
    SKY_TOP         = {0.04, 0.03, 0.12, 1.0},
    SKY_BOTTOM      = {0.10, 0.04, 0.16, 1.0},
    GRID_LINE       = {0.12, 0.10, 0.22, 0.5},
    HUD_BG          = {0.06, 0.05, 0.14, 0.72},
    TEXT_MAIN       = {0.96, 0.97, 1.00, 1.0},
    TEXT_MUTED      = {0.62, 0.66, 0.82, 1.0},
    ACCENT_CYAN     = {0.25, 0.95, 1.00, 1.0},
    ACCENT_GOLD     = {1.00, 0.84, 0.28, 1.0},
    ACCENT_PINK     = {1.00, 0.32, 0.68, 1.0},
    ACCENT_VIOLET   = {0.62, 0.38, 1.00, 1.0},
    SAFETY_NET      = {0.20, 0.90, 1.00, 0.85},

    PADDLE_BASE     = {0.20, 0.75, 0.95, 1.0},
    PADDLE_GLOW     = {0.00, 0.90, 1.00, 0.4},
    PADDLE_LASER    = {1.00, 0.20, 0.30, 1.0},

    BALL_NORMAL     = {1.00, 0.95, 0.85, 1.0},
    BALL_FIRE       = {1.00, 0.40, 0.10, 1.0},
    BALL_STICKY     = {0.20, 0.95, 0.40, 1.0},

    -- Brick Tier Colors
    BRICK_TIERS = {
        {0.95, 0.25, 0.35, 1.0}, -- Tier 1: Crimson Red
        {1.00, 0.55, 0.15, 1.0}, -- Tier 2: Amber Orange
        {0.98, 0.85, 0.20, 1.0}, -- Tier 3: Bright Gold
        {0.25, 0.88, 0.45, 1.0}, -- Tier 4: Neon Green
        {0.15, 0.80, 0.98, 1.0}, -- Tier 5: Electric Cyan
        {0.70, 0.35, 0.95, 1.0}, -- Tier 6: Royal Purple
        {0.95, 0.35, 0.75, 1.0}, -- Tier 7: Magenta Pink
    },

    BRICK_STEEL     = {0.70, 0.75, 0.82, 1.0},
    BRICK_TNT       = {0.95, 0.20, 0.15, 1.0},
    BRICK_POWERUP   = {1.00, 0.85, 0.10, 1.0},

    -- Powerup Colors
    POWERUP = {
        MULTIBALL   = {0.20, 0.85, 1.00, 1.0},
        EXPAND      = {0.30, 0.95, 0.40, 1.0},
        LASER       = {1.00, 0.25, 0.35, 1.0},
        FIREBALL    = {1.00, 0.50, 0.10, 1.0},
        SAFETY_NET  = {0.10, 0.75, 0.95, 1.0},
        EXTRA_LIFE  = {1.00, 0.30, 0.60, 1.0},
        MULTIPLIER  = {1.00, 0.85, 0.10, 1.0},
    }
}

-- Paddle Settings
Constants.PADDLE_BASE_WIDTH = 120
Constants.PADDLE_EXPAND_WIDTH = 180
Constants.PADDLE_HEIGHT = 18
Constants.PADDLE_SPEED = 750
Constants.PADDLE_Y = 660

-- Ball Settings
Constants.BALL_RADIUS = 9
Constants.BALL_BASE_SPEED = 500
Constants.BALL_MAX_SPEED = 900
Constants.BALL_SPEED_INC = 12

-- Powerup Types
Constants.POWERUP_TYPES = {
    "MULTIBALL",
    "EXPAND",
    "LASER",
    "FIREBALL",
    "SAFETY_NET",
    "EXTRA_LIFE",
    "MULTIPLIER"
}

-- Touch HUD Pause Button Constants
Constants.PAUSE_BTN_X = 1200
Constants.PAUSE_BTN_Y = 12
Constants.PAUSE_BTN_WIDTH = 50
Constants.PAUSE_BTN_HEIGHT = 38

function Constants.isAndroid()
    return love.system and love.system.getOS() == "Android"
end

return Constants

