local Constants = require("src.constants")
local Brick = require("src.brick")

local Levels = {}

local COLS = 13
local ROWS = 8
local SPACING = 6
local START_Y = Constants.PLAYFIELD_Y + 20

local BRICK_WIDTH = (Constants.PLAYFIELD_WIDTH - (COLS + 1) * SPACING) / COLS
local BRICK_HEIGHT = 26

-- Helper to instantiate brick from symbol
local function createBrickFromSymbol(col, row, sym)
    if sym == 0 or sym == " " or sym == "." then return nil end

    local x = Constants.PLAYFIELD_X + SPACING + (col - 1) * (BRICK_WIDTH + SPACING)
    local y = START_Y + (row - 1) * (BRICK_HEIGHT + SPACING)

    if type(sym) == "number" then
        return Brick.new(x, y, BRICK_WIDTH, BRICK_HEIGHT, sym, "NORMAL")
    elseif sym == "T" then
        return Brick.new(x, y, BRICK_WIDTH, BRICK_HEIGHT, 3, "TOUGH")
    elseif sym == "S" then
        return Brick.new(x, y, BRICK_WIDTH, BRICK_HEIGHT, 1, "STEEL")
    elseif sym == "X" then
        return Brick.new(x, y, BRICK_WIDTH, BRICK_HEIGHT, 1, "TNT")
    elseif sym == "P" then
        return Brick.new(x, y, BRICK_WIDTH, BRICK_HEIGHT, 4, "POWERUP")
    end

    return Brick.new(x, y, BRICK_WIDTH, BRICK_HEIGHT, 1, "NORMAL")
end

-- 10 Handcrafted Level Definitions
local levelMaps = {
    -- Stage 1: Rainbow Arcade
    {
        name = "1. Rainbow Arcade",
        map = {
            {7,7,7,7,7,7,7,7,7,7,7,7,7},
            {6,6,6,6,6,P,6,P,6,6,6,6,6},
            {5,5,5,5,5,5,5,5,5,5,5,5,5},
            {4,4,4,P,4,4,4,4,4,P,4,4,4},
            {3,3,3,3,3,3,3,3,3,3,3,3,3},
            {2,2,2,2,2,P,2,P,2,2,2,2,2},
            {1,1,1,1,1,1,1,1,1,1,1,1,1},
        }
    },

    -- Stage 2: Crystal Pyramid
    {
        name = "2. Crystal Pyramid",
        map = {
            {0,0,0,0,0,0,"T",0,0,0,0,0,0},
            {0,0,0,0,0,"T",7,"T",0,0,0,0,0},
            {0,0,0,0,6,6,"X",6,6,0,0,0,0},
            {0,0,0,5,5,5,"P",5,5,5,0,0,0},
            {0,0,4,4,4,"T",4,"T",4,4,4,0,0},
            {0,3,3,3,"P",3,3,3,"P",3,3,3,0},
            {2,2,2,2,2,2,"S",2,2,2,2,2,2},
        }
    },

    -- Stage 3: Retro Invader
    {
        name = "3. Retro Invader",
        map = {
            {0,0,0,6,0,0,0,0,0,6,0,0,0},
            {0,0,0,0,6,0,0,0,6,0,0,0,0},
            {0,0,0,6,6,6,6,6,6,6,0,0,0},
            {0,0,5,5,"S",5,5,5,"S",5,5,0,0},
            {0,4,4,4,4,4,4,4,4,4,4,4,0},
            {0,3,0,3,3,"X",3,"X",3,3,0,3,0},
            {0,2,0,2,0,0,0,0,0,2,0,2,0},
            {0,0,0,0,1,1,0,1,1,0,0,0,0},
        }
    },

    -- Stage 4: Diamond Fortress
    {
        name = "4. Diamond Fortress",
        map = {
            {0,0,0,0,0,0,"S",0,0,0,0,0,0},
            {0,0,0,0,0,"S","T","S",0,0,0,0,0},
            {0,0,0,0,"S",6,"X",6,"S",0,0,0,0},
            {0,0,0,"S",5,5,"P",5,5,"S",0,0,0},
            {0,0,"S",4,4,"T","S","T",4,4,"S",0,0},
            {0,0,0,"S",3,3,"X",3,3,"S",0,0,0},
            {0,0,0,0,"S",2,2,2,"S",0,0,0,0},
            {0,0,0,0,0,0,"S",0,0,0,0,0,0},
        }
    },

    -- Stage 5: Neon Castle
    {
        name = "5. Neon Castle",
        map = {
            {"S","T","S",0,0,0,7,0,0,0,"S","T","S"},
            {"S",6,"S",0,6,6,P,6,6,0,"S",6,"S"},
            {"S",5,"S",5,"T",5,"X",5,"T",5,"S",5,"S"},
            {4,4,4,4,4,4,4,4,4,4,4,4,4},
            {3,"P",3,"S",3,"X",3,"X",3,"S",3,"P",3},
            {2,2,2,2,2,2,2,2,2,2,2,2,2},
            {"S",1,"S",0,1,1,P,1,1,0,"S",1,"S"},
        }
    },

    -- Stage 6: Solar Flare
    {
        name = "6. Solar Flare",
        map = {
            {0,0,0,0,7,7,"X",7,7,0,0,0,0},
            {0,0,6,6,6,"T",6,"T",6,6,6,0,0},
            {0,5,5,"P",5,5,5,5,5,"P",5,5,0},
            {4,4,4,4,"S",4,"X",4,"S",4,4,4,4},
            {0,3,3,"P",3,3,3,3,3,"P",3,3,0},
            {0,0,2,2,2,"T",2,"T",2,2,2,0,0},
            {0,0,0,0,1,1,"X",1,1,0,0,0,0},
        }
    },

    -- Stage 7: Star Destroyer
    {
        name = "7. Star Destroyer",
        map = {
            {0,0,0,0,0,0,"S",0,0,0,0,0,0},
            {0,0,0,0,0,7,"T",7,0,0,0,0,0},
            {0,0,0,0,6,6,"P",6,6,0,0,0,0},
            {0,0,0,5,5,"S","X","S",5,5,0,0,0},
            {0,0,4,4,4,4,"T",4,4,4,4,0,0},
            {0,3,3,3,"P",3,"X",3,"P",3,3,3,0},
            {2,2,"S",2,2,2,2,2,2,2,"S",2,2},
            {"S","X","S",0,0,"S","X","S",0,0,"S","X","S"},
        }
    },

    -- Stage 8: Double Helix
    {
        name = "8. Double Helix",
        map = {
            {7,0,0,0,0,0,7,0,0,0,0,0,7},
            {0,6,0,0,0,6,"P",6,0,0,0,6,0},
            {0,0,5,0,5,0,5,0,5,0,5,0,0},
            {0,0,0,"X",0,0,"S",0,0,"X",0,0,0},
            {0,0,3,0,3,0,3,0,3,0,3,0,0},
            {0,2,0,0,0,2,"P",2,0,0,0,2,0},
            {1,0,0,0,0,0,1,0,0,0,0,0,1},
        }
    },

    -- Stage 9: Infinity Matrix
    {
        name = "9. Infinity Matrix",
        map = {
            {0,7,7,7,0,0,0,0,0,7,7,7,0},
            {7,6,"P",6,7,0,0,0,7,6,"P",6,7},
            {7,5,5,5,7,0,0,0,7,5,5,5,7},
            {0,7,"X",7,0,"S","P","S",0,7,"X",7,0},
            {7,3,3,3,7,0,0,0,7,3,3,3,7},
            {7,2,"P",2,7,0,0,0,7,2,"P",2,7},
            {0,1,1,1,0,0,0,0,0,1,1,1,0},
        }
    },

    -- Stage 10: Chaos Gauntlet
    {
        name = "10. Chaos Gauntlet",
        map = {
            {"S",7,"T",7,"S",7,"X",7,"S",7,"T",7,"S"},
            {6,"T",6,"P",6,"T",6,"T",6,"P",6,"T",6},
            {5,"P",5,"S",5,"X",5,"X",5,"S",5,"P",5},
            {4,"T",4,4,4,"T",4,"T",4,4,4,"T",4},
            {3,3,"X",3,"S",3,"P",3,"S",3,"X",3,3},
            {2,"T",2,"P",2,"T",2,"T",2,"P",2,"T",2},
            {"S",1,"T",1,"S",1,"X",1,"S",1,"T",1,"S"},
        }
    }
}

function Levels.loadLevel(levelNum)
    local idx = math.fmod(levelNum - 1, #levelMaps) + 1
    local lvlData = levelMaps[idx]
    local bricks = {}

    for rowIdx, rowData in ipairs(lvlData.map) do
        for colIdx, sym in ipairs(rowData) do
            local brick = createBrickFromSymbol(colIdx, rowIdx, sym)
            if brick then
                table.insert(bricks, brick)
            end
        end
    end

    return bricks, lvlData.name
end

function Levels.getLevelNames()
    local names = {}
    for _, map in ipairs(levelMaps) do
        table.insert(names, map.name)
    end
    return names
end

function Levels.getMapCount()
    return #levelMaps
end

return Levels
