SFX = {
    soundData = {},
    volumes = {
        shoot = 0.3,
        hit = 0.4,
        crit = 0.5,
        enemyDeath = 0.4,
        playerDeath = 0.5,
        upgrade = 0.4,
        error = 0.5,
        bossSpawn = 0.6,
        heal = 0.4,
        teleport = 0.3,
        shield = 0.4
    }
}

function SFX.init()
    SFX.soundData = {
        shoot = { 
            SFX.generateShoot(), SFX.generateShoot(), SFX.generateShoot(),
            SFX.generateShoot(), SFX.generateShoot(), SFX.generateShoot() 
        },
        hit = { SFX.generateHit(), SFX.generateHit(), SFX.generateHit() },
        crit = { SFX.generateCrit(), SFX.generateCrit(), SFX.generateCrit() },
        enemyDeath = { SFX.generateEnemyDeath(), SFX.generateEnemyDeath(), SFX.generateEnemyDeath() },
        playerDeath = { SFX.generatePlayerDeath(), SFX.generatePlayerDeath(), SFX.generatePlayerDeath() },
        upgrade = { SFX.generateUpgrade(), SFX.generateUpgrade(), SFX.generateUpgrade() },
        error = { SFX.generateError(), SFX.generateError(), SFX.generateError() },
        bossSpawn = { SFX.generateBossSpawn(), SFX.generateBossSpawn(), SFX.generateBossSpawn() },
        heal = { SFX.generateHeal(), SFX.generateHeal(), SFX.generateHeal() },
        teleport = { SFX.generateTeleport(), SFX.generateTeleport(), SFX.generateTeleport() },
        shield = { SFX.generateShield(), SFX.generateShield(), SFX.generateShield() }
    }
end

function SFX.play(soundName)
    if not SFX.soundData[soundName] then return end
    local variations = SFX.soundData[soundName]
    local index = love.math.random(1, #variations)
    local source = love.audio.newSource(variations[index], "static")
    source:setVolume(SFX.volumes[soundName] or 1.0)
    source:play()
end

-- Updated Shooting Sound with Significant Variation
function SFX.generateShoot()
    local duration = 0.15  -- very short burst
    local sampleRate = 44100
    local samples = math.ceil(duration * sampleRate)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)
    
    for i = 0, samples-1 do
        local t = i / sampleRate
        -- White noise sample
        local noise = love.math.random() * 2 - 1
        -- Rapid decay envelope
        local env = 1 - (t / duration)
        data:setSample(i, noise * env * 0.5)
    end
    
    return data
end

-- Other Sound Generation Functions (unchanged)
function SFX.generateHit()
    local duration = 0.1 + love.math.random() * 0.05
    local sampleRate = 44100
    local samples = math.ceil(duration * sampleRate)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)
    
    local decayPower = love.math.random(1.0, 3.0)
    for i = 0, samples-1 do
        local t = i / sampleRate
        local noise = (love.math.random() * 2 - 1) * 0.5
        local env = 1 - (t / duration)^decayPower
        data:setSample(i, noise * env)
    end
    return data
end

function SFX.generateCrit()
    local duration = 0.15
    local freq1 = 1500 + love.math.random(-300, 300)
    local freq2 = 800 + love.math.random(-200, 200)
    local sampleRate = 44100
    local samples = math.ceil(duration * sampleRate)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)

    for i = 0, samples-1 do
        local t = i / sampleRate
        local wave = (math.sin(t * freq1 * math.pi * 2) + math.sin(t * freq2 * math.pi * 2)) * 0.3
        local env = 1 - (t / duration)
        data:setSample(i, wave * env)
    end
    return data
end

function SFX.generateEnemyDeath()
    local duration = 0.4
    local startFreq = 400 + love.math.random(-100, 100)
    local endFreq = startFreq - 300 + love.math.random(-100, 100)
    local sampleRate = 44100
    local samples = math.ceil(duration * sampleRate)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)

    for i = 0, samples-1 do
        local t = i / sampleRate
        local freq = startFreq + (endFreq - startFreq) * (i / samples)
        local wave = math.sin(t * freq * math.pi * 2)
        local env = 1 - (t / duration)
        data:setSample(i, wave * env * 0.4)
    end
    return data
end

function SFX.generatePlayerDeath()
    local duration = 1.2
    local startFreq = 120 + love.math.random(-20, 20)
    local endFreq = startFreq - 100 + love.math.random(-50, 50)
    local sampleRate = 44100
    local samples = math.ceil(duration * sampleRate)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)

    for i = 0, samples-1 do
        local t = i / sampleRate
        local freq = startFreq + (endFreq - startFreq) * (i / samples)
        local wave = math.sin(t * freq * math.pi * 2)
        local env = 1 - (t / duration)
        data:setSample(i, wave * env * 0.5)
    end
    return data
end

function SFX.generateUpgrade()
    local duration = 0.3
    local startFreq = 300 + love.math.random(-100, 100)
    local endFreq = startFreq + 800 + love.math.random(-200, 200)
    local sampleRate = 44100
    local samples = math.ceil(duration * sampleRate)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)

    for i = 0, samples-1 do
        local t = i / sampleRate
        local freq = startFreq + (endFreq - startFreq) * (i / samples)
        local wave = math.sin(t * freq * math.pi * 2)
        local env = math.min(t / 0.05, 1 - (t / duration))
        data:setSample(i, wave * env * 0.4)
    end
    return data
end

function SFX.generateError()
    local duration = 0.4
    local baseFreq = 220 + love.math.random(-50, 50)
    local modFreq = 20 + love.math.random(-5, 5)
    local sampleRate = 44100
    local samples = math.ceil(duration * sampleRate)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)

    for i = 0, samples-1 do
        local t = i / sampleRate
        local freq = baseFreq + math.sin(t * modFreq) * 100
        local wave = math.sin(t * freq * math.pi * 2) * 0.5
        local env = 1 - (t / duration)
        data:setSample(i, wave * env)
    end
    return data
end

function SFX.generateBossSpawn()
    local duration = 1.0
    local baseFreq = 60 + love.math.random(-20, 20)
    local modFreq = 2 + love.math.random() * 1
    local sampleRate = 44100
    local samples = math.ceil(duration * sampleRate)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)

    for i = 0, samples-1 do
        local t = i / sampleRate
        local freq = baseFreq + math.sin(t * modFreq) * 20
        local wave = math.sin(t * freq * math.pi * 2) * 0.6
        local env = math.min(t / 0.2, 1 - (t / duration))
        data:setSample(i, wave * env)
    end
    return data
end

function SFX.generateHeal()
    local duration = 0.4
    local startFreq = 600 + love.math.random(-200, 200)
    local endFreq = startFreq + 400 + love.math.random(-100, 100)
    local sampleRate = 44100
    local samples = math.ceil(duration * sampleRate)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)

    for i = 0, samples-1 do
        local t = i / sampleRate
        local freq = startFreq + (endFreq - startFreq) * (i / samples)
        local wave = math.sin(t * freq * math.pi * 2)
        local env = 1 - (t / duration)
        data:setSample(i, wave * env * 0.3)
    end
    return data
end

function SFX.generateTeleport()
    local duration = 0.2
    local baseFreq = 800 + love.math.random(-200, 200)
    local modFreq = 20 + love.math.random(-5, 5)
    local sampleRate = 44100
    local samples = math.ceil(duration * sampleRate)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)

    for i = 0, samples-1 do
        local t = i / sampleRate
        local freq = baseFreq + math.sin(t * modFreq) * 400
        local wave = math.sin(t * freq * math.pi * 2) * 0.4
        local env = 1 - (t / duration)
        data:setSample(i, wave * env)
    end
    return data
end

function SFX.generateShield()
    local duration = 0.3
    local baseFreq = 300 + love.math.random(-100, 100)
    local modFreq = 15 + love.math.random(-5, 5)
    local sampleRate = 44100
    local samples = math.ceil(duration * sampleRate)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)

    for i = 0, samples-1 do
        local t = i / sampleRate
        local freq = baseFreq + math.sin(t * modFreq) * 100
        local wave = math.sin(t * freq * math.pi * 2) * 0.5
        local env = math.min(t / 0.1, 1 - (t / duration))
        data:setSample(i, wave * env)
    end
    return data
end

-- Convenience Functions
function SFX.playShoot() SFX.play("shoot") end
function SFX.playHit() SFX.play("hit") end
function SFX.playCrit() SFX.play("crit") end
function SFX.playEnemyDeath() SFX.play("enemyDeath") end
function SFX.playPlayerDeath() SFX.play("playerDeath") end
function SFX.playUpgrade() SFX.play("upgrade") end
function SFX.playError() SFX.play("error") end
function SFX.playBossSpawn() SFX.play("bossSpawn") end
function SFX.playHeal() SFX.play("heal") end
function SFX.playTeleport() SFX.play("teleport") end
function SFX.playShield() SFX.play("shield") end