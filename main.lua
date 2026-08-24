local Constants = require("src.constants")
local Sounds    = require("src.sounds")
local Particle  = require("src.particle")
local Powerup   = require("src.powerup")
local Brick     = require("src.brick")
local Paddle    = require("src.paddle")
local Ball      = require("src.ball")
local Levels    = require("src.levels")
local UI        = require("src.ui")
local Visuals   = require("src.visuals")

-- Game State Variables
local gameState = "start" -- "start", "levelselect", "serve", "play", "paused", "gameover", "victory"

local paddle
local balls = {}
local bricks = {}
local currentLevel = 1
local levelName = ""
local score = 0
local highScore = 0
local isNewHighScore = false
local lives = 3
local comboCount = 0
local scoreMultiplier = 1
local multiplierTimer = 0
local safetyNetActive = false

-- Menu Options & Selection Tracking
local menuIndex = 1

local function getLevelSelectOptions()
    local opts = {}
    for _, name in ipairs(Levels.getLevelNames()) do
        table.insert(opts, name)
    end
    table.insert(opts, "BACK TO MAIN MENU")
    return opts
end

local gameOverOptions  = {"PLAY AGAIN", "MAIN MENU", "QUIT GAME"}
local victoryOptions   = {"NEXT STAGE", "MAIN MENU", "QUIT GAME"}

-- Viewport Canvas Scaling & Display Mode State
local scaleX, scaleY, offsetX, offsetY
local isFullscreen = false

-- Scroll Viewport State for Stage Selection
local levelScrollY = 0
local scrollTargetY = 0

-- Mouse Wheel Input Callback for Scrolling
function love.wheelmoved(x, y)
    if gameState == "levelselect" then
        local opts = getLevelSelectOptions()
        local totalH = #opts * 56
        local viewH = 370
        local maxScroll = math.max(0, totalH - viewH)

        if y > 0 then
            scrollTargetY = math.max(0, scrollTargetY - 75)
        elseif y < 0 then
            scrollTargetY = math.min(maxScroll, scrollTargetY + 75)
        end
    end
end

-- Ensure selected level is scrolled smoothly into viewport visibility
local function ensureLevelVisible(index, totalItems)
    local itemSpacing = 56
    local viewH = 370
    local itemTop = (index - 1) * itemSpacing
    local itemBottom = itemTop + 50

    local totalH = totalItems * itemSpacing
    local maxScroll = math.max(0, totalH - viewH)

    if itemTop < scrollTargetY then
        scrollTargetY = math.max(0, itemTop - 10)
    elseif itemBottom > (scrollTargetY + viewH) then
        scrollTargetY = math.min(maxScroll, itemBottom - viewH + 10)
    end
end

-- Recalculate canvas viewport scaling
local function updateViewport()
    local w, h = love.graphics.getDimensions()
    local scale = math.min(w / Constants.VIRTUAL_WIDTH, h / Constants.VIRTUAL_HEIGHT)
    scaleX = scale
    scaleY = scale
    offsetX = (w - Constants.VIRTUAL_WIDTH * scale) / 2
    offsetY = (h - Constants.VIRTUAL_HEIGHT * scale) / 2
end

local function getStartMenuOptions()
    return {"START GAME", "SELECT STAGE", "QUIT GAME"}
end

local function getPauseMenuOptions()
    return {"RESUME GAME", "MAIN MENU", "QUIT GAME"}
end

-- Load High Score from Love2D filesystem
local function loadHighScore()
    if love.filesystem.getInfo("highscore.dat") then
        local contents = love.filesystem.read("highscore.dat")
        if contents then
            highScore = tonumber(contents) or 0
        end
    end
end

-- Save High Score to Love2D filesystem
local function saveHighScore()
    if score > highScore then
        highScore = score
        isNewHighScore = true
        love.filesystem.write("highscore.dat", tostring(highScore))
    end
end

-- Convert screen coordinates to virtual resolution coordinates (touch & mouse)
local function getVirtualPos(x, y)
    if not x or not y then return nil, nil end
    local vx = (x - offsetX) / scaleX
    local vy = (y - offsetY) / scaleY
    return vx, vy
end

local function getVirtualMouse()
    local mx, my = love.mouse.getPosition()
    return getVirtualPos(mx, my)
end

local function isTouchOnPauseBtn(vx, vy)
    if not vx or not vy then return false end
    return vx >= Constants.PAUSE_BTN_X and vx <= (Constants.PAUSE_BTN_X + Constants.PAUSE_BTN_WIDTH) and
           vy >= Constants.PAUSE_BTN_Y and vy <= (Constants.PAUSE_BTN_Y + Constants.PAUSE_BTN_HEIGHT)
end


-- Check mouse hover over menu option buttons
local function getHoveredMenuIndex(startY, optionsCount, buttonHeight, spacing, customWidth)
    local vx, vy = getVirtualMouse()
    local width = customWidth or 380
    local height = buttonHeight or 50
    local left = (Constants.VIRTUAL_WIDTH - width) / 2
    local right = left + width

    if vx >= left and vx <= right then
        for i = 1, optionsCount do
            local top = startY + (i - 1) * spacing
            local bottom = top + height
            if vy >= top and vy <= bottom then
                return i
            end
        end
    end
    return nil
end

-- Load specific level map
local function loadLevel(lvlNum)
    currentLevel = lvlNum
    bricks, levelName = Levels.loadLevel(currentLevel)
    Powerup.clearAll()

    paddle:reset()
    balls = { Ball.new() }
    balls[1]:resetOnPaddle(paddle)

    safetyNetActive = false
    multiplierTimer = 0
    scoreMultiplier = 1
    comboCount = 0

    gameState = "serve"
end

-- Initialize Game
function love.load()
    love.graphics.setDefaultFilter("linear", "linear")
    Sounds.init()
    Sounds.playBGM()
    Particle.init()
    Visuals.init()
    UI.init()
    loadHighScore()
    loadSettings()

    paddle = Paddle.new()
    updateViewport()
end

function love.resize(w, h)
    updateViewport()
end

-- Destroy brick & process chain reactions / score popups / powerup drops
local function destroyBrick(brick, isExplosion)
    if not brick.alive then return end

    local wasDestroyed, points = brick:hit(1, isExplosion)
    if points > 0 then
        comboCount = comboCount + 1
        local awarded = points * comboCount * scoreMultiplier
        score = score + awarded
        if score > highScore then
            highScore = score
        end

        -- Floating Score Text Popup
        local popX = brick.x + brick.width / 2
        local popY = brick.y + brick.height / 2
        local popTxt = string.format("+%d", awarded)
        if comboCount > 2 then
            popTxt = string.format("+%d (x%d)", awarded, comboCount)
        end
        Particle.spawnScoreText(popX, popY, popTxt, Constants.COLORS.ACCENT_GOLD)
    end

    if wasDestroyed then
        if brick.type == "POWERUP" or love.math.random() < 0.22 then
            Powerup.spawn(brick.x + brick.width / 2, brick.y + brick.height / 2)
        end

        if brick.type == "TNT" then
            local radius = 110
            local cx = brick.x + brick.width / 2
            local cy = brick.y + brick.height / 2

            for _, other in ipairs(bricks) do
                if other.alive and other ~= brick then
                    local ocx = other.x + other.width / 2
                    local ocy = other.y + other.height / 2
                    local distSq = (cx - ocx)^2 + (cy - ocy)^2
                    if distSq <= (radius * radius) then
                        destroyBrick(other, true)
                    end
                end
            end
        end
    end
end

-- Check win condition (all clearable bricks destroyed)
local function checkWinCondition()
    local clearableLeft = 0
    for _, b in ipairs(bricks) do
        if b.alive and b.type ~= "STEEL" then
            clearableLeft = clearableLeft + 1
        end
    end

    if clearableLeft == 0 then
        for _, b in ipairs(bricks) do
            if b.alive and b.type == "STEEL" then
                b.alive = false
                score = score + 500
                Particle.spawnExplosion(b.x + b.width / 2, b.y + b.height / 2, Constants.COLORS.BRICK_STEEL, 20, 250, 4)
                Particle.spawnScoreText(b.x + b.width / 2, b.y + b.height / 2, "+500 STEEL BONUS!", Constants.COLORS.ACCENT_CYAN)
            end
        end

        saveHighScore()
        Sounds.play("victory")
        menuIndex = 1
        gameState = "victory"
    end
end

-- Activate Powerup Effect
local function handlePowerupCollect(type)
    if type == "MULTIBALL" then
        local b1 = Ball.new(paddle.x + paddle.width / 3, paddle.y - 12)
        b1:launch(-0.35)
        local b2 = Ball.new(paddle.x + paddle.width * 2 / 3, paddle.y - 12)
        b2:launch(0.35)
        table.insert(balls, b1)
        table.insert(balls, b2)
    elseif type == "EXPAND" then
        paddle:activatePowerup("EXPAND")
    elseif type == "LASER" then
        paddle:activatePowerup("LASER")
    elseif type == "FIREBALL" then
        for _, b in ipairs(balls) do
            b:activateFireball(8.0)
        end
    elseif type == "SAFETY_NET" then
        safetyNetActive = true
    elseif type == "EXTRA_LIFE" then
        lives = math.min(5, lives + 1)
        Sounds.play("powerup_pickup")
    elseif type == "MULTIPLIER" then
        scoreMultiplier = 2
        multiplierTimer = 15.0
    end
end

-- Hover index detector for Scrollable Stage Select List
local function getHoveredLevelIndex(optionsCount)
    local vx, vy = getVirtualMouse()
    local cardW = 580
    local cardX = (Constants.VIRTUAL_WIDTH - cardW) / 2
    local cardY = 135

    local viewX = cardX + 25
    local viewY = cardY + 20
    local viewW = cardW - 70
    local viewH = 370
    local itemSpacing = 56

    if vx >= viewX and vx <= (viewX + viewW) and vy >= viewY and vy <= (viewY + viewH) then
        local relativeY = (vy - viewY) + levelScrollY
        local hoverIndex = math.floor(relativeY / itemSpacing) + 1
        if hoverIndex >= 1 and hoverIndex <= optionsCount then
            return hoverIndex
        end
    end
    return nil
end

-- Execute selected menu item based on state
local function confirmMenuSelection()
    Sounds.play("paddle_hit")

    if gameState == "start" then
        if menuIndex == 1 then
            score = 0; lives = 3; isNewHighScore = false; loadLevel(1)
        elseif menuIndex == 2 then
            menuIndex = 1; levelScrollY = 0; scrollTargetY = 0; gameState = "levelselect"
        elseif menuIndex == 3 then
            love.event.quit()
        end
    elseif gameState == "levelselect" then
        local lvlCount = Levels.getMapCount()
        if menuIndex >= 1 and menuIndex <= lvlCount then
            score = 0; lives = 3; isNewHighScore = false; loadLevel(menuIndex)
        else
            menuIndex = 1; gameState = "start"
        end
    elseif gameState == "paused" then
        if menuIndex == 1 then
            gameState = "play"
        elseif menuIndex == 2 then
            menuIndex = 1; gameState = "start"
        elseif menuIndex == 3 then
            love.event.quit()
        end
    elseif gameState == "gameover" then
        if menuIndex == 1 then
            score = 0; lives = 3; isNewHighScore = false; loadLevel(1)
        elseif menuIndex == 2 then
            menuIndex = 1; gameState = "start"
        elseif menuIndex == 3 then
            love.event.quit()
        end
    elseif gameState == "victory" then
        if menuIndex == 1 then
            loadLevel(currentLevel + 1)
        elseif menuIndex == 2 then
            menuIndex = 1; gameState = "start"
        elseif menuIndex == 3 then
            love.event.quit()
        end
    end
end


-- Main Update Loop
function love.update(dt)
    UI.update(dt)
    Particle.update(dt)

    -- Handle mouse hover selection in menus
    if gameState == "start" then
        local startOpts = getStartMenuOptions()
        local hoverIdx = getHoveredMenuIndex(242, #startOpts, 50, 60, 390)
        if hoverIdx and hoverIdx ~= menuIndex then
            menuIndex = hoverIdx
            Sounds.play("wall_hit")
        end
        return
    elseif gameState == "levelselect" then
        levelScrollY = levelScrollY + (scrollTargetY - levelScrollY) * math.min(1, dt * 18)
        local lvlOpts = getLevelSelectOptions()
        local hoverIdx = getHoveredLevelIndex(#lvlOpts)
        if hoverIdx and hoverIdx ~= menuIndex then
            menuIndex = hoverIdx
            Sounds.play("wall_hit")
        end
        return
    elseif gameState == "paused" then
        local pauseOpts = getPauseMenuOptions()
        local hoverIdx = getHoveredMenuIndex(215, #pauseOpts, 50, 60, 390)
        if hoverIdx and hoverIdx ~= menuIndex then
            menuIndex = hoverIdx
            Sounds.play("wall_hit")
        end
        return
    elseif gameState == "gameover" then
        local hoverIdx = getHoveredMenuIndex(338, #gameOverOptions, 50, 62, 380)
        if hoverIdx and hoverIdx ~= menuIndex then
            menuIndex = hoverIdx
            Sounds.play("wall_hit")
        end
        return
    elseif gameState == "victory" then
        local hoverIdx = getHoveredMenuIndex(308, #victoryOptions, 50, 62, 380)
        if hoverIdx and hoverIdx ~= menuIndex then
            menuIndex = hoverIdx
            Sounds.play("wall_hit")
        end
        return
    end

    local vx, vy
    if love.touch and love.touch.getTouches then
        local touches = love.touch.getTouches()
        if #touches > 0 then
            local tx, ty = love.touch.getPosition(touches[1])
            vx, vy = getVirtualPos(tx, ty)
        end
    end
    if not vx then
        vx, vy = getVirtualMouse()
    end

    -- Update Multiplier Timer
    if multiplierTimer > 0 then
        multiplierTimer = multiplierTimer - dt
        if multiplierTimer <= 0 then
            scoreMultiplier = 1
        end
    end

    paddle:update(dt, vx)
    Powerup.updateAll(dt, paddle, handlePowerupCollect)

    for _, b in ipairs(bricks) do
        b:update(dt)
    end

    paddle:checkLaserBrickCollisions(bricks, function(b, damage)
        destroyBrick(b, false)
        checkWinCondition()
    end)

    if gameState == "serve" then
        if #balls > 0 then
            balls[1]:resetOnPaddle(paddle)
        end
        return
    end

    if gameState == "play" then
        for i = #balls, 1, -1 do
            local ball = balls[i]
            ball:update(dt, paddle)

            if ball:checkPaddleCollision(paddle) then
                comboCount = 0
            end

            for _, b in ipairs(bricks) do
                if b.alive and ball:checkBrickCollision(b) then
                    destroyBrick(b, false)
                    checkWinCondition()
                    if gameState ~= "play" then break end
                end
            end

            local bottomBoundary = Constants.PLAYFIELD_Y + Constants.PLAYFIELD_HEIGHT + 20
            if ball.y > bottomBoundary then
                if safetyNetActive then
                    ball.y = bottomBoundary - 10
                    ball.vy = -math.abs(ball.vy)
                    safetyNetActive = false
                    Sounds.play("wall_hit")
                    Particle.shake(6, 0.2)
                else
                    table.remove(balls, i)
                end
            end
        end

        if #balls == 0 then
            lives = lives - 1
            comboCount = 0
            scoreMultiplier = 1
            multiplierTimer = 0
            Sounds.play("lose_life")
            Particle.shake(16, 0.4)

            if lives <= 0 then
                saveHighScore()
                Sounds.play("game_over")
                menuIndex = 1
                gameState = "gameover"
            else
                paddle:reset()
                balls = { Ball.new() }
                balls[1]:resetOnPaddle(paddle)
                gameState = "serve"
            end
        end
    end
end

-- Key Press Input Callback
function love.keypressed(key)
    if key == "f11" or (key == "return" and (love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt"))) then
        toggleDisplayMode()
        return
    end

    if key == "m" then
        Sounds.toggleMusic()
        return
    end

    if key == "p" then
        if gameState == "play" then
            menuIndex = 1
            gameState = "paused"
        elseif gameState == "paused" then
            gameState = "play"
        end
        return
    end

    if key == "escape" then
        if gameState == "play" then
            menuIndex = 1
            gameState = "paused"
        elseif gameState == "paused" or gameState == "start" or gameState == "levelselect" then
            love.event.quit()
        end
        return
    end

    if gameState == "levelselect" then
        local lvlOpts = getLevelSelectOptions()
        local maxOpts = #lvlOpts
        if key == "up" or key == "w" then
            menuIndex = menuIndex - 1
            if menuIndex < 1 then menuIndex = maxOpts end
            ensureLevelVisible(menuIndex, maxOpts)
            Sounds.play("wall_hit")
            return
        elseif key == "down" or key == "s" then
            menuIndex = menuIndex + 1
            if menuIndex > maxOpts then menuIndex = 1 end
            ensureLevelVisible(menuIndex, maxOpts)
            Sounds.play("wall_hit")
            return
        elseif key == "return" or key == "space" then
            confirmMenuSelection()
            return
        end
    end

    local maxOptions = 3
    if gameState == "start" then
        maxOptions = #getStartMenuOptions()
    elseif gameState == "paused" then
        maxOptions = #getPauseMenuOptions()
    end

    if gameState == "start" or gameState == "paused" or gameState == "gameover" or gameState == "victory" then
        if key == "up" or key == "w" then
            menuIndex = menuIndex - 1
            if menuIndex < 1 then menuIndex = maxOptions end
            Sounds.play("wall_hit")
        elseif key == "down" or key == "s" then
            menuIndex = menuIndex + 1
            if menuIndex > maxOptions then menuIndex = 1 end
            Sounds.play("wall_hit")
        elseif key == "return" or key == "space" then
            confirmMenuSelection()
        end
        return
    end

    if gameState == "serve" then
        if key == "space" or key == "return" then
            if #balls > 0 then
                balls[1]:launch()
                gameState = "play"
            end
        end
    elseif gameState == "play" then
        if key == "space" and paddle.laserTimer > 0 then
            paddle:shootLasers()
        end
    end
end

local lastTouchY = nil

-- Touch Press Input Callback
function love.touchpressed(id, x, y, dx, dy, pressure)
    local vx, vy = getVirtualPos(x, y)
    if not vx or not vy then return end

    if gameState == "levelselect" then
        lastTouchY = vy
    end
end

-- Touch Move Drag Callback (Smooth stage select scrolling)
function love.touchmoved(id, x, y, dx, dy, pressure)
    local vx, vy = getVirtualPos(x, y)
    if not vx or not vy then return end

    if gameState == "levelselect" and lastTouchY then
        local deltaY = lastTouchY - vy
        local opts = getLevelSelectOptions()
        local totalH = #opts * 56
        local viewH = 370
        local maxScroll = math.max(0, totalH - viewH)
        scrollTargetY = math.max(0, math.min(maxScroll, scrollTargetY + deltaY * 1.5))
        lastTouchY = vy
    end
end

-- Mouse & Touch Press Input Callback
function love.mousepressed(x, y, button)
    if button == 1 then
        local vx, vy = getVirtualPos(x, y)

        if (gameState == "play" or gameState == "serve") and isTouchOnPauseBtn(vx, vy) then
            menuIndex = 1
            gameState = "paused"
            Sounds.play("wall_hit")
            return
        end

        if gameState == "start" or gameState == "levelselect" or gameState == "paused" or gameState == "gameover" or gameState == "victory" then
            confirmMenuSelection()
        elseif gameState == "serve" then
            if #balls > 0 then
                balls[1]:launch()
                gameState = "play"
            end
        elseif gameState == "play" then
            if paddle.laserTimer > 0 then
                paddle:shootLasers()
            end
        end
    end
end


-- Main Draw Loop
function love.draw()
    local sw, sh = love.graphics.getDimensions()
    love.graphics.setColor(0.015, 0.01, 0.04, 1)
    love.graphics.rectangle("fill", 0, 0, sw, sh)

    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scaleX, scaleY)

    Visuals.drawBackground(love.timer.getTime())
    Particle.drawStarfield()
    Visuals.drawPlayfield()

    -- Apply Screen Shake
    love.graphics.push()
    Particle.applyShake()

    for _, b in ipairs(bricks) do
        b:draw()
    end

    Powerup.drawAll()
    paddle:draw()

    for _, ball in ipairs(balls) do
        ball:draw()
    end

    Particle.draw()
    love.graphics.pop() -- End Screen Shake

    -- Draw HUD Header
    local activePowerupMap = {
        EXPAND = paddle.expandTimer,
        LASER = paddle.laserTimer,
        MULTIPLIER = multiplierTimer
    }
    UI.drawHUD(score, highScore, lives, levelName, comboCount, scoreMultiplier, safetyNetActive, activePowerupMap)

    -- Draw State Overlays
    if gameState == "start" then
        UI.drawStartScreen(highScore, menuIndex, getStartMenuOptions())
    elseif gameState == "levelselect" then
        UI.drawLevelSelectScreen(menuIndex, getLevelSelectOptions(), levelScrollY, scaleX, scaleY, offsetX, offsetY)
    elseif gameState == "serve" then
        UI.drawServeScreen(levelName)
    elseif gameState == "paused" then
        UI.drawPauseScreen(menuIndex, getPauseMenuOptions())
    elseif gameState == "gameover" then
        UI.drawGameOverScreen(score, highScore, isNewHighScore, menuIndex, gameOverOptions)
    elseif gameState == "victory" then
        UI.drawVictoryScreen(score, menuIndex, victoryOptions)
    end

    Visuals.drawVignetteAndScanlines()

    love.graphics.pop() -- End Viewport Transform
end
