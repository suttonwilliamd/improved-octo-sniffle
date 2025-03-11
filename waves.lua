-- waves.lua
Waves = {}

-- Core wave state
Waves.currentWave      = 1
Waves.enemiesRemaining = 0
Waves.waveTimer        = 5         -- Countdown until next wave starts
Waves.spawnInterval    = 2.0       -- Base interval between enemy spawns
Waves.spawnTimer       = 0         -- Timer for spawning enemies
Waves.spawnRandomness  = 0.3       -- Random variation for spawn timing
Waves.betweenWaves     = true      -- Flag indicating intermission between waves
Waves.bossWarningTimer = 0         -- Timer for boss warning flash effect
Waves.eliteChance      = 0         -- Chance for elite enemy spawns

-- New: Spawn pattern state for dynamic patterns
-- Options: "normal", "burst", "chain", "boss"
Waves.spawnPattern     = "normal"
Waves.chainCount       = 0         -- Counter for chain spawn pattern

-- Scaling parameters for dynamic difficulty progression
Waves.scaling = {
    base = {
        health    = 1.12,  -- 12% health increase per wave
        speed     = 1.04,  -- 4% speed increase per wave
        spawnRate = 0.97,  -- 3% faster spawn intervals per wave
        count     = 1.15   -- 15% more enemies per wave beyond predefined waves
    },
    tier = {             -- Applied every 5 waves
        health = 1.25,
        speed  = 1.10,
        elite  = 0.15
    }
}

-- Predefined wave definitions
-- Format: { enemies, baseHealth, speed, spawnInterval, eliteChance }
local waveDefinitions = {
    {5,  8,  1.0, 2.5, 0.00},  -- Wave 1
    {8,  10, 1.0, 2.3, 0.00},  -- Wave 2
    {12, 12, 1.1, 2.0, 0.05},  -- Wave 3
    {15, 15, 1.1, 1.8, 0.08},  -- Wave 4
    {1,  50, 1.2, 0.0, 0.00},  -- Wave 5 (Boss)
    {22, 22, 1.2, 1.3, 0.15},  -- Wave 6
    {25, 25, 1.3, 1.1, 0.18},  -- Wave 7
    {28, 28, 1.3, 1.0, 0.20},  -- Wave 8
    {32, 32, 1.4, 0.9, 0.25},  -- Wave 9
    {1,  80, 1.4, 0.0, 0.00}   -- Wave 10 (Boss)
}

-- Helper: Get wave tier (every 5 waves form a tier)
local function getWaveTier(wave)
    return math.floor((math.max(1, wave) - 1) / 5)
end

-- Calculate multipliers for waves beyond the predefined ones.
function Waves.getWaveMultipliers(wave)
    local tier = getWaveTier(wave)
    local defIndex = math.max(1, math.min(wave, #waveDefinitions))
    return {
        health    = math.pow(Waves.scaling.base.health, wave) * math.pow(Waves.scaling.tier.health, tier),
        speed     = math.pow(Waves.scaling.base.speed, wave) * math.pow(Waves.scaling.tier.speed, tier),
        spawnRate = math.pow(Waves.scaling.base.spawnRate, wave),
        count     = math.pow(Waves.scaling.base.count, math.max(0, wave - #waveDefinitions)),
        elite     = math.min(0.5, waveDefinitions[defIndex][5] + (tier * Waves.scaling.tier.elite))
    }
end

-- Optional: Adaptive difficulty adjustment based on player performance.
local function adjustDifficulty()
    -- Placeholder: adjust spawn timing based on player score or other metrics.
    if Player and Player.score and Player.score > 1000 then
         return 0.9  -- 10% faster spawns for high-performing players.
    end
    return 1.0
end

-- Helper: Get a randomized spawn timer with difficulty adjustment.
local function getRandomSpawnTimer(base)
    local randomOffset = (math.random() * Waves.spawnRandomness * 2) - Waves.spawnRandomness
    return (base + randomOffset) * adjustDifficulty()
end

-- Set up a boss wave. Boss waves occur every 5th wave.
local function setupBossWave(wave)
    local tier = getWaveTier(wave)
    local bossCount = 1 + math.floor(wave / 10)  -- Increase boss count every 10 waves.
    Waves.enemiesRemaining = bossCount

    -- Set boss enemy parameters (customize these formulas as needed).
    Enemy.baseHealth = 50 * (1.8 ^ tier)
    Enemy.speedMultiplier = 0.7 + (0.05 * tier)
    
    Waves.spawnInterval   = 0   -- Bosses spawn instantly.
    Waves.spawnRandomness = 0
    Waves.spawnPattern    = "boss"
end

-- Set up a normal (non-boss) wave.
local function setupNormalWave(wave)
    local multipliers = Waves.getWaveMultipliers(wave)
    if wave <= #waveDefinitions then
        local def = waveDefinitions[wave]
        Waves.enemiesRemaining = def[1]
        Enemy.baseHealth = def[2]
        Enemy.speedMultiplier = def[3]
        Waves.spawnInterval = def[4]
        Waves.eliteChance = def[5] + (getWaveTier(wave) * Waves.scaling.tier.elite)
    else
        local def = waveDefinitions[#waveDefinitions]
        Waves.enemiesRemaining = math.floor(def[1] * multipliers.count)
        Enemy.baseHealth = def[2] * multipliers.health
        Enemy.speedMultiplier = def[3] * multipliers.speed
        Waves.spawnInterval = math.max(0.4, def[4] * multipliers.spawnRate)
        Waves.eliteChance = multipliers.elite
    end
    Waves.spawnRandomness = 0.3

    -- Dynamic spawn pattern selection for waves 10 and beyond.
    if wave >= 10 then
        local patternRoll = math.random()
        if patternRoll < 0.33 then
            Waves.spawnPattern = "normal"
        elseif patternRoll < 0.66 then
            Waves.spawnPattern = "burst"
        else
            Waves.spawnPattern = "chain"
            Waves.chainCount = math.random(3, 5)
        end
    else
        Waves.spawnPattern = "normal"
    end
end

-- Begin the next wave by setting up parameters based on wave type.
function Waves.startNextWave()
    local wave = Waves.currentWave
    local isBossWave = (wave % 5 == 0)
    
    if isBossWave then
        setupBossWave(wave)
    else
        setupNormalWave(wave)
    end

    Waves.spawnTimer = Waves.spawnInterval  -- Reset spawn timer.
    Waves.betweenWaves = false
    Game.showBossWarning = false
end

-- Update routine for the intermission between waves.
local function updateBetweenWaves(dt)
    Waves.waveTimer = Waves.waveTimer - dt

    -- Boss warning effect for boss waves.
    if Waves.currentWave % 5 == 0 then
        Waves.bossWarningTimer = (Waves.bossWarningTimer + dt * 5) % 1
        if Waves.waveTimer <= 4 then
            Game.showBossWarning = (Waves.bossWarningTimer < 0.5)
        end
    end

    if Waves.waveTimer <= 0 then
        if Waves.currentWave % 5 == 0 then
            local bonusGold = 500 + (200 * getWaveTier(Waves.currentWave))
            Player.gold = Player.gold + bonusGold
        end

        Waves.currentWave = Waves.currentWave + 1
        Waves.startNextWave()
        Game.showBossWarning = false
    end
end

-- Update routine for spawning enemies during an active wave.
local function updateSpawning(dt)
    if Waves.enemiesRemaining > 0 then
        Waves.spawnTimer = Waves.spawnTimer - dt

        if Waves.spawnTimer <= 0 then
            if Waves.spawnPattern == "normal" then
                -- Normal spawn: one enemy per event.
                Enemy.spawn()
                Waves.enemiesRemaining = Waves.enemiesRemaining - 1
                Waves.spawnTimer = getRandomSpawnTimer(Waves.spawnInterval)

            elseif Waves.spawnPattern == "burst" then
                -- Burst spawn: spawn 2-3 enemies at once.
                local spawnCount = math.random(2, 3)
                for i = 1, spawnCount do
                    if Waves.enemiesRemaining > 0 then
                        Enemy.spawn()
                        Waves.enemiesRemaining = Waves.enemiesRemaining - 1
                    end
                end
                Waves.spawnTimer = getRandomSpawnTimer(Waves.spawnInterval)

            elseif Waves.spawnPattern == "chain" then
                -- Chain spawn: rapid succession of individual spawns.
                Enemy.spawn()
                Waves.enemiesRemaining = Waves.enemiesRemaining - 1
                Waves.chainCount = Waves.chainCount - 1

                if Waves.chainCount > 0 then
                    -- Continue chain with a faster spawn interval.
                    Waves.spawnTimer = getRandomSpawnTimer(Waves.spawnInterval * 0.5)
                else
                    -- Chain finished; revert to normal spawning.
                    Waves.spawnPattern = "normal"
                    Waves.spawnTimer = getRandomSpawnTimer(Waves.spawnInterval)
                end

            elseif Waves.spawnPattern == "boss" then
                -- Boss waves: spawn all bosses instantly.
                Enemy.spawn()
                Waves.enemiesRemaining = Waves.enemiesRemaining - 1
                Waves.spawnTimer = 0
            end

            -- For boss waves, ensure immediate spawning.
            if Waves.currentWave % 5 == 0 then
                Waves.spawnTimer = 0
            end
        end
    else
        -- Transition to intermission when all enemies have been spawned.
        Waves.betweenWaves = true
        if Waves.currentWave % 5 == 0 then
            Waves.waveTimer = 10
        else
            Waves.waveTimer = 6 - math.min(5, Waves.currentWave * 0.1)
        end
    end
end

-- Main update function: determines state and updates accordingly.
function Waves.update(dt)
    if Waves.betweenWaves then
        updateBetweenWaves(dt)
    else
        updateSpawning(dt)
    end
end

-- Draw wave-related UI elements.
function Waves.draw()
    if Waves.betweenWaves then
        local alpha = math.min(1, Waves.waveTimer * 0.5)
        local baseY = Game.screen.height * 0.4
        local textScale = math.max(1.0, Game.fontScale) * 1.5

        local text
        if Waves.currentWave % 5 == 0 then
            local bossWaveNumber = math.floor(Waves.currentWave / 5) + 1
            text = ("BOSS WAVE %d INCOMING!\n%d"):format(bossWaveNumber, math.ceil(Waves.waveTimer))
        else
            text = "Next Wave: " .. math.ceil(Waves.waveTimer)
        end

        local font = love.graphics.newFont(32 * textScale)
        font:setWeight(700)
        love.graphics.setFont(font)

        local textWidth = font:getWidth(text)
        local textHeight = font:getHeight() * 2
        local maxWidth = Game.screen.width * 0.9
        textWidth = math.min(textWidth, maxWidth)

        local padding = 30 * Game.uiScale
        local bgWidth = textWidth + padding * 2
        local bgHeight = textHeight + padding * 2
        local bgX = (Game.screen.width - bgWidth) / 2
        local bgY = Game.screen.height * 0.4 - padding

        love.graphics.setColor(0, 0, 0, 0.8 * alpha)
        utils.drawRoundedRect({ x = bgX, y = bgY, width = bgWidth, height = bgHeight }, 15 * Game.uiScale)

        local textY = bgY + (bgHeight - textHeight) / 2 + padding/2
        love.graphics.setColor(1, 0.4, 0.4, alpha)
        love.graphics.printf(text, bgX + padding, textY, textWidth, "center", 0, textScale)

        if Game.showBossWarning then
            local pulse = 0.5 + math.abs(math.sin(Waves.bossWarningTimer * 15)) * 0.5
            love.graphics.setColor(1, 0, 0, pulse * alpha)
            local warningFont = love.graphics.newFont(48 * textScale)
            love.graphics.setFont(warningFont)
            love.graphics.printf("!!! DANGER !!!", 0, bgY - 0.1 * Game.screen.height, Game.screen.width, "center")
        end
    end
end

-- Reset waves to the initial state.
function Waves.reset()
    Waves.currentWave      = 1
    Waves.enemiesRemaining = 5
    Waves.waveTimer        = 5
    Waves.spawnInterval    = 2.0
    Waves.spawnTimer       = 0
    Waves.spawnRandomness  = 0.3
    Waves.betweenWaves     = true
    Waves.bossWarningTimer = 0
    Waves.eliteChance      = 0
    Waves.spawnPattern     = "normal"
    Waves.chainCount       = 0

    Enemy.baseHealth = waveDefinitions[1][2]
    Enemy.speedMultiplier = waveDefinitions[1][3]
    Game.showBossWarning = false
end

return Waves