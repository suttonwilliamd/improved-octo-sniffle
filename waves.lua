Waves = {
    currentWave = 1,
    enemiesRemaining = 0,
    waveTimer = 5,
    spawnInterval = 2.0,
    spawnTimer = 0,
    spawnRandomness = 0.3,
    betweenWaves = true,
    bossWarningTimer = 0,
    eliteChance = 0,
    
    -- Centralized scaling parameters
    scaling = {
        base = {
            health = 1.12,    -- 12% health per wave
            speed = 1.04,     -- 4% speed per wave
            spawnRate = 0.97, -- 3% faster spawns
            count = 1.15      -- 15% more enemies
        },
        tier = {              -- Every 5 waves
            health = 1.25,
            speed = 1.10,
            elite = 0.15
        }
    }
}

local waveDefinitions = {
    -- Format: [enemies, base_health, speed, spawn_interval, elite_chance]
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

function Waves.getWaveMultipliers(wave)
    local tier = math.floor((wave - 1) / 5)
    return {
        health = math.pow(Waves.scaling.base.health, wave) * math.pow(Waves.scaling.tier.health, tier),
        speed = math.pow(Waves.scaling.base.speed, wave) * math.pow(Waves.scaling.tier.speed, tier),
        spawnRate = math.pow(Waves.scaling.base.spawnRate, wave),
        count = math.pow(Waves.scaling.base.count, math.max(0, wave - #waveDefinitions)),
        elite = math.min(0.5, waveDefinitions[math.min(wave, #waveDefinitions)][5] + (tier * Waves.scaling.tier.elite))
    }
end

function Waves.startNextWave()
    local wave = Waves.currentWave
    local isBossWave = wave % 5 == 0
    local multipliers = Waves.getWaveMultipliers(wave)

    if isBossWave then
        -- Boss wave setup
        local bossCount = 1 + math.floor(wave / 10)
        Waves.enemiesRemaining = bossCount
        Enemy.baseHealth = 50 * (1.8 ^ math.floor(wave / 5))
        Enemy.speedMultiplier = 0.7 + (0.05 * math.floor(wave / 5))
        Waves.spawnInterval = 0
        Waves.spawnRandomness = 0
    else
        -- Normal wave scaling
        if wave <= #waveDefinitions then
            local def = waveDefinitions[wave]
            Waves.enemiesRemaining = def[1]
            Enemy.baseHealth = def[2]
            Enemy.speedMultiplier = def[3]
            Waves.spawnInterval = def[4]
        else
            Waves.enemiesRemaining = math.floor(waveDefinitions[#waveDefinitions][1] * multipliers.count)
            Enemy.baseHealth = waveDefinitions[#waveDefinitions][2] * multipliers.health
            Enemy.speedMultiplier = waveDefinitions[#waveDefinitions][3] * multipliers.speed
            Waves.spawnInterval = math.max(0.4, waveDefinitions[#waveDefinitions][4] * multipliers.spawnRate)
        end
        
        Waves.spawnRandomness = 0.3
        Waves.eliteChance = multipliers.elite
    end

    Waves.spawnTimer = Waves.spawnInterval
    Waves.betweenWaves = false
    Game.showBossWarning = false
end

function Waves.update(dt)
    if Waves.betweenWaves then
        Waves.waveTimer = Waves.waveTimer - dt
        
        -- Enhanced boss warnings
        if Waves.currentWave % 5 == 0 then
            Waves.bossWarningTimer = (Waves.bossWarningTimer + dt * 5) % 1
            if Waves.waveTimer <= 4 then
                Game.showBossWarning = (Waves.bossWarningTimer < 0.5)
            end
        end

        if Waves.waveTimer <= 0 then
            Game.state.inShop = true
            if Waves.currentWave % 5 == 0 then
                Player.gold = Player.gold + 500 + (200 * math.floor(Waves.currentWave / 5))
            end
            
            Waves.currentWave = Waves.currentWave + 1
            Waves.startNextWave()
            Game.showBossWarning = false
        end
    else
        if Waves.enemiesRemaining > 0 then
            Waves.spawnTimer = Waves.spawnTimer - dt
            
            -- Cluster spawning for higher waves
            if Waves.spawnTimer <= 0 then
                local spawnCount = 1
                if Waves.currentWave > 15 and math.random() < 0.3 then
                    spawnCount = math.random(2, 3)
                end
                
                for _ = 1, spawnCount do
                    Enemy.spawn()
                    Waves.enemiesRemaining = Waves.enemiesRemaining - 1
                end
                
                Waves.spawnTimer = Waves.spawnInterval + 
                    (math.random() * Waves.spawnRandomness * 2 - Waves.spawnRandomness)
                
                if Waves.currentWave % 5 == 0 then
                    Waves.spawnTimer = 0  -- Instant boss spawn
                end
            end
        else
            Waves.betweenWaves = true
            Waves.waveTimer = Waves.currentWave % 5 == 0 and 10 or 6 - math.min(5, Waves.currentWave * 0.1)
        end
    end
end

function Waves.draw()
    if Waves.betweenWaves then
        love.graphics.setColor(1, 1, 1)
        local text = "Next Wave in: " .. math.ceil(Waves.waveTimer)
        
        if Waves.currentWave % 5 == 0 then
            local tier = math.floor(Waves.currentWave / 5)
            text = "TIER " .. tier .. " BOSS INCOMING!\n" .. text
            love.graphics.setFont(love.graphics.newFont(24))
        else
            love.graphics.setFont(love.graphics.newFont(18))
        end

        love.graphics.printf(text, 0, Game.screen.height/2 - 30, Game.screen.width, "center")
        
        if Game.showBossWarning then
            love.graphics.setColor(1, 0, 0, 0.8)
            love.graphics.printf("!!! BOSS APPROACHING !!!", 
                0, Game.screen.height/2 - 60, 
                Game.screen.width, "center")
        end
    end
end
