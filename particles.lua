Particles = {
    enemies = nil
}

function Particles.init()
    local particleImg = love.graphics.newImage("particle.png")
    Particles.enemies = love.graphics.newParticleSystem(particleImg, 32)
    
    Particles.enemies:setColors(
        1, 1, 1, 1,
        1, 1, 1, 0
    )
    Particles.enemies:setParticleLifetime(0.5, 1)
    Particles.enemies:setEmissionRate(0)
    Particles.enemies:setSizeVariation(1)
    Particles.enemies:setLinearAcceleration(-20, -20, 20, 20)
    Particles.enemies:setSizes(0.5, 0.2)
end

function Particles.update(dt)
    Particles.enemies:update(dt)
end

function Particles.draw()
    love.graphics.draw(Particles.enemies)
end