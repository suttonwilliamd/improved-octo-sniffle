Effects = {
    damageNumbers = {}
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
    print("Spawned damage number:", amount) -- Debug
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
    print("Spawned crit effect") -- Debug
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