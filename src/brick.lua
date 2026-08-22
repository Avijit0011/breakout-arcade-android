local Constants = require("src.constants")
local Sounds = require("src.sounds")
local Particle = require("src.particle")

local Brick = {}
Brick.__index = Brick

function Brick.new(x, y, width, height, tier, type)
    local self = setmetatable({}, Brick)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.tier = tier or 1
    self.type = type or "NORMAL" -- "NORMAL", "TOUGH", "STEEL", "TNT", "POWERUP"

    if self.type == "TOUGH" then
        self.maxHits = 3
        self.hitsLeft = 3
    elseif self.type == "STEEL" then
        self.maxHits = math.huge
        self.hitsLeft = math.huge
    else
        self.maxHits = 1
        self.hitsLeft = 1
    end

    self.alive = true
    self.flashTimer = 0
    return self
end

function Brick:getColor()
    if self.type == "STEEL" then
        return Constants.COLORS.BRICK_STEEL
    elseif self.type == "TNT" then
        return Constants.COLORS.BRICK_TNT
    elseif self.type == "POWERUP" then
        return Constants.COLORS.BRICK_POWERUP
    else
        local idx = math.min(#Constants.COLORS.BRICK_TIERS, self.tier)
        return Constants.COLORS.BRICK_TIERS[idx]
    end
end

-- Take hit, return true if destroyed, and points scored
function Brick:hit(damage, isExplosion)
    if not self.alive then return false, 0 end
    damage = damage or 1

    self.flashTimer = 0.12

    if self.type == "STEEL" then
        if isExplosion then
            -- Explosions can shatter steel!
            self.alive = false
            Sounds.play("brick_break")
            Particle.spawnExplosion(self.x + self.width / 2, self.y + self.height / 2, Constants.COLORS.BRICK_STEEL, 20, 250, 4)
            return true, 300
        else
            Sounds.play("steel_hit")
            Particle.spawnExplosion(self.x + self.width / 2, self.y + self.height / 2, Constants.COLORS.BRICK_STEEL, 8, 150, 2)
            return false, 0
        end
    end

    self.hitsLeft = self.hitsLeft - damage

    if self.hitsLeft <= 0 then
        self.alive = false
        local color = self:getColor()
        if self.type == "TNT" then
            Sounds.play("explosion")
            Particle.shake(14, 0.35)
            Particle.spawnExplosion(self.x + self.width / 2, self.y + self.height / 2, Constants.COLORS.BRICK_TNT, 40, 380, 6)
        else
            Sounds.play("brick_break")
            Particle.spawnExplosion(self.x + self.width / 2, self.y + self.height / 2, color, 22, 220, 4)
        end

        local basePoints = 100 * self.tier
        if self.type == "TNT" then basePoints = 250 end
        if self.type == "TOUGH" then basePoints = 300 end
        if self.type == "POWERUP" then basePoints = 200 end

        return true, basePoints
    else
        Sounds.play("brick_hit")
        Particle.spawnExplosion(self.x + self.width / 2, self.y + self.height / 2, self:getColor(), 8, 120, 2)
        return false, 50
    end
end

function Brick:update(dt)
    if self.flashTimer > 0 then
        self.flashTimer = self.flashTimer - dt
    end
end

function Brick:draw()
    if not self.alive then return end

    local color = self:getColor()
    local flashing = self.flashTimer > 0
    local pulse = 0.55 + math.sin(love.timer.getTime() * 4 + self.x * 0.02) * 0.45

    -- Soft color bloom
    love.graphics.setBlendMode("add")
    if flashing then
        love.graphics.setColor(1, 1, 1, 0.45)
    else
        love.graphics.setColor(color[1], color[2], color[3], 0.18)
    end
    love.graphics.rectangle("fill", self.x - 3, self.y - 3, self.width + 6, self.height + 6, 6, 6)
    love.graphics.setBlendMode("alpha")

    -- Body
    if flashing then
        love.graphics.setColor(1, 1, 1, 1)
    else
        love.graphics.setColor(color[1] * 0.55, color[2] * 0.55, color[3] * 0.55, 1)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5, 5)

    -- Upper gradient sheen
    if not flashing then
        love.graphics.setColor(color[1], color[2], color[3], 1)
        love.graphics.rectangle("fill", self.x + 1, self.y + 1, self.width - 2, self.height * 0.55, 4, 4)
    end

    -- Specular
    love.graphics.setColor(1, 1, 1, flashing and 0.9 or 0.28)
    love.graphics.rectangle("fill", self.x + 4, self.y + 3, self.width - 8, 3, 2, 2)

    -- Neon edge
    love.graphics.setColor(color[1], color[2], color[3], 0.85)
    love.graphics.setLineWidth(1.4)
    love.graphics.rectangle("line", self.x + 0.5, self.y + 0.5, self.width - 1, self.height - 1, 5, 5)

    if self.type == "TOUGH" and self.hitsLeft < self.maxHits then
        love.graphics.setColor(0.05, 0.02, 0.08, 0.75)
        love.graphics.setLineWidth(2)
        if self.hitsLeft == 2 then
            love.graphics.line(self.x + 6, self.y + 4, self.x + self.width * 0.4, self.y + self.height * 0.6)
        elseif self.hitsLeft == 1 then
            love.graphics.line(self.x + 6, self.y + 4, self.x + self.width * 0.4, self.y + self.height * 0.6)
            love.graphics.line(self.x + self.width * 0.4, self.y + self.height * 0.6, self.x + self.width - 6, self.y + self.height - 4)
            love.graphics.line(self.x + self.width * 0.6, self.y + 4, self.x + self.width * 0.3, self.y + self.height - 4)
        end
    elseif self.type == "TNT" then
        love.graphics.setColor(1, 0.92, 0.2, 0.25 + pulse * 0.35)
        love.graphics.rectangle("fill", self.x + 2, self.y + 2, self.width - 4, self.height - 4, 3, 3)
        love.graphics.setColor(1, 1, 1, 0.95)
        local font = love.graphics.getFont()
        local txt = "TNT"
        love.graphics.print(txt, self.x + (self.width - font:getWidth(txt)) / 2, self.y + (self.height - font:getHeight()) / 2)
    elseif self.type == "STEEL" then
        love.graphics.setColor(0.85, 0.92, 1.0, 0.22)
        for i = 1, 3 do
            local ly = self.y + 5 + (i - 1) * (self.height / 4)
            love.graphics.line(self.x + 6, ly, self.x + self.width - 6, ly)
        end
        love.graphics.setColor(0.95, 0.98, 1.0, 0.45)
        love.graphics.line(self.x + 5, self.y + self.height - 5, self.x + self.width - 5, self.y + 5)
    elseif self.type == "POWERUP" then
        love.graphics.setColor(1, 1, 1, 0.55 + pulse * 0.4)
        local font = love.graphics.getFont()
        local txt = "★"
        love.graphics.print(txt, self.x + (self.width - font:getWidth(txt)) / 2, self.y + (self.height - font:getHeight()) / 2)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return Brick
