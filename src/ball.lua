local Constants = require("src.constants")
local Sounds = require("src.sounds")
local Particle = require("src.particle")

local Ball = {}
Ball.__index = Ball

function Ball.new(x, y)
    local self = setmetatable({}, Ball)
    self.x = x or (Constants.VIRTUAL_WIDTH / 2)
    self.y = y or (Constants.PADDLE_Y - Constants.BALL_RADIUS - 2)
    self.radius = Constants.BALL_RADIUS
    self.speed = Constants.BALL_BASE_SPEED
    self.vx = 0
    self.vy = 0
    self.served = false
    self.alive = true
    self.fireballTimer = 0
    self.trailTimer = 0
    return self
end

function Ball:resetOnPaddle(paddle)
    self.speed = Constants.BALL_BASE_SPEED
    self.served = false
    self.fireballTimer = 0
    self.x = paddle.x + paddle.width / 2
    self.y = paddle.y - self.radius - 2
    self.vx = 0
    self.vy = 0
    self.alive = true
end

function Ball:launch(angleOffset)
    self.served = true
    angleOffset = angleOffset or ((love.math.random() - 0.5) * 0.4)
    local launchAngle = -math.pi / 2 + angleOffset
    self.vx = math.cos(launchAngle) * self.speed
    self.vy = math.sin(launchAngle) * self.speed
    Sounds.play("paddle_hit")
end

function Ball:activateFireball(duration)
    self.fireballTimer = duration or 8.0
end

function Ball:update(dt, paddle)
    if not self.alive then return end

    if self.fireballTimer > 0 then
        self.fireballTimer = self.fireballTimer - dt
    end

    if not self.served then
        self.x = paddle.x + paddle.width / 2
        self.y = paddle.y - self.radius - 2
        return
    end

    -- Update motion
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    -- Spawn Trail Particles
    self.trailTimer = self.trailTimer + dt
    if self.trailTimer >= 0.02 then
        self.trailTimer = 0
        local color = (self.fireballTimer > 0) and Constants.COLORS.BALL_FIRE or Constants.COLORS.BALL_NORMAL
        Particle.spawnTrail(self.x, self.y, self.radius, color)
    end

    -- Wall Collisions
    local minX = Constants.PLAYFIELD_X + self.radius
    local maxX = Constants.PLAYFIELD_X + Constants.PLAYFIELD_WIDTH - self.radius
    local minY = Constants.PLAYFIELD_Y + self.radius

    if self.x < minX then
        self.x = minX
        self.vx = math.abs(self.vx)
        Sounds.play("wall_hit")
    elseif self.x > maxX then
        self.x = maxX
        self.vx = -math.abs(self.vx)
        Sounds.play("wall_hit")
    end

    if self.y < minY then
        self.y = minY
        self.vy = math.abs(self.vy)
        Sounds.play("wall_hit")
    end
end

-- Paddle Collision check
function Ball:checkPaddleCollision(paddle)
    if not self.served or self.vy < 0 then return false end

    if self.x + self.radius >= paddle.x and self.x - self.radius <= paddle.x + paddle.width and
       self.y + self.radius >= paddle.y and self.y - self.radius <= paddle.y + paddle.height then

        self.y = paddle.y - self.radius - 1
        
        -- Deflection angle based on relative hit position on paddle (-1.0 to 1.0)
        local hitOffset = (self.x - (paddle.x + paddle.width / 2)) / (paddle.width / 2)
        if hitOffset < -1 then hitOffset = -1 end
        if hitOffset > 1 then hitOffset = 1 end

        -- Calculate bounce angle (max 60 degrees deflection from vertical)
        local maxAngle = math.pi * 0.35
        local bounceAngle = hitOffset * maxAngle

        self.speed = math.min(Constants.BALL_MAX_SPEED, self.speed + Constants.BALL_SPEED_INC)
        self.vx = math.sin(bounceAngle) * self.speed
        self.vy = -math.cos(bounceAngle) * self.speed

        paddle:triggerBounceVisual()
        Sounds.play("paddle_hit")
        Particle.spawnExplosion(self.x, self.y, Constants.COLORS.PADDLE_GLOW, 10, 150, 3)

        return true
    end
    return false
end

-- Circle vs Box (AABB) Collision detection for Bricks
function Ball:checkBrickCollision(brick)
    if not self.alive or not self.served or not brick.alive then return false end

    -- Nearest point on box to circle center
    local closestX = math.max(brick.x, math.min(self.x, brick.x + brick.width))
    local closestY = math.max(brick.y, math.min(self.y, brick.y + brick.height))

    local dx = self.x - closestX
    local dy = self.y - closestY
    local distSq = dx * dx + dy * dy

    if distSq < (self.radius * self.radius) then
        -- Collision detected!
        if self.fireballTimer <= 0 or brick.type == "STEEL" then
            -- Determine collision normal (which side was hit)
            local overlapX = (self.radius) - math.abs(dx)
            local overlapY = (self.radius) - math.abs(dy)

            if dx == 0 and dy == 0 then
                self.vy = -self.vy
            elseif overlapX < overlapY then
                self.vx = (dx > 0) and math.abs(self.vx) or -math.abs(self.vx)
                self.x = self.x + ((dx > 0) and overlapX or -overlapX)
            else
                self.vy = (dy > 0) and math.abs(self.vy) or -math.abs(self.vy)
                self.y = self.y + ((dy > 0) and overlapY or -overlapY)
            end
        end

        self.speed = math.min(Constants.BALL_MAX_SPEED, self.speed + Constants.BALL_SPEED_INC * 0.5)

        return true
    end
    return false
end

function Ball:draw()
    if not self.alive then return end

    love.graphics.push()
    love.graphics.translate(self.x, self.y)

    -- Glow outline
    local glowColor = (self.fireballTimer > 0) and {1, 0.4, 0.1, 0.5} or {1, 1, 1, 0.3}
    love.graphics.setColor(glowColor)
    love.graphics.circle("fill", 0, 0, self.radius + 4)

    -- Core Ball
    local coreColor = (self.fireballTimer > 0) and Constants.COLORS.BALL_FIRE or Constants.COLORS.BALL_NORMAL
    love.graphics.setColor(coreColor)
    love.graphics.circle("fill", 0, 0, self.radius)

    -- Inner specular highlight
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.circle("fill", -self.radius * 0.3, -self.radius * 0.3, self.radius * 0.35)

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

return Ball
