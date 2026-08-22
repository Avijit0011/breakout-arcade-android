local Constants = require("src.constants")
local Sounds = require("src.sounds")
local Particle = require("src.particle")

local Powerup = {}
Powerup.__index = Powerup

local activeDrops = {}

function Powerup.new(x, y, type)
    local self = setmetatable({}, Powerup)
    self.x = x
    self.y = y
    self.width = 44
    self.height = 20
    self.type = type or Constants.POWERUP_TYPES[love.math.random(#Constants.POWERUP_TYPES)]
    self.vy = 160 -- Fall speed
    self.alive = true
    self.color = Constants.COLORS.POWERUP[self.type] or {1, 1, 1, 1}
    self.pulse = 0
    return self
end

function Powerup.clearAll()
    activeDrops = {}
end

function Powerup.spawn(x, y, forceType)
    local p = Powerup.new(x, y, forceType)
    table.insert(activeDrops, p)
    Sounds.play("powerup_spawn")
end

function Powerup.updateAll(dt, paddle, onCollectCallback)
    for i = #activeDrops, 1, -1 do
        local p = activeDrops[i]
        p.y = p.y + p.vy * dt
        p.pulse = p.pulse + dt * 6

        -- Check collision with paddle AABB
        if p.x + p.width / 2 >= paddle.x and p.x - p.width / 2 <= paddle.x + paddle.width and
           p.y + p.height / 2 >= paddle.y and p.y - p.height / 2 <= paddle.y + paddle.height then
            
            p.alive = false
            Sounds.play("powerup_pickup")
            Particle.spawnExplosion(p.x, p.y, p.color, 30, 300, 5)
            if onCollectCallback then
                onCollectCallback(p.type)
            end
        end

        -- Remove if below screen
        if p.y > Constants.VIRTUAL_HEIGHT + 30 or not p.alive then
            table.remove(activeDrops, i)
        end
    end
end

function Powerup.drawAll()
    for _, p in ipairs(activeDrops) do
        local scale = 1 + math.sin(p.pulse) * 0.08
        love.graphics.push()
        love.graphics.translate(p.x, p.y)
        love.graphics.scale(scale, scale)

        -- Capsule Background
        love.graphics.setColor(p.color)
        love.graphics.rectangle("fill", -p.width / 2, -p.height / 2, p.width, p.height, 10, 10)

        -- Capsule Border
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", -p.width / 2, -p.height / 2, p.width, p.height, 10, 10)

        -- Icon Label text
        love.graphics.setColor(0, 0, 0, 0.9)
        local labelMap = {
            MULTIBALL  = "3x",
            EXPAND     = "< >",
            LASER      = "||",
            FIREBALL   = "F",
            SAFETY_NET = "==",
            EXTRA_LIFE = "+1",
            MULTIPLIER = "2x"
        }
        local font = love.graphics.getFont()
        local label = labelMap[p.type] or "P"
        love.graphics.print(label, -font:getWidth(label) / 2, -font:getHeight() / 2)

        love.graphics.pop()
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return Powerup
