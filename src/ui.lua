local Constants = require("src.constants")

local UI = {}

local fonts = {}
local titlePulse = 0

function UI.init()
    fonts.small  = love.graphics.newFont(15)
    fonts.medium = love.graphics.newFont(20)
    fonts.large  = love.graphics.newFont(32)
    fonts.title  = love.graphics.newFont(54)
    fonts.badge  = love.graphics.newFont(14)
end

function UI.update(dt)
    titlePulse = titlePulse + dt * 4
end

-- Helper to draw centered text with optional shadow
local function drawCenteredText(font, text, y, color, shadowColor)
    love.graphics.setFont(font)
    local width = font:getWidth(text)
    local x = (Constants.VIRTUAL_WIDTH - width) / 2

    if shadowColor then
        love.graphics.setColor(shadowColor)
        love.graphics.print(text, x + 2, y + 2)
    end

    love.graphics.setColor(color or Constants.COLORS.TEXT_MAIN)
    love.graphics.print(text, x, y)
end

-- Draw a Glassmorphic Card Container
function UI.drawGlassCard(x, y, width, height, cornerRadius, borderColor)
    cornerRadius = cornerRadius or 12
    -- Dark translucent card background
    love.graphics.setColor(0.06, 0.05, 0.14, 0.85)
    love.graphics.rectangle("fill", x, y, width, height, cornerRadius, cornerRadius)

    -- Top inner specular highlight
    love.graphics.setColor(1, 1, 1, 0.08)
    love.graphics.rectangle("fill", x + 3, y + 3, width - 6, math.min(18, height / 3), cornerRadius - 2, cornerRadius - 2)

    -- Glowing border line
    love.graphics.setColor(borderColor or Constants.COLORS.ACCENT_CYAN)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height, cornerRadius, cornerRadius)
end

-- Helper to draw an interactive menu option button
function UI.drawMenuButton(font, text, y, isSelected, customWidth)
    local width = customWidth or 380
    local height = 50
    local x = (Constants.VIRTUAL_WIDTH - width) / 2

    love.graphics.setFont(font)

    if isSelected then
        local pulseScale = 1 + math.sin(titlePulse * 3.5) * 0.025
        love.graphics.push()
        love.graphics.translate(Constants.VIRTUAL_WIDTH / 2, y + height / 2)
        love.graphics.scale(pulseScale, pulseScale)
        love.graphics.translate(-Constants.VIRTUAL_WIDTH / 2, -(y + height / 2))

        -- Active Button Background & Neon Glow
        love.graphics.setColor(0.12, 0.10, 0.26, 0.95)
        love.graphics.rectangle("fill", x, y, width, height, 12, 12)

        -- Outer neon glow line
        love.graphics.setColor(0.00, 0.90, 1.00, 0.3)
        love.graphics.setLineWidth(6)
        love.graphics.rectangle("line", x - 2, y - 2, width + 4, height + 4, 14, 14)

        love.graphics.setColor(Constants.COLORS.ACCENT_CYAN)
        love.graphics.setLineWidth(2.5)
        love.graphics.rectangle("line", x, y, width, height, 12, 12)

        -- Button Text
        local displayText = "▶   " .. text .. "   ◀"
        local textW = font:getWidth(displayText)
        love.graphics.setColor(Constants.COLORS.ACCENT_GOLD)
        love.graphics.print(displayText, (Constants.VIRTUAL_WIDTH - textW) / 2, y + (height - font:getHeight()) / 2)

        love.graphics.pop()
    else
        -- Unselected Button
        love.graphics.setColor(0.06, 0.05, 0.12, 0.70)
        love.graphics.rectangle("fill", x, y, width, height, 12, 12)

        love.graphics.setColor(0.25, 0.25, 0.38, 0.5)
        love.graphics.setLineWidth(1.5)
        love.graphics.rectangle("line", x, y, width, height, 12, 12)

        local textW = font:getWidth(text)
        love.graphics.setColor(Constants.COLORS.TEXT_MUTED)
        love.graphics.print(text, (Constants.VIRTUAL_WIDTH - textW) / 2, y + (height - font:getHeight()) / 2)
    end
end

-- Draw HUD Header
function UI.drawHUD(score, highScore, lives, levelName, combo, multiplier, safetyNetActive, activePowerups)
    -- Top HUD Glass Header Bar
    UI.drawGlassCard(15, 8, Constants.VIRTUAL_WIDTH - 30, 44, 10, {0.15, 0.75, 0.95, 0.4})

    love.graphics.setFont(fonts.medium)

    -- Score Pill Widget
    love.graphics.setColor(Constants.COLORS.ACCENT_GOLD)
    love.graphics.print(string.format("SCORE: %06d", score), 35, 18)

    -- High Score Pill Widget
    love.graphics.setColor(Constants.COLORS.TEXT_MUTED)
    love.graphics.print(string.format("HIGH: %06d", highScore), 330, 18)

    -- Stage Title Badge
    love.graphics.setColor(Constants.COLORS.TEXT_MAIN)
    local stageText = levelName or "Stage 1"
    love.graphics.print(stageText, 620 - fonts.medium:getWidth(stageText) / 2, 18)

    -- Combo & Multiplier Badge
    if combo > 1 or multiplier > 1 then
        local multiText = string.format("⚡ COMBO x%d", combo * multiplier)
        love.graphics.setColor(Constants.COLORS.ACCENT_PINK)
        love.graphics.print(multiText, 850, 18)
    end

    -- Pulsing Animated Heart Containers for Lives
    local heartX = Constants.VIRTUAL_WIDTH - 150
    local heartScale = 1 + math.sin(titlePulse * 2.5) * 0.08
    for i = 1, lives do
        local hx = heartX + (i - 1) * 32
        local hy = 30

        love.graphics.push()
        love.graphics.translate(hx, hy)
        love.graphics.scale(heartScale, heartScale)

        -- Glowing Heart Outer Aura
        love.graphics.setColor(1, 0.2, 0.4, 0.3)
        love.graphics.circle("fill", -4, -4, 8)
        love.graphics.circle("fill", 4, -4, 8)

        -- Core Animated Heart
        love.graphics.setColor(1, 0.25, 0.50, 1)
        love.graphics.circle("fill", -4, -4, 6)
        love.graphics.circle("fill", 4, -4, 6)
        love.graphics.polygon("fill", -10, -2, 10, -2, 0, 10)

        love.graphics.pop()
    end

    -- Active Powerup Badges HUD (Bottom Left)
    if activePowerups then
        local badgeX = 30
        local badgeY = Constants.VIRTUAL_HEIGHT - 40
        love.graphics.setFont(fonts.badge)

        for name, timer in pairs(activePowerups) do
            if timer > 0 then
                -- Badge background box
                love.graphics.setColor(0.08, 0.06, 0.16, 0.85)
                love.graphics.rectangle("fill", badgeX, badgeY, 140, 28, 8, 8)

                local pColor = Constants.COLORS.POWERUP[name] or {1, 1, 1, 1}
                love.graphics.setColor(pColor)
                love.graphics.setLineWidth(1.5)
                love.graphics.rectangle("line", badgeX, badgeY, 140, 28, 8, 8)

                -- Countdown progress bar fill
                local maxTimeMap = { EXPAND = 12, LASER = 10, MULTIPLIER = 15 }
                local maxT = maxTimeMap[name] or 10
                local pct = math.max(0, math.min(1, timer / maxT))
                love.graphics.setColor(pColor[1], pColor[2], pColor[3], 0.3)
                love.graphics.rectangle("fill", badgeX + 2, badgeY + 2, (136) * pct, 24, 6, 6)

                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.print(string.format("%s: %.1fs", name, timer), badgeX + 10, badgeY + 6)

                badgeX = badgeX + 155
            end
        end
    end

    -- Draw Safety Net Electric Shield if Active
    if safetyNetActive then
        local netY = Constants.VIRTUAL_HEIGHT - 25
        local alphaPulse = 0.6 + math.sin(titlePulse * 4) * 0.3

        love.graphics.setColor(0.0, 0.85, 1.0, alphaPulse)
        love.graphics.setLineWidth(4)
        love.graphics.line(Constants.PLAYFIELD_X, netY, Constants.PLAYFIELD_X + Constants.PLAYFIELD_WIDTH, netY)

        -- Glowing node circles along safety net
        for x = Constants.PLAYFIELD_X, Constants.PLAYFIELD_X + Constants.PLAYFIELD_WIDTH, 40 do
            love.graphics.circle("fill", x, netY, 4)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

-- Main Title Screen Menu
function UI.drawStartScreen(highScore, selectedIndex, menuOptions)
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", 0, 0, Constants.VIRTUAL_WIDTH, Constants.VIRTUAL_HEIGHT)

    -- Floating Header Logo Frame
    local titleY = 100 + math.sin(titlePulse) * 5
    love.graphics.setFont(fonts.title)

    -- Drop Shadow Header
    love.graphics.setColor(Constants.COLORS.ACCENT_PINK)
    love.graphics.print("BREAKOUT ARCADE", (Constants.VIRTUAL_WIDTH - fonts.title:getWidth("BREAKOUT ARCADE")) / 2 + 4, titleY + 4)

    -- Cyan Main Header
    love.graphics.setColor(Constants.COLORS.ACCENT_CYAN)
    love.graphics.print("BREAKOUT ARCADE", (Constants.VIRTUAL_WIDTH - fonts.title:getWidth("BREAKOUT ARCADE")) / 2, titleY)

    drawCenteredText(fonts.medium, "★ LÖVE 2D EDITION ★", titleY + 68, Constants.COLORS.ACCENT_GOLD)
    drawCenteredText(fonts.medium, string.format("HIGH SCORE: %06d", highScore), titleY + 102, Constants.COLORS.TEXT_MUTED)

    -- Glassmorphic Menu Container Card
    local cardW, cardH = 460, 240
    local cardX = (Constants.VIRTUAL_WIDTH - cardW) / 2
    local cardY = 305
    UI.drawGlassCard(cardX, cardY, cardW, cardH, 16, {0.00, 0.90, 1.00, 0.4})

    -- Interactive Menu Buttons
    local startY = cardY + 28
    for i, optionText in ipairs(menuOptions) do
        UI.drawMenuButton(fonts.medium, optionText, startY + (i - 1) * 62, selectedIndex == i, 380)
    end

    -- Navigation Helper Footer
    drawCenteredText(fonts.small, "Use UP / DOWN or Mouse to Navigate  •  ENTER / Click to Select", 570, Constants.COLORS.TEXT_MUTED)

    -- Controls Guide Box
    local ctrlW, ctrlH = 580, 85
    local ctrlX = (Constants.VIRTUAL_WIDTH - ctrlW) / 2
    UI.drawGlassCard(ctrlX, 608, ctrlW, ctrlH, 12, {0.3, 0.3, 0.5, 0.4})

    drawCenteredText(fonts.small, "CONTROLS GUIDE", 618, Constants.COLORS.ACCENT_GOLD)
    drawCenteredText(fonts.small, "Paddle: Left / Right Arrows or Mouse  |  Launch / Lasers: Spacebar or Left Click", 642, Constants.COLORS.TEXT_MAIN)
    drawCenteredText(fonts.small, "Pause Game: P  |  Quit: Select Quit or press Escape", 665, Constants.COLORS.TEXT_MUTED)

    love.graphics.setColor(1, 1, 1, 1)
end

-- Stage Selector Screen
function UI.drawLevelSelectScreen(selectedLevelIndex, levelNames)
    love.graphics.setColor(0, 0, 0, 0.60)
    love.graphics.rectangle("fill", 0, 0, Constants.VIRTUAL_WIDTH, Constants.VIRTUAL_HEIGHT)

    drawCenteredText(fonts.title, "SELECT STAGE", 100, Constants.COLORS.ACCENT_CYAN, {0, 0, 0, 0.8})

    -- Glass Modal Card
    local cardW, cardH = 500, 440
    local cardX = (Constants.VIRTUAL_WIDTH - cardW) / 2
    local cardY = 180
    UI.drawGlassCard(cardX, cardY, cardW, cardH, 16, {0.0, 0.85, 1.0, 0.4})

    local startY = cardY + 25
    for i, name in ipairs(levelNames) do
        local isBack = (i == #levelNames)
        local btnW = isBack and 420 or 440
        UI.drawMenuButton(fonts.medium, name, startY + (i - 1) * 62, selectedLevelIndex == i, btnW)
    end

    drawCenteredText(fonts.small, "Select a stage using UP / DOWN or Mouse  •  Press ENTER to Launch", 645, Constants.COLORS.TEXT_MUTED)

    love.graphics.setColor(1, 1, 1, 1)
end

-- Serve Screen Overlay
function UI.drawServeScreen(levelName)
    local alpha = 0.5 + math.sin(titlePulse * 3) * 0.5
    drawCenteredText(fonts.large, levelName or "GET READY!", 310, Constants.COLORS.ACCENT_GOLD, {0, 0, 0, 0.8})
    drawCenteredText(fonts.medium, "PRESS SPACE OR CLICK TO LAUNCH BALL", 370, {1, 1, 1, alpha})
end

-- Pause Screen Overlay
function UI.drawPauseScreen(selectedIndex, menuOptions)
    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.rectangle("fill", 0, 0, Constants.VIRTUAL_WIDTH, Constants.VIRTUAL_HEIGHT)

    drawCenteredText(fonts.title, "GAME PAUSED", 160, Constants.COLORS.ACCENT_CYAN, {0, 0, 0, 0.8})

    -- Glass Modal Card
    local cardW, cardH = 440, 240
    local cardX = (Constants.VIRTUAL_WIDTH - cardW) / 2
    local cardY = 250
    UI.drawGlassCard(cardX, cardY, cardW, cardH, 16, {0.0, 0.9, 1.0, 0.4})

    local startY = cardY + 28
    for i, text in ipairs(menuOptions) do
        UI.drawMenuButton(fonts.medium, text, startY + (i - 1) * 62, selectedIndex == i, 380)
    end

    drawCenteredText(fonts.small, "Use UP / DOWN or Mouse to navigate  •  ENTER / Click to select", 515, Constants.COLORS.TEXT_MUTED)

    love.graphics.setColor(1, 1, 1, 1)
end

-- Game Over Screen Overlay
function UI.drawGameOverScreen(finalScore, highScore, isNewHigh, selectedIndex, menuOptions)
    love.graphics.setColor(0.10, 0.02, 0.05, 0.85)
    love.graphics.rectangle("fill", 0, 0, Constants.VIRTUAL_WIDTH, Constants.VIRTUAL_HEIGHT)

    drawCenteredText(fonts.title, "GAME OVER", 120, Constants.COLORS.BRICK_TNT, {0, 0, 0, 0.9})
    drawCenteredText(fonts.large, string.format("FINAL SCORE: %d", finalScore), 195, Constants.COLORS.TEXT_MAIN)

    if isNewHigh then
        local alpha = 0.5 + math.sin(titlePulse * 4) * 0.5
        drawCenteredText(fonts.large, "★ NEW HIGH SCORE! ★", 245, {1, 0.85, 0.1, alpha})
    else
        drawCenteredText(fonts.medium, string.format("HIGH SCORE: %d", highScore), 245, Constants.COLORS.TEXT_MUTED)
    end

    -- Glass Modal Card
    local cardW, cardH = 440, 240
    local cardX = (Constants.VIRTUAL_WIDTH - cardW) / 2
    local cardY = 310
    UI.drawGlassCard(cardX, cardY, cardW, cardH, 16, {1.0, 0.2, 0.3, 0.4})

    local startY = cardY + 28
    for i, text in ipairs(menuOptions) do
        UI.drawMenuButton(fonts.medium, text, startY + (i - 1) * 62, selectedIndex == i, 380)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

-- Victory Screen Overlay
function UI.drawVictoryScreen(finalScore, selectedIndex, menuOptions)
    love.graphics.setColor(0.02, 0.10, 0.05, 0.85)
    love.graphics.rectangle("fill", 0, 0, Constants.VIRTUAL_WIDTH, Constants.VIRTUAL_HEIGHT)

    drawCenteredText(fonts.title, "STAGE CLEARED!", 130, Constants.COLORS.ACCENT_GOLD, {0, 0, 0, 0.9})
    drawCenteredText(fonts.large, string.format("CURRENT SCORE: %d", finalScore), 205, Constants.COLORS.TEXT_MAIN)

    -- Glass Modal Card
    local cardW, cardH = 440, 240
    local cardX = (Constants.VIRTUAL_WIDTH - cardW) / 2
    local cardY = 280
    UI.drawGlassCard(cardX, cardY, cardW, cardH, 16, {0.2, 0.9, 0.4, 0.4})

    local startY = cardY + 28
    for i, text in ipairs(menuOptions) do
        UI.drawMenuButton(fonts.medium, text, startY + (i - 1) * 62, selectedIndex == i, 380)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return UI
