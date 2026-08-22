local Sounds = {}

local sources = {}
local sampleRate = 44100
local bgmSource = nil
local musicEnabled = true

-- Helper function to generate SoundData and Source
local function createSound(duration, generateFunc)
    local sampleCount = math.floor(sampleRate * duration)
    local soundData = love.sound.newSoundData(sampleCount, sampleRate, 16, 1)

    for i = 0, sampleCount - 1 do
        local t = i / sampleRate
        local sample = generateFunc(t, duration, i, sampleCount)
        -- Clamp sample between -1 and 1
        if sample > 1 then sample = 1 end
        if sample < -1 then sample = -1 end
        soundData:setSample(i, sample)
    end

    local source = love.audio.newSource(soundData, "static")
    return source
end

-- Procedurally synthesize a soothing ambient background music track (16s seamless chord loop)
local function createBGM(duration)
    local sampleCount = math.floor(sampleRate * duration)
    local soundData = love.sound.newSoundData(sampleCount, sampleRate, 16, 1)

    local bars = {
        { bass = 65.41,  pad = {130.81, 164.81, 196.00, 246.94} }, -- Cmaj7
        { bass = 55.00,  pad = {110.00, 130.81, 164.81, 196.00, 246.94} }, -- Am9
        { bass = 43.65,  pad = {87.31,  110.00, 130.81, 164.81} }, -- Fmaj7
        { bass = 49.00,  pad = {98.00,  123.47, 146.83, 164.81} }  -- G6
    }

    local arpNotes = {
        523.25, 659.25, 783.99, 987.77, 1046.50, 783.99, 659.25, 523.25,
        440.00, 523.25, 659.25, 783.99, 987.77,  783.99, 659.25, 523.25,
        349.23, 440.00, 523.25, 659.25, 783.99,  659.25, 523.25, 440.00,
        392.00, 493.88, 587.33, 659.25, 783.99,  659.25, 493.88, 392.00
    }

    local barDuration = duration / 4
    local arpNoteDuration = duration / #arpNotes

    for i = 0, sampleCount - 1 do
        local t = i / sampleRate

        local barFloat = (t / barDuration) % 4
        local barIndex1 = math.floor(barFloat) + 1
        local barIndex2 = (barIndex1 % 4) + 1
        local barPos = barFloat - math.floor(barFloat)

        local fadeWidth = 0.25
        local w1, w2 = 1, 0
        if barPos > (1 - fadeWidth) then
            local blend = (barPos - (1 - fadeWidth)) / fadeWidth
            w2 = blend * blend * (3 - 2 * blend)
            w1 = 1 - w2
        end

        local b1 = bars[barIndex1]
        local b2 = bars[barIndex2]

        -- Sub Bass
        local bassSample = (math.sin(2 * math.pi * b1.bass * t) * w1 + math.sin(2 * math.pi * b2.bass * t) * w2) * 0.26

        -- Warm Synth Pad
        local padSample1 = 0
        for _, f in ipairs(b1.pad) do
            padSample1 = padSample1 + math.sin(2 * math.pi * f * t) + 0.5 * math.sin(2 * math.pi * (f * 1.003) * t)
        end
        padSample1 = padSample1 / (#b1.pad * 1.5)

        local padSample2 = 0
        for _, f in ipairs(b2.pad) do
            padSample2 = padSample2 + math.sin(2 * math.pi * f * t) + 0.5 * math.sin(2 * math.pi * (f * 1.003) * t)
        end
        padSample2 = padSample2 / (#b2.pad * 1.5)

        local padSample = (padSample1 * w1 + padSample2 * w2) * 0.32

        -- Ambient Arpeggio
        local arpIndex = math.floor((t / arpNoteDuration) % #arpNotes) + 1
        local arpT = (t % arpNoteDuration)
        local arpFreq = arpNotes[arpIndex]
        local arpEnv = math.exp(-arpT * 4.5) * (1 - math.exp(-arpT * 80))
        local arpSample = math.sin(2 * math.pi * arpFreq * t) * arpEnv * 0.16

        local sample = bassSample + padSample + arpSample
        if sample > 1 then sample = 1 end
        if sample < -1 then sample = -1 end

        soundData:setSample(i, sample)
    end

    local source = love.audio.newSource(soundData, "static")
    source:setLooping(true)
    source:setVolume(0.30)
    return source
end

function Sounds.init()
    -- Synthesize BGM
    bgmSource = createBGM(16.0)

    -- 1. Paddle Bounce: short rising sine wave
    sources["paddle_hit"] = createSound(0.08, function(t, dur)
        local freq = 250 + (t / dur) * 200
        local env = 1 - (t / dur)
        return math.sin(2 * math.pi * freq * t) * env * 0.5
    end)

    -- 2. Wall Bounce: dull sine ping
    sources["wall_hit"] = createSound(0.06, function(t, dur)
        local freq = 180 + (t / dur) * 100
        local env = 1 - (t / dur)
        return math.sin(2 * math.pi * freq * t) * env * 0.4
    end)

    -- 3. Brick Hit: bright sine ping
    sources["brick_hit"] = createSound(0.07, function(t, dur)
        local freq = 500 + (t / dur) * 400
        local env = math.exp(-t * 25)
        return math.sin(2 * math.pi * freq * t) * env * 0.5
    end)

    -- 4. Brick Break: noise + decaying tone pulse
    sources["brick_break"] = createSound(0.12, function(t, dur)
        local env = math.exp(-t * 18)
        local noise = (love.math.random() * 2 - 1) * 0.5
        local tone = math.sin(2 * math.pi * (700 - t * 3000) * t) * 0.5
        return (noise + tone) * env * 0.6
    end)

    -- 5. Steel Hit: metallic chime
    sources["steel_hit"] = createSound(0.09, function(t, dur)
        local env = math.exp(-t * 30)
        local tone1 = math.sin(2 * math.pi * 1200 * t)
        local tone2 = math.sin(2 * math.pi * 1850 * t) * 0.6
        return (tone1 + tone2) * 0.5 * env * 0.5
    end)

    -- 6. Explosion (TNT): deep noise blast
    sources["explosion"] = createSound(0.35, function(t, dur)
        local env = (1 - t / dur) ^ 2
        local noise = (love.math.random() * 2 - 1)
        local rumble = math.sin(2 * math.pi * (120 - t * 250) * t) * 0.6
        return (noise * 0.7 + rumble * 0.3) * env * 0.7
    end)

    -- 7. Powerup Spawn: quick chime
    sources["powerup_spawn"] = createSound(0.15, function(t, dur)
        local freq = 440 + math.floor(t * 20) * 110
        local env = 1 - t / dur
        return math.sin(2 * math.pi * freq * t) * env * 0.4
    end)

    -- 8. Powerup Pickup: bright arpeggio (C5 -> E5 -> G5 -> C6)
    sources["powerup_pickup"] = createSound(0.28, function(t, dur)
        local step = math.floor(t / (dur / 4))
        local freqs = {523.25, 659.25, 783.99, 1046.50}
        local freq = freqs[step + 1] or 1046.50
        local env = (1 - ((t % (dur / 4)) / (dur / 4)))
        return math.sin(2 * math.pi * freq * t) * env * 0.5
    end)

    -- 9. Laser Shoot: high-to-low zapping saw wave
    sources["laser"] = createSound(0.10, function(t, dur)
        local freq = 900 - (t / dur) * 600
        local phase = (freq * t) % 1
        local saw = (phase * 2) - 1
        local env = 1 - t / dur
        return saw * env * 0.4
    end)

    -- 10. Lose Life: sad glide down
    sources["lose_life"] = createSound(0.45, function(t, dur)
        local freq = math.max(60, 420 - (t / dur) * 340)
        local env = 1 - (t / dur)
        return math.sin(2 * math.pi * freq * t) * env * 0.6
    end)

    -- 11. Game Over: descending minor notes
    sources["game_over"] = createSound(0.85, function(t, dur)
        local step = math.floor(t / (dur / 4))
        local freqs = {440, 392, 349.23, 220}
        local freq = freqs[step + 1] or 220
        local env = 1 - (t / dur)
        local wave = math.sin(2 * math.pi * freq * t)
        return wave * env * 0.6
    end)

    -- 12. Victory Fanfare
    sources["victory"] = createSound(0.90, function(t, dur)
        local step = math.floor(t / (dur / 5))
        local freqs = {523.25, 659.25, 783.99, 1046.50, 1318.51}
        local freq = freqs[step + 1] or 1318.51
        local env = 1 - (t / dur)
        return math.sin(2 * math.pi * freq * t) * env * 0.6
    end)
end

function Sounds.play(name)
    if sources[name] then
        local src = sources[name]:clone()
        src:setVolume(0.7)
        src:play()
    end
end

function Sounds.playBGM()
    if musicEnabled and bgmSource and not bgmSource:isPlaying() then
        bgmSource:play()
    end
end

function Sounds.stopBGM()
    if bgmSource then
        bgmSource:stop()
    end
end

function Sounds.toggleMusic()
    musicEnabled = not musicEnabled
    if musicEnabled then
        Sounds.playBGM()
    else
        Sounds.stopBGM()
    end
    return musicEnabled
end

function Sounds.isMusicEnabled()
    return musicEnabled
end

function Sounds.setMusicEnabled(enabled)
    musicEnabled = enabled
    if musicEnabled then
        Sounds.playBGM()
    else
        Sounds.stopBGM()
    end
end

return Sounds
