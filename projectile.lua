Projectile = {}

function Projectile.create(x, y, target)
    -- Calculate damage upfront including crit chance
    local isCrit = math.random() < Player.critChance
    local damage = Player.attackDamage * (isCrit and 2 or 1)
    
    -- Initialize pending damage if needed and track incoming damage
    target.pendingDamage = (target.pendingDamage or 0) + damage
    
    table.insert(Game.state.projectiles, {
        x = x, y = y,
        target = target,
        speed = 500,
        damage = damage,  -- Store pre-calculated damage
        crit = isCrit     -- Store crit status for effects
    })
end

function Projectile.updateAll(dt)
    Game.state.projectiles = utils.arrayRemove(Game.state.projectiles, function(_, i)
        local p = Game.state.projectiles[i]
        if not p then return false end
        
        local dx = (p.target.x - p.x) + p.target.size/2
        local dy = (p.target.y - p.y) + p.target.size/2
        local dist = math.sqrt(dx^2 + dy^2)
        
        if dist < 5 then
            -- Use pre-calculated damage
            Effects.spawnDamageNumber(p.target.x, p.target.y, p.damage, p.crit)
            
            if p.crit then
                Effects.spawnCritEffect(p.target.x, p.target.y)
            end

            -- Apply damage and update pending damage
            p.target.health = p.target.health - p.damage
            p.target.pendingDamage = p.target.pendingDamage - p.damage
            
            -- Clean up dead enemies
            if p.target.health <= 0 then
                Enemy.onDeath(p.target)
            end
            return false  -- Remove projectile
        else
            -- Update projectile position
            p.x = p.x + (dx/dist) * p.speed * dt
            p.y = p.y + (dy/dist) * p.speed * dt
            return true  -- Keep projectile
        end
    end)
end

function Projectile.drawAll()
    love.graphics.setColor(1, 1, 0)
    for _, p in ipairs(Game.state.projectiles) do
        love.graphics.circle("fill", p.x, p.y, 3)
    end
end
