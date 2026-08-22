local Constants = require("src.constants")
local Sounds = require("src.sounds")
local Particle = require("src.particle")

local Brick = {}
Brick.__index = Brick

-- Helper to generate procedural jagged crack polylines unique to each brick's position
local function generateCrackPatterns(x, y, w, h)
    local rngState = (math.floor(x * 17 + y * 31) % 9999) + 1
    local function pseudoRNG(min, max)
        rngState = (rngState * 1103515245 + 12345) % 2147483648
        local val = rngState / 2147483648
        return min + val * (max - min)
    end

    local cx = pseudoRNG(w * 0.35, w * 0.65)
    local cy = pseudoRNG(h * 0.35, h * 0.65)

    -- Stage 1 Cracks (Minor damage: Primary jagged fracture + 2 branches)
    local stage1 = {
        {
            { x + pseudoRNG(4, 10), y + pseudoRNG(2, 6) },
            { x + cx * 0.6, y + cy * 0.7 },
            { x + cx, y + cy },
            { x + cx + pseudoRNG(6, 16), y + cy + pseudoRNG(-3, 5) },
            { x + w - pseudoRNG(4, 10), y + h - pseudoRNG(2, 6) }
        },
        {
            { x + cx, y + cy },
            { x + cx + pseudoRNG(-14, -4), y + h - pseudoRNG(2, 5) }
        },
        {
            { x + cx * 0.6, y + cy * 0.7 },
            { x + pseudoRNG(3, 7), y + cy + pseudoRNG(2, 6) }
        }
    }

    -- Stage 2 Cracks (Critical damage: Full spiderweb fracture network + cross fissures)
    local stage2 = {
        stage1[1],
        stage1[2],
        stage1[3],
        {
            { x + pseudoRNG(w * 0.55, w * 0.85), y + pseudoRNG(2, 5) },
            { x + cx + pseudoRNG(3, 10), y + cy - pseudoRNG(2, 6) },
            { x + cx, y + cy },
            { x + pseudoRNG(5, 12), y + h - pseudoRNG(2, 5) }
        },
        {
            { x + cx + pseudoRNG(3, 10), y + cy - pseudoRNG(2, 6) },
            { x + w - pseudoRNG(2, 6), y + pseudoRNG(4, 10) }
        },
        {
            { x + pseudoRNG(4, 10), y + h * 0.5 },
            { x + cx, y + cy }
        }
    }

    return { stage1 = stage1, stage2 = stage2, impactX = x + cx, impactY = y + cy }
end

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
        self.crackData = generateCrackPatterns(x, y, width, height)
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

    -- Aesthetic Procedural Crack System for Tough Bricks
    if self.type == "TOUGH" and self.hitsLeft < self.maxHits and self.crackData then
        local crackSet = (self.hitsLeft == 2) and self.crackData.stage1 or self.crackData.stage2
        local pulseEnergy = 0.5 + math.sin(love.timer.getTime() * 6 + self.x) * 0.5

        -- 1. Outer Glowing Energy Fracture Layer
        love.graphics.setBlendMode("add")
        love.graphics.setColor(color[1] * 0.9, color[2] * 0.9 + 0.1, 1.0, 0.45 + pulseEnergy * 0.3)
        love.graphics.setLineWidth(3.2)
        for _, poly in ipairs(crackSet) do
            for k = 1, #poly - 1 do
                love.graphics.line(poly[k][1], poly[k][2], poly[k+1][1], poly[k+1][2])
            end
        end

        -- 2. Impact Center Energy Core (Glowing collision point)
        love.graphics.setColor(1, 1, 1, 0.65 + pulseEnergy * 0.35)
        love.graphics.circle("fill", self.crackData.impactX, self.crackData.impactY, 2.5)
        love.graphics.setLineWidth(1.2)
        love.graphics.circle("line", self.crackData.impactX, self.crackData.impactY, 4.5)
        love.graphics.setBlendMode("alpha")

        -- 3. Inner Dark Obsidian Crack Lines (Fissure core)
        love.graphics.setColor(0.02, 0.01, 0.05, 0.92)
        love.graphics.setLineWidth(1.5)
        for _, poly in ipairs(crackSet) do
            for k = 1, #poly - 1 do
                love.graphics.line(poly[k][1], poly[k][2], poly[k+1][1], poly[k+1][2])
            end
        end

        -- 4. Micro Shard Chip at Impact Point on Critical Damage (hitsLeft == 1)
        if self.hitsLeft == 1 then
            local ix, iy = self.crackData.impactX, self.crackData.impactY
            love.graphics.setColor(0.01, 0.01, 0.03, 0.95)
            love.graphics.polygon("fill", ix - 3, iy - 2, ix + 2, iy - 3, ix + 3, iy + 2, ix - 2, iy + 3)
            love.graphics.setColor(1, 1, 1, 0.7)
            love.graphics.setLineWidth(1)
            love.graphics.polygon("line", ix - 3, iy - 2, ix + 2, iy - 3, ix + 3, iy + 2, ix - 2, iy + 3)
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
