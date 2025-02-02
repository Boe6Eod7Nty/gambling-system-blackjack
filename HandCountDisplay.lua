HandCountDisplay = {
    version = '1.0.0',
    displayEnabled = false,
    displays = {}
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

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

--- Spawns 2 digits for a hand count display
---@param isDealer boolean true/false, is the dealer's hand?
---@param handIndex number? hand number to display count for
local function displayStartup(isDealer, handIndex)
    if isDealer then
        local card1pos = calculateDisplayOrigin(true)
        local card2pos = Vector4.new(card1pos.x-0.04, card1pos.y, card1pos.z, 1)
        local card1app = "0"
        local card2app = "0"
        HandCountDisplay.displays['dealerHand'].enabled = true
        local value = HandCountDisplay.displays['dealerHand'].value
        value = SingleRoundLogic.dealerCardsValue
        if value ~= 0 then
            local tens = math.floor(value / 10)
            local ones = value % 10
            card1app = tostring(tens)
            card2app = tostring(ones)
            HandCountDisplay.displays['dealerHand'].appValue = value
        end
        HandCountDisplay.SpawnDigit("dealerDigit_h1_c1", card1app, card1pos, orientation)
        HandCountDisplay.SpawnDigit("dealerDigit_h1_c2", card2app, card2pos, orientation)
    end
    if handIndex then
        --pass
    end
end

---Update display values to match current card's hand's values
local function updateEachDisplay()
    HandCountDisplay.displays['dealerHand'].value = SingleRoundLogic.dealerCardsValue
    for i, hand in pairs(SingleRoundLogic.playerHands) do
        HandCountDisplay.displays['playerHand'..tostring(i)].value = SingleRoundLogic.playerCardsValue[i]
    end
    for i, display in pairs(HandCountDisplay.displays) do
        if display.appValue ~= display.value then
            local tens = math.floor(display.value / 10)
            local ones = display.value % 10
            display.appValue = display.value
            print(string.format("Value: %02d, Tens: %d, Ones: %d", display.value, tens, ones) .. tostring())
        end
    end
end

function HeadCountDisplay.init()
    HandCountDisplay.displays['playerHand1'] = {value=0, appValue=0, enabled=false}
    HandCountDisplay.displays['playerHand2'] = {value=0, appValue=0, enabled=false}
    HandCountDisplay.displays['playerHand3'] = {value=0, appValue=0, enabled=false}
    HandCountDisplay.displays['playerHand4'] = {value=0, appValue=0, enabled=false}
    HandCountDisplay.displays['dealerHand'] = {value=0, appValue=0, enabled=false}
end
function HeadCountDisplay.update()
    if HandCountDisplay.displayEnabled then
        updateEachDisplay()
    end
end



return HandCountDisplay