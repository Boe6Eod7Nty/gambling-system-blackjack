--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================
SpotManager = { version = '1.0.0' }

local Cron = require('External/Cron.lua')
local world = require('External/worldInteraction.lua')
local GameUI = require("External/GameUI.lua")

local inMenu = true --libaries requirement
local inGame = false


--Register Events (passed from parent)
--===============
function SpotManager.init()

    Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu) -- Setup observer and GameUI to detect inGame / inMenu, credit: keanuwheeze | init.lua from the sitAnywhere mod
        inMenu = isInMenu
    end)

    inGame = false          --Setup observer and GameUI to detect inGame / inMenu
    GameUI.OnSessionStart(function() --  credit: keanuwheeze | init.lua from the sitAnywhere mod
        inGame = true
        world.onSessionStart()
    end)
    GameUI.OnSessionEnd(function()
        inGame = false
    end)
    inGame = not GameUI.IsDetached() -- Required to check if ingame after reloading all mods

    world.init()

    world.addInteraction('demofirst', Vector4.new(-1041.2463, 1341.5469, 6.21331358, 1), 1.0, 80, "ChoiceIcons.SitIcon", 6.5, 0.5, nil, function(state)
        --  (id, position, interactionRange, angle, icon, iconRange, iconRangeMin, iconColor, callback)
        if state then -- Show
            DualPrint('Show')
        else -- Hide
            DualPrint('Hide')
        end
    end)
end
function SpotManager.update() --runs every frame
    if  not inMenu and inGame then
        Cron.Update(dt) -- This is required for Cron to function
        world.update()
    end
end


--Methods
--=======
function SpotManager.Animate()
    local player = Game.GetPlayer()
    local playerTransform = player:GetWorldTransform()
    local dynamicEntitySystem = Game.GetDynamicEntitySystem()
    local workspotSystem = Game.GetWorkspotSystem()
    -- Create entity spec
    DualPrint('vars created')
    local spec = DynamicEntitySpec.new()
    spec.templatePath = "boe6\\GamblingSystemBlackjack\\workspot_anim.ent"
    --local xyzw = playerTransform:GetWorldPosition()
    local newX = -1041.2463
    local newY = 1341.5469
    local newZ = 5.2774734
    spec.position = Vector4.new(newX, newY, newZ, 1)
    local quat = EulerAngles.new(0,0,0):ToQuat()
    spec.orientation = quat
    --spec.orientation = playerTransform:GetOrientation()
    spec.tags = {"SpotManager"}
    DualPrint('spec created')
    -- Spawn entity
    local entID = dynamicEntitySystem:CreateEntity(spec)
    DualPrint('entity spawned')

    callback1 = function()
        local entity = Game.FindEntityByID(entID)
        DualPrint('entity found')
        -- Play workspot
        workspotSystem:PlayInDevice(entity, player)
        DualPrint('workspot played')
        -- Start animation
        --workspotSystem:SendJumpToAnimEnt(player, "sit_chair_table_lean0__2h_on_table__01", true)
    end
    Cron.After(1, callback1)


    DualPrint('Animation started')
end
function SpotManager.ExitAnim()
    local workspotSystem = Game.GetWorkspotSystem()
    workspotSystem:SendFastExitSignal(Game.GetPlayer())
    DualPrint('SendFastExitSignal')
end
function SpotManager.workspotUI()
    
end

--Functions
--=========
function DualPrint(string) --prints to both CET console and local .log file
    if not string then return end
    print('[Gambling System] ' .. string) -- CET console
    spdlog.error('[Gambling System] ' .. string) -- .log
end

return SpotManager