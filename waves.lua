Waves = {
    currentWave = 1,
    enemiesRemaining = 0,
    waveTimer = 5,
    spawnInterval = 2.0,
    spawnTimer = 0,
    spawnRandomness = 0.3,
    betweenWaves = true -- New state flag
}

local waveDefinitions = {
    {5, 10, 1.0, 2.0},
    {8, 15, 1.1, 1.8},
    {12, 20, 1.2, 1.5},
    {15, 25, 1.3, 1.2},
    {20, 30, 1.5, 1.0}
}

function Waves.startNextWave()
    if Waves.currentWave > #waveDefinitions then
        local lastWave = waveDefinitions[#waveDefinitions]
        Waves.enemiesRemaining = math.floor(lastWave[1] * 1.3)
        Enemy.baseHealth = lastWave[2] * 1.15
        Enemy.speedMultiplier = lastWave[3] * 1.05
        Waves.spawnInterval = math.max(0.5, lastWave[4] * 0.95)
    else
        local wave = waveDefinitions[Waves.currentWave]
        Waves.enemiesRemaining = wave[1]
        Enemy.baseHealth = wave[2]
        Enemy.speedMultiplier = wave[3]
        Waves.spawnInterval = wave[4]
    end
    
    Waves.spawnTimer = Waves.spawnInterval
    Waves.betweenWaves = false
    print("Starting Wave", Waves.currentWave)
end

function Waves.update(dt)
    if Waves.betweenWaves then
        Waves.waveTimer = Waves.waveTimer - dt
        if Waves.waveTimer <= 0 then
            Game.state.inShop = true
            Waves.currentWave = Waves.currentWave + 1
            Waves.startNextWave()
        end
    else
        if Waves.enemiesRemaining > 0 then
            Waves.spawnTimer = Waves.spawnTimer - dt
            if Waves.spawnTimer <= 0 then
                Enemy.spawn()
                Waves.enemiesRemaining = Waves.enemiesRemaining - 1
                Waves.spawnTimer = Waves.spawnInterval + (math.random() * Waves.spawnRandomness * 2 - Waves.spawnRandomness)
            end
        else
            Waves.betweenWaves = true
            Waves.waveTimer = 5 -- Reset between-waves timer
        end
    end
end