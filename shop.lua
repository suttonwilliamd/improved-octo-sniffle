Shop = {
    buttons = {
        main = {x = 20, y = 0, width = 100, height = 50},
        upgrade = {x = 0, y = 0, width = 200, height = 60}
    },
    colors = {
        background = {0.4, 0.4, 0.4},
        buttonActive = {0.3, 0.25, 0.3},
        buttonInactive = {0.15, 0.25, 0.3}
    }
}

function Shop.init()
    Shop.buttons.main.y = Game.screen.height - 70
end

function Shop.draw()
    -- Shop toggle button
    love.graphics.setColor(0.2, 0.2, 0.8)
    love.graphics.rectangle("fill",
        Shop.buttons.main.x,
        Shop.buttons.main.y,
        Shop.buttons.main.width,
        Shop.buttons.main.height
    )
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("SHOP", Shop.buttons.main.x + 10, Shop.buttons.main.y + 15)

    -- Permanent UI
    love.graphics.print("Gold: " .. Player.gold, 10, 10)
    love.graphics.print("Level: " .. Player.level, 10, 30)
    love.graphics.print("Health: " .. math.floor(Player.health) .. "/" .. Player.maxHealth, 10, 90)
    
    -- XP Bar
    local xpWidth = 200
    local xpPercent = Player.xp / Player.xpToNextLevel
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", 10, 50, xpWidth, 15)
    love.graphics.setColor(0.2, 0.6, 1)
    love.graphics.rectangle("fill", 10, 50, xpWidth * xpPercent, 15)

    -- Shop window
    if Game.state.inShop then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, Game.screen.width, Game.screen.height)
        
        local shopW = Game.screen.width * 0.8
        local shopH = Game.screen.height * 0.7
        love.graphics.setColor(Shop.colors.background)
        love.graphics.rectangle("fill", 
            (Game.screen.width - shopW)/2,
            (Game.screen.height - shopH)/2,
            shopW,
            shopH
        )

        -- Upgrade buttons in 2 columns
        local btnY = (Game.screen.height - shopH)/2 + 50
        local btnW = shopW * 0.45
        local btnH = 60
        local btnSpacing = 80
        
        -- Left Column
        Shop.drawUpgradeButton(
            "Damage +"..Upgrades.stats.attackDamage.base.." ("..Upgrades.stats.attackDamage.currentCost.."g)", 
            (Game.screen.width/2 - btnW) - 10, btnY, btnW, btnH, "attackDamage"
        )
        Shop.drawUpgradeButton(
            "Defense +"..Upgrades.stats.defense.base.."% ("..Upgrades.stats.defense.currentCost.."g)", 
            (Game.screen.width/2 - btnW) - 10, btnY + btnSpacing, btnW, btnH, "defense"
        )
        Shop.drawUpgradeButton(
            "Regen +"..Upgrades.stats.regen.base.."/s ("..Upgrades.stats.regen.currentCost.."g)", 
            (Game.screen.width/2 - btnW) - 10, btnY + btnSpacing*2, btnW, btnH, "regen"
        )
        
        -- Right Column
        Shop.drawUpgradeButton(
            "Speed +"..Upgrades.stats.attackSpeed.base.." ("..Upgrades.stats.attackSpeed.currentCost.."g)", 
            (Game.screen.width/2) + 10, btnY, btnW, btnH, "attackSpeed"
        )
        Shop.drawUpgradeButton(
            "Crit +"..(Upgrades.stats.critChance.base*100).."% ("..Upgrades.stats.critChance.currentCost.."g)", 
            (Game.screen.width/2) + 10, btnY + btnSpacing, btnW, btnH, "critChance"
        )
        
        -- Close button
        Shop.drawButton("Close Shop", (Game.screen.width - btnW*2)/2, btnY + btnSpacing*3, btnW*2 + 20, btnH)
    end
end

function Shop.drawUpgradeButton(text, x, y, w, h, statType)
    if not Upgrades.stats[statType] or not Player[statType] then
        print("WARNING: Missing upgrade or player stat for:", statType)
        return
    end

    local canBuy = Player.gold >= Upgrades.stats[statType].currentCost
    love.graphics.setColor(canBuy and Shop.colors.buttonActive or Shop.colors.buttonInactive)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(text, x + 20, y + 20)
    
    -- Current stat value
    local statValue = Player[statType]
    local currentValue = ""
    if statType == "critChance" then
        currentValue = math.floor(statValue * 100) .. "%"
    elseif statType == "defense" then
        currentValue = math.floor(statValue) .. "%"
    elseif statType == "regen" then
        currentValue = string.format("%.1f HP/s", statValue)
    else
        currentValue = math.floor(statValue * 10)/10
    end
    love.graphics.print("Current: " .. currentValue, x + 20, y + 40)
end

function Shop.drawButton(text, x, y, w, h)
    love.graphics.setColor(Shop.colors.buttonActive)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(text, x + 20, y + 20)
end

function Shop.handleTouch(id, x, y)
    local tx = x
    local ty = y
    
    if utils.pointInRect(tx, ty, Shop.buttons.main) then
        Game.state.inShop = not Game.state.inShop
        return true
    end

    if Game.state.inShop then
        local shopW = Game.screen.width * 0.8
        local shopH = Game.screen.height * 0.7
        local btnW = shopW * 0.45
        local btnH = 60
        local btnSpacing = 80
        local firstBtnY = (Game.screen.height - shopH)/2 + 50

        -- New grid-based touch detection
        local buttons = {
            {x = "left", y = 0, type = "attackDamage"},
            {x = "left", y = 1, type = "defense"},
            {x = "left", y = 2, type = "regen"},
            {x = "right", y = 0, type = "attackSpeed"},
            {x = "right", y = 1, type = "critChance"},
            {y = 3, type = "close"}
        }

        for _, btn in ipairs(buttons) do
            local btnX = (btn.x == "left") and (Game.screen.width/2 - btnW - 10) or
                       (btn.x == "right") and (Game.screen.width/2 + 10) or
                       (Game.screen.width - btnW*2)/2
            local btnYPos = firstBtnY + (btnSpacing * (btn.y or 0))
            
            if ty > btnYPos and ty < btnYPos + btnH and
               tx > btnX and tx < btnX + btnW
            then
                if btn.type == "close" then
                    Game.state.inShop = false
                else
                    Upgrades.purchaseStat(btn.type)
                end
                return true
            end
        end
    end
    return false
end