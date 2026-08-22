local Constants = require("src.constants")

local Particle = {}

local particles = {}
local scoreTexts = {}
local stars = {}

local shakeTimer = 0
local shakeDuration = 0
local shakeIntensity = 0

function Particle.init()
    particles = {}
    scoreTexts = {}
    stars = {}
    shakeTimer = 0

    -- Initialize layered ambient starfield
    for i = 1, 110 do
        local layer = (i <= 40) and 1 or ((i <= 80) and 2 or 3)
        table.insert(stars, {
            x = love.math.random(0, Constants.VIRTUAL_WIDTH),
            y = love.math.random(0, Constants.VIRTUAL_HEIGHT),
            speed = ({12, 28, 55})[layer] + love.math.random() * ({18, 22, 30})[layer],
            radius = ({0.6, 1.1, 1.8})[layer] + love.math.random() * ({0.5, 0.8, 1.1})[layer],
            alpha = ({0.18, 0.35, 0.55})[layer] + love.math.random() * 0.25,
            twinkle = love.math.random() * math.pi * 2,
            sparkle = layer == 3
        })
    end
end

-- Spawn a burst of particles at (x, y) with color {r, g, b, a}
function Particle.spawnExplosion(x, y, color, count, speed, size)
    count = count or 25
    speed = speed or 250
    size = size or 4

    for i = 1, count do
        local angle = love.math.random() * math.pi * 2
        local pSpeed = (0.3 + love.math.random() * 0.7) * speed
        local vx = math.cos(angle) * pSpeed
        local vy = math.sin(angle) * pSpeed
        local lifetime = 0.3 + love.math.random() * 0.4
        local pSize = size * (0.6 + love.math.random() * 0.8)

        table.insert(particles, {
            x = x,
            y = y,
            vx = vx,
            vy = vy,
            color = {color[1], color[2], color[3], color[4] or 1},
            size = pSize,
            life = lifetime,
            maxLife = lifetime,
            gravity = 350
        })
    end
end

-- Spawn floating score text popup (+100, COMBO x3, etc.)
function Particle.spawnScoreText(x, y, text, color)
    table.insert(scoreTexts, {
        x = x,
        y = y,
        text = text,
        color = color or Constants.COLORS.ACCENT_GOLD,
        life = 0.85,
        maxLife = 0.85,
        scale = 0.7
    })
end

-- Spawn trail particle behind ball
function Particle.spawnTrail(x, y, radius, color)
    table.insert(particles, {
        x = x,
        y = y,
        vx = (love.math.random() - 0.5) * 30,
        vy = (love.math.random() - 0.5) * 30,
        color = {color[1], color[2], color[3], 0.6},
        size = radius * 0.7,
        life = 0.25,
        maxLife = 0.25,
        gravity = 0
    })
end

-- Trigger screen shake
function Particle.shake(intensity, duration)
    shakeIntensity = intensity or 8
    shakeDuration = duration or 0.25
    shakeTimer = shakeDuration
end

function Particle.update(dt)
    -- Update Ambient Starfield
    for _, s in ipairs(stars) do
        s.y = s.y + s.speed * dt
        if s.y > Constants.VIRTUAL_HEIGHT then
            s.y = -10
            s.x = love.math.random(0, Constants.VIRTUAL_WIDTH)
        end
        s.twinkle = s.twinkle + dt * 3
    end

    -- Update Screen Shake
    if shakeTimer > 0 then
        shakeTimer = shakeTimer - dt
    end

    -- Update Particles
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.life = p.life - dt
        if p.life <= 0 then
            table.remove(particles, i)
        else
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            p.vy = p.vy + (p.gravity or 0) * dt
            local alpha = (p.life / p.maxLife)
            p.color[4] = alpha
        end
    end

    -- Update Floating Score Texts
    for i = #scoreTexts, 1, -1 do
        local st = scoreTexts[i]
        st.life = st.life - dt
        if st.life <= 0 then
            table.remove(scoreTexts, i)
        else
            st.y = st.y - 45 * dt
            st.scale = st.scale + (1.1 - st.scale) * math.min(1, dt * 10)
        end
    end
end

function Particle.drawStarfield()
    love.graphics.setBlendMode("add")
    for _, s in ipairs(stars) do
        local twinkle = 0.55 + math.sin(s.twinkle) * 0.45
        local currentAlpha = s.alpha * twinkle
        love.graphics.setColor(0.75, 0.88, 1.0, currentAlpha)
        love.graphics.circle("fill", s.x, s.y, s.radius)
        if s.sparkle then
            love.graphics.setColor(1, 1, 1, currentAlpha * 0.55)
            love.graphics.setLineWidth(1)
            local arm = s.radius * 3.2
            love.graphics.line(s.x - arm, s.y, s.x + arm, s.y)
            love.graphics.line(s.x, s.y - arm, s.x, s.y + arm)
        end
    end
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1, 1)
end

function Particle.draw()
    love.graphics.setBlendMode("add")
    for _, p in ipairs(particles) do
        love.graphics.setColor(p.color)
        local curSize = p.size * (0.35 + 0.65 * (p.life / p.maxLife))
        love.graphics.circle("fill", p.x, p.y, curSize * 1.8)
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], (p.color[4] or 1) * 0.9)
        love.graphics.circle("fill", p.x, p.y, curSize)
    end
    love.graphics.setBlendMode("alpha")

    -- Draw Floating Score Popups
    local font = love.graphics.getFont()
    for _, st in ipairs(scoreTexts) do
        local progress = st.life / st.maxLife
        local alpha = math.min(1, progress * 1.5)

        love.graphics.push()
        love.graphics.translate(st.x, st.y)
        love.graphics.scale(st.scale, st.scale)

        -- Text drop shadow
        love.graphics.setColor(0, 0, 0, alpha * 0.8)
        love.graphics.print(st.text, -font:getWidth(st.text) / 2 + 2, -font:getHeight() / 2 + 2)

        -- Text main color
        love.graphics.setColor(st.color[1], st.color[2], st.color[3], alpha)
        love.graphics.print(st.text, -font:getWidth(st.text) / 2, -font:getHeight() / 2)

        love.graphics.pop()
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function Particle.applyShake()
    if shakeTimer > 0 then
        local progress = shakeTimer / shakeDuration
        local currentIntensity = shakeIntensity * progress
        local dx = (love.math.random() * 2 - 1) * currentIntensity
        local dy = (love.math.random() * 2 - 1) * currentIntensity
        love.graphics.translate(dx, dy)
    end
end

return Particle
