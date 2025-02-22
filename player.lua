Player = {
    x = 0, y = 0,
    size = 20,
    attackSpeed = 1,
    attackDamage = 1,
    critChance = 0.1,
    defense = 0,      -- New: Percentage damage reduction
    regen = 0,        -- New: HP per second regeneration
    gold = 0,
    level = 1,
    xp = 0,
    xpToNextLevel = 100,
    health = 100,
    maxHealth = 100
}

function Player.init(screenWidth, screenHeight)
    Player.x = screenWidth / 2
    Player.y = screenHeight / 2
    Player.health = Player.maxHealth
    Player.baseStats = {
        attackDamage = Player.attackDamage,
        attackSpeed = Player.attackSpeed,
        critChance = Player.critChance,
        defense = Player.defense,    -- New: Track base defense
        regen = Player.regen         -- New: Track base regen
    }
end

function Player.takeDamage(amount)
    -- New damage calculation with defense mitigation
    local mitigated = amount * (1 - Player.defense/100)
    Player.health = Player.health - mitigated
end

function Player.levelUp()
    Player.level = Player.level + 1
    Player.xp = Player.xp - Player.xpToNextLevel
    Player.xpToNextLevel = math.floor(Player.xpToNextLevel * 1.5)
    
    -- Automatic stat boosts based on base values
    Player.attackDamage = Player.baseStats.attackDamage * (1 + Player.level * 0.1)
    Player.attackSpeed = Player.baseStats.attackSpeed * (1 + Player.level * 0.05)
    Player.defense = Player.baseStats.defense * (1 + Player.level * 0.02)  -- New: Defense scaling
    Player.regen = Player.baseStats.regen * (1 + Player.level * 0.03)       -- New: Regen scaling
    
    print("Level Up! Reached level", Player.level)
end

function Player.autoAttack(dt)
    Game.state.attackTimer = Game.state.attackTimer + dt
    if Game.state.attackTimer > 1/Player.attackSpeed then
        local nearestEnemy = nil
        local closestDistance = math.huge
        
        for _, e in ipairs(Game.state.enemies) do
            local dx = Player.x - e.x
            local dy = Player.y - e.y
            local distance = math.sqrt(dx*dx + dy*dy)
            
            if distance < closestDistance then
                closestDistance = distance
                nearestEnemy = e
            end
        end
        
        if nearestEnemy then
            Projectile.create(Player.x, Player.y, nearestEnemy)
        end
        
        Game.state.attackTimer = 0
    end
end

function Player.draw()
    love.graphics.setColor(0, 1, 0)
    love.graphics.circle('fill', Player.x, Player.y, Player.size)
    
    -- Draw defense aura if upgraded
    if Player.defense > 0 then
        love.graphics.setColor(0.2, 0.5, 1, 0.3)
        love.graphics.circle('line', Player.x, Player.y, Player.size * 1.5)
    end
end

-- New: Helper function for regeneration system
function Player.getRegenRate()
    return Player.regen + (Player.level * 0.1)  -- Base + level bonus
end

-- New: Full heal when starting new wave
function Player.resetHealth()
    Player.health = Player.maxHealth
end