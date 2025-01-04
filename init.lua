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
--ArchiveXL
--TweakXL   ?
--===================

--Modules
--=======
local Cron = require('External/Cron.lua') --Time handling
local SpotManager = require('SpotManager.lua') --workspot management
local CardEngine = require('CardEngine.lua') --Card Entity Handler



GamblingSystemBlackjack = {
    loaded = false,
    ready = false
}

-- Register Events
--================
registerForEvent( "onInit", function() 
    SpotManager.init()
    CardEngine.init()

    -- Define Hooh location
    local worldPinUI = {
        position = Vector4.new(-1041.2463, 1341.5469, 6.21331358, 1)
    }
    local animObj = {
        position = Vector4.new(-1041.2463, 1341.5469, 5.2774734, 1),
        orientation = {x=0,y=0,z=0},
        templatePath = "boe6\\GamblingSystemBlackjack\\workspot_anim.ent",
        defaultAnim = "sit_chair_table_lean0__2h_on_table__01",
        exitAnim = "sit_chair_table_lean0__2h_on_table__01__to__stand__2h_on_sides__01__turn0l__01",
        exitTime = 2.5
    }
    SpotManager.AddSpot('hooh', worldPinUI, animObj)
end)
registerForEvent('onUpdate', function(dt)
    Cron.Update(dt)
    SpotManager.update(dt)
    CardEngine.update(dt)

    for i, spot in pairs(SpotManager.spots) do
        if spot.active == true and spot.startTriggered == false then
            DualPrint('spot start triggered')
            spot.startTriggered = true
        elseif spot.active == false and spot.startTriggered == true then
            DualPrint('spot end triggered')
            spot.startTriggered = false
        end
    end
end)
registerHotkey('DevHotkey1', 'Dev Hotkey 1', function()
    DualPrint('||=1  Dev hotkey 1 Pressed =')

    SpotManager.ExitSpot('hooh')
end)
registerHotkey('DevHotkey2', 'Dev Hotkey 2', function()
    DualPrint('||=2  Dev hotkey 2 Pressed =')

    local cardID = CardEngine.CreateCard('7h', Vector4.new(-1041.759, 1340.121, 6.085, 1), { r = 0, p = 180, y = -90 })
    Cron.After(1, function()
        DualPrint('cardID: '..cardID)
    end)
end)
registerHotkey('DevHotkey3', 'Dev Hotkey 3', function()
    DualPrint('||=3  Dev hotkey 3 Pressed =')

    CardEngine.DeleteCard('TEMP')
end)
registerHotkey('DevHotkey4', 'Dev Hotkey 4', function()
    DualPrint('||=4  Dev hotkey 4 Pressed =')

    CardEngine.MoveCard('TEMP', Vector4.new(-1041.189, 1340.711, 6.085, 1), { r = 0, p = 0, y = -90 }, 'smooth')
end)
registerHotkey('DevHotkey5', 'Dev Hotkey 5', function()
    DualPrint('||=5  Dev hotkey 5 Pressed =')
    local quat1 = EulerAngles.ToQuat(EulerAngles.new(0,0,0))
    local quat2 = EulerAngles.ToQuat(EulerAngles.new(0,0,-90))
    local quat3 = EulerAngles.ToQuat(EulerAngles.new(0,0,90))
    local quat4 = EulerAngles.ToQuat(EulerAngles.new(0,180,-90))
    local quat5 = EulerAngles.ToQuat(EulerAngles.new(90,0,-90))
    local entQuat1 = quat4
    local cardSpec = StaticEntitySpec.new()
    cardSpec.templatePath = "boe6\\gambling_props\\boe6_playing_card.ent"
    cardSpec.appearanceName = "7h"
    cardSpec.position = Vector4.new(-1041.759, 1340.421, 6.085, 1)
    cardSpec.orientation = entQuat1
    cardSpec.tags = {"quatTest"}
    DualPrint('Start euler: '..tostring(entQuat1:ToEulerAngles()))

    local entityID = Game.GetStaticEntitySystem():SpawnEntity(cardSpec)

    Cron.Every(0.1, function()
        DualPrint('-=- cron every start -=-')
        local entity = Game.FindEntityByID(entityID)
        local entQuat = entity:GetWorldOrientation() --Quaternion
        local entEuler = entQuat:ToEulerAngles()
        DualPrint('entEuler: '..tostring(entEuler))


        local forwardVector = entQuat:GetForward() --Vector4
        DualPrint('forward vector4: x: '..forwardVector.x..' y: '..forwardVector.y..' z: '..forwardVector.z..' w: '..forwardVector.w)
        local upVector = entQuat:GetUp() --Vector4
        DualPrint('up vector4: x: '..upVector.x..' y: '..upVector.y..' z: '..upVector.z..' w: '..upVector.w)
        local rightVector = entQuat:GetRight() --Vector4 forward, rotates card on long axis
        DualPrint('right vector4: x: '..rightVector.x..' y: '..rightVector.y..' z: '..rightVector.z..' w: '..rightVector.w)
        local xAxis = entQuat:GetXAxis() --Vector4 forward, rotates card on long axis
        local yAxis = entQuat:GetYAxis() --Vector4
        local zAxis = entQuat:GetZAxis() --Vector4 forward, rotates card on its face

        local angleRadians = 10 * (math.pi / 180)
        local rotatedAxis = forwardVector.RotateAxis(forwardVector, xAxis, angleRadians)
        DualPrint('rotatedAxis vector4: x: '..rotatedAxis.x..' y: '..rotatedAxis.y..' z: '..rotatedAxis.z..' w: '..rotatedAxis.w)

        local outQuat = entQuat.BuildFromDirectionVector(rotatedAxis, upVector)

        local entityVector4 = entity:GetWorldPosition()
        local outEuler = outQuat:ToEulerAngles()
        DualPrint('out euler: '..tostring(outEuler))

        Game.GetTeleportationFacility():Teleport(entity, entityVector4, outEuler)

        --[[
        Cron.After(5, function()
            
            local nforward = outQuat:GetForward() --Vector4
            local nup = outQuat:GetUp() --Vector4
            local nright = outQuat:GetRight() --Vector4
            local lastOutQuat = outQuat.BuildFromDirectionVector(nright, nup)
            Game.GetTeleportationFacility():Teleport(entity, entityVector4, lastOutQuat:ToEulerAngles())
        end)
        ]]--
    end)

end)
registerHotkey('DevHotkey6', 'Dev Hotkey 6', function()
    DualPrint('||=6  Dev hotkey 6 Pressed =')

    CardEngine.FlipCard('TEMP', true)
end)

--[[ animations tested
player stands and leaves:
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__to__stand__2h_on_sides__01__turn0l__01", 2.766, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__to__stand__2h_on_sides__01__turn0r__01", 3.766, "sit_chair_table_lean0__2h_on_table__01")
very nice 2 palms down:
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__2h_flick__01", 1.7, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__describe_front__01", 1.7, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__describe_front__02", 1.0, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__lh_flick__03", 1.5, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__talk__02", 1.9, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__talk__05", 3.1, "sit_chair_table_lean0__2h_on_table__01")
camera movement glitchy:
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__drink__01", 4.5, "sit_chair_table_lean0__2h_on_table__01")
other arm weirdly jerks forward:
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__rh_flick__03", 1.5, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__yes__01", 1.9, "sit_chair_table_lean0__2h_on_table__01")
animaiton fucked:
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__rh_flick__04", 1.6, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__rh_flick__03", 1.9, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__personal_link_plugged__01__to__sit_chair_table_lean0__2h_on_table__01", 1.6, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__to__sit_chair_table_lean0__personal_link_plugged__01", 3.0333, "sit_chair_table_lean0__personal_link_plugged__01")
one palm up:
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__describe_right__01", 2.3666, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__rh_flick__04", 1.6, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__stop__angry__01", 2.4333, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__yes__01", 2.4, "sit_chair_table_lean0__2h_on_table__01")
]]--


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