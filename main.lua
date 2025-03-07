require 'rebirth'
require 'game'       -- Game state and core functionality
require 'effects'    -- Visual effects system
require 'projectile' -- Projectile logic
require 'player'     -- Player controller
require 'enemy'      -- Enemy behaviors
require 'waves'      -- Wave progression system
require 'upgrades'   -- Upgrade economy
require 'utils'      -- Utility functions
require 'ui'         -- User interface system
require 'music'


function love.load()
    
    
    
    
    math.randomseed(os.time())
    
    -- Initialize core systems
    Game.init()
    UI.init()
    Player.init()
    MusicGenerator:init()
    
    
    -- Configure graphics
    love.graphics.setLineStyle("rough")
    love.graphics.setDefaultFilter("nearest", "nearest")
    if Game.scale > 1 then
        love.graphics.setFont(love.graphics.newFont(14 * Game.scale))
    end
end

function love.update(dt)
    local scaledDt = dt * Game.state.speedMultiplier
    
    -- Apply regeneration when alive and not in shop
    if not Game.state.inShop and not Player.isDead and Player.health > 0 then
        Player.health = math.min(Player.maxHealth, 
            Player.health + (Player.regen * scaledDt))
    end

    -- Check for player death
    Player.checkDeath()

    -- Only update game world when alive and not in shop
    if not Game.state.inShop and not Player.isDead then
        Waves.update(scaledDt)
        Enemy.updateMovement(scaledDt)
        Player.autoAttack(scaledDt)
        Projectile.updateAll(scaledDt)

        -- Handle wave transitions (without health reset)
        if Waves.enemiesRemaining == 0 and not Game.state.waveTransition then
            Game.state.waveTransition = true
            Waves.startNextWave()
        end
    end

    MusicGenerator:update(dt)


    Effects.update(scaledDt)
end

function love.draw()
    -- Main game rendering
    Player.draw()
    Enemy.drawAll()
    Projectile.drawAll()
    Effects.draw()
    
    -- UI Elements
    UI.draw()
    
    
    

end


-- main.lua
function love.touchpressed(id, x, y)
    local scaledX, scaledY = x/Game.scale, y/Game.scale
    UI.handleTouch(scaledX, scaledY)
end



-- Update the touch handler in main.lua
--function love.touchpressed(id, x, y)
--    if Game.state.showDeathScreen then
--        Player.init()
--        Game.state.showDeathScreen = false
--        return true
--    end
--    UI.handleTouch(x, y)  -- Pass only coordinates, not ID
--end

-- Debugging
function love.keypressed(key)
    if key == 's' then
        Game.state.inShop = not Game.state.inShop
    end
    if key == 'r' then  -- Debug: test regeneration
        Player.health = 50
    end
    if key == 't' then  -- Debug: test speed
        Game.state.speedMultiplier = math.min(2.0, Game.state.speedMultiplier + 0.1)
    end
end
