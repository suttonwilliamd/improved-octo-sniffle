function love.conf(t)
    t.window.title = "Incremental Rogue-like"
    t.version = "11.4" -- Add this line
    
    -- Keep existing settings
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = true
    t.modules.joystick = false
    t.modules.physics = false
    t.console = true
    
    -- Android specific
    if t.os then
        t.window.fullscreen = true
        t.window.highdpi = true
    end
end