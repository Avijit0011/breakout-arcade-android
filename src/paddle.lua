local Constants = require("src.constants")
local Sounds = require("src.sounds")
local Particle = require("src.particle")

local Paddle = {}
Paddle.__index = Paddle

function Paddle.new()
    local self = setmetatable({}, Paddle)
    self.baseWidth = Constants.PADDLE_BASE_WIDTH
    self.width = self.baseWidth
    self.targetWidth = self.baseWidth
    self.height = Constants.PADDLE_HEIGHT
    self.x = (Constants.VIRTUAL_WIDTH - self.width) / 2
    self.y = Constants.PADDLE_Y
    self.speed = Constants.PADDLE_SPEED

    -- Active Powerups Timers
    self.expandTimer = 0
    self.laserTimer = 0
    self.laserCooldown = 0

    -- Projectiles fired by lasers
    self.lasers = {}

    -- Visual squish/stretch animation parameters
    self.scaleX = 1
    self.scaleY = 1

    return self
end

function Paddle:reset()
    self.targetWidth = self.baseWidth
    self.width = self.baseWidth
    self.x = (Constants.VIRTUAL_WIDTH - self.width) / 2
    self.expandTimer = 0
    self.laserTimer = 0
    self.laserCooldown = 0
    self.lasers = {}
    self.scaleX = 1
    self.scaleY = 1
end

function Paddle:activatePowerup(type)
    if type == "EXPAND" then
        self.expandTimer = 12.0
        self.targetWidth = Constants.PADDLE_EXPAND_WIDTH
    elseif type == "LASER" then
        self.laserTimer = 10.0
    end
end

function Paddle:shootLasers()
    if self.laserTimer > 0 and self.laserCooldown <= 0 then
        self.laserCooldown = 0.25
        Sounds.play("laser")

        -- Left cannon projectile
        table.insert(self.lasers, {
            x = self.x + 8,
            y = self.y - 6,
            width = 4,
            height = 14,
            vy = -850
        })

        -- Right cannon projectile
        table.insert(self.lasers, {
            x = self.x + self.width - 12,
            y = self.y - 6,
            width = 4,
            height = 14,
            vy = -850
        })

        self.scaleY = 1.15
        self.scaleX = 0.95
    end
end

function Paddle:triggerBounceVisual()
    self.scaleY = 0.70
    self.scaleX = 1.30
end

function Paddle:update(dt, mouseX)
    -- Handle Powerup Timers
    if self.expandTimer > 0 then
        self.expandTimer = self.expandTimer - dt
        if self.expandTimer <= 0 then
            self.targetWidth = self.baseWidth
        end
    end

    if self.laserTimer > 0 then
        self.laserTimer = self.laserTimer - dt
    end

    if self.laserCooldown > 0 then
        self.laserCooldown = self.laserCooldown - dt
    end

    -- Smoothly interpolate width to targetWidth
    self.width = self.width + (self.targetWidth - self.width) * math.min(1, dt * 10)

    -- Smoothly return scale to 1 (squish animation recovery)
    self.scaleX = self.scaleX + (1 - self.scaleX) * math.min(1, dt * 15)
    self.scaleY = self.scaleY + (1 - self.scaleY) * math.min(1, dt * 15)

    -- Movement Controls: Mouse + Keyboard fallback
    if mouseX then
        self.x = mouseX - self.width / 2
    end

    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        self.x = self.x - self.speed * dt
    elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        self.x = self.x + self.speed * dt
    end

    -- Clamp within screen boundaries
    local minX = Constants.PLAYFIELD_X
    local maxX = Constants.PLAYFIELD_X + Constants.PLAYFIELD_WIDTH - self.width
    if self.x < minX then self.x = minX end
    if self.x > maxX then self.x = maxX end

    -- Update Lasers
    for i = #self.lasers, 1, -1 do
        local l = self.lasers[i]
        l.y = l.y + l.vy * dt

        -- Remove if off-screen
        if l.y < Constants.PLAYFIELD_Y then
            table.remove(self.lasers, i)
        end
    end
end

function Paddle:checkLaserBrickCollisions(bricks, onBrickHitCallback)
    for i = #self.lasers, 1, -1 do
        local l = self.lasers[i]
        local hit = false

        for _, b in ipairs(bricks) do
            if b.alive and l.x + l.width >= b.x and l.x <= b.x + b.width and
               l.y <= b.y + b.height and l.y + l.height >= b.y then
                
                hit = true
                Particle.spawnExplosion(l.x + l.width / 2, l.y, Constants.COLORS.PADDLE_LASER, 12, 180, 3)
                if onBrickHitCallback then
                    onBrickHitCallback(b, 1)
                end
                break
            end
        end

        if hit then
            table.remove(self.lasers, i)
        end
    end
end

function Paddle:draw()
    love.graphics.push()
    -- Pivot around center of paddle for squish animation
    local cx = self.x + self.width / 2
    local cy = self.y + self.height / 2
    love.graphics.translate(cx, cy)
    love.graphics.scale(self.scaleX, self.scaleY)
    love.graphics.translate(-cx, -cy)

    -- Glow outline
    love.graphics.setColor(Constants.COLORS.PADDLE_GLOW)
    love.graphics.rectangle("fill", self.x - 4, self.y - 4, self.width + 8, self.height + 8, 12, 12)

    -- Main Paddle Body
    if self.laserTimer > 0 then
        love.graphics.setColor(Constants.COLORS.PADDLE_LASER)
    else
        love.graphics.setColor(Constants.COLORS.PADDLE_BASE)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 8, 8)

    -- Top Highlight Strip
    love.graphics.setColor(1, 1, 1, 0.4)
    love.graphics.rectangle("fill", self.x + 4, self.y + 2, self.width - 8, 4, 4, 4)

    -- Draw Laser Cannons if Laser Powerup Active
    if self.laserTimer > 0 then
        love.graphics.setColor(1, 0.2, 0.3, 1)
        love.graphics.rectangle("fill", self.x + 4, self.y - 8, 8, 10, 3, 3)
        love.graphics.rectangle("fill", self.x + self.width - 12, self.y - 8, 8, 10, 3, 3)

        -- Energy tip glow
        love.graphics.setColor(1, 0.9, 0.2, 0.9)
        love.graphics.circle("fill", self.x + 8, self.y - 8, 3)
        love.graphics.circle("fill", self.x + self.width - 8, self.y - 8, 3)
    end

    love.graphics.pop()

    -- Draw Active Lasers
    love.graphics.setColor(Constants.COLORS.PADDLE_LASER)
    for _, l in ipairs(self.lasers) do
        love.graphics.rectangle("fill", l.x, l.y, l.width, l.height, 2, 2)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return Paddle
