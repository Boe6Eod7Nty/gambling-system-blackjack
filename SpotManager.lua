SpotManager = {
    version = '1.1.0',
    spots = {},
    activeCam = nil,
    forcedCam = false
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

--local BlackjackMainMenu = require("BlackjackMainMenu.lua")
local Cron = require('External/Cron.lua')
local world = require('External/worldInteraction.lua')
local GameUI = require("External/GameUI.lua")
local interactionUI = require("External/interactionUI.lua")

local inMenu = true --libaries requirement
local inGame = false

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
    spec.orientation = animObj.orientation:ToQuat()
    spec.tags = {"SpotManager"} --note; I don't know if this needs to be a unique value or what exactly
    -- Spawn entity
    local entID = dynamicEntitySystem:CreateEntity(spec)
    animObj.entID = entID

    Cron.After(1, function()
        local entity = Game.FindEntityByID(entID)
        workspotSystem:PlayInDevice(entity, player) --Play workspot
    end)
end

---Move player camera to forced position, typically above table
---@param enable boolean to enable, or disable the forced camera perspective
---@param animObj? table spot's animation object
local function setForcedCamera(enable, animObj)
    SpotManager.forcedCam = enable
    if enable then
        local camera = GetPlayer():GetFPPCameraComponent()
        local quatOri = animObj.cameraSpotRotationOffset:ToQuat()
        if ImmersiveFirstPersonInstalled then
            --camera:SetLocalTransform(Vector4.new(0, 0.4, 0.9, 1), quatOri) --alt position for immersiveFirstPerson camera
            --GetMod("ImmersiveFirstPerson").api.Disable()
            StatusEffectHelper.ApplyStatusEffect(GetPlayer(), "GameplayRestriction.NoCameraControl")
        end
        camera:SetLocalTransform(animObj.cameraSpotPositionOffset, quatOri) --default settings
    else
        --reset to normal camera control
        local camera = GetPlayer():GetFPPCameraComponent()
        camera:SetLocalPosition(Vector4.new(0, 0, 0, 1))
        camera:SetLocalOrientation(EulerAngles.new(0, 0, 0):ToQuat())
        StatusEffectHelper.RemoveStatusEffect(GetPlayer(), "GameplayRestriction.NoCameraControl")
        --[[
        if ImmersiveFirstPersonInstalled then
            --GetMod("ImmersiveFirstPerson").api.Enable()
        end
        ]]--
    end
end

---Triggered on interactionUI choice to enter workspot
---@param animObj table spot's animation information
local function triggeredSpot(animObj)
    animateEnteringSpot(animObj)
    animObj.immediateCallback()
    if ImmersiveFirstPersonInstalled then
        --disables camera control. User movement input + Immersive First Person causes visual bug
        StatusEffectHelper.ApplyStatusEffect(GetPlayer(), "GameplayRestriction.NoCameraControl")
        --GetMod("ImmersiveFirstPerson").api.Disable()
    end
    local enterCallback = function()
        StatusEffectHelper.ApplyStatusEffect(GetPlayer(), "BaseStatusEffect.FatalElectrocutedParticleStatus")
        SpotManager.activeCam = animObj.id
        setForcedCamera(true, animObj)
    end
    --[[
    local callback2 = function()
        BlackjackMainMenu.playerChipsMoney = 0        --Reset vars security
        BlackjackMainMenu.playerChipsHalfDollar = false
        BlackjackMainMenu.previousBet = nil
        BlackjackMainMenu.currentBet = nil
        BlackjackMainMenu.StartMainMenu()
    end
    ]]--
    Cron.After(animObj.enterTime, enterCallback)
    Cron.After(animObj.delayedCallbackTime, animObj.delayedCallback)
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
    if SpotManager.forcedCam and SpotManager.activeCam ~= nil then --fixes the camera being reset by workspot animation
                                --TODO: Add yaw correction
        local camera = GetPlayer():GetFPPCameraComponent()
        local o = camera:GetLocalOrientation():ToEulerAngles()
        local spot = SpotManager.spots[SpotManager.activeCam]
        local targetP = spot.animObj.cameraSpotRotationOffset.pitch
        if not (o.pitch < targetP+0.0001 and o.pitch > targetP-0.0001) then
            setForcedCamera(true, spot.animObj)
        end
    else
        StatusEffectHelper.RemoveStatusEffect(GetPlayer(), "GameplayRestriction.NoCameraControl") --insurance
        --[[
        if ImmersiveFirstPersonInstalled then
            --GetMod("ImmersiveFirstPerson").api.Enable()
        end
        ]]--
    end
end

--Methods
--=======
--- Animate player leaving spot
--- @param id any identification id
function SpotManager.ExitSpot(id) --Exit spot
    setForcedCamera(false) --disable forced camera perspective
    SpotManager.activeCam = nil
    local spot = SpotManager.spots[id]
    SpotManager.ChangeAnimation(spot.animObj.exitAnim, spot.animObj.exitTime + 3, spot.animObj.defaultAnim)

    spot.animObj.exitStartedCallback()
    Cron.After(spot.animObj.exitTime, function() -- Wait for animation to finish
        local player = GetPlayer()
        local playerTransform = player:GetWorldTransform()
        local position = playerTransform:GetWorldPosition()
        local x = position:GetX() + spot.animObj.exitSpotShift.x
        local y = position:GetY() + spot.animObj.exitSpotShift.y
        local z = position:GetZ() + spot.animObj.exitSpotShift.z
        local baseOri = spot.animObj.orientation
        local offOri = spot.animObj.exitOrientationOffset
        local localEuler = EulerAngles.new( baseOri.roll+offOri.r, baseOri.pitch+offOri.p, baseOri.yaw+offOri.y )
        Game.GetTeleportationFacility():Teleport(player, Vector4.new(x, y, z, 1), localEuler)--150 hardcoded..?
        Game.GetWorkspotSystem():SendFastExitSignal(player)

        spot.animObj.exitPostAnimationCallback()
    end)
end

--- Add spot to SpotManager's managed list of spots
---@param animObj table spot's animation information
function SpotManager.AddSpot(animObj) --Create spot
    SpotManager.spots[animObj.id] = {animObj = animObj}
    world.addInteraction(animObj.id, animObj.worldPinLocation, animObj.interactionRange, animObj.interactionAngle,
                         animObj.choiceIcon, animObj.iconRange, animObj.iconRangeMin, animObj.iconColor, function(state)
        --(id, position, interactionRange, angle, icon, iconRange, iconRangeMin, iconColor, callback)
        if state then -- Show
            local UIcallback = function()
                triggeredSpot(animObj)
            end
            --Display interactionUI menu
            basicInteractionUIPrompt(animObj.UIhubText,animObj.UIchoiceText,animObj.UIicon,animObj.UIchoiceType,UIcallback)
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