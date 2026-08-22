local Constants = require("src.constants")

local Visuals = {}

local bgMesh
local vignetteMeshes
local scanlineCanvas

local function makeGradientQuad(w, h, top, bottom)
    return love.graphics.newMesh({
        {0, 0, 0, 0, top[1], top[2], top[3], top[4] or 1},
        {w, 0, 1, 0, top[1], top[2], top[3], top[4] or 1},
        {w, h, 1, 1, bottom[1], bottom[2], bottom[3], bottom[4] or 1},
        {0, h, 0, 1, bottom[1], bottom[2], bottom[3], bottom[4] or 1},
    }, "fan")
end

function Visuals.init()
    local w, h = Constants.VIRTUAL_WIDTH, Constants.VIRTUAL_HEIGHT
    local c = Constants.COLORS

    bgMesh = makeGradientQuad(w, h, c.SKY_TOP, c.SKY_BOTTOM)

    vignetteMeshes = {
        makeGradientQuad(w, 160, {0, 0, 0, 0.72}, {0, 0, 0, 0}),
        makeGradientQuad(w, 220, {0, 0, 0, 0}, {0, 0, 0, 0.78}),
    }

    scanlineCanvas = love.graphics.newCanvas(2, 4)
    scanlineCanvas:setWrap("repeat", "repeat")
    scanlineCanvas:setFilter("nearest", "nearest")
    love.graphics.setCanvas(scanlineCanvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setColor(0, 0, 0, 0.22)
    love.graphics.rectangle("fill", 0, 2, 2, 2)
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
end

function Visuals.set(c, a)
    love.graphics.setColor(c[1], c[2], c[3], a or c[4] or 1)
end

function Visuals.drawBackground(time)
    local w, h = Constants.VIRTUAL_WIDTH, Constants.VIRTUAL_HEIGHT
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(bgMesh, 0, 0)

    -- Soft nebula blooms
    love.graphics.setBlendMode("add")
    local nebulae = {
        {x = 180, y = 140, r = 260, c = {0.35, 0.12, 0.55, 0.16}},
        {x = 1080, y = 90, r = 300, c = {0.08, 0.28, 0.55, 0.18}},
        {x = 640, y = 520, r = 340, c = {0.45, 0.08, 0.28, 0.10}},
        {x = 420, y = 80, r = 180, c = {0.10, 0.45, 0.50, 0.10}},
    }
    for _, n in ipairs(nebulae) do
        local pulse = 0.85 + math.sin(time * 0.4 + n.x) * 0.15
        love.graphics.setColor(n.c[1], n.c[2], n.c[3], n.c[4] * pulse)
        love.graphics.circle("fill", n.x, n.y, n.r)
    end
    love.graphics.setBlendMode("alpha")

    -- Horizon glow
    local horizon = h * 0.58
    love.graphics.setBlendMode("add")
    love.graphics.setColor(0.55, 0.18, 0.55, 0.12)
    love.graphics.ellipse("fill", w / 2, horizon, 520, 48)
    love.graphics.setColor(0.10, 0.70, 0.95, 0.10)
    love.graphics.ellipse("fill", w / 2, horizon + 8, 380, 22)
    love.graphics.setBlendMode("alpha")

    -- Perspective floor grid
    love.graphics.setLineWidth(1)
    local vpX = w / 2
    for i = 0, 16 do
        local t = i / 16
        local y = horizon + (h - horizon) * (t * t)
        local a = 0.04 + t * 0.14
        love.graphics.setColor(0.35, 0.85, 1.0, a)
        love.graphics.line(0, y, w, y)
    end
    for i = -18, 18 do
        local x = vpX + i * 70
        love.graphics.setColor(0.35, 0.85, 1.0, 0.07)
        love.graphics.line(x, h + 40, vpX, horizon)
    end

    -- Sparse upper grid (faint)
    love.graphics.setColor(0.45, 0.35, 0.95, 0.05)
    for x = 0, w, 80 do
        love.graphics.line(x, 0, x, horizon)
    end
    for y = 0, horizon, 80 do
        love.graphics.line(0, y, w, y)
    end
end

function Visuals.drawPlayfield()
    local x, y = Constants.PLAYFIELD_X, Constants.PLAYFIELD_Y
    local w, h = Constants.PLAYFIELD_WIDTH, Constants.PLAYFIELD_HEIGHT
    local r = 16

    -- Inner glass panel
    love.graphics.setColor(0.04, 0.05, 0.12, 0.42)
    love.graphics.rectangle("fill", x, y, w, h, r, r)

    -- Inner top sheen
    love.graphics.setColor(1, 1, 1, 0.035)
    love.graphics.rectangle("fill", x + 8, y + 6, w - 16, 28, 10, 10)

    -- Outer bloom
    love.graphics.setBlendMode("add")
    love.graphics.setColor(0.05, 0.65, 0.95, 0.10)
    love.graphics.setLineWidth(10)
    love.graphics.rectangle("line", x - 3, y - 3, w + 6, h + 6, r + 3, r + 3)
    love.graphics.setBlendMode("alpha")

    -- Neon frame
    love.graphics.setColor(0.20, 0.90, 1.00, 0.85)
    love.graphics.setLineWidth(2.2)
    love.graphics.rectangle("line", x, y, w, h, r, r)

    -- Corner brackets
    local len = 28
    love.graphics.setLineWidth(3)
    love.graphics.setColor(1.00, 0.35, 0.75, 0.9)
    local corners = {
        {x, y, 1, 1},
        {x + w, y, -1, 1},
        {x, y + h, 1, -1},
        {x + w, y + h, -1, -1},
    }
    for _, c in ipairs(corners) do
        local cx, cy, sx, sy = c[1], c[2], c[3], c[4]
        love.graphics.line(cx, cy + 10 * sy, cx, cy, cx + 10 * sx, cy)
        love.graphics.line(cx, cy, cx + len * sx, cy)
        love.graphics.line(cx, cy, cx, cy + len * sy)
    end
end

function Visuals.drawVignetteAndScanlines()
    local w, h = Constants.VIRTUAL_WIDTH, Constants.VIRTUAL_HEIGHT
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(vignetteMeshes[1], 0, 0)
    love.graphics.draw(vignetteMeshes[2], 0, h - 220)

    -- Side fades
    love.graphics.setColor(0, 0, 0, 0.35)
    love.graphics.rectangle("fill", 0, 0, 18, h)
    love.graphics.rectangle("fill", w - 18, 0, 18, h)

    love.graphics.setColor(1, 1, 1, 0.55)
    love.graphics.draw(scanlineCanvas, 0, 0, 0, w / 2, h / 4)
end

function Visuals.glowRect(x, y, width, height, radius, color, intensity)
    intensity = intensity or 0.22
    love.graphics.setBlendMode("add")
    love.graphics.setColor(color[1], color[2], color[3], intensity * 0.45)
    love.graphics.rectangle("fill", x - 6, y - 6, width + 12, height + 12, radius + 6, radius + 6)
    love.graphics.setColor(color[1], color[2], color[3], intensity)
    love.graphics.rectangle("fill", x - 2, y - 2, width + 4, height + 4, radius + 2, radius + 2)
    love.graphics.setBlendMode("alpha")
end

function Visuals.glowCircle(x, y, radius, color, intensity)
    intensity = intensity or 0.35
    love.graphics.setBlendMode("add")
    love.graphics.setColor(color[1], color[2], color[3], intensity * 0.35)
    love.graphics.circle("fill", x, y, radius * 2.4)
    love.graphics.setColor(color[1], color[2], color[3], intensity)
    love.graphics.circle("fill", x, y, radius * 1.45)
    love.graphics.setBlendMode("alpha")
end

function Visuals.pill(x, y, width, height, fill, border)
    love.graphics.setColor(fill[1], fill[2], fill[3], fill[4] or 0.78)
    love.graphics.rectangle("fill", x, y, width, height, height / 2, height / 2)
    if border then
        love.graphics.setColor(border[1], border[2], border[3], border[4] or 0.7)
        love.graphics.setLineWidth(1.4)
        love.graphics.rectangle("line", x, y, width, height, height / 2, height / 2)
    end
end

return Visuals
