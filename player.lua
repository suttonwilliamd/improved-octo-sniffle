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
    Player.maxHealth = 100 * (Rebirth and Rebirth.multipliers.health or 1)
    Player.health = Player.maxHealth
    Player.isDead = false
    
    -- Initialize base stats for scaling
    Player.baseStats = {
        attackDamage = 1 * (Rebirth and Rebirth.multipliers.damage or 1),
        attackSpeed = 1,
        critChance = 0.1,
        defense = 0,
        regen = 0,
        areaDamage = 0,
        lifeSteal = 0,
        thorns = 0.0
    }
    
    -- Persistent progression between runs
    Player.gold = Player.gold or 0
    Player.level = Player.level or 1
    Player.xp = Player.xp or 0
    Player.xpToNextLevel = Player.xpToNextLevel or 100
    
    Player.updateStats()  -- Set initial values
    
    Game.state.enemies = {}
end

function Player.takeDamage(amount, attacker)
    local mitigated = amount * (1 - Player.defense/100)
    Player.health = Player.health - mitigated
    Player.checkDeath()

    -- Reflect thorns damage if applicable
    if attacker and Player.thorns > 0 then
        local thornsDamage = Player.thorns * 10
        attacker.health = attacker.health - thornsDamage
        Effects.spawnThornsEffect(attacker.x, attacker.y)
        Effects.spawnDamageEffect(attacker.x, attacker.y, 0.5, math.floor(thornsDamage))
    end
end

function Player.updateStats()
    -- Calculate current stats based on base stats + level scaling
    Player.attackDamage = Player.baseStats.attackDamage * (1 + Player.level * 0.1)
    Player.critChance = Player.baseStats.critChance * (1 + Player.level * 0.01)
    Player.attackSpeed = Player.baseStats.attackSpeed * (1 + Player.level * 0.05)
    Player.defense = Player.baseStats.defense * (1 + Player.level * 0.02)
    Player.regen = Player.baseStats.regen * (1 + Player.level * 0.03)
    Player.areaDamage = (Player.baseStats.areaDamage or 0) * (1 + Player.level * 0.05)
    Player.lifeSteal = (Player.baseStats.lifeSteal or 0) * (1 + Player.level * 0.03)
    Player.thorns = (Player.baseStats.thorns or 0) * (Rebirth and Rebirth.multipliers.damage or 1)
end


function Player.levelUp()
    Player.level = Player.level + 1
    Player.xp = Player.xp - Player.xpToNextLevel
    Player.xpToNextLevel = math.floor(Player.xpToNextLevel * 1.5)
    
    Player.updateStats()
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
                if e.health > 0 and e.health > e.pendingDamage then
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

        -- Fire only at valid targets
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
        MusicGenerator:switchPattern("cyber_arpeggio") -- Reset to default
    end
        Rebirth.souls = Rebirth.souls + Rebirth.calculateSoulGain()
        Player.isDead = true
        Game.state.showDeathScreen = true
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

function Player.reset()
    -- Reset position and vital stats
    Player.x = Game.screen.width / 2
    Player.y = Game.screen.height / 2
    Player.health = Player.maxHealth
    Player.isDead = false
    
    -- Reset progression system
    Player.xp = 0
    Player.xpToNextLevel = 100
    
    Player.updateStats()
    
    -- Clear any target lock
    Player.target = nil
    
    -- Reset wave state
    Waves.currentWave = 1
    Waves.betweenWaves = true
    Game.state.enemies = {}
end
