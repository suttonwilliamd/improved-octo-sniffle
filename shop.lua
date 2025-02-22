Shop = {
    colors = {
        background = {0.15, 0.15, 0.2, 0.95},
        buttonActive = {0.3, 0.5, 0.4},
        buttonInactive = {0.2, 0.2, 0.25},
        textActive = {0.9, 0.9, 0.9},
        textInactive = {0.6, 0.6, 0.6}
    }
}

function Shop.init()
    -- Adaptive scaling with better breakpoints
    local baseWidth = 1440  -- Higher reference width for better scaling
    Game.uiScale = math.min(
        math.max(Game.screen.width / baseWidth, 0.65),  -- More conservative minimum
        1.0  -- Never exceed 100% scale
    )
    
    -- Separate font scale for better text control
    Game.fontScale = Game.uiScale * 0.9  -- 10% smaller than UI elements
    
    Shop.buttons = {
        main = {
            x = 0.02 * Game.screen.width,
            y = 0.85 * Game.screen.height,
            width = 0.2 * Game.screen.width,
            height = 0.08 * Game.screen.height
        }
    }
end

function Shop.draw()
    -- Permanent UI with font scaling
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(18 * Game.fontScale)
    love.graphics.print("Gold: " .. Player.gold, 10, 10)
    love.graphics.print("Lv." .. Player.level, 10, 30 * Game.fontScale)

    -- XP Bar (size relative to font scale)
    local xpHeight = 6 * Game.fontScale
    local xpWidth = 0.3 * Game.screen.width
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", 10, 50 * Game.fontScale, xpWidth, xpHeight)
    love.graphics.setColor(0.2, 0.6, 1)
    love.graphics.rectangle("fill", 10, 50 * Game.fontScale, xpWidth * (Player.xp/Player.xpToNextLevel), xpHeight)

    -- Shop toggle button
    local btn = Shop.buttons.main
    love.graphics.setColor(0.3, 0.4, 0.6)
    love.graphics.rectangle("fill", btn.x, btn.y, btn.width, btn.height, 5 * Game.uiScale)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("SHOP", btn.x, btn.y + btn.height/4, btn.width, "center", 0, Game.fontScale * 0.9)

    -- Shop window
    if Game.state.inShop then
        love.graphics.setColor(0, 0, 0, 0.85)
        love.graphics.rectangle("fill", 0, 0, Game.screen.width, Game.screen.height)
        
        local shopW = Game.screen.width * 0.85
        local shopH = Game.screen.height * 0.75
        local shopX = (Game.screen.width - shopW) * 0.5
        local shopY = (Game.screen.height - shopH) * 0.5
        
        -- Window background
        love.graphics.setColor(Shop.colors.background)
        love.graphics.rectangle("fill", shopX, shopY, shopW, shopH, 12 * Game.uiScale)
        love.graphics.setColor(0.3, 0.3, 0.4)
        love.graphics.rectangle("line", shopX, shopY, shopW, shopH, 12 * Game.uiScale)

        -- Title with separate scaling
        love.graphics.setColor(1, 1, 1)
        love.graphics.setNewFont(24 * Game.fontScale)  -- Reduced base size
        love.graphics.printf("UPGRADES", shopX, shopY + 20 * Game.fontScale, shopW, "center")

        -- Close button
        local closeSize = 40 * Game.uiScale
        local closeX = shopX + shopW - closeSize - 15 * Game.uiScale
        local closeY = shopY + 15 * Game.uiScale
        
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.rectangle("fill", closeX, closeY, closeSize, closeSize, 6 * Game.uiScale)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setNewFont(28 * Game.fontScale)  -- Smaller X symbol
        love.graphics.printf("×", closeX, closeY + closeSize/4, closeSize, "center")

        -- Upgrade grid
        local btnWidth = shopW * 0.42
        local btnHeight = 80 * Game.uiScale  -- Reduced button height
        local verticalSpacing = 15 * Game.uiScale
        local startY = shopY + 60 * Game.uiScale

        -- Left Column
        Shop.drawUpgradeCompact("Damage", "attackDamage", shopX + shopW*0.04, startY, btnWidth, btnHeight)
        Shop.drawUpgradeCompact("Defense", "defense", shopX + shopW*0.04, startY + (btnHeight + verticalSpacing), btnWidth, btnHeight)
        Shop.drawUpgradeCompact("Regen", "regen", shopX + shopW*0.04, startY + 2*(btnHeight + verticalSpacing), btnWidth, btnHeight)

        -- Right Column
        Shop.drawUpgradeCompact("Atk Speed", "attackSpeed", shopX + shopW*0.54, startY, btnWidth, btnHeight)
        Shop.drawUpgradeCompact("Crit %", "critChance", shopX + shopW*0.54, startY + (btnHeight + verticalSpacing), btnWidth, btnHeight)
        Shop.drawUpgradeCompact("Game Speed", "gameSpeed", shopX + shopW*0.54, startY + 2*(btnHeight + verticalSpacing), btnWidth, btnHeight)


    end
end

function Shop.drawUpgradeCompact(title, statType, x, y, w, h)
    local stat = Upgrades.stats[statType]
    local canBuy = Player.gold >= stat.currentCost
    
    -- Button background
    love.graphics.setColor(canBuy and Shop.colors.buttonActive or Shop.colors.buttonInactive)
    love.graphics.rectangle("fill", x, y, w, h, 8 * Game.uiScale)
    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.rectangle("line", x, y, w, h, 8 * Game.uiScale)

    -- Text elements
    love.graphics.setColor(canBuy and Shop.colors.textActive or Shop.colors.textInactive)
    
    -- Title
    love.graphics.setNewFont(18 * Game.fontScale)  -- Reduced from 28
    love.graphics.print(title, x + 12 * Game.uiScale, y + 8 * Game.uiScale)

    -- Current value
    love.graphics.setColor(canBuy and {0.9,0.9,0.9} or {0.7,0.7,0.7})
    love.graphics.setNewFont(14 * Game.fontScale)  -- Reduced from 18
    local current = Shop.getFormattedStat(statType)
    love.graphics.print(current, x + 12 * Game.uiScale, y + h - 24 * Game.uiScale)

    -- Cost
    love.graphics.setNewFont(16 * Game.fontScale)  -- Reduced from 24
    local costText = stat.currentCost .. "g"
    local textWidth = love.graphics.getFont():getWidth(costText)
    love.graphics.setColor(canBuy and {1,1,0.8} or {0.6,0.6,0.5})
    love.graphics.print(costText, x + w - textWidth - 12 * Game.uiScale, y + h/2 - 10 * Game.uiScale)
end

-- Rest of the file remains unchanged

function Shop.getFormattedStat(statType)
    -- Handle game speed special case
    if statType == "gameSpeed" then
        return string.format("%.1fx", Game.state.speedMultiplier)
    end

    local value = Player[statType]
    if statType == "critChance" then return string.format("%.1f%%", value*100) end
    if statType == "defense" then return string.format("%d%%", value) end
    if statType == "regen" then return string.format("%.1f/s", value) end
    return string.format("%.1f", value)
end

function Shop.handleTouch(id, x, y)
    -- Shop toggle
    if utils.pointInRect(x, y, Shop.buttons.main) then
        Game.state.inShop = not Game.state.inShop
        return true
    end

    if Game.state.inShop then
        local shopW = Game.screen.width * 0.85
        local shopH = Game.screen.height * 0.75
        local shopX = (Game.screen.width - shopW) * 0.5
        local shopY = (Game.screen.height - shopH) * 0.5

        -- Close button (exact match with draw code)
        local closeSize = 40 * Game.uiScale
        local closeX = shopX + shopW - closeSize - 15 * Game.uiScale
        local closeY = shopY + 15 * Game.uiScale
        if utils.pointInRect(x, y, {x=closeX, y=closeY, width=closeSize, height=closeSize}) then
            Game.state.inShop = false
            return true
        end

        -- Upgrade buttons (identical to visual calculations)
        local btnWidth = shopW * 0.42
        local btnHeight = 80 * Game.uiScale
        local verticalSpacing = 15 * Game.uiScale
        local startY = shopY + 60 * Game.uiScale  -- Matches draw code's Y start

        -- Column definitions (mirroring draw positions)
        local columns = {
            {x = shopX + (shopW * 0.04), stats = {"attackDamage", "defense", "regen"}},
            {x = shopX + (shopW * 0.54), stats = {"attackSpeed", "critChance", "gameSpeed"}}
        }

        for _, col in ipairs(columns) do
            for i, stat in ipairs(col.stats) do
                -- Calculate button Y position identically to draw logic
                local btnY = startY + ((i-1) * (btnHeight + verticalSpacing))
                
                -- Check touch boundaries (exact match with rendered button)
                if x > col.x and x < col.x + btnWidth and
                   y > btnY and y < btnY + btnHeight 
                then
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
