Game = {
    state = {},
    screen = {},
    scale = 1,
    uiScale = 1,
    fontScale = 1,
    debug = false
}

function Game.init()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    
    -- Initialize display settings
    Game.scale = 1
    Game.screen = {
        width = screenWidth,
        height = screenHeight,
        pixelWidth = screenWidth,
        pixelHeight = screenHeight
    }
    
    -- Initialize game state
    Game.resetState()
    
    -- Initialize UI scaling
    Game.calculateUIScaling()
end

function Game.resetState()
    Game.state = {
        enemies = {},
        projectiles = {},
        particles = {},
        inShop = false,
        spawnTimer = 0,
        attackTimer = 0,
        waveTransition = false,
        speedMultiplier = 1.0,
        showDeathScreen = false,
        showRebirthScreen = false,
        bossDefeated = false,
        player = {
            gold = 0,
            xp = 0,
            level = 1
        }
    }
end

function Game.calculateUIScaling()
    local baseWidth = 1440  -- Reference width for scaling
    Game.uiScale = math.min(
        math.max(Game.screen.width / baseWidth, 0.65),
        1.0
    )
    Game.fontScale = Game.uiScale * 0.9
end

function Game.toggleDebug()
    Game.debug = not Game.debug
end

-- Utility functions for state serialization
function Game.saveState()
    return {
        player = {
            gold = Player.gold,
            xp = Player.xp,
            level = Player.level,
            xpToNextLevel = Player.xpToNextLevel
        },
        wave = Waves.currentWave,
        upgrades = Upgrades.stats,
        rebirth = Rebirth
    }
end


function Game.loadState(savedState)
    if savedState then
        Player.gold = savedState.player.gold
        Player.xp = savedState.player.xp
        Player.level = savedState.player.level
        Player.xpToNextLevel = savedState.player.xpToNextLevel
        Waves.currentWave = savedState.wave
        Upgrades.stats = savedState.upgrades
        Rebirth = savedState.rebirth or Rebirth
    end
end

-- Screen utilities
function Game.worldToScreen(x, y)
    return x * Game.scale, y * Game.scale
end

function Game.screenToWorld(x, y)
    return x / Game.scale, y / Game.scale
end

-- State transition handlers
function Game.enterShop()
    Game.state.inShop = true
    Game.state.speedMultiplier = 0.25  -- Slow motion during shop
end

function Game.exitShop()
    Game.state.inShop = false
    Game.state.speedMultiplier = 1.0
end

function Game.startNewRun()
    Game.resetState()
    Player.init()
    Waves.startNextWave()
end
