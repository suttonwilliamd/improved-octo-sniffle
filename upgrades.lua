Upgrades = {
    stats = {
        attackDamage = {
            base = 1,
            costMultiplier = 1.5,
            currentCost = 50,
            description = "Increases damage per attack",
            purchased = 0
        },
        attackSpeed = {
            base = 0.1,
            costMultiplier = 2,
            currentCost = 50,
            description = "Improves attack frequency",
            purchased = 0
        },
        critChance = {
            base = 0.05,
            costMultiplier = 2.2,
            currentCost = 50,
            description = "Chance for critical hits",
            purchased = 0
        },
        defense = {
            base = 1,
            costMultiplier = 1.8,
            currentCost = 75,
            description = "Reduces incoming damage",
            max = 50,  -- Max 50% damage reduction
            purchased = 0
        },
        regen = {
            base = 0.5,
            costMultiplier = 2.5,
            currentCost = 100,
            description = "Health regeneration per second",
            purchased = 0
        },
        gameSpeed = {
            base = 0.25,
            costMultiplier = 1.01,
            currentCost = 250,
            description = "Increase game speed",
            max = 100.0,  -- Max 100x speed
            purchased = 0
        },
        areaDamage = {
            base = 0.1,
            costMultiplier = 1.8,
            currentCost = 150,
            description = "Chance to damage nearby enemies",
            purchased = 0,
            max = 3.0
        },
        lifeSteal = {
            base = 0.05,
            costMultiplier = 2.0,
            currentCost = 200,
            description = "Heal percentage of damage dealt",
            purchased = 0,
            max = 0.25
        },
        thorns = {
            base = 0.1,
            costMultiplier = 1.8,
            currentCost = 150,
            description = "Reflect a percentage of damage taken",
            purchased = 0,
            max = 3.0  -- Max 3x damage reflection
        }
    }
}


function Upgrades.purchaseStat(stat)
    local upgrade = Upgrades.stats[stat]
    if not upgrade or (stat ~= "gameSpeed" and not Player.baseStats[stat]) then return end
    
    -- Handle game speed separately
    if stat == "gameSpeed" then
        if Player.gold >= upgrade.currentCost then
            local newSpeed = Game.state.speedMultiplier + upgrade.base
            
            if upgrade.max and newSpeed > upgrade.max then
                Effects.spawnErrorEffect(Player.x, Player.y)
                return
            end

            Game.state.speedMultiplier = newSpeed
            Player.gold = Player.gold - upgrade.currentCost
            upgrade.currentCost = math.floor(upgrade.currentCost * upgrade.costMultiplier)
            upgrade.purchased = upgrade.purchased + 1
            Effects.spawnSpeedEffect(Player.x, Player.y)
        end
        return
    end

    -- Handle other stats (modify base stats)
    if Player.gold >= upgrade.currentCost then
        local originalBase = Player.baseStats[stat]
        local originalGold = Player.gold
        
        -- Tentatively apply upgrade to base stat
        Player.baseStats[stat] = originalBase + upgrade.base
        Player.updateStats()
        
        -- Check if current value exceeds max
        if upgrade.max and Player[stat] > upgrade.max then
            -- Revert changes
            Player.baseStats[stat] = originalBase
            Player.gold = originalGold
            Effects.spawnErrorEffect(Player.x, Player.y)
            return
        end
        
        -- Deduct gold and update cost
        Player.gold = Player.gold - upgrade.currentCost
        upgrade.currentCost = math.floor(upgrade.currentCost * upgrade.costMultiplier)
        upgrade.purchased = upgrade.purchased + 1
        
        -- Visual feedback
        if stat == "defense" then
            Effects.spawnShieldEffect(Player.x, Player.y)
        elseif stat == "regen" then
            Effects.spawnHealEffect(Player.x, Player.y)
        end
    end
end

function Upgrades.getUpgradeInfo(stat)
    local info = Upgrades.stats[stat]
    if not info then return nil end
    
    local currentValue = stat == "gameSpeed" and Game.state.speedMultiplier or Player[stat]
    
    return {
        current = currentValue,
        nextCost = info.currentCost,
        description = info.description,
        progress = info.max and (currentValue / info.max) or nil,
        purchased = info.purchased
    }
end

function Upgrades.reset()
    for stat, data in pairs(Upgrades.stats) do
        data.currentCost = data.initialCost or data.currentCost
        data.purchased = 0
    end
    Game.state.speedMultiplier = 1.0
end

-- Initialize initial costs for reset functionality
for stat, data in pairs(Upgrades.stats) do
    data.initialCost = data.currentCost
end
