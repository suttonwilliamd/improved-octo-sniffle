Enemy = {
    baseHealth = 3,  -- Reduced from 10
    speedMultiplier = 1.0,
    types = {
        normal = {
            color = {1, 0, 0}, 
            speedBonus = 1.0,
            goldMultiplier = 1.0,
            xpMultiplier = 1.0,
            attackSpeed = 1  -- Attacks per second
        },
        fast = {
            color = {0.2, 0.5, 1}, 
            speedBonus = 1.8,
            goldMultiplier = 1.5,
            xpMultiplier = 1.3,
            attackSpeed = 1.5
        },
        tank = {
            color = {0, 0.8, 0}, 
            speedBonus = 0.8,
            goldMultiplier = 2.0,
            xpMultiplier = 1.8,
            attackSpeed = 0.8
        }
    }
}

function Enemy.spawn()
    local enemyType = "normal"
    local wave = Waves.currentWave
    
    -- Type probabilities based on wave
    if wave >= 3 then
        local roll = math.random()
        if roll < 0.15 then
            enemyType = "tank"
        elseif roll < 0.3 then
            enemyType = "fast"
        end
    end
    
    if wave >= 5 then
        local roll = math.random()
        if roll < 0.25 then
            enemyType = "tank"
        elseif roll < 0.5 then
            enemyType = "fast"
        end
    end

    local config = Enemy.types[enemyType]
    local baseSpeed = 40 * Enemy.speedMultiplier * config.speedBonus
    
    local enemy = {
        x = math.random(50, Game.screen.width-50),
        y = math.random(50, Game.screen.height-50),
        size = 15,
        health = Enemy.baseHealth,  -- Removed health bonus
        maxHealth = Enemy.baseHealth,
        speed = baseSpeed,
        gold = math.random(50,500) * config.goldMultiplier,
        xp = math.random(5,15) * config.xpMultiplier,
        type = enemyType,
        attackTimer = 0,
        attackSpeed = config.attackSpeed,
        inMeleeRange = false
    }
    
    table.insert(Game.state.enemies, enemy)
end

function Enemy.updateMovement(dt)
    Game.state.enemies = utils.arrayRemove(Game.state.enemies, function(_, i)
        local e = Game.state.enemies[i]
        if not e then return false end
        
        -- Calculate distance to player
        local dx = Player.x - e.x
        local dy = Player.y - e.y
        local dist = math.sqrt(dx^2 + dy^2)
        local meleeRange = e.size + Player.size + 5  -- Small buffer
        
        if dist > meleeRange then
            -- Move towards player
            e.x = e.x + (dx/dist) * e.speed * dt
            e.y = e.y + (dy/dist) * e.speed * dt
            e.inMeleeRange = false
        else
            -- In melee range, attack periodically
            e.inMeleeRange = true
            e.attackTimer = e.attackTimer - dt
            if e.attackTimer <= 0 then
                Player.health = Player.health - 1
                e.attackTimer = 1 / e.attackSpeed
            end
        end
        
        -- Keep enemy in array unless dead
        return e.health > 0
    end)
end

function Enemy.drawAll()
    for _, e in ipairs(Game.state.enemies) do
        -- Health bar
        local healthPercent = e.health / e.maxHealth
        local barWidth = e.size
        local barHeight = 3
        
        love.graphics.setColor(0.5, 0, 0)
        love.graphics.rectangle("fill", 
            e.x - barWidth/2, 
            e.y - 15, 
            barWidth, 
            barHeight
        )
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", 
            e.x - barWidth/2, 
            e.y - 15, 
            barWidth * healthPercent, 
            barHeight
        )

        -- Enemy body
        local color = Enemy.types[e.type].color
        love.graphics.setColor(color[1], color[2], color[3])
        love.graphics.rectangle("fill", e.x, e.y, e.size, e.size)
    end
end

function Enemy.onDeath(enemy)
    Player.gold = Player.gold + enemy.gold
    Player.xp = Player.xp + enemy.xp
    if Player.xp >= Player.xpToNextLevel then
        Player.levelUp()
    end
end