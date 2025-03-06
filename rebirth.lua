Rebirth = {
    souls = 0,
    soulMultiplier = 1,
    multipliers = {
        health = 1,
        damage = 1,
        speed = 1
    },
    upgrades = {
        {
            name = "Vitality Core",
            description = "Permanently increase base health by 15%",
            cost = 50,
            effect = function() 
                Rebirth.multipliers.health = Rebirth.multipliers.health * 1.15 
            end
        },
        {
            name = "Damage Amplifier",
            description = "Increase base damage by 10%",
            cost = 100,
            effect = function()
                Rebirth.multipliers.damage = Rebirth.multipliers.damage * 1.10
            end
        },
        {
            name = "Soul Harvester",
            description = "Gain 20% more souls per rebirth",
            cost = 150,
            effect = function()
                Rebirth.soulMultiplier = Rebirth.soulMultiplier * 1.2
            end
        },
        {
            name = "Swift Essence",
            description = "Permanent 5% movement speed boost",
            cost = 200,
            effect = function()
                Rebirth.multipliers.speed = Rebirth.multipliers.speed * 1.05
            end
        }
    }
}

function Rebirth.purchaseUpgrade(upgrade)
    if Rebirth.souls >= upgrade.cost then
        Rebirth.souls = Rebirth.souls - upgrade.cost
        upgrade.effect()
        return true
    end
    return false
end

function Rebirth.calculateSoulGain()
    return math.floor(
        (Waves.currentWave * 5 + Player.level * 2) * 
        Rebirth.soulMultiplier
    )
end

function Rebirth.reset()
    -- Called when starting new run
    Rebirth.soulMultiplier = 1
    -- Keep purchased multipliers between runs
end