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
    local tier = math.floor((math.max(1, wave) - 1) / 5)  -- Ensure wave >=1 for tier calculation
    local defIndex = math.max(1, math.min(wave, #waveDefinitions))  -- Critical fix
    return {
        health = math.pow(Waves.scaling.base.health, wave) * math.pow(Waves.scaling.tier.health, tier),
        speed = math.pow(Waves.scaling.base.speed, wave) * math.pow(Waves.scaling.tier.speed, tier),
        spawnRate = math.pow(Waves.scaling.base.spawnRate, wave),
        count = math.pow(Waves.scaling.base.count, math.max(0, wave - #waveDefinitions)),
        elite = math.min(0.5, waveDefinitions[defIndex][5] + (tier * Waves.scaling.tier.elite))
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
        wave = math.max(1, wave)
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
        local alpha = math.min(1, Waves.waveTimer * 0.5)
        local baseY = Game.screen.height * 0.4  -- 40% from top (true center would be 0.5)
        local textScale = math.max(1.0, Game.fontScale) * 1.5  -- Minimum scale of 1.0

        -- Text content
        local text = Waves.currentWave % 5 == 0 and 
            ("BOSS WAVE %d INCOMING!\n%d"):format(math.floor(Waves.currentWave/5)+1, math.ceil(Waves.waveTimer)) or 
            "Next Wave: " .. math.ceil(Waves.waveTimer)

        -- Font setup
        local font = love.graphics.newFont(32 * textScale)
        font:setWeight(700)
        love.graphics.setFont(font)

        -- Text measurements
        local textWidth = font:getWidth(text)
        local textHeight = font:getHeight() * 2  -- Account for line breaks
        local maxWidth = Game.screen.width * 0.9  -- Prevent overflow
        textWidth = math.min(textWidth, maxWidth)

        -- Background panel (centered with constraints)
        local padding = 30 * Game.uiScale
        local bgWidth = textWidth + padding * 2
        local bgHeight = textHeight + padding * 2
        local bgX = (Game.screen.width - bgWidth) / 2
        local bgY = baseY - padding

        love.graphics.setColor(0, 0, 0, 0.8 * alpha)
        utils.drawRoundedRect({
            x = bgX,
            y = bgY,
            width = bgWidth,
            height = bgHeight
        }, 15 * Game.uiScale)

        -- Text positioning (true vertical center)
        local textY = bgY + (bgHeight - textHeight)/2 + padding/2

        love.graphics.setColor(1, 0.4, 0.4, alpha)
        love.graphics.printf(text, 
            bgX + padding,  -- Left boundary
            textY, 
            textWidth,      -- Wrap width
            "center",       -- Alignment
            0,              -- Rotation
            textScale       -- Scaling
        )

        -- Boss warning
        if Game.showBossWarning then
            local pulse = 0.5 + math.abs(math.sin(Waves.bossWarningTimer * 15)) * 0.5
            love.graphics.setColor(1, 0, 0, pulse * alpha)
            love.graphics.setFont(love.graphics.newFont(48 * textScale))
            love.graphics.printf("!!! DANGER !!!", 
                0, 
                bgY - 0.1 * Game.screen.height,  -- Position above main panel
                Game.screen.width, 
                "center"
            )
        end
    end
end

function Waves.reset()
    -- Reset wave progression
    Waves.currentWave = 1
    Waves.enemiesRemaining = 5
    Waves.waveTimer = 5
    Waves.spawnInterval = 2.0
    Waves.spawnTimer = 0
    Waves.spawnRandomness = 0.3
    Waves.betweenWaves = true
    Waves.bossWarningTimer = 0
    Waves.eliteChance = 0
    
    -- Reset enemy scaling
    Enemy.baseHealth = waveDefinitions[1][2]
    Enemy.speedMultiplier = waveDefinitions[1][3]
    
    -- Clear any pending warnings
    Game.showBossWarning = false
end
