local Class = require "libs.hump.class"
local imgParticle = love.graphics.newImage("graphics/particles/20.png")
local Explosion = Class{}

function Explosion:init()
    self.active = false
    self.x = 0
    self.y = 0
    self.r = 1
    self.g = 1
    self.b = 1
    self.scale = 1  
    
    self.particleSystem = love.graphics.newParticleSystem(imgParticle,100)
    self.particleSystem:setParticleLifetime(0.2, 1.0)
    self.particleSystem:setEmissionRate(0)
    self.particleSystem:setSizes(0.1, 0)
    self.particleSystem:setSpeed(0, 20)
    self.particleSystem:setLinearAcceleration(0, 0, 0, 0)
    self.particleSystem:setEmissionArea("uniform", 20, 20, 0, true)
    self.particleSystem:setColors(1, 1, 1, 1, 0, 0, 0, 0)
end

function Explosion:setColor(r,g,b)
    self.r = r
    self.g = g
    self.b = b
    self.particleSystem:setColors(r,g,b,1, r,g,b,0)
end

function Explosion:setScale(scale)
    self.scale = scale
    self.particleSystem:setEmissionArea("uniform", 20 * scale, 20 * scale, 0, true)
    self.particleSystem:setSizes(0.1 * scale, 0)
end

function Explosion:trigger(x,y)
    self.active = true
    if x and y then
        self.particleSystem:setPosition(x, y)
    end
    -- bigger explosions
    self.particleSystem:emit(30 * self.scale)
end

function Explosion:update(dt)
    self.particleSystem:update(dt)
    if self.particleSystem:getCount() == 0 then
        self.active = false
    end
end

function Explosion:draw()
    love.graphics.draw(self.particleSystem)
end

function Explosion:isActive()
    return self.active
end

return Explosion
