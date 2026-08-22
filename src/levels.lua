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

-- Level Definitions
local levelMaps = {
    -- Level 1: Classic Rainbow
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

    -- Level 2: The Pyramid
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

    -- Level 3: Space Invader
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

    -- Level 4: Diamond Fortress
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

    -- Level 5: Chaos Core
    {
        name = "5. Chaos Core",
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

function Levels.getMapCount()
    return #levelMaps
end

return Levels
