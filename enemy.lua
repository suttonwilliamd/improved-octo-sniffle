require 'boss'

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
            sizeMultiplier = 1
        },
        fast = {
            color = {0.2, 0.5, 1}, 
            speedBonus = 1.8,
            goldMultiplier = 1.5,
            xpMultiplier = 1.3,
            attackSpeed = 1.5,
            sizeMultiplier = 0.9
        },
        tank = {
            color = {0, 0.8, 0}, 
            speedBonus = 0.8,
            goldMultiplier = 2.0,
            xpMultiplier = 1.8,
            attackSpeed = 0.8,
            sizeMultiplier = 1.3
        },
        miniboss = {
            color = {1, 0.5, 0}, 
            speedBonus = 1.1,
            goldMultiplier = 3.0,
            xpMultiplier = 2.5,
            attackSpeed = 1.2,
            sizeMultiplier = 1.5,
            healthMultiplier = 3
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
        tier = 1
    }
end

function Enemy.updateMovement(dt)
    Game.state.enemies = utils.arrayRemove(Game.state.enemies, function(_, i)
        local e = Game.state.enemies[i]
        if not e then return false end
        
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
                Player.health = Player.health - (e.isBoss and 2 or 1)
                e.attackTimer = 1 / e.attackSpeed
            end
        end

        return e.health > 0
    end)
end

function Enemy.drawAll()
    for _, e in ipairs(Game.state.enemies) do
        -- Health bar
        local healthColor = e.isBoss and {1, 0.2, 0.2} or {0, 1, 0}
        local barWidth = e.isBoss and 150 or e.size * 2
        local barHeight = e.isBoss and 8 or 4
        local barY = e.isBoss and 20 or (e.y - 20)

        love.graphics.setColor(0.3, 0, 0)
        love.graphics.rectangle("fill", 
            e.isBoss and (Game.screen.width/2 - barWidth/2) or (e.x - barWidth/2), 
            barY, 
            barWidth, 
            barHeight
        )
        love.graphics.setColor(unpack(healthColor))
        love.graphics.rectangle("fill", 
            e.isBoss and (Game.screen.width/2 - barWidth/2) or (e.x - barWidth/2), 
            barY, 
            barWidth * (e.health/e.maxHealth), 
            barHeight
        )

        -- Enemy body color handling
        local color
        if e.isBoss then
            -- Get color from Boss system
            local bossConfig = Boss.types[e.type]
            color = bossConfig and bossConfig.color or {1, 0, 1} -- fallback magenta
        else
            -- Get color from Enemy system
            local enemyConfig = Enemy.types[e.type]
            color = enemyConfig and enemyConfig.color or {1, 1, 0} -- fallback yellow
        end

        love.graphics.setColor(color[1], color[2], color[3])
        love.graphics.rectangle("fill", e.x - e.size/2, e.y - e.size/2, e.size, e.size)
        
        -- Boss crown
        if e.isBoss then
            Boss.drawCrown(e.x, e.y, e.size)
        end
    end
end

function Enemy.onDeath(enemy)
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
