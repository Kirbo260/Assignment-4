local Class = require "libs.hump.class"
local Anim8 = require "libs.anim8"

local spriGem = love.graphics.newImage(
    "graphics/sprites/coin_gem_spritesheet.png")
local gridGem = Anim8.newGrid(16,16,spriGem:getWidth(),spriGem:getHeight())

local Gem = Class{}
Gem.SIZE = 16
Gem.SCALE = 2.5
function Gem:init(x,y,type)
    self.x = x
    self.y = y
    self.type = type 
    if self.type == nil then self.type = 4 end

    -- For coin gem (type 9), use row 1 of the spritesheet
    -- For regular gems (types 4-8), use their respective rows
    local animationRow = self.type
    if self.type == 9 then
        animationRow = 1  -- Use first row for coin
    end
    self.animation = Anim8.newAnimation(gridGem('1-4', animationRow), 0.25)
end

function Gem:setType(type)
    self.type = type
    -- For coin gem (type 9), use row 1 of the spritesheet
    -- For regular gems (types 4-8), use their respective rows
    local animationRow = self.type
    if self.type == 9 then
        animationRow = 1  -- Use first row for coin
    end
    self.animation = Anim8.newAnimation(gridGem('1-4', animationRow), 0.25)
end

function Gem:nextType()
    local newtype = self.type+1
    if newtype > 9 then newtype = 4 end  -- Include type 9 in rotation
    self:setType(newtype)
end

function Gem:update(dt)
    self.animation:update(dt)
end

function Gem:draw()
    self.animation:draw(spriGem, self.x, self.y, 0, Gem.SCALE, Gem.SCALE)
end

function Gem:getColor()
    if self.type == 4 then -- yellow
        return 1,1,0
    elseif self.type == 5 then -- red
        return 0,0,1
    elseif self.type == 6 then -- gray
        return 1,1,1
    elseif self.type == 7 then -- blue
        return 1,0,0
    elseif self.type == 8 then -- green
        return 0,1,0
    elseif self.type == 9 then -- gold/coin
        return 1,0.84,0  -- Golden color
    end
end

return Gem
