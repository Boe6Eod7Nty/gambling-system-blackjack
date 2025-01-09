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
local deckShuffling = false
local deckShuffleAge = 0

--Functions
--=========

function CardEngine.init() --runs on game launch
    Cron.Every(0.05, function()
        FlippingCardsProcess()
    end)
    Cron.Every(0.1, function()
        ShuffleDeckAnim()
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
            local stepSize = 1
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
            euler = EulerAngles.new(curOri.r,curOri.p,curOri.y)



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
function CardEngine.CreateCard(id, faceType, positionVector4, orientationRPY)
    local cardSpec = StaticEntitySpec.new()
    cardSpec.templatePath = cardPath
    cardSpec.appearanceName = faceType
    cardSpec.position = positionVector4
    cardSpec.orientation = EulerAngles.ToQuat(EulerAngles.new(orientationRPY.r,orientationRPY.p,orientationRPY.y))
    cardSpec.tags = {"cardEngine",id}

    --local entitySystem = Game.GetStaticEntitySystem()
    local entityID = Game.GetStaticEntitySystem():SpawnEntity(cardSpec)
    CardEngine.cards[id] = { id = id, entID = entityID }
    return id
end

---Delete card
---@param id any id of card to delete
function CardEngine.DeleteCard(id)
    DualPrint('card deleted: '..tostring(id))
    DualPrint('entity deleted: '..tostring(CardEngine.cards[id].id))
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
---@param flipAngle string type of rotation. horizontal, facewise, etc.
---@param direction string direction of flip, left or right
function CardEngine.FlipCard(id, flipAngle, direction)
    local entity = Game.FindEntityByID(CardEngine.cards[id].entID)
    local entityVector4 = entity:GetWorldPosition()
    flippingCards[id] = {id = id, flipAngle = flipAngle, direction = direction, lifetime = 0, startHeight = entityVector4.z}
end

---Processes 1 step of each current card in the flippingCards table
function FlippingCardsProcess()
    for k,v in pairs(flippingCards) do
        if flippingCards[v.id] == nil then
            break
        end
        --DualPrint('flipping card: '..tostring(v.id))

        local flipAngle = 20 --angle to move each step. Basically card flip speed.
        local totalFlipDegrees = 180

        if v.direction == 'left' then --inverts angle to swap direction
            totalFlipDegrees = totalFlipDegrees * -1
            flipAngle = flipAngle * -1
        end

        local steps = totalFlipDegrees / flipAngle --how many iterations of FlippingCardsProcess() to flip 180 degrees
        local liftDistance = 0.01 --amount of height to add to the card during each step
        local entity = Game.FindEntityByID(CardEngine.cards[v.id].entID)
        local entQuat = entity:GetWorldOrientation() --Quaternion datatype. Used as starting reference for each step
        local entityVector4 = entity:GetWorldPosition() --XYZ world position
        if v.lifetime >= steps then --after steps (degrees x steps = 180) mark card as done flipping. ('delete')
            --[[
            local entEuler = entQuat:ToEulerAngles()
            local outPitch = entEuler.pitch
            DualPrint('out eulers: '..tostring(entEuler))
            local outEuler = EulerAngles.new(entEuler.roll, outPitch, entEuler.yaw)
            local outPos = Vector4.new(entityVector4.x, entityVector4.y, flippingCards[v.startHeight], entityVector4.w)
            Game.GetTeleportationFacility():Teleport(entity, outPos, outEuler)
            ]]--
            --DualPrint('attempted nil set on card: '..tostring(v.id))
            flippingCards[v.id] = nil
            break
        end
        local forwardVector = entQuat:GetForward()  --Vector4
        local upVector = entQuat:GetUp()            --Vector4
        local rightVector = entQuat:GetRight()      --Vector4 forward, rotates card on long axis
        local outQuat
        local angleRadians = (math.pi / 180) * flipAngle --convert degrees to radians

        if v.flipAngle == 'horizontal' then
            local rotatedVector = forwardVector.RotateAxis(forwardVector, rightVector, angleRadians)  --[ These 2 functions
            outQuat = entQuat.BuildFromDirectionVector(rotatedVector, upVector)                       --[ Are black magic
        elseif v.flipAngle == 'facewise' then
            --TODO: Add vertical flip. quaternions are DUMB
            local rotatedVector = forwardVector.RotateAxis(forwardVector, upVector, angleRadians)
            outQuat = entQuat.BuildFromDirectionVector(rotatedVector, upVector)
        end
        local outEuler = outQuat:ToEulerAngles()

        --add height during first half of flip, subtract during second. no action when in the middle. (the 0.5 does this)
        if v.flipAngle == 'horizontal' then
            if v.lifetime < (steps / 2)-0.5 then
                entityVector4.z = entityVector4.z + liftDistance
            elseif v.lifetime > (steps / 2)-0.5 then
                entityVector4.z = entityVector4.z - liftDistance
            end
        end

        Game.GetTeleportationFacility():Teleport(entity, entityVector4, outEuler)

        v.lifetime = v.lifetime + 1
    end
end

---Spawns card entities to look like a deck
---@param positionVector4 Vector4 spawn position
---@param orientationRPY any orientation as {r=,p=,y=}, p=180 for face down
function CardEngine.BuildVisualDeck(positionVector4, orientationRPY)
    for i = 0, 39 do
        local newZ = positionVector4.z + (0.0005 * i)
        local newPositionVector4 = Vector4.new(positionVector4.x, positionVector4.y, newZ, 1)
        CardEngine.CreateCard('deckCard_'..tostring(i), '7h', newPositionVector4, orientationRPY)
    end
end

---Removes all deck card entities
function CardEngine.RemoveVisualDeck()
    for i = 0, 39 do
        CardEngine.DeleteCard('deckCard_'..tostring(i))
    end
end

---Flips deckShuffling to true, causing the deck 'shuffle' animation
function CardEngine.TriggerDeckShuffle()
    deckShuffling = true
end

---If deck shuffling, process 1 step
function ShuffleDeckAnim()
    if not deckShuffling then
        return
    end
    deckShuffleAge = deckShuffleAge + 1
    if deckShuffleAge > 20 then
        deckShuffleAge = 0
        deckShuffling = false
    end

    local cardOrder = {14,5,36,22,28,13,39,9,3,12,35,2,34,19,23,30,20,37,17,25}
    local direction = 'left'
    if math.random(1,2) == 1 then --randomly set rotation direction, clockwise or counterclockwise.
        direction = 'right'
    end
    CardEngine.FlipCard('deckCard_'..tostring(cardOrder[deckShuffleAge]), 'facewise', direction)
end


return CardEngine