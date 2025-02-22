require 'effects'
require 'projectile'
require 'player'
require 'enemy'
require 'shop'
require 'upgrades'
require 'utils'
require 'waves'

function love.load()
    math.randomseed(os.time())
    
    -- Get actual screen dimensions with scaling consideration
    local pixelScale = 1
    local screenWidth, screenHeight = love.graphics.getDimensions()
    
    Game = {
        scale = pixelScale,
        screen = {
            width = screenWidth / pixelScale,  -- Logical width
            height = screenHeight / pixelScale, -- Logical height
            pixelWidth = screenWidth,          -- Actual pixel dimensions
            pixelHeight = screenHeight
        },
        state = {
            player = Player,
            enemies = {},
            projectiles = {},
            inShop = false,
            spawnTimer = 0,
            attackTimer = 0,
            waveTransition = false,
            speedMultiplier = 1.0  -- New speed control
        }
    }
    
    -- Initialize systems with proper scaling
    Player.init(Game.screen.width, Game.screen.height)
    Shop.init()
    Waves.startNextWave()
    
    -- Set up mobile-friendly graphics
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

    Effects.update(scaledDt)
end

function love.draw()
    -- Main game rendering
    Player.draw()
    Enemy.drawAll()
    Projectile.drawAll()
    Effects.draw()
    
    -- UI Elements
    Shop.draw()
    Player.drawHealth()
    Player.drawDeathScreen()
    
    -- Wave counter
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Wave: " .. Waves.currentWave, Game.screen.width - 150, 10)
    
    -- Speed multiplier indicator
    love.graphics.print("Speed: " .. string.format("%.1fx", Game.state.speedMultiplier), 
        Game.screen.width - 150, 50)
    
    -- Next wave countdown
    if Waves.enemiesRemaining == 0 then
        love.graphics.print("Next wave in: " .. math.ceil(Waves.waveTimer), 
            Game.screen.width - 150, 30)
    end
end

function love.touchpressed(id, x, y)
    if Game.state.showDeathScreen then
        Player.init()
        Game.state.showDeathScreen = false
        return true
    end
    Shop.handleTouch(id, x, y)
end

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
