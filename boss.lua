Boss = {
    types = {
        standard = {
            name = "Standard Boss",
            color = {0.5, 0, 0.5},
            sizeMultiplier = 2.0,
            speedBonus = 0.7,
            goldMultiplier = 5.0,
            xpMultiplier = 4.0,
            attackSpeed = 0.5,
            healthMultiplier = 12,
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
            name = "Swarmlord",
            color = {0.8, 0.8, 0},
            sizeMultiplier = 2.0,
            speedBonus = 0.8,
            goldMultiplier = 5.0,
            xpMultiplier = 4.0,
            attackSpeed = 0.6,
            healthMultiplier = 12,
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
            name = "Phasebeast",
            color = {0.4, 0.4, 0.9},
            sizeMultiplier = 2.2,
            speedBonus = 1.1,
            goldMultiplier = 5.0,
            xpMultiplier = 4.0,
            attackSpeed = 0.7,
            healthMultiplier = 12,
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

function Boss.create(tier, bossType)
    
    --MusicGenerator:switchPattern("boss_battle")
    
    local config = Boss.types[bossType]
    if not config then return nil end
    
    -- Create base enemy properties
    local baseSpeed = 40 * Enemy.speedMultiplier * config.speedBonus
    
    local boss = {
        x = math.random(50, Game.screen.width-50),
        y = math.random(50, Game.screen.height-50),
        size = 15 * config.sizeMultiplier,
        health = Enemy.baseHealth * config.healthMultiplier * tier,
        maxHealth = Enemy.baseHealth * config.healthMultiplier * tier,
        pendingDamage = 0,
        speed = baseSpeed,
        gold = math.random(50, 500) * config.goldMultiplier * tier * 3,
        xp = math.random(5, 15) * config.xpMultiplier * tier * 5,
        type = bossType,
        attackTimer = 0,
        attackSpeed = config.attackSpeed,
        inMeleeRange = false,
        isBoss = true,
        tier = tier,
        specialAbility = config.specialAbility
    }

    -- Apply tier scaling
    boss.size = 25 * (1 + tier * 0.25) * config.sizeMultiplier
    boss.speed = boss.speed * (0.95 ^ tier)

    -- Tier-specific modifications
    if tier >= 3 and bossType == "standard" then
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

-- Rest of the file remains the same...

function Boss.drawCrown(x, y, size)
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.polygon("fill",
        x, y - size,
        x - 5, y - size + 10,
        x + 5, y - size + 10
    )
end

function Boss.getAvailableTypes(tier)
    local types = {"standard", "swarmlord", "phasebeast"}
    if tier >= 5 then
        table.insert(types, "enhanced_"..types[math.random(#types)])
    end
    return types
end