local Constants = require("src.constants")
local Visuals = require("src.visuals")

local UI = {}

local fonts = {}
local titlePulse = 0

local function trySystemFont(names, size)
    for _, name in ipairs(names) do
        local path = "C:/Windows/Fonts/" .. name
        local file = io.open(path, "rb")
        if file then
            local data = file:read("*all")
            file:close()
            local ok, font = pcall(function()
                return love.graphics.newFont(love.filesystem.newFileData(data, name), size)
            end)
            if ok and font then
                return font
            end
        end
    end
    return love.graphics.newFont(size)
end

function UI.init()
    fonts.small  = trySystemFont({"segoeui.ttf", "SegoeUI.ttf"}, 15)
    fonts.medium = trySystemFont({"segoeui.ttf", "SegoeUI.ttf"}, 20)
    fonts.large  = trySystemFont({"bahnschrift.ttf", "segoeui.ttf"}, 34)
    fonts.title  = trySystemFont({"bahnschrift.ttf", "seguisb.ttf", "segoeui.ttf"}, 58)
    fonts.badge  = trySystemFont({"consola.ttf", "segoeui.ttf"}, 13)
    fonts.score  = trySystemFont({"consola.ttf", "bahnschrift.ttf", "segoeui.ttf"}, 20)
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
    cornerRadius = cornerRadius or 14
    love.graphics.setColor(0.04, 0.04, 0.10, 0.78)
    love.graphics.rectangle("fill", x, y, width, height, cornerRadius, cornerRadius)

    love.graphics.setColor(1, 1, 1, 0.06)
    love.graphics.rectangle("fill", x + 4, y + 4, width - 8, math.min(22, height / 3.2), cornerRadius - 3, cornerRadius - 3)

    local bc = borderColor or Constants.COLORS.ACCENT_CYAN
    love.graphics.setBlendMode("add")
    love.graphics.setColor(bc[1], bc[2], bc[3], 0.16)
    love.graphics.setLineWidth(6)
    love.graphics.rectangle("line", x - 1, y - 1, width + 2, height + 2, cornerRadius + 1, cornerRadius + 1)
    love.graphics.setBlendMode("alpha")

    love.graphics.setColor(bc[1], bc[2], bc[3], bc[4] or 0.85)
    love.graphics.setLineWidth(1.8)
    love.graphics.rectangle("line", x, y, width, height, cornerRadius, cornerRadius)
end

-- Helper to draw an interactive menu option button
function UI.drawMenuButton(font, text, y, isSelected, customWidth, customHeight, customX)
    local width = customWidth or 380
    local height = customHeight or 50
    local x = customX or ((Constants.VIRTUAL_WIDTH - width) / 2)

    love.graphics.setFont(font)

    if isSelected then
        local pulseScale = 1 + math.sin(titlePulse * 3.5) * 0.025
        love.graphics.push()
        love.graphics.translate(x + width / 2, y + height / 2)
        love.graphics.scale(pulseScale, pulseScale)
        love.graphics.translate(-(x + width / 2), -(y + height / 2))

        -- Active Button Background & Neon Glow
        love.graphics.setColor(0.10, 0.16, 0.32, 0.95)
        love.graphics.rectangle("fill", x, y, width, height, 14, 14)

        love.graphics.setBlendMode("add")
        love.graphics.setColor(0.15, 0.75, 1.00, 0.18)
        love.graphics.setLineWidth(8)
        love.graphics.rectangle("line", x - 1, y - 1, width + 2, height + 2, 15, 15)
        love.graphics.setBlendMode("alpha")

        love.graphics.setColor(Constants.COLORS.ACCENT_CYAN)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, width, height, 14, 14)

        love.graphics.setColor(Constants.COLORS.ACCENT_CYAN)
        love.graphics.rectangle("fill", x + 10, y + 10, 4, height - 20, 2, 2)

        local displayText = text
        local textW = font:getWidth(displayText)
        love.graphics.setColor(Constants.COLORS.ACCENT_GOLD)
        love.graphics.print(displayText, x + (width - textW) / 2, y + (height - font:getHeight()) / 2)

        love.graphics.pop()
    else
        -- Unselected Button
        love.graphics.setColor(0.05, 0.05, 0.10, 0.55)
        love.graphics.rectangle("fill", x, y, width, height, 14, 14)

        love.graphics.setColor(0.42, 0.48, 0.68, 0.28)
        love.graphics.setLineWidth(1.4)
        love.graphics.rectangle("line", x, y, width, height, 14, 14)

        local textW = font:getWidth(text)
        love.graphics.setColor(Constants.COLORS.TEXT_MUTED)
        love.graphics.print(text, x + (width - textW) / 2, y + (height - font:getHeight()) / 2)
    end
end

-- Draw HUD Header
function UI.drawHUD(score, highScore, lives, levelName, combo, multiplier, safetyNetActive, activePowerups)
    -- Top HUD Glass Header Bar
    UI.drawGlassCard(18, 8, Constants.VIRTUAL_WIDTH - 36, 44, 16, {0.25, 0.85, 1.0, 0.35})

    love.graphics.setFont(fonts.score)

    Visuals.pill(32, 16, 178, 28, {0.12, 0.09, 0.04, 0.55}, {1.00, 0.82, 0.28, 0.45})
    love.graphics.setColor(Constants.COLORS.ACCENT_GOLD)
    love.graphics.print(string.format("SCORE  %06d", score), 46, 20)

    Visuals.pill(222, 16, 168, 28, {0.06, 0.07, 0.14, 0.55}, {0.55, 0.62, 0.85, 0.30})
    love.graphics.setColor(Constants.COLORS.TEXT_MUTED)
    love.graphics.print(string.format("BEST  %06d", highScore), 236, 20)

    love.graphics.setFont(fonts.medium)
    love.graphics.setColor(Constants.COLORS.TEXT_MAIN)
    local stageText = levelName or "Stage 1"
    love.graphics.print(stageText, 640 - fonts.medium:getWidth(stageText) / 2, 18)

    if combo > 1 or multiplier > 1 then
        local multiText = string.format("COMBO  x%d", combo * multiplier)
        local mw = fonts.medium:getWidth(multiText) + 28
        Visuals.pill(850, 16, mw, 28, {0.22, 0.04, 0.12, 0.7}, {1.0, 0.32, 0.62, 0.55})
        love.graphics.setColor(Constants.COLORS.ACCENT_PINK)
        love.graphics.print(multiText, 864, 20)
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

        love.graphics.setColor(1, 0.22, 0.42, 0.22)
        love.graphics.circle("fill", -4, -4, 9)
        love.graphics.circle("fill", 4, -4, 9)

        love.graphics.setColor(1, 0.28, 0.52, 1)
        love.graphics.circle("fill", -4, -4, 6)
        love.graphics.circle("fill", 4, -4, 6)
        love.graphics.polygon("fill", -10, -2, 10, -2, 0, 11)
        love.graphics.setColor(1, 0.72, 0.82, 0.55)
        love.graphics.circle("fill", -5, -5, 2.2)

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
        local alphaPulse = 0.45 + math.sin(titlePulse * 4) * 0.25

        love.graphics.setBlendMode("add")
        love.graphics.setColor(0.2, 0.85, 1.0, alphaPulse * 0.35)
        love.graphics.rectangle("fill", Constants.PLAYFIELD_X, netY - 6, Constants.PLAYFIELD_WIDTH, 12, 6, 6)
        love.graphics.setColor(0.35, 0.95, 1.0, alphaPulse)
        love.graphics.setLineWidth(3)
        love.graphics.line(Constants.PLAYFIELD_X, netY, Constants.PLAYFIELD_X + Constants.PLAYFIELD_WIDTH, netY)
        for x = Constants.PLAYFIELD_X, Constants.PLAYFIELD_X + Constants.PLAYFIELD_WIDTH, 36 do
            love.graphics.circle("fill", x, netY, 3.5)
        end
        love.graphics.setBlendMode("alpha")
    end

    love.graphics.setColor(1, 1, 1, 1)
end

-- Main Title Screen Menu
function UI.drawStartScreen(highScore, selectedIndex, menuOptions)
    love.graphics.setColor(0.02, 0.02, 0.08, 0.38)
    love.graphics.rectangle("fill", 0, 0, Constants.VIRTUAL_WIDTH, Constants.VIRTUAL_HEIGHT)

    local titleY = 60 + math.sin(titlePulse) * 5
    local title = "BREAKOUT ARCADE"
    love.graphics.setFont(fonts.title)
    local tx = (Constants.VIRTUAL_WIDTH - fonts.title:getWidth(title)) / 2

    love.graphics.setBlendMode("add")
    love.graphics.setColor(1.00, 0.28, 0.70, 0.35)
    love.graphics.print(title, tx + 5, titleY + 5)
    love.graphics.setColor(0.20, 0.90, 1.00, 0.55)
    love.graphics.print(title, tx, titleY)
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(0.96, 0.98, 1.00, 1)
    love.graphics.print(title, tx, titleY)

    drawCenteredText(fonts.medium, "NEON EDITION", titleY + 62, Constants.COLORS.ACCENT_GOLD)
    drawCenteredText(fonts.score, string.format("HIGH SCORE  %06d", highScore), titleY + 92, Constants.COLORS.TEXT_MUTED)

    -- Glassmorphic Menu Container Card
    local cardW, cardH = 460, 280
    local cardX = (Constants.VIRTUAL_WIDTH - cardW) / 2
    local cardY = 222
    UI.drawGlassCard(cardX, cardY, cardW, cardH, 16, {0.00, 0.90, 1.00, 0.4})

    -- Interactive Menu Buttons
    local startY = cardY + 20
    for i, optionText in ipairs(menuOptions) do
        UI.drawMenuButton(fonts.medium, optionText, startY + (i - 1) * 60, selectedIndex == i, 390)
    end

    -- Navigation Helper Footer
    drawCenteredText(fonts.small, "Use UP / DOWN or Mouse to Navigate  •  ENTER / Click to Select", 516, Constants.COLORS.TEXT_MUTED)

    -- Controls Guide Box
    local ctrlW, ctrlH = 740, 80
    local ctrlX = (Constants.VIRTUAL_WIDTH - ctrlW) / 2
    local ctrlY = 550
    UI.drawGlassCard(ctrlX, ctrlY, ctrlW, ctrlH, 12, {0.3, 0.3, 0.5, 0.4})

    drawCenteredText(fonts.small, "CONTROLS GUIDE", ctrlY + 10, Constants.COLORS.ACCENT_GOLD)
    drawCenteredText(fonts.small, "Paddle: Left / Right Arrows or Mouse  |  Launch / Lasers: Spacebar or Left Click", ctrlY + 32, Constants.COLORS.TEXT_MAIN)
    drawCenteredText(fonts.small, "Pause: P  |  Music Toggle: M  |  Fullscreen: F11 / Alt+Enter  |  Quit: Esc", ctrlY + 54, Constants.COLORS.TEXT_MUTED)

    love.graphics.setColor(1, 1, 1, 1)
end

-- Stage Selector Screen (Scrollable Glass Modal List)
function UI.drawLevelSelectScreen(selectedLevelIndex, levelNames, scrollY, scaleX, scaleY, offsetX, offsetY)
    love.graphics.setColor(0.02, 0.03, 0.10, 0.48)
    love.graphics.rectangle("fill", 0, 0, Constants.VIRTUAL_WIDTH, Constants.VIRTUAL_HEIGHT)

    drawCenteredText(fonts.title, "SELECT STAGE", 65, Constants.COLORS.ACCENT_CYAN, {0, 0, 0, 0.8})

    -- Glass Modal Container Card
    local cardW, cardH = 580, 440
    local cardX = (Constants.VIRTUAL_WIDTH - cardW) / 2
    local cardY = 135
    UI.drawGlassCard(cardX, cardY, cardW, cardH, 16, {0.0, 0.85, 1.0, 0.4})

    local viewX = cardX + 25
    local viewY = cardY + 20
    local viewW = cardW - 70
    local viewH = 370
    local itemH = 50
    local itemSpacing = 56

    local totalH = #levelNames * itemSpacing
    local maxScroll = math.max(0, totalH - viewH)
    local curScroll = math.max(0, math.min(maxScroll, scrollY or 0))

    -- Set Scissor clipping for smooth viewport scrolling
    if scaleX and scaleY and offsetX and offsetY then
        local scX = offsetX + viewX * scaleX
        local scY = offsetY + viewY * scaleY
        local scW = viewW * scaleX
        local scH = viewH * scaleY
        love.graphics.setScissor(scX, scY, scW, scH)
    end

    for i, name in ipairs(levelNames) do
        local btnY = viewY + (i - 1) * itemSpacing - curScroll
        -- Only draw buttons visible within the viewport
        if btnY + itemH >= viewY and btnY <= viewY + viewH then
            local isSelected = (selectedLevelIndex == i)
            local isBack = (i == #levelNames)
            local btnW = isBack and 440 or 490
            UI.drawMenuButton(fonts.medium, name, btnY, isSelected, btnW, itemH, viewX + (viewW - btnW) / 2)
        end
    end

    -- Reset Scissor clipping
    if scaleX then
        love.graphics.setScissor()
    end

    -- Draw Glowing Scrollbar Track & Thumb
    if maxScroll > 0 then
        local trackX = cardX + cardW - 22
        local trackY = viewY
        local trackH = viewH

        -- Scrollbar Track
        love.graphics.setColor(0.08, 0.10, 0.20, 0.6)
        love.graphics.rectangle("fill", trackX, trackY, 8, trackH, 4, 4)

        -- Scrollbar Thumb
        local thumbH = math.max(35, (viewH / totalH) * trackH)
        local thumbY = trackY + (curScroll / maxScroll) * (trackH - thumbH)

        love.graphics.setColor(Constants.COLORS.ACCENT_CYAN[1], Constants.COLORS.ACCENT_CYAN[2], Constants.COLORS.ACCENT_CYAN[3], 0.85)
        love.graphics.rectangle("fill", trackX, thumbY, 8, thumbH, 4, 4)

        love.graphics.setBlendMode("add")
        love.graphics.setColor(0.2, 0.85, 1.0, 0.3)
        love.graphics.rectangle("fill", trackX - 1, thumbY - 1, 10, thumbH + 2, 5, 5)
        love.graphics.setBlendMode("alpha")
    end

    -- Scroll Indicators
    if curScroll > 5 then
        love.graphics.setColor(Constants.COLORS.ACCENT_GOLD)
        love.graphics.setFont(fonts.badge)
        love.graphics.print("▲ SCROLL UP", cardX + cardW / 2 - 40, cardY + 6)
    end

    if curScroll < maxScroll - 5 then
        love.graphics.setColor(Constants.COLORS.ACCENT_GOLD)
        love.graphics.setFont(fonts.badge)
        love.graphics.print("▼ SCROLL DOWN", cardX + cardW / 2 - 48, cardY + cardH - 22)
    end

    drawCenteredText(fonts.small, "Use Mouse Wheel or UP / DOWN / WASD to Scroll  •  ENTER / Click to Select", 590, Constants.COLORS.TEXT_MUTED)

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
    love.graphics.setColor(0.02, 0.04, 0.10, 0.52)
    love.graphics.rectangle("fill", 0, 0, Constants.VIRTUAL_WIDTH, Constants.VIRTUAL_HEIGHT)

    drawCenteredText(fonts.title, "GAME PAUSED", 110, Constants.COLORS.ACCENT_CYAN, {0, 0, 0, 0.8})

    -- Glass Modal Card
    local cardW, cardH = 460, 280
    local cardX = (Constants.VIRTUAL_WIDTH - cardW) / 2
    local cardY = 195
    UI.drawGlassCard(cardX, cardY, cardW, cardH, 16, {0.0, 0.9, 1.0, 0.4})

    local startY = cardY + 20
    for i, text in ipairs(menuOptions) do
        UI.drawMenuButton(fonts.medium, text, startY + (i - 1) * 60, selectedIndex == i, 390)
    end

    drawCenteredText(fonts.small, "Use UP / DOWN or Mouse to navigate  •  ENTER / Click to select", 490, Constants.COLORS.TEXT_MUTED)
    drawCenteredText(fonts.small, "Press F11 or Alt+Enter to Toggle Fullscreen Mode", 518, Constants.COLORS.ACCENT_CYAN)

    love.graphics.setColor(1, 1, 1, 1)
end

-- Game Over Screen Overlay
function UI.drawGameOverScreen(finalScore, highScore, isNewHigh, selectedIndex, menuOptions)
    love.graphics.setColor(0.12, 0.02, 0.06, 0.62)
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
    love.graphics.setColor(0.02, 0.10, 0.06, 0.58)
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
