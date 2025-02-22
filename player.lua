Player = {
    x = 0, y = 0,
    size = 20,
    target = nil,
    attackSpeed = 1,
    attackDamage = 1,
    critChance = 0.1,
    defense = 0,      -- Percentage damage reduction
    regen = 0,        -- HP per second regeneration
    gold = 0,
    level = 1,
    xp = 0,
    xpToNextLevel = 100,
    health = 100,
    maxHealth = 100,
    isDead = false    -- New death state
}

function Player.init()
    -- Position and reset stats
    Player.x = Game.screen.width / 2
    Player.y = Game.screen.height / 2
    Player.health = Player.maxHealth
    Player.isDead = false
    
    -- Initialize base stats for scaling
    Player.baseStats = {
        attackDamage = Player.attackDamage,
        attackSpeed = Player.attackSpeed,
        critChance = Player.critChance,
        defense = Player.defense,
        regen = Player.regen
    }
    
    -- Persistent progression between runs
    Player.gold = Player.gold or 0
    Player.level = Player.level or 1
    Player.xp = Player.xp or 0
    Player.xpToNextLevel = Player.xpToNextLevel or 100
    
    -- Reset wave state
    Waves.currentWave = 1
    Waves.betweenWaves = true
    Game.state.enemies = {}
end

function Player.takeDamage(amount)
    local mitigated = amount * (1 - Player.defense/100)
    Player.health = Player.health - mitigated
    Player.checkDeath()
end

function Player.levelUp()
    Player.level = Player.level + 1
    Player.xp = Player.xp - Player.xpToNextLevel
    Player.xpToNextLevel = math.floor(Player.xpToNextLevel * 1.5)
    
    -- Scale stats based on base values
    Player.attackDamage = Player.baseStats.attackDamage * (1 + Player.level * 0.1)
    Player.attackSpeed = Player.baseStats.attackSpeed * (1 + Player.level * 0.05)
    Player.defense = Player.baseStats.defense * (1 + Player.level * 0.02)
    Player.regen = Player.baseStats.regen * (1 + Player.level * 0.03)
    
    print("Level Up! Reached level", Player.level)
end

function Player.autoAttack(dt)
    Game.state.attackTimer = Game.state.attackTimer + dt
    if Game.state.attackTimer > 1/Player.attackSpeed then
        -- Clear invalid or dead targets
        if Player.target and (not isEnemyValid(Player.target) or Player.target.health <= 0) then
            Player.target = nil
        end

        -- Find new target only if needed
        if not Player.target then
            local nearestValidEnemy = nil
            local closestDistance = math.huge
            
            for _, e in ipairs(Game.state.enemies) do
                if e.health > 0 and e.health > e.pendingDamage then -- Add health check
                    local dx = Player.x - e.x
                    local dy = Player.y - e.y
                    local distance = math.sqrt(dx*dx + dy*dy)
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        nearestValidEnemy = e
                    end
                end
            end
            
            Player.target = nearestValidEnemy
        end

        -- Fire only at valid, alive targets
        if Player.target and Player.target.health > 0 and Player.target.health > Player.target.pendingDamage then
            Projectile.create(Player.x, Player.y, Player.target)
        end
        
        Game.state.attackTimer = 0
    end
end

function Player.draw()
    -- Main player circle
    love.graphics.setColor(0, 1, 0)
    love.graphics.circle('fill', Player.x, Player.y, Player.size)
    
    -- Defense aura visualization
    if Player.defense > 0 then
        love.graphics.setColor(0.2, 0.5, 1, 0.3)
        love.graphics.circle('line', Player.x, Player.y, Player.size * 1.5)
    end
end

function Player.drawHealth()
    -- Health bar background
    love.graphics.setColor(0.3, 0, 0)
    love.graphics.rectangle("fill", 10, 100, 200, 20)
    
    -- Current health fill
    local healthWidth = (Player.health / Player.maxHealth) * 200
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.rectangle("fill", 10, 100, healthWidth, 20)
    
    -- Health text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Health: " .. math.floor(Player.health) .. "/" .. Player.maxHealth, 15, 103)
end

function Player.checkDeath()
    if Player.health <= 0 and not Player.isDead then
        Player.isDead = true
        Game.state.showDeathScreen = true
    end
end

function Player.drawDeathScreen()
    if Game.state.showDeathScreen then
        -- Dark overlay
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, Game.screen.width, Game.screen.height)
        
        -- Death text
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("YOU DIED", 0, Game.screen.height/2 - 60, Game.screen.width, "center", 0, 2)
        
        -- Stats summary
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Wave Reached: " .. Waves.currentWave .. "\nGold Collected: " .. Player.gold, 
            0, Game.screen.height/2, Game.screen.width, "center")
            
        -- Restart prompt
        love.graphics.printf("Tap to Start New Run", 0, Game.screen.height - 100, Game.screen.width, "center")
    end
end

function Player.getRegenRate()
    return Player.regen + (Player.level * 0.1)
end

function Player.resetHealth()
    Player.health = Player.maxHealth
end

-- Helper function to validate targets
function isEnemyValid(enemy)
    for _, e in ipairs(Game.state.enemies) do
        if e == enemy then
            return true
        end
    end
    return false
end
