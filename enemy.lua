require 'boss'
require 'particles'

Enemy = {
    baseHealth = 3,
    speedMultiplier = 1.0,
    types = {
        normal = {
            color = {1, 0, 0}, 
            speedBonus = 1.0,
            goldMultiplier = 1.0,
            xpMultiplier = 1.0,
            attackSpeed = 1,
            sizeMultiplier = 1,
            shape = "circle"
        },
        fast = {
            color = {0.2, 0.5, 1}, 
            speedBonus = 1.8,
            goldMultiplier = 1.5,
            xpMultiplier = 1.3,
            attackSpeed = 1.5,
            sizeMultiplier = 0.9,
            shape = "triangle"
        },
        tank = {
            color = {0, 0.8, 0}, 
            speedBonus = 0.8,
            goldMultiplier = 2.0,
            xpMultiplier = 1.8,
            attackSpeed = 0.8,
            sizeMultiplier = 1.3,
            shape = "hexagon"
        },
        miniboss = {
            color = {1, 0.5, 0}, 
            speedBonus = 1.1,
            goldMultiplier = 3.0,
            xpMultiplier = 2.5,
            attackSpeed = 1.2,
            sizeMultiplier = 1.5,
            healthMultiplier = 3,
            shape = "circle"
        }
    }
}

function Enemy.spawn()
    local wave = Waves.currentWave
    local isBossWave = wave % 5 == 0
    
    if isBossWave then
        local bossTier = math.floor(wave / 5) + 1
        local bossTypes = {"standard", "swarmlord", "phasebeast"}
        local bossType = bossTypes[(bossTier % #bossTypes) + 1]
        local boss = Boss.create(bossTier, bossType)
        if boss then
            table.insert(Game.state.enemies, boss)
        end
        return
    end

    local typeChances = {
        normal = 0.6,
        fast = 0.3,
        tank = 0.1
    }

    if wave >= 10 then
        typeChances = {
            normal = 0.45,
            fast = 0.35,
            tank = 0.15,
            miniboss = 0.05
        }
    end

    if Waves.eliteChance > 0 and math.random() < Waves.eliteChance then
        typeChances.miniboss = (typeChances.miniboss or 0) + 0.2
    end

    local roll = math.random()
    local cumulative = 0
    local enemyType = "normal"
    for t, chance in pairs(typeChances) do
        cumulative = cumulative + chance
        if roll <= cumulative then
            enemyType = t
            break
        end
    end

    local enemy = Enemy.createEnemy(enemyType)
    table.insert(Game.state.enemies, enemy)
end

function Enemy.createEnemy(type)
    local config = Enemy.types[type]
    
    
    

    
    local baseSpeed = 40 * Enemy.speedMultiplier * config.speedBonus
    
    return {
        x = math.random(50, Game.screen.width-50),
        y = math.random(50, Game.screen.height-50),
        size = 15 * config.sizeMultiplier,
        health = Enemy.baseHealth * (config.healthMultiplier or 1),
        maxHealth = Enemy.baseHealth * (config.healthMultiplier or 1),
        pendingDamage = 0,
        speed = baseSpeed,
        gold = math.random(50, 500) * config.goldMultiplier,
        xp = math.random(5, 15) * config.xpMultiplier,
        type = type,
        attackTimer = 0,
        attackSpeed = config.attackSpeed,
        inMeleeRange = false,
        isBoss = false,
        tier = 1,
        isDead = false
    }
end

function Enemy.updateMovement(dt)
    Game.state.enemies = utils.arrayRemove(Game.state.enemies, function(_, i)
        local e = Game.state.enemies[i]
        if not e or e.isDead then return false end
        
        if e.specialAbility then
            e.specialAbility(e, dt)
        end

        local dx = Player.x - e.x
        local dy = Player.y - e.y
        local dist = math.sqrt(dx^2 + dy^2)
        local meleeRange = e.size + Player.size + 5

        if dist > meleeRange then
            e.x = e.x + (dx/dist) * e.speed * dt
            e.y = e.y + (dy/dist) * e.speed * dt
            e.inMeleeRange = false
        else
            e.inMeleeRange = true
            e.attackTimer = e.attackTimer - dt
            if e.attackTimer <= 0 then
                Player.takeDamage(e.isBoss and 2 or 1, e)
                e.attackTimer = 1 / e.attackSpeed
            end
        end

        if e.health <= 0 then
            e.isDead = true -- Mark as dead
            Enemy.onDeath(e)
            return false
        end

        return true
    end)
end

function Enemy.drawAll()
    for _, e in ipairs(Game.state.enemies) do
        -- Enhanced Health Bar
        local healthColor = e.isBoss and {1, 0.2, 0.2} or {0, 1, 0}
        local barWidth = e.isBoss and 150 or e.size * 2.5
        local barHeight = e.isBoss and 10 or 6
        local barY = e.isBoss and 20 or (e.y - e.size - 15)
        
        -- Health bar background
        love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
        love.graphics.rectangle("fill", 
            e.isBoss and (Game.screen.width/2 - barWidth/2) or (e.x - barWidth/2 - 2), 
            barY - 2, 
            barWidth + 4, 
            barHeight + 4, 3
        )
        
        -- Health bar
        love.graphics.setColor(0.3, 0, 0, 0.8)
        love.graphics.rectangle("fill", 
            e.isBoss and (Game.screen.width/2 - barWidth/2) or (e.x - barWidth/2), 
            barY, 
            barWidth, 
            barHeight, 3
        )
        love.graphics.setColor(unpack(healthColor))
        love.graphics.rectangle("fill", 
            e.isBoss and (Game.screen.width/2 - barWidth/2) or (e.x - barWidth/2), 
            barY, 
            barWidth * (e.health/e.maxHealth), 
            barHeight, 3
        )

        -- Enemy body
        local color = getEnemyColor(e)

        -- Glow effect
        if e.type == "miniboss" or e.isBoss then
            love.graphics.setColor(color[1], color[2], color[3], 0.3)
            love.graphics.circle("fill", e.x, e.y, e.size * 1.4, 32)
        end

        -- Shape drawing
        love.graphics.setColor(color)
        local shape = e.isBoss and "circle" or (Enemy.types[e.type].shape or "circle")
        
        if shape == "circle" then
            love.graphics.circle("fill", e.x, e.y, e.size/2, 32)
        elseif shape == "triangle" then
            drawTriangle(e.x, e.y, e.size, color)
        elseif shape == "hexagon" then
            drawHexagon(e.x, e.y, e.size/2, color)
        end

        -- Damage flash
        if e.pendingDamage > 0 then
            love.graphics.setColor(1, 1, 1, 0.4)
            love.graphics.circle("fill", e.x, e.y, e.size/2 * 1.1, 32)
        end

        -- Boss effects
        if e.isBoss then
            -- Draw aura
            if e.auraEffect then
                e.auraEffect(e, dt)
                love.graphics.setColor(e.auraColor)
                love.graphics.circle("fill", e.x, e.y, e.auraRadius, 64)
            end
            Boss.drawCrown(e.x, e.y, e.size)
        end
    end
end

function Enemy.onDeath(enemy)
    -- Particle effect
    SFX.playEnemyDeath()
    Particles.enemies:setPosition(enemy.x, enemy.y)
    Particles.enemies:emit(32)
    
    -- Existing death logic
    Player.gold = Player.gold + enemy.gold
    Player.xp = Player.xp + enemy.xp
    
    if enemy.isBoss then
        Player.gold = Player.gold + 500 * math.floor(Waves.currentWave / 5)
        Game.state.bossDefeated = true
    end

    if Player.xp >= Player.xpToNextLevel then
        Player.levelUp()
    end
end

-- Helper functions
function getEnemyColor(e)
    if e.isBoss then
        local bossConfig = Boss.types[e.type]
        return bossConfig and bossConfig.color or {1, 0, 1}
    else
        local enemyConfig = Enemy.types[e.type]
        return enemyConfig and enemyConfig.color or {1, 1, 0}
    end
end

function drawTriangle(x, y, size, color)
    local height = size * math.sqrt(3)/2
    love.graphics.setColor(color)
    love.graphics.polygon("fill", 
        x, y - height/2,
        x - size/2, y + height/2,
        x + size/2, y + height/2
    )
end

function drawHexagon(x, y, size, color)
    local vertices = {}
    local angle = 2 * math.pi / 6
    for i = 0, 5 do
        table.insert(vertices, x + size * math.cos(angle * i))
        table.insert(vertices, y + size * math.sin(angle * i))
    end
    love.graphics.setColor(color)
    love.graphics.polygon("fill", vertices)
end