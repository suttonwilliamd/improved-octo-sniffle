Upgrades = {
    stats = {
        attackDamage = {
            base = 1,
            costMultiplier = 1.5,
            currentCost = 50,
            description = "Increases damage per attack"
        },
        attackSpeed = {
            base = 0.1,
            costMultiplier = 2,
            currentCost = 50,
            description = "Improves attack frequency"
        },
        critChance = {
            base = 0.05,
            costMultiplier = 2.2,
            currentCost = 50,
            description = "Chance for critical hits"
        },
        defense = {
            base = 1,
            costMultiplier = 1.8,
            currentCost = 75,
            description = "Reduces incoming damage",
            max = 50  -- Cap at 50% damage reduction
        },
        regen = {
            base = 0.5,
            costMultiplier = 2.5,
            currentCost = 100,
            description = "Health regeneration per second"
        }
    }
}

function Upgrades.purchaseStat(stat)
    local upgrade = Upgrades.stats[stat]
    if not upgrade or not Player[stat] then return end
    
    if Player.gold >= upgrade.currentCost then
        -- Calculate potential new value
        local newValue = Player[stat] + upgrade.base
        
        -- Apply defense cap if needed
        if stat == "defense" and newValue > upgrade.max then
            newValue = upgrade.max
        end

        -- Update values
        Player[stat] = newValue
        Player.baseStats[stat] = newValue  -- Maintain base for scaling
        
        -- Handle transaction
        Player.gold = Player.gold - upgrade.currentCost
        upgrade.currentCost = math.floor(upgrade.currentCost * upgrade.costMultiplier)
        
        -- Post-purchase effects
        if stat == "defense" then
            Effects.create("shield", Player.x, Player.y)
        elseif stat == "regen" then
            Effects.create("heal", Player.x, Player.y)
        end
    end
end

function Upgrades.getUpgradeInfo(stat)
    local info = Upgrades.stats[stat]
    return {
        current = Player[stat],
        nextCost = info.currentCost,
        description = info.description,
        progress = stat == "defense" and (Player.defense / info.max) or nil
    }
end