-- v1.0.0
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================
--REQUIREMENTS:
--RED4ext   
--Cyber Engine Tweaks
--Codeware
--TweakXL   ?
--ArchiveXL ?
--===================

--Modules
--=======
local Cron = require('External/Cron.lua') --Time handling
local SpotManager = require('SpotManager.lua') --workspot management



GamblingSystemBlackjack = {
    loaded = false,
    ready = false
}

-- Register Events
--================
registerForEvent( "onInit", function() 
    SpotManager.init()
end)
registerForEvent('onUpdate', function(dt)
    Cron.Update(dt)
    SpotManager.update()
end)
registerHotkey('DevHotkey1', 'Dev Hotkey 1', function()
    DualPrint('||=1  Dev hotkey 1 Pressed =')

    SpotManager.Animate()
end)
registerHotkey('DevHotkey2', 'Dev Hotkey 2', function()
    DualPrint('||=2  Dev hotkey 2 Pressed =')

    SpotManager.ExitAnim()
end)
registerHotkey('DevHotkey3', 'Dev Hotkey 3', function()
    DualPrint('||=3  Dev hotkey 3 Pressed =')

    SpotManager.workspotUI()
end)





--Methods
--=======


--Functions
--=========
function DualPrint(string) --prints to both CET console and local .log file
    if not string then return end
    print('[Gambling System] ' .. string) -- CET console
    spdlog.error('[Gambling System] ' .. string) -- .log
end

--End of File
--===========
return GamblingSystemBlackjack