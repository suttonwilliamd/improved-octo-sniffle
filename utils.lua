utils = {}

function utils.pointInRect(x, y, rect)
    return x > rect.x 
        and y > rect.y 
        and x < rect.x + rect.width 
        and y < rect.y + rect.height
end

function utils.distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function utils.arrayRemove(t, fnKeep)
    local j, n = 1, #t
    for i = 1, n do
        if fnKeep(t, i, j) then
            if i ~= j then
                t[j] = t[i]
                t[i] = nil
            end
            j = j + 1
        else
            t[i] = nil
        end
    end
    return t
end

-- utils.lua
function utils.drawRoundedRect(rect, radius)
    love.graphics.rectangle("fill", rect.x, rect.y, rect.width, rect.height, radius)
end
