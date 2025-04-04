local Class = require "libs.hump.class"
local Timer = require "libs.hump.timer"
local Tween = require "libs.tween" 
local Sounds = require "src.game.SoundEffects"

local statFont = love.graphics.newFont(26)

local Stats = Class{}
function Stats:init()
    self.y = 10 -- we will need it for tweening later
    self.level = 1 -- current level    
    self.totalScore = 0 -- total score so far
    self.targetScore = 1000
    self.maxSecs = 99 -- max seconds for the level
    self.elapsedSecs = 0 -- elapsed seconds
    self.timeOut = false -- when time is out
    self.tweenLevel = nil -- for later
    Timer.every(1,function() self:clock() end)
end

function Stats:draw()
    if self.y > 10 then
        love.graphics.setColor(0, 0, 0, 0.6)
    end
    love.graphics.setColor(1,0,1)
    love.graphics.printf("Level "..tostring(self.level), statFont, gameWidth/2-60,self.y,100,"center")
    if self.y <= 10 then
        love.graphics.printf("Time "..tostring(self.elapsedSecs).."/"..tostring(self.maxSecs), statFont,10,10,200)
        love.graphics.printf("Score "..tostring(self.totalScore), statFont,gameWidth-210,10,200,"right")
    end
    love.graphics.setColor(1,1,1)      
end
    
function Stats:update(dt) -- for now, empty function
    Timer.update(dt)
    if self.tweenLevel then -- if tweenLevel is not nil
        self.tweenLevel:update(dt) -- for later
    end
end

function Stats:addScore(n)
    self.totalScore = self.totalScore + n
    if self.totalScore > self.targetScore then
        self:levelUp()
    end
end

function Stats:levelUp()
    self.level = self.level +1
    self.targetScore = self.targetScore+self.level*1000
    self.elapsedSecs = -1
    self.y = gameHeight/2
    self.tweenLevel = Tween.new(1,self,{y = 10})
    Sounds["levelUp"]:play()
end

function Stats:clock()
    self.elapsedSecs = self.elapsedSecs+1 -- 1 sec passed
    if self.elapsedSecs > self.maxSecs then -- max passed
        self.timeOut = true
    end
end    
    
return Stats
    