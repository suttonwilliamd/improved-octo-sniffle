UI = {
    buttons = {},
    colors = {
        background = {0.15, 0.15, 0.2, 0.95},
        buttonActive = {0.3, 0.5, 0.4},
        buttonInactive = {0.2, 0.2, 0.25},
        textActive = {0.9, 0.9, 0.9},
        textInactive = {0.6, 0.6, 0.6}
    }
}

function UI.init()
    local baseWidth = 1440
    Game.uiScale = math.min(
        math.max(Game.screen.width / baseWidth, 0.65),
        1.0
    )
    Game.fontScale = Game.uiScale * 0.9

    UI.buttons = {
        main = {
            x = 0.02 * Game.screen.width,
            y = 0.85 * Game.screen.height,
            width = 0.2 * Game.screen.width,
            height = 0.08 * Game.screen.height
        },
        close = {
            size = 40 * Game.uiScale
        }
    }
end

function UI.draw()
    UI.drawPersistentUI()
    UI.drawPlayerHealth()
    
    if Game.state.showDeathScreen then
        UI.drawDeathScreen()
    end
    
    if Game.state.inShop then
        UI.drawShop()
    end
    
    UI.drawWaveCounter()
    UI.drawSpeedIndicator()
end

function UI.drawPersistentUI()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(18 * Game.fontScale)
    love.graphics.print("Gold: " .. Player.gold, 10, 10)
    love.graphics.print("Lv." .. Player.level, 10, 30 * Game.fontScale)

    -- XP Bar
    local xpHeight = 6 * Game.fontScale
    local xpWidth = 0.3 * Game.screen.width
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", 10, 50 * Game.fontScale, xpWidth, xpHeight)
    love.graphics.setColor(0.2, 0.6, 1)
    love.graphics.rectangle("fill", 10, 50 * Game.fontScale, xpWidth * (Player.xp/Player.xpToNextLevel), xpHeight)

    -- Shop toggle button
    local btn = UI.buttons.main
    love.graphics.setColor(0.3, 0.4, 0.6)
    utils.drawRoundedRect({
        x = btn.x,
        y = btn.y,
        width = btn.width,
        height = btn.height
    }, 5 * Game.uiScale)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("SHOP", btn.x, btn.y + btn.height/4, btn.width, "center", 0, Game.fontScale * 0.9)
end

function UI.drawPlayerHealth()
    -- Health bar background
    love.graphics.setColor(0.3, 0, 0)
    love.graphics.rectangle("fill", 10, 100, 200, 20)
    
    -- Current health fill
    local healthWidth = (Player.health / Player.maxHealth) * 200
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.rectangle("fill", 10, 100, healthWidth, 20)
    
    -- Health text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Health: " .. math.floor(Player.health) .. "/" .. Player.maxHealth, 15, 103)
end

function UI.drawDeathScreen()
    -- Dark overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, Game.screen.width, Game.screen.height)
    
    -- Death text
    love.graphics.setColor(1, 0, 0)
    love.graphics.printf("YOU DIED", 0, Game.screen.height/2 - 60, Game.screen.width, "center", 0, 2)
    
    -- Stats summary
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Wave Reached: " .. Waves.currentWave .. "\nGold Collected: " .. Player.gold, 
        0, Game.screen.height/2, Game.screen.width, "center")
        
    -- Restart prompt
    love.graphics.printf("Tap to Start New Run", 0, Game.screen.height - 100, Game.screen.width, "center")
end

function UI.drawShop()
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 0, 0, Game.screen.width, Game.screen.height)
    
    local shopW = Game.screen.width * 0.85
    local shopH = Game.screen.height * 0.75
    local shopX = (Game.screen.width - shopW) * 0.5
    local shopY = (Game.screen.height - shopH) * 0.5
    
    -- Window background
    love.graphics.setColor(UI.colors.background)
    utils.drawRoundedRect({
        x = shopX,
        y = shopY,
        width = shopW,
        height = shopH
    }, 12 * Game.uiScale)
    
    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(24 * Game.fontScale)
    love.graphics.printf("UPGRADES", shopX, shopY + 20 * Game.fontScale, shopW, "center")

    -- Close button
    local close = UI.buttons.close
    local closeX = shopX + shopW - close.size - 15 * Game.uiScale
    local closeY = shopY + 15 * Game.uiScale
    love.graphics.setColor(0.8, 0.2, 0.2)
    utils.drawRoundedRect({
        x = closeX,
        y = closeY,
        width = close.size,
        height = close.size
    }, 6 * Game.uiScale)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("×", closeX, closeY + close.size/4, close.size, "center", 0, Game.fontScale * 1.2)

    -- Upgrade grid
    local btnWidth = shopW * 0.42
    local btnHeight = 80 * Game.uiScale
    local verticalSpacing = 15 * Game.uiScale
    local startY = shopY + 60 * Game.uiScale

    -- Left Column
    UI.drawUpgradeButton("Damage", "attackDamage", shopX + shopW*0.04, startY, btnWidth, btnHeight)
    UI.drawUpgradeButton("Defense", "defense", shopX + shopW*0.04, startY + (btnHeight + verticalSpacing), btnWidth, btnHeight)
    UI.drawUpgradeButton("Regen", "regen", shopX + shopW*0.04, startY + 2*(btnHeight + verticalSpacing), btnWidth, btnHeight)

    -- Right Column
    UI.drawUpgradeButton("Atk Speed", "attackSpeed", shopX + shopW*0.54, startY, btnWidth, btnHeight)
    UI.drawUpgradeButton("Crit %", "critChance", shopX + shopW*0.54, startY + (btnHeight + verticalSpacing), btnWidth, btnHeight)
    UI.drawUpgradeButton("Game Speed", "gameSpeed", shopX + shopW*0.54, startY + 2*(btnHeight + verticalSpacing), btnWidth, btnHeight)
end

function UI.drawUpgradeButton(title, statType, x, y, w, h)
    local stat = Upgrades.stats[statType]
    local canBuy = Player.gold >= stat.currentCost
    
    -- Button background
    love.graphics.setColor(canBuy and UI.colors.buttonActive or UI.colors.buttonInactive)
    utils.drawRoundedRect({
        x = x,
        y = y,
        width = w,
        height = h
    }, 8 * Game.uiScale)

    -- Text elements
    love.graphics.setColor(canBuy and UI.colors.textActive or UI.colors.textInactive)
    
    -- Title
    love.graphics.setNewFont(18 * Game.fontScale)
    love.graphics.print(title, x + 12 * Game.uiScale, y + 8 * Game.uiScale)

    -- Current value
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.setNewFont(14 * Game.fontScale)
    local current = UI.getFormattedStat(statType)
    love.graphics.print(current, x + 12 * Game.uiScale, y + h - 24 * Game.uiScale)

    -- Cost
    love.graphics.setNewFont(16 * Game.fontScale)
    local costText = stat.currentCost .. "g"
    local textWidth = love.graphics.getFont():getWidth(costText)
    love.graphics.setColor(canBuy and {1,1,0.8} or {0.6,0.6,0.5})
    love.graphics.print(costText, x + w - textWidth - 12 * Game.uiScale, y + h/2 - 10 * Game.uiScale)
end

function UI.getFormattedStat(statType)
    if statType == "gameSpeed" then
        return string.format("%.1fx", Game.state.speedMultiplier)
    end

    local value = Player[statType]
    if statType == "critChance" then return string.format("%.1f%%", value*100) end
    if statType == "defense" then return string.format("%d%%", value) end
    if statType == "regen" then return string.format("%.1f/s", value) end
    return string.format("%.1f", value)
end

function UI.drawWaveCounter()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Wave: " .. Waves.currentWave, Game.screen.width - 150, 10)
end

function UI.drawSpeedIndicator()
    love.graphics.print("Speed: " .. string.format("%.1fx", Game.state.speedMultiplier), 
        Game.screen.width - 150, 50)
end

-- Update the UI touch handler signature
function UI.handleTouch(x, y)
    -- Shop toggle
    if utils.pointInRect(x, y, UI.buttons.main) then
        Game.state.inShop = not Game.state.inShop
        return true
    end

    if Game.state.inShop then
        local shopW = Game.screen.width * 0.85
        local shopH = Game.screen.height * 0.75
        local shopX = (Game.screen.width - shopW) * 0.5
        local shopY = (Game.screen.height - shopH) * 0.5

        -- Close button
        local close = UI.buttons.close
        local closeX = shopX + shopW - close.size - 15 * Game.uiScale
        local closeY = shopY + 15 * Game.uiScale
        if utils.pointInRect(x, y, {x=closeX, y=closeY, width=close.size, height=close.size}) then
            Game.state.inShop = false
            return true
        end

        -- Upgrade buttons
        local btnWidth = shopW * 0.42
        local btnHeight = 80 * Game.uiScale
        local verticalSpacing = 15 * Game.uiScale
        local startY = shopY + 60 * Game.uiScale

        local columns = {
            {x = shopX + (shopW * 0.04), stats = {"attackDamage", "defense", "regen"}},
            {x = shopX + (shopW * 0.54), stats = {"attackSpeed", "critChance", "gameSpeed"}}
        }

        for _, col in ipairs(columns) do
            for i, stat in ipairs(col.stats) do
                local btnY = startY + ((i-1) * (btnHeight + verticalSpacing))
                if utils.pointInRect(x, y, {x=col.x, y=btnY, width=btnWidth, height=btnHeight}) then
                    if Player.gold >= Upgrades.stats[stat].currentCost then
                        Upgrades.purchaseStat(stat)
                    end
                    return true
                end
            end
        end
    end
    return false
end
