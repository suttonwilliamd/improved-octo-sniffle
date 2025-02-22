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
        },
        boss = {
            color = {0.5, 0, 0.5}, 
            speedBonus = 0.7,
            goldMultiplier = 5.0,
            xpMultiplier = 4.0,
            attackSpeed = 0.5,
            sizeMultiplier = 2.0,
            specialAbility = function(self, dt)
                if math.random() < 0.15 * dt then
                    self.x = math.random(50, Game.screen.width-50)
                    self.y = math.random(50, Game.screen.height-50)
                end
                if self.health < self.maxHealth * 0.3 then
                    self.speed = self.speed * 1.2
                end
            end
        },
        swarmlord = {
            color = {0.8, 0.8, 0},
            speedBonus = 0.8,
            goldMultiplier = 5.0,
            xpMultiplier = 4.0,
            attackSpeed = 0.6,
            sizeMultiplier = 2.0,
            specialAbility = function(self, dt)
                self.summonTimer = (self.summonTimer or 4) - dt
                if self.summonTimer <= 0 then
                    for i = 1, 3 do
                        local m = Enemy.createEnemy(math.random() < 0.7 and "normal" or "fast")
                        m.health = 1
                        m.gold = 0
                        m.x = self.x + math.random(-75, 75)
                        m.y = self.y + math.random(-75, 75)
                        table.insert(Game.state.enemies, m)
                    end
                    self.summonTimer = 4
                end
            end
        },
        phasebeast = {
            color = {0.4, 0.4, 0.9},
            speedBonus = 1.1,
            goldMultiplier = 5.0,
            xpMultiplier = 4.0,
            attackSpeed = 0.7,
            sizeMultiplier = 2.2,
            specialAbility = function(self, dt)
                if math.random() < 0.25 * dt then
                    Effects.spawnDamageEffect(self.x, self.y, 1.5, 0.5)
                end
                if math.random() < 0.3 * dt then
                    self.x = self.x + math.random(-100, 100)
                    self.y = self.y + math.random(-100, 100)
                end
            end
        }
    }
}

function Enemy.spawn()
    local wave = Waves.currentWave
    local isBossWave = wave % 5 == 0
    
    if isBossWave then
        local bossTier = math.floor(wave / 5) + 1
        local bossTypes = {"boss", "swarmlord", "phasebeast"}
        local bossType = bossTypes[(bossTier % #bossTypes) + 1]
        local boss = Enemy.createBoss(bossTier, bossType)
        table.insert(Game.state.enemies, boss)
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
        specialAbility = config.specialAbility,
        tier = 1
    }
end

function Enemy.createBoss(tier, bossType)
    bossType = bossType or "boss"
    local boss = Enemy.createEnemy(bossType)
    boss.isBoss = true
    boss.tier = tier

    boss.size = 25 * (1 + tier * 0.25) * Enemy.types[bossType].sizeMultiplier
    boss.health = Enemy.baseHealth * 12 * tier
    boss.maxHealth = boss.health
    boss.gold = boss.gold * tier * 3
    boss.xp = boss.xp * tier * 5
    boss.speed = boss.speed * (0.95 ^ tier)

    if tier >= 3 and bossType == "boss" then
        boss.specialAbility = function(self, dt)
            if math.random() < 0.15 * dt then
                self.x = math.random(50, Game.screen.width-50)
                self.y = math.random(50, Game.screen.height-50)
            end
            if self.health < self.maxHealth * 0.3 then
                self.speed = self.speed * 1.15
            end
        end
    end

    return boss
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

        -- Enemy body
        local color = Enemy.types[e.type].color
        love.graphics.setColor(color[1], color[2], color[3])
        love.graphics.rectangle("fill", e.x - e.size/2, e.y - e.size/2, e.size, e.size)
        
        -- Boss crown
        if e.isBoss then
            love.graphics.setColor(1, 0.8, 0)
            love.graphics.polygon("fill",
                e.x, e.y - e.size,
                e.x - 5, e.y - e.size + 10,
                e.x + 5, e.y - e.size + 10
            )
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
