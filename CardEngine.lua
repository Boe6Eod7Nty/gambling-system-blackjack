CardEngine = {
    version = '1.0.0',
    cards = {}
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
local cardPath = "boe6\\gambling_props\\boe6_playing_card.ent"
local movingCards = {}
local flippingCards = {}

--Functions
--=========
function CardEngine.init() --runs on game launch
    Cron.Every(0.05, function()
        FlippingCardsProcess()
    end)
end
--- Runs every frame
---@param dt any delta time
function CardEngine.update(dt)
    --DualPrint('CardEngine update: '..tostring(dt))
    --[[
    if  not inMenu and inGame then
        Cron.Update(dt) -- This is required for Cron to function
        world.update()
        interactionUI.update()
    end
    ]]--

    if next(movingCards) then
        for i, card in pairs(movingCards) do
            local stepSize = 0.5
            local moveDistance = stepSize * dt * 1
            local rotateDistance = stepSize * dt * 1

            local cardObj = CardEngine.cards[card.id]
            local entID = cardObj.entID
            local entity = Game.FindEntityByID(entID)

            --instatiate output euler
            local euler = EulerAngles.new(card.TargetOriRPY.r, card.TargetOriRPY.p, card.TargetOriRPY.y)

            local currentOrientationRPY = entity:GetWorldOrientation():ToEulerAngles()
            local curOri = {r=currentOrientationRPY.roll,p=currentOrientationRPY.pitch,y=currentOrientationRPY.yaw}
            local tarOri = {r=card.TargetOriRPY.r,p=card.TargetOriRPY.p,y=card.TargetOriRPY.y}



            local entityVector4 = entity:GetWorldPosition()
            local TargetVector4 = card.targetPos
            local vectorXYZ = {x=TargetVector4.x-entityVector4.x,y=TargetVector4.y-entityVector4.y,z=TargetVector4.z-entityVector4.z}
            local magnitude = math.sqrt(vectorXYZ.x^2 + vectorXYZ.y^2 + vectorXYZ.z^2)
            if magnitude <= moveDistance then
                Game.GetTeleportationFacility():Teleport(entity, TargetVector4, euler)
                movingCards[i] = nil
                DualPrint('card move end triggered')
                break
            end
            local directionXYZ = {x=vectorXYZ.x/magnitude,y=vectorXYZ.y/magnitude,z=vectorXYZ.z/magnitude}
            local newXYZ = {
                x=entityVector4.x+directionXYZ.x*moveDistance,
                y=entityVector4.y+directionXYZ.y*moveDistance,
                z=entityVector4.z+directionXYZ.z*moveDistance}
            local outPositionVector4 = Vector4.new(newXYZ.x,newXYZ.y,newXYZ.z,1)

            Game.GetTeleportationFacility():Teleport(entity, outPositionVector4, euler)
        end
    end
end
---Create card entity and lua object
---@param faceType string card face, k4, 8s, Ah, etc
---@param positionVector4 any Vector4 spawn position of card
---@param orientationXYZ any orientation as {r=,p=,y=}
---@return any id card id output
function CardEngine.CreateCard(faceType, positionVector4, orientationRPY)
    local cardSpec = StaticEntitySpec.new()
    cardSpec.templatePath = cardPath
    cardSpec.appearanceName = faceType
    cardSpec.position = positionVector4
    cardSpec.orientation = EulerAngles.ToQuat(EulerAngles.new(orientationRPY.r,orientationRPY.p,orientationRPY.y))
    cardSpec.tags = {"cardEngine"}

    local id = 'TEMP' --replace with some dynamic id system
    --local entitySystem = Game.GetStaticEntitySystem()
    local entityID = Game.GetStaticEntitySystem():SpawnEntity(cardSpec)
    CardEngine.cards[id] = { id = id, entID = entityID }
    return id
end
---Delete card
---@param id any id of card to delete
function CardEngine.DeleteCard(id)
    Game.GetStaticEntitySystem():DespawnEntity(CardEngine.cards[id].entID)
end
---Move card to position with animation 'style'
---@param id any id of card to move
---@param positionVector4 any Vector4 target position of card
---@param orientationXYZ any orientation target as {r=,p=,y=}
---@param movementStyle string animation style
function CardEngine.MoveCard(id, positionVector4, orientationRPY, movementStyle)
    if movementStyle == 'snap' then
        local entity = Game.FindEntityByID(CardEngine.cards[id].entID)
        local euler = EulerAngles.new(orientationRPY.r, orientationRPY.p, orientationRPY.y)
        Game.GetTeleportationFacility():Teleport(entity, positionVector4, euler)
    elseif movementStyle == 'smooth' then
        movingCards[id] = {id = id, targetPos = positionVector4, TargetOriRPY = orientationRPY, movementStyle = movementStyle}
        DualPrint('added card to move queue: '..tostring(id))
    end
end
---Flip card 180 to other face/side
---@param id any id of card to flip
---@param horizontal boolean true for flip along horizontal, false for vertical
function CardEngine.FlipCard(id, horizontal)
    local entity = Game.FindEntityByID(CardEngine.cards[id].entID)
    local entityVector4 = entity:GetWorldPosition()
    flippingCards[id] = {id = id, horizontal = horizontal, lifetime = 0, startHeight = entityVector4.z}
end
function FlippingCardsProcess()
    if not next(flippingCards) then --check if list empty
        return
    end
    for k,v in pairs(flippingCards) do
        if flippingCards[v.id] == nil then
            break
        end
        local flipAngle = 20 --angle to move each step. Basically card flip speed.
        local steps = 180 / flipAngle
        local liftDistance = 0.01
        local entity = Game.FindEntityByID(CardEngine.cards[v.id].entID)
        local entQuat = entity:GetWorldOrientation()--Quaternion
        local entityVector4 = entity:GetWorldPosition()
        if v.lifetime >= steps then --after steps (degrees x steps = 180) card is done flipping.
            local entEuler = entQuat:ToEulerAngles()
            local outPitch = entEuler.pitch
            if entEuler.pitch < 170 and entEuler.pitch > 90 then --force card to be flat
                outPitch = 180
            else
                outPitch = 0
            end
            local outEuler = EulerAngles.new(entEuler.roll, outPitch, entEuler.yaw)
            local outQuat = outEuler:ToQuat()
            local outPos = Vector4.new(entityVector4.x, entityVector4.y, flippingCards[v.startHeight], 1)
            Game.GetTeleportationFacility():Teleport(entity, outPos, outEuler)
            flippingCards[v.id] = nil
            break
        end
        local forwardVector = entQuat:GetForward()  --Vector4
        local upVector = entQuat:GetUp()            --Vector4
        local rightVector = entQuat:GetRight()      --Vector4 forward, rotates card on long axis
        local xAxis = entQuat:GetXAxis()            --Vector4 forward, rotates card on long axis
        local yAxis = entQuat:GetYAxis()            --Vector4
        local zAxis = entQuat:GetZAxis()            --Vector4 forward, rotates card on its face

        local outQuat
        local angleRadians = (math.pi / 180) * flipAngle --convert degrees to radians
        if v.horizontal == true then
            local rotatedAxis = forwardVector.RotateAxis(forwardVector, xAxis, angleRadians)--[ These 2 functions
            outQuat = entQuat.BuildFromDirectionVector(rotatedAxis, upVector)               --[ Are black magic
        else
            local rotatedAxis = forwardVector.RotateAxis(forwardVector, yAxis, angleRadians)--ai wrote this else
            outQuat = entQuat.BuildFromDirectionVector(rotatedAxis, rightVector)            --statement, untested
        end
        local outEuler = outQuat:ToEulerAngles()

        if v.lifetime < steps / 2 then
            entityVector4.z = entityVector4.z + liftDistance
        else
            entityVector4.z = entityVector4.z - liftDistance
        end

        Game.GetTeleportationFacility():Teleport(entity, entityVector4, outEuler)

        v.lifetime = v.lifetime + 1
    end
end

return CardEngine