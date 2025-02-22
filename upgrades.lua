Upgrades = Upgrades or {
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
        },
        gameSpeed = {
            base = 0.1,  -- 10% speed increase per level
            costMultiplier = 3.0,
            currentCost = 250,
            description = "Increase game speed",
            max = 2.0  -- Max 2x speed
        }
    }
}

function Upgrades.purchaseStat(stat)
    if stat == "gameSpeed" then
        local upgrade = Upgrades.stats.gameSpeed
        if Player.gold >= upgrade.currentCost then
            -- Calculate new speed multiplier
            local newSpeed = Game.state.speedMultiplier + upgrade.base
            
            -- Apply maximum cap
            if newSpeed > upgrade.max then
                newSpeed = upgrade.max
                Effects.spawnErrorEffect(Player.x, Player.y)
                return
            end

            -- Apply upgrade
            Game.state.speedMultiplier = newSpeed
            Player.gold = Player.gold - upgrade.currentCost
            upgrade.currentCost = math.floor(upgrade.currentCost * upgrade.costMultiplier)
            Effects.spawnSpeedEffect(Player.x, Player.y)
        end
        return
    end

    -- Existing upgrade logic for other stats
    local upgrade = Upgrades.stats[stat]
    if not upgrade or not Player[stat] then return end
    
    if Player.gold >= upgrade.currentCost then
        -- ... rest of original purchase logic ...
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
