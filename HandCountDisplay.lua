HandCountDisplay = {
    version = '1.0.0',
    displayEnabled = false,
    displays = {},
    playerActiveHands = 0
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

local Cron = require('External/Cron.lua')

local digitEntPath = "boe6\\gamblingsystemblackjack\\boe6_number_digit_vanilla.ent"

---Calculates the 3D origin of a hand count display
---@param isDealer boolean true/false
---@param handIndex number? hand number to display count for
---@return Vector4 origin world location for first digit of display
local function calculateDisplayOrigin(isDealer, handIndex)
    local justBelowFirstHand = Vector4.new(-1041.175, 1340.821, 6.085, 1)
    if isDealer then
        local newVector = Vector4.new(justBelowFirstHand.x-0.060, justBelowFirstHand.y-0.511, justBelowFirstHand.z, 1)
        return newVector
    end
    if handIndex then
        local newVector = Vector4.new(justBelowFirstHand.x+(0.18*(handIndex-1)), justBelowFirstHand.y, justBelowFirstHand.z, 1)
        return newVector
    end
    return justBelowFirstHand
end

---Spawns digit entity in world. Sets HandCountDisplay.displays[id].entID
---@param digit1or2 integer 1 or 2, first or 2nd digit.
---@param displayID string id of containing display, ie "playerHand3"
---@param appName string appearance name for entity
---@param worldPosition Vector4 world position
---@param orientation Quaternion world orientation
local function spawnDigit(digit1or2, displayID, appName, worldPosition, orientation)
    local spec = StaticEntitySpec.new()
    spec.templatePath = digitEntPath
    spec.appearanceName = appName
    spec.position = worldPosition
    spec.orientation = orientation
    spec.tags = {"HandCountDisplay",tostring(id)}

    local entityID = Game.GetStaticEntitySystem():SpawnEntity(spec)
    if digit1or2 == 1 then
        HandCountDisplay.displays[displayID].ent1ID = entityID
    else
        HandCountDisplay.displays[displayID].ent2ID = entityID
    end
end

--- Spawns 2 digits for a hand count display
---@param isDealer boolean true/false, is the dealer's hand?
---@param handIndex number? hand number to display count for
local function displayStartup(isDealer, handIndex)
    local digit1pos
    local digit2pos
    local digit1app = "0"
    local digit2app = "0"
    local value
    local orientation = EulerAngles.new(0,60,0):ToQuat()

    if isDealer then
        digit1pos = calculateDisplayOrigin(true)
        digit2pos = Vector4.new(digit1pos.x-0.04, digit1pos.y, digit1pos.z, 1)
        HandCountDisplay.displays['dealerHand'].enabled = true
        value = SingleRoundLogic.dealerCardsValue
    elseif handIndex then
        digit1pos = calculateDisplayOrigin(false, handIndex)
        digit2pos = Vector4.new(digit1pos.x-0.04, digit1pos.y, digit1pos.z, 1)
        HandCountDisplay.displays['playerHand'..tostring(handIndex)].enabled = true
        value = SingleRoundLogic.playerCardsValue[handIndex]
    end

    if value ~= 0 then
        local tens = math.floor(value / 10)
        local ones = value % 10
        digit1app = tostring(tens)
        digit2app = tostring(ones)
    end

    if isDealer then
        spawnDigit(1, "dealerHand", digit1app, digit1pos, orientation)
        spawnDigit(2, "dealerHand", digit2app, digit2pos, orientation)
        HandCountDisplay.displays['dealerHand'].appValue = value
    elseif handIndex then
        spawnDigit(1, "playerHand"..tostring(handIndex), digit1app, digit1pos, orientation)
        spawnDigit(2, "playerHand"..tostring(handIndex), digit2app, digit2pos, orientation)
        HandCountDisplay.displays['playerHand'..tostring(handIndex)].appValue = value
    end
end

local function displayShutdown(isDealer, handIndex)
    local display
    if isDealer then
        display = HandCountDisplay.displays['dealerHand']
    elseif handIndex then
        display = HandCountDisplay.displays['playerHand'..tostring(handIndex)]
    else
        DualPrint('HCD | Incorrect displayShutdown() call. Error #4027')
        return
    end
    --local entity1 = Game.GetStaticEntitySystem():GetEntityByID(display.ent1ID)
    --local entity2 = Game.GetStaticEntitySystem():GetEntityByID(display.ent2ID)
    Game.GetStaticEntitySystem():DespawnEntity(display.ent1ID)
    Game.GetStaticEntitySystem():DespawnEntity(display.ent2ID)
    display.enabled = false
end

---Update display values to match current card's hand's values
local function updateEachDisplay()
    local dealerDisplay = HandCountDisplay.displays['dealerHand']
    if dealerDisplay.enabled then
        dealerDisplay.value = SingleRoundLogic.dealerCardsValue
        if dealerDisplay.value ~= dealerDisplay.appValue then
            local tens = math.floor(dealerDisplay.value / 10)
            local ones = dealerDisplay.value % 10
            dealerDisplay.appValue = dealerDisplay.value
            local digit1Entity = Game.FindEntityByID(dealerDisplay.ent1ID)
            local digit2Entity = Game.FindEntityByID(dealerDisplay.ent2ID)
            if digit1Entity and digit2Entity then
                local function callback()
                    digit1Entity:ScheduleAppearanceChange(tostring(tens))
                    digit2Entity:ScheduleAppearanceChange(tostring(ones))
                end
                Cron.After(2.0, callback)
            end
        end
    end
    for i, hand in pairs(SingleRoundLogic.playerHands) do
        local playerDisplay = HandCountDisplay.displays['playerHand'..tostring(i)]
        if playerDisplay.enabled then
            playerDisplay.value = SingleRoundLogic.playerCardsValue[i]
            if playerDisplay.value ~= playerDisplay.appValue then
                local tens = math.floor(playerDisplay.value / 10)
                local ones = playerDisplay.value % 10
                playerDisplay.appValue = playerDisplay.value
                local digit1Entity = Game.FindEntityByID(playerDisplay.ent1ID)
                local digit2Entity = Game.FindEntityByID(playerDisplay.ent2ID)
                if digit1Entity and digit2Entity then
                    local function callback()
                        digit1Entity:ScheduleAppearanceChange(tostring(tens))
                        digit2Entity:ScheduleAppearanceChange(tostring(ones))
                    end
                    Cron.After(2.0, callback)
                end
            end
        end
    end

    --detect new split hands as they happen
    if HandCountDisplay.playerActiveHands ~= #SingleRoundLogic.playerHands then
        DualPrint('HCD | HandCountDisplay.playerActiveHands: '..tostring(HandCountDisplay.playerActiveHands))
        DualPrint('HCD | #SingleRoundLogic.playerHands: '..tostring(#SingleRoundLogic.playerHands))
        if HandCountDisplay.playerActiveHands < #SingleRoundLogic.playerHands then
            for i = HandCountDisplay.playerActiveHands+1, #SingleRoundLogic.playerHands do
                DualPrint('HCD |  i: '..tostring(i))
                displayStartup(false, i)
            end
        end
        HandCountDisplay.playerActiveHands = #SingleRoundLogic.playerHands
    end

    --detect new dealer hand reveal
    if SingleRoundLogic.dealerHandRevealed and not HandCountDisplay.displays['dealerHand'].enabled then
        displayStartup(true)
    end
end

function HandCountDisplay.init()
    HandCountDisplay.displays['playerHand1'] = {value=0, appValue=0, enabled=false, ent1ID=nil, ent2ID=nil}
    HandCountDisplay.displays['playerHand2'] = {value=0, appValue=0, enabled=false, ent1ID=nil, ent2ID=nil}
    HandCountDisplay.displays['playerHand3'] = {value=0, appValue=0, enabled=false, ent1ID=nil, ent2ID=nil}
    HandCountDisplay.displays['playerHand4'] = {value=0, appValue=0, enabled=false, ent1ID=nil, ent2ID=nil}
    HandCountDisplay.displays['dealerHand'] = {value=0, appValue=0, enabled=false, ent1ID=nil, ent2ID=nil}
end
function HandCountDisplay.update()
    if HandCountDisplay.displayEnabled then
        updateEachDisplay()
    end
end

--- Enables or disables the entire display
---@param bool boolean true/false, turns display numbers on or off.
function HandCountDisplay.DisplayEnabled(bool)
    if bool then
        for i, hand in pairs(SingleRoundLogic.playerHands) do
            displayStartup(false, i)
        end
        HandCountDisplay.displayEnabled = true
        HandCountDisplay.playerActiveHands = #SingleRoundLogic.playerHands
    else
        displayShutdown(true)
        for i, hand in pairs(SingleRoundLogic.playerHands) do
            displayShutdown(false, i)
        end
        HandCountDisplay.displayEnabled = false
    end
end


return HandCountDisplay