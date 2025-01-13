SpotManager = {
    version = '1.0.0',
    spots = {}
}
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
local forcedCam = false
local forcedCamOri = {r=0,p=-60,y=0}
local localPlayer

--Functions
--=========
--- Display Basic UI interaction prompt
---@param hubText string "hub" text, left side
---@param choiceText string option text, right side
---@param icon string UI icon tweak record
---@param choiceType string gameinteractionsChoiceType
---@param callback function callback when UI is selected
local function basicInteractionUIPrompt(hubText, choiceText, icon, choiceType, callback) --Display interactionUI menu
    local choice = interactionUI.createChoice(choiceText, TweakDBInterface.GetChoiceCaptionIconPartRecord(icon), choiceType)
    local hub = interactionUI.createHub(hubText, {choice})
    interactionUI.setupHub(hub)
    interactionUI.showHub()
    interactionUI.callbacks[1] = function()
        interactionUI.hideHub()
        callback()
    end
end
--- Animate player entering spot
---@param animObj table spot's animation information
local function animateEnteringSpot(animObj) --Triggers workspot animation
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

    Cron.After(1, function()
        local entity = Game.FindEntityByID(entID)
        workspotSystem:PlayInDevice(entity, player) --Play workspot

        CardEngine.BuildVisualDeck(Vector4.new(-1041.759, 1340.121, 6.085, 1), { r = 0, p = 180, y = -90 })
    end)
end

---Move player camera to forced position, typically above table
---@param enable boolean to enable, or disable the forced camera perspective
local function setForcedCamera(enable)
    forcedCam = enable
    if enable then
        local camera = GetPlayer():GetFPPCameraComponent()
        local quatOri = EulerAngles.new(forcedCamOri.r, forcedCamOri.p, forcedCamOri.y):ToQuat()
        camera:SetLocalTransform(Vector4.new(0, 0.4, 0.7, 1), quatOri)
        StatusEffectHelper.ApplyStatusEffect(GetPlayer(), "GameplayRestriction.NoCameraControl")
        --camera:SetLocalPosition(Vector4.new(0, 0.4, 0.6, 1))
        --camera:SetLocalOrientation(quatOri)--this needs to be spammed(?), otherwise player mouse movement resets entire camera back to player
        --camera:Activate(5) --test if this line is needed
        --camera.headingLocked = true
        --camera:SceneDisableBlendingToStaticPosition()
    else
        local camera = GetPlayer():GetFPPCameraComponent()
        camera:SetLocalPosition(Vector4.new(0, 0, 0, 1))
        camera:SetLocalOrientation(EulerAngles.new(0, 0, 0):ToQuat())
        StatusEffectHelper.RemoveStatusEffect(GetPlayer(), "GameplayRestriction.NoCameraControl")
        --camera.SetLocalTransform(Vector4.new(0, 0, 0, 1), EulerAngles.new(0, 0, 0):ToQuat())
        --camera:Activate(5)
        --camera.headingLocked = false
    end
end

---Triggered on interactionUI choice to enter workspot
---@param id any identification id
---@param animObj table spot's animation information
local function satAtSpot(id, animObj)
    animateEnteringSpot(animObj)
    SpotManager.spots[id].active = true
    local callback = function()
        setForcedCamera(true)
    end
    Cron.After(3, callback)
end

--Register Events (passed from parent)
--===============
function SpotManager.init() --runs on game launch

    Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu) -- Setup observer and GameUI to detect inGame / inMenu, credit: keanuwheeze | init.lua from the sitAnywhere mod
        inMenu = isInMenu
    end)

    inGame = false          --Setup observer and GameUI to detect inGame / inMenu
    GameUI.OnSessionStart(function() --  credit: keanuwheeze | init.lua from the sitAnywhere mod
        inGame = true
        world.onSessionStart()
        Cron.After(1, function ()
            localPlayer = Game.GetPlayer()
        end)
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
    end
    if forcedCam then --fixes the camera being reset by workspot animation
        local camera = localPlayer:GetFPPCameraComponent()
        local o = camera:GetLocalOrientation():ToEulerAngles()
        local targetP = forcedCamOri.p
        if not (o.pitch < targetP+0.001 and o.pitch > targetP-0.001) then
            setForcedCamera(true)
        end
    else
        StatusEffectHelper.RemoveStatusEffect(GetPlayer(), "GameplayRestriction.NoCameraControl") --insurance
    end
end

--Methods
--=======
--- Animate player leaving spot
--- @param id any identification id
function SpotManager.ExitSpot(id) --Exit spot
    setForcedCamera(false) --disable forced camera perspective
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

        CardEngine.RemoveVisualDeck()

        spot.active = false
    end)
end

--- Add spot to SpotManager's managed list of spots
---@param id any identification id
---@param worldPinUI table worldPinUI information
---@param animObj table spot's animation information
function SpotManager.AddSpot(id, worldPinUI, animObj) --Create spot
    SpotManager.spots[id] = {worldPinUI = worldPinUI, animObj = animObj, active = false, startTriggered = false}
    world.addInteraction(id, worldPinUI.position, 1.0, 80, "ChoiceIcons.SitIcon", 6.5, 0.5, nil, function(state)
                    --  (id, position, interactionRange, angle, icon, iconRange, iconRangeMin, iconColor, callback)
        if state then -- Show
            local UIcallback = function()
                satAtSpot(id, animObj)
            end
            basicInteractionUIPrompt("Blackjack", "Join Table", "ChoiceCaptionParts.SitIcon", gameinteractionsChoiceType.QuestImportant, UIcallback) --Display interactionUI menu
        else -- Hide
            interactionUI.hideHub()
        end
    end)
end
--- Change Animation for set time, then return to 'default' animation position
---@param animName string Animation to trigger
---@param duration number Duration of animation
---@param returnAnimName string Animation to reset to as default
function SpotManager.ChangeAnimation(animName, duration, returnAnimName)
    local player = Game.GetPlayer()
    local workspotSystem = Game.GetWorkspotSystem()
    workspotSystem:SendJumpToAnimEnt(player, animName, true)
    Cron.After(duration, function()
        workspotSystem:SendJumpToAnimEnt(player, returnAnimName, true)
    end)
end



return SpotManager