Effects = {
    damageNumbers = {},
    list = {}
}

function Effects.spawnDamageNumber(x, y, amount, isCrit)
    table.insert(Effects.damageNumbers, {
        x = x,
        y = y,
        text = tostring(amount),
        color = isCrit and {1, 0, 0} or {1, 1, 1},
        timer = 1,
        alpha = 1,
        scale = isCrit and 1.3 or 1
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
    for i = #Effects.damageNumbers, 1, -1 do
        local num = Effects.damageNumbers[i]
        num.timer = num.timer - dt
        num.alpha = num.timer
        num.y = num.y - 50 * dt
        
        if num.timer <= 0 then
            table.remove(Effects.damageNumbers, i)
        end
    end
end

function Effects.draw()
    for _, num in ipairs(Effects.damageNumbers) do
        love.graphics.setColor(num.color[1], num.color[2], num.color[3], num.alpha)
        love.graphics.push()
        love.graphics.translate(num.x, num.y)
        love.graphics.scale(num.scale)
        love.graphics.print(num.text, 0, 0)
        love.graphics.pop()
    end
    love.graphics.setColor(1, 1, 1) -- Reset color
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
