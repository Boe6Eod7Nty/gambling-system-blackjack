SpotManager = { version = '1.0.0' }
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

local Cron = require('External/Cron.lua')
local world = require('External/worldInteraction.lua')
local GameUI = require("External/GameUI.lua")
local interactionUI = require("External/interactionUI.lua")

local inMenu = true --libaries requirement
local inGame = false
local SpotManager = {
    spots = {}
}

--Register Events (passed from parent)
--===============
function SpotManager.init() --runs on game launch
    interactionUI.init()

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

end
function SpotManager.update(dt) --runs every frame
    if  not inMenu and inGame then
        Cron.Update(dt) -- This is required for Cron to function
        world.update()
        interactionUI.update()
    end
end


--Methods
--=======
function SpotManager.ExitSpot(id) --Exit spot
    local spot = SpotManager.spots[id]
    SpotManager.ChangeAnimation(spot.animObj.exitAnim, spot.animObj.exitTime + 3, spot.animObj.defaultAnim)
    Cron.After(spot.animObj.exitTime, function() -- Wait for animation to finish
        local player = Game.GetPlayer()
        local playerTransform = player:GetWorldTransform()
        local position = playerTransform:GetWorldPosition()
        local x = position:GetX() + 0.5
        local y = position:GetY()
        local z = position:GetZ()
        local o = spot.animObj.orientation
        Game.GetTeleportationFacility():Teleport(player, Vector4.new(x, y, z, 1), EulerAngles.new(o.x,o.y,o.z+150))

        local workspotSystem = Game.GetWorkspotSystem()
        workspotSystem:SendFastExitSignal(player)

        spot.active = false
    end)
end
function SpotManager.AddSpot(id, worldPinUI, animObj) --Create spot
    SpotManager.spots[id] = {active = false, startTriggered = false, worldPinUI = worldPinUI, animObj = animObj}
    world.addInteraction(id, worldPinUI.position, 1.0, 80, "ChoiceIcons.SitIcon", 6.5, 0.5, nil, function(state)
                    --  (id, position, interactionRange, angle, icon, iconRange, iconRangeMin, iconColor, callback)
        if state then -- Show
            local UIcallback = function()
                DualPrint('Callback SM executed')
                AnimateEnteringSpot(animObj)
                SpotManager.spots[id].active = true
            end
            BasicInteractionUIPrompt("Blackjack", "Join Table", "ChoiceCaptionParts.SitIcon", gameinteractionsChoiceType.QuestImportant, UIcallback) --Display interactionUI menu
        else -- Hide
            interactionUI.hideHub()
        end
    end)
end
function SpotManager.ChangeAnimation(animName, duration, returnAnimName)
    local player = Game.GetPlayer()
    local workspotSystem = Game.GetWorkspotSystem()
    workspotSystem:SendJumpToAnimEnt(player, animName, true)
    Cron.After(duration, function()
        workspotSystem:SendJumpToAnimEnt(player, returnAnimName, true)
    end)
end

--Functions
--=========
function DualPrint(string) --prints to both CET console and local .log file
    if not string then return end
    print('[Gambling System] ' .. string) -- CET console
    spdlog.error('[Gambling System] ' .. string) -- .log
end
function BasicInteractionUIPrompt(hubText, choiceText, icon, choiceType, callback) --Display interactionUI menu
    local choice = interactionUI.createChoice(choiceText, TweakDBInterface.GetChoiceCaptionIconPartRecord(icon), choiceType)
    local hub = interactionUI.createHub(hubText, {choice})
    interactionUI.setupHub(hub)
    interactionUI.showHub()
    interactionUI.callbacks[1] = function()
        interactionUI.hideHub()
        callback()
    end
end
function AnimateEnteringSpot(animObj) --Triggers workspot animation
    local player = Game.GetPlayer()
    local dynamicEntitySystem = Game.GetDynamicEntitySystem()
    local workspotSystem = Game.GetWorkspotSystem()
    local spec = DynamicEntitySpec.new()
    spec.templatePath = animObj.templatePath
    spec.position = animObj.position
    local o = animObj.orientation
    spec.orientation = EulerAngles.new(o.x,o.y,o.z):ToQuat()
    spec.tags = {"SpotManager"} --note; I don't know if this needs to be a unique value or what exactly
    -- Spawn entity
    local entID = dynamicEntitySystem:CreateEntity(spec)
    animObj.entID = entID

    callback = function()
        local entity = Game.FindEntityByID(entID)
        workspotSystem:PlayInDevice(entity, player) --Play workspot
    end
    Cron.After(1, callback)
end

return SpotManager