UI = {
    buttons = {},
    colors = {
        background = {0.15, 0.15, 0.2, 0.95},
        buttonActive = {0.3, 0.5, 0.4},
        buttonInactive = {0.2, 0.2, 0.25},
        textActive = {0.9, 0.9, 0.9},
        textInactive = {0.6, 0.6, 0.6}
    },
    fonts = {}
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
        },
        -- Initialize death screen button positions
        death = {
            rebirth = {x = 0, y = 0, width = 180, height = 50},
            restart = {x = 0, y = 0, width = 180, height = 50}
        }
    }

    UI.fonts = {
        small = love.graphics.newFont(14 * Game.fontScale),
        medium = love.graphics.newFont(20 * Game.fontScale),
        large = love.graphics.newFont(24 * Game.fontScale),
        xlarge = love.graphics.newFont(72 * Game.fontScale)
    }
    
    
    UI.buttons.shop = {
        width_ratio = 0.85,   -- % of screen width
        height_ratio = 0.75,  -- % of screen height
        padding = 20,         -- base padding in pixels
        btn_width_ratio = 0.21, -- % of shop width
        btn_height = 90,      -- base button height
        column_count = 4,
        columns = {}
    }
    
end

function UI.draw()
    -- Draw different UI states with proper layering
    if Game.state.showDeathScreen then
        UI.drawDeathScreen()
    elseif Game.state.showRebirthScreen then
        UI.drawRebirthScreen()
    else
        UI.drawPersistentUI()
        if Game.state.inShop then
            UI.drawShop()
        else
            UI.drawGameHUD()
        end
    end
end

function UI.drawPersistentUI()
    -- Always visible elements
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(UI.fonts.medium)
    love.graphics.print("Gold: " .. string.format("%d", Player.gold, 10, 10))
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
    love.graphics.printf("SHOP", btn.x, btn.y + btn.height/4, btn.width, "center", 0, Game.fontScale * 2)
end

function UI.drawGameHUD()
    -- Only drawn during normal gameplay
    UI.drawPlayerHealth()
    UI.drawWaveCounter()
    UI.drawSpeedIndicator()
end

function UI.drawPlayerHealth()
    local barWidth = 200 * Game.uiScale
    local barHeight = 20 * Game.uiScale
    local posX = 10 * Game.uiScale
    local posY = 100 * Game.uiScale

    love.graphics.setColor(0.3, 0, 0)
    love.graphics.rectangle("fill", posX, posY, barWidth, barHeight)
    
    local healthWidth = (Player.health / Player.maxHealth) * barWidth
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.rectangle("fill", posX, posY, healthWidth, barHeight)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(UI.fonts.small)
    love.graphics.print(string.format("Health: %d/%d", math.floor(Player.health), Player.maxHealth), 
        posX + 5 * Game.uiScale, posY + 3 * Game.uiScale)
end

function UI.drawDeathScreen()
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 0, 0, Game.screen.width, Game.screen.height)
    
    -- Main death text
    love.graphics.setColor(1, 0, 0)
    love.graphics.setFont(UI.fonts.xlarge)
    local textY = Game.screen.height/2 - UI.fonts.xlarge:getHeight() * 2
    love.graphics.printf("YOU DIED", 0, textY, Game.screen.width, "center")
    
    -- Stats panel
    love.graphics.setColor(0.2, 0.2, 0.3, 0.9)
    local panelW = 400 * Game.uiScale
    local panelH = 250 * Game.uiScale
    utils.drawRoundedRect({
        x = (Game.screen.width - panelW)/2,
        y = textY + 100 * Game.uiScale,
        width = panelW,
        height = panelH
    }, 15 * Game.uiScale)
    
    -- Stats text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(UI.fonts.large)
    local statsText = string.format(
        "Wave: %d\nGold: %d\nSouls Gained: %d\nTotal Souls: %d",
        Waves.currentWave,
        Player.gold,
        Rebirth.calculateSoulGain(),
        Rebirth.souls
    )
    love.graphics.printf(statsText, 0, textY + 120 * Game.uiScale, Game.screen.width, "center")
    
    -- Buttons
    local btnY = textY + panelH + 50 * Game.uiScale
    local btnWidth = 180 * Game.uiScale
    local btnHeight = 50 * Game.uiScale
    
    -- Update and draw rebirth chamber button
    UI.buttons.death.rebirth.x = (Game.screen.width/2 - btnWidth - 10 * Game.uiScale)
    UI.buttons.death.rebirth.y = btnY
    UI.drawDeathButton("Rebirth Chamber", "rebirth", 
        UI.buttons.death.rebirth.x, 
        UI.buttons.death.rebirth.y, 
        btnWidth)

    -- Update and draw new run button
    UI.buttons.death.restart.x = (Game.screen.width/2 + 10 * Game.uiScale)
    UI.buttons.death.restart.y = btnY
    UI.drawDeathButton("New Run", "restart", 
        UI.buttons.death.restart.x, 
        UI.buttons.death.restart.y, 
        btnWidth)
end



function UI.drawDeathButton(text, action, x, y, width)
    local isHovered = utils.pointInRect(love.mouse.getX(), love.mouse.getY(), {x=x, y=y, width=width, height=50 * Game.uiScale})
    
    love.graphics.setColor(isHovered and {0.4, 0.2, 0.6} or {0.3, 0.15, 0.45})
    utils.drawRoundedRect({
        x = x,
        y = y,
        width = width,
        height = 50 * Game.uiScale
    }, 8 * Game.uiScale)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(UI.fonts.medium)
    love.graphics.printf(text, x, y + 15 * Game.uiScale, width, "center")
end

function UI.drawShop()
    -- Update shop layout calculations first
    UI.updateShopLayout()
    local s = UI.buttons.shop
    
    -- Dark background overlay
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 0, 0, Game.screen.width, Game.screen.height)
    
    -- Shop background panel
    love.graphics.setColor(UI.colors.background)
    utils.drawRoundedRect({
        x = s.x,
        y = s.y,
        width = s.w,
        height = s.h
    }, 12 * Game.uiScale)
    
    -- Header text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(UI.fonts.large)
    love.graphics.printf("UPGRADES", s.x, s.y + 20 * Game.uiScale, s.w, "center")

    -- Close button
    local closeSize = UI.buttons.close.size
    local closeX = s.x + s.w - closeSize - 15 * Game.uiScale
    local closeY = s.y + 15 * Game.uiScale
    love.graphics.setColor(0.8, 0.2, 0.2)
    utils.drawRoundedRect({
        x = closeX,
        y = closeY,
        width = closeSize,
        height = closeSize
    }, 6 * Game.uiScale)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("×", closeX, closeY + closeSize/4, closeSize, "center")

    -- Draw upgrade buttons using centralized columns
    local buttonY = s.start_y
    local rowSpacing = s.btn_height_scaled + 15 * Game.uiScale
    
    -- Column 1: Core Stats
    UI.drawUpgradeButton("Damage", "attackDamage", s.columns[1], buttonY, s.btn_width, s.btn_height_scaled)
    UI.drawUpgradeButton("Defense", "defense", s.columns[1], buttonY + rowSpacing, s.btn_width, s.btn_height_scaled)

    -- Column 2: Special Abilities
    UI.drawUpgradeButton("Area Damage", "areaDamage", s.columns[2], buttonY, s.btn_width, s.btn_height_scaled)
    UI.drawUpgradeButton("Life Steal", "lifeSteal", s.columns[2], buttonY + rowSpacing, s.btn_width, s.btn_height_scaled)

    -- Column 3: Utility
    UI.drawUpgradeButton("Atk Speed", "attackSpeed", s.columns[3], buttonY, s.btn_width, s.btn_height_scaled)
    UI.drawUpgradeButton("Game Speed", "gameSpeed", s.columns[3], buttonY + rowSpacing, s.btn_width, s.btn_height_scaled)

    -- Column 4: Defensive
    UI.drawUpgradeButton("Regeneration", "regen", s.columns[4], buttonY, s.btn_width, s.btn_height_scaled)
    UI.drawUpgradeButton("Thorns", "thorns", s.columns[4], buttonY + rowSpacing, s.btn_width, s.btn_height_scaled)

    -- Footer: Souls display
    love.graphics.setColor(0.8, 0.6, 1)
    love.graphics.setFont(UI.fonts.medium)
    love.graphics.printf("Souls: " .. Rebirth.souls, s.x, s.y + s.h - 50 * Game.uiScale, s.w, "center")
end

function UI.drawUpgradeButton(title, statType, x, y, w, h)
    local stat = Upgrades.stats[statType] or {}  -- Handle missing stat
    local canBuy = Player.gold >= (stat.currentCost or 0)  -- Default to 0
    
    love.graphics.setColor(canBuy and UI.colors.buttonActive or UI.colors.buttonInactive)
    utils.drawRoundedRect({
        x = x,
        y = y,
        width = w,
        height = h
    }, 8 * Game.uiScale)

    love.graphics.setColor(canBuy and UI.colors.textActive or UI.colors.textInactive)
    love.graphics.setFont(UI.fonts.medium)
    love.graphics.print(title, x + 12 * Game.uiScale, y + 8 * Game.uiScale)

    love.graphics.setFont(UI.fonts.small)
    local current = UI.getFormattedStat(statType)
    love.graphics.print(current, x + 12 * Game.uiScale, y + h - 24 * Game.uiScale)

    love.graphics.setFont(UI.fonts.medium)
    local costText = (stat.currentCost or 0) .. "g"  -- Ensure costText is never nil
    local textWidth = love.graphics.getFont():getWidth(costText)
    love.graphics.setColor(canBuy and {1,1,0.8} or {0.6,0.6,0.5})
    love.graphics.print(costText, x + w - textWidth - 12 * Game.uiScale, y + h/2 - 10 * Game.uiScale)
end

function UI.getFormattedStat(statType)
    if statType == "gameSpeed" then
        return string.format("%.2fx", Game.state.speedMultiplier)
    end

    local value = Player[statType]
    if statType == "critChance" then
        return string.format("%.1f%%", value * 100)
    elseif statType == "defense" then
        return string.format("%d%%", value)
    elseif statType == "regen" then
        return string.format("%.1f/s", value)
    elseif statType == "areaDamage" then
        return string.format("%.1f%%", value * 100)
    elseif statType == "lifeSteal" then
        return string.format("%.1f%%", value * 100)
    elseif statType == "thorns" then
        return string.format("%.1f%%", value * 100)
    else
        return string.format("%.1f", value)
    end
end

function UI.drawWaveCounter()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(UI.fonts.medium)
    love.graphics.print("Wave: " .. Waves.currentWave, Game.screen.width - 150 * Game.uiScale, 10 * Game.uiScale)
end

function UI.drawSpeedIndicator()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(UI.fonts.medium)
    love.graphics.print("Speed: " .. string.format("%.2fx", Game.state.speedMultiplier), 
        Game.screen.width - 150 * Game.uiScale, 50 * Game.uiScale)
end


function UI.drawRebirthScreen()
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", 0, 0, Game.screen.width, Game.screen.height)
    
    local rebirthW = Game.screen.width * 0.9
    local rebirthH = Game.screen.height * 0.8
    local rebirthX = (Game.screen.width - rebirthW) * 0.5
    local rebirthY = (Game.screen.height - rebirthH) * 0.5

    -- Header
    love.graphics.setColor(0.8, 0.4, 0.8)
    love.graphics.setFont(UI.fonts.xlarge)
    love.graphics.printf("Rebirth Chamber", rebirthX, rebirthY + 20, rebirthW, "center")
    
    -- Souls Display
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(UI.fonts.large)
    love.graphics.printf("Souls: " .. Rebirth.souls, rebirthX, rebirthY + 80, rebirthW, "center")

    -- Upgrade Buttons
    local btnWidth = rebirthW * 0.4
    local btnHeight = 100 * Game.uiScale
    local startY = rebirthY + 150 * Game.uiScale
    
    for i, upgrade in ipairs(Rebirth.upgrades) do
        local col = (i-1) % 2
        local row = math.floor((i-1)/2)
        UI.drawRebirthUpgrade(
            upgrade,
            rebirthX + 20 + (col * (btnWidth + 20)),
            startY + (row * (btnHeight + 20)),
            btnWidth,
            btnHeight
        )
    end
    
    
    local closeSize = UI.buttons.close.size
    local closeX = rebirthX + rebirthW - closeSize - 15 * Game.uiScale
    local closeY = rebirthY + 15 * Game.uiScale
    love.graphics.setColor(0.8, 0.2, 0.2)
    utils.drawRoundedRect({
        x = closeX,
        y = closeY,
        width = closeSize,
        height = closeSize
    }, 6 * Game.uiScale)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("×", closeX, closeY + closeSize/4, closeSize, "center")
end

function UI.drawRebirthUpgrade(upgrade, x, y, w, h)
    local canAfford = Rebirth.souls >= upgrade.cost
    love.graphics.setColor(canAfford and {0.3, 0.2, 0.4} or {0.15, 0.15, 0.2})
    utils.drawRoundedRect({x=x, y=y, width=w, height=h}, 10)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(UI.fonts.medium)
    love.graphics.printf(upgrade.name, x+10, y+10, w-20, "left")
    
    love.graphics.setFont(UI.fonts.small)
    love.graphics.printf(upgrade.description, x+10, y+40, w-20, "left")
    
    love.graphics.setColor(0.8, 0.8, 0)
    love.graphics.printf("Cost: " .. upgrade.cost .. " Souls", x+10, y+h-30, w-20, "left")
end

function UI.updateShopLayout()
    local s = UI.buttons.shop
    
    -- Calculate core dimensions
    s.w = Game.screen.width * s.width_ratio
    s.h = Game.screen.height * s.height_ratio
    s.x = (Game.screen.width - s.w) * 0.5
    s.y = (Game.screen.height - s.h) * 0.5
    
    -- Button dimensions
    s.btn_width = s.w * s.btn_width_ratio
    s.btn_height_scaled = s.btn_height * Game.uiScale
    s.start_y = s.y + 80 * Game.uiScale
    
    -- Column spacing
    s.column_spacing = s.btn_width + (s.padding * 2 * Game.uiScale)
    
    -- Calculate column positions
    s.columns = {}
    local base_x = s.x + s.padding * Game.uiScale
    for i=1,s.column_count do
        s.columns[i] = base_x + ((i-1) * s.column_spacing)
    end
end

function UI.handleTouch(x, y)
    if Game.state.showDeathScreen then
        -- Death screen buttons
        if utils.pointInRect(x, y, {
            x = UI.buttons.death.rebirth.x,
            y = UI.buttons.death.rebirth.y,
            width = 180 * Game.uiScale,
            height = 50 * Game.uiScale
        }) then
            Game.state.showDeathScreen = false
            Game.state.showRebirthScreen = true
            return true
        end

        if utils.pointInRect(x, y, {
            x = UI.buttons.death.restart.x,
            y = UI.buttons.death.restart.y,
            width = 180 * Game.uiScale,
            height = 50 * Game.uiScale
        }) then
            Game.state.showDeathScreen = false
            Waves.reset()
            Player.reset()
            return true
        end
        return true
        
    elseif Game.state.showRebirthScreen then
        -- Rebirth screen close button
        local rebirthW = Game.screen.width * 0.9
        local rebirthH = Game.screen.height * 0.8
        local rebirthX = (Game.screen.width - rebirthW) * 0.5
        local rebirthY = (Game.screen.height - rebirthH) * 0.5
        
        local closeX = rebirthX + rebirthW - UI.buttons.close.size - 15 * Game.uiScale
        local closeY = rebirthY + 15 * Game.uiScale
        if utils.pointInRect(x, y, {
            x = closeX,
            y = closeY,
            width = UI.buttons.close.size,
            height = UI.buttons.close.size
        }) then
            Game.state.showRebirthScreen = false
            Game.state.showDeathScreen = true
            return true
        end

        -- Rebirth upgrade buttons
        local btnWidth = rebirthW * 0.4
        local btnHeight = 100 * Game.uiScale
        local startY = rebirthY + 150 * Game.uiScale

        for i, upgrade in ipairs(Rebirth.upgrades) do
            local col = (i-1) % 2
            local row = math.floor((i-1)/2)
            local btnX = rebirthX + 20 + (col * (btnWidth + 20))
            local btnY = startY + (row * (btnHeight + 20))

            if utils.pointInRect(x, y, {
                x = btnX,
                y = btnY,
                width = btnWidth,
                height = btnHeight
            }) and Rebirth.souls >= upgrade.cost then
                Rebirth.purchaseUpgrade(upgrade)
                return true
            end
        end
        return true

    elseif Game.state.inShop then
        -- Shop close button
        local s = UI.buttons.shop
        UI.updateShopLayout()
        local closeX = s.x + s.w - UI.buttons.close.size - 15 * Game.uiScale
        local closeY = s.y + 15 * Game.uiScale
        if utils.pointInRect(x, y, {
            x = closeX,
            y = closeY,
            width = UI.buttons.close.size,
            height = UI.buttons.close.size
        }) then
            Game.state.inShop = false
            return true
        end

        -- Shop upgrade buttons
        local baseY = s.start_y
        local rowSpacing = s.btn_height_scaled + 15 * Game.uiScale
        
        -- Column check helper
        local function checkColumn(col, yPos, stat)
            return utils.pointInRect(x, y, {
                x = s.columns[col],
                y = yPos,
                width = s.btn_width,
                height = s.btn_height_scaled
            }) and Player.gold >= (Upgrades.stats[stat].currentCost or 0)
        end

        -- Check all columns
        if checkColumn(1, baseY, "attackDamage") then Upgrades.purchaseStat("attackDamage") return true end
        if checkColumn(1, baseY + rowSpacing, "defense") then Upgrades.purchaseStat("defense") return true end
        if checkColumn(2, baseY, "areaDamage") then Upgrades.purchaseStat("areaDamage") return true end
        if checkColumn(2, baseY + rowSpacing, "lifeSteal") then Upgrades.purchaseStat("lifeSteal") return true end
        if checkColumn(3, baseY, "attackSpeed") then Upgrades.purchaseStat("attackSpeed") return true end
        if checkColumn(3, baseY + rowSpacing, "gameSpeed") then Upgrades.purchaseStat("gameSpeed") return true end
        if checkColumn(4, baseY, "regen") then Upgrades.purchaseStat("regen") return true end
        if checkColumn(4, baseY + rowSpacing, "thorns") then Upgrades.purchaseStat("thorns") return true end

    else
        -- Regular gameplay click handling
        if utils.pointInRect(x, y, UI.buttons.main) then
            Game.state.inShop = true
            return true
        end

        -- Target selection
        local searchRadius = 100 * Game.scale
        local closestEnemy = nil
        local closestDistance = searchRadius
        
        for _, e in ipairs(Game.state.enemies) do
            local dist = utils.distance(x, y, e.x, e.y)
            if dist < closestDistance then
                closestDistance = dist
                closestEnemy = e
            end
        end

        if closestEnemy then
            Player.target = closestEnemy
            Effects.spawnTargetIndicator(closestEnemy.x, closestEnemy.y)
            return true
        end
    end
    
    return false
end