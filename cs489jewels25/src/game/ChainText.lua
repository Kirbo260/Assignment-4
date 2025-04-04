local Class = require "libs.hump.class"
local Tween = require "libs.tween"

local ChainText = Class{}

function ChainText:init(x, y, chainLevel)
    self.x = x
    self.y = y
    self.text = chainLevel
    self.active = true

    self.font = love.graphics.newFont(24)
    self.scale = 0.8
    self.color = {r=1, g=1, b=0}  -- yellow
    self.alpha = 0  -- transparent
    -- text centered
    self.width = self.font:getWidth(self.text)
    

    self.duration = 3.0  
    self.fadeInTime = 0.5  
    self.holdTime = 2.0  
    self.fadeOutTime = 0.5  
    self.currentTime = 0
    
    -- animation tween
    self.animationTween = Tween.new(self.duration, self, {
        y = self.y - 80  
    }, 'outQuad')
end

function ChainText:update(dt)
    if not self.active then return end
    
    self.currentTime = self.currentTime + dt
    

    if self.currentTime < self.fadeInTime then
        -- fade in
        self.alpha = self.currentTime / self.fadeInTime
    elseif self.currentTime < self.fadeInTime + self.holdTime then
        -- hold
        self.alpha = 1
    elseif self.currentTime < self.duration then
        -- out
        local fadeOutProgress = (self.currentTime - (self.fadeInTime + self.holdTime)) / self.fadeOutTime
        self.alpha = 1 - fadeOutProgress
    else
        self.active = false
        return
    end

    if self.animationTween then
        self.animationTween:update(dt)
    end
end

function ChainText:draw()
    if not self.active then return end
    
    love.graphics.setFont(self.font)
    
    love.graphics.setColor(0, 0, 0, self.alpha)
    for dx = -1, 1 do
        for dy = -1, 1 do
            love.graphics.print(self.text, 
                self.x - (self.width * self.scale) / 2 + dx,
                self.y - (self.font:getHeight() * self.scale) / 2 + dy,
                0, self.scale, self.scale)
        end
    end
    
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.alpha)
    love.graphics.print(self.text, 
        self.x - (self.width * self.scale) / 2,
        self.y - (self.font:getHeight() * self.scale) / 2,
        0, self.scale, self.scale)
end

function ChainText:isActive()
    return self.active
end

return ChainText 