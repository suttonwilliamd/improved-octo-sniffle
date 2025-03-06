Effects = {
    damageNumbers = {},
    list = {}
}

function Effects.spawnDamageNumber(x, y, amount, isCrit)
    table.insert(Effects.damageNumbers, {
        x = x,
        y = y,
        text = tostring(math.floor(amount)),
        color = isCrit and {1, 0, 0} or {1, 1, 1},
        timer = 1,
        alpha = 1,
        scale = isCrit and 1.3 or 1
    })
end



function Effects.spawnErrorEffect(x, y)
    table.insert(Effects.damageNumbers, {
        x = x, y = y,
        text = "MAX!",
        color = {1, 0, 0},
        timer = 1,
        alpha = 1,
        scale = 1.2
    })
end

function Effects.spawnDamageEffect(x, y, duration, damage)
    table.insert(Effects.damageNumbers, {  -- Using existing damageNumbers system
        x = x,
        y = y,
        text = "✴ " .. tostring(damage),
        color = {0.4, 0.4, 0.9},
        timer = duration,
        alpha = 1,
        scale = 0.8,
        velocityY = -20
    })
end

function Effects.spawnCritEffect(x, y)
    table.insert(Effects.damageNumbers, {
        x = x,
        y = y,
        text = "CRIT!",
        color = {1, 0.5, 0},
        timer = 1.5,
        alpha = 1,
        scale = 2
    })
end

function Effects.spawnSpeedEffect(x, y)
    table.insert(Effects.list, {
        type = "speed",
        x = x,
        y = y,
        timer = 1.0,
        radius = 0,
        color = {0.2, 0.8, 1, 0.9}
    })
end

function Effects.update(dt)
    -- Update regular effects using utils.arrayRemove
    Effects.list = utils.arrayRemove(Effects.list, function(_, i)
        local effect = Effects.list[i]
        effect.timer = effect.timer - dt
        
        if effect.type == "explosion" then
            effect.radius = effect.maxRadius * (1 - (effect.timer / 1))
            effect.color[4] = 0.8 * (effect.timer / 1)
        elseif effect.type == "speed" then
            effect.radius = effect.radius + 100 * dt
        end
        
        return effect.timer > 0
    end)

    -- Update damage numbers using utils.arrayRemove
    Effects.damageNumbers = utils.arrayRemove(Effects.damageNumbers, function(_, i)
        local num = Effects.damageNumbers[i]
        num.timer = num.timer - dt
        num.alpha = num.timer
        num.y = num.y - 50 * dt
        return num.timer > 0
    end)
end

function Effects.draw()
    for _, effect in ipairs(Effects.list) do
        if effect.type == "target" then
            love.graphics.setColor(effect.color)
            love.graphics.circle("line", effect.x, effect.y, 
                effect.size + 20 * (1 - effect.timer), 32)
        elseif effect.type == "explosion" then
            love.graphics.setColor(effect.color)
            love.graphics.setLineWidth(effect.thickness)
            love.graphics.circle("line", effect.x, effect.y, effect.radius)
            love.graphics.setLineWidth(1)
        end
    end
    
    -- Existing damage numbers drawing code remains the same
    for _, num in ipairs(Effects.damageNumbers) do
        love.graphics.setColor(num.color[1], num.color[2], num.color[3], num.alpha)
        love.graphics.push()
        love.graphics.translate(num.x, num.y)
        love.graphics.scale(num.scale)
        love.graphics.print(num.text, 0, 0)
        love.graphics.pop()
    end
    love.graphics.setColor(1, 1, 1)
end

-- Add these to the Effects table in effects.lua
function Effects.spawnShieldEffect(x, y)
    table.insert(Effects.damageNumbers, {
        x = x,
        y = y,
        text = "SHIELD+",
        color = {0.2, 0.6, 1},
        timer = 1.2,
        alpha = 1,
        scale = 1.5
    })
end

function Effects.spawnHealEffect(x, y)
    table.insert(Effects.damageNumbers, {
        x = x,
        y = y,
        text = "HEAL+",
        color = {0.4, 1, 0.4},
        timer = 1.2,
        alpha = 1,
        scale = 1.5
    })
end

function Effects.spawnTargetIndicator(x, y)
    table.insert(Effects.list, {
        type = "target",
        x = x,
        y = y,
        timer = 1.0,
        size = 0,
        color = {1, 0.8, 0, 1}
    })
end

function Effects.spawnThornsEffect(x, y)
    table.insert(Effects.list, {  -- Changed from Game.effects to Effects.list
        type = "thorns",
        x = x,
        y = y,
        timer = 0.4,
        color = {0.8, 0.2, 0.2}
    })
end

function Effects.spawnExplosion(x, y, radius, duration)
    table.insert(Effects.list, {
        type = "explosion",
        x = x,
        y = y,
        timer = duration,
        maxRadius = radius,
        radius = 0,
        color = {1, 0.5, 0, 0.8},
        thickness = 3
    })
end
