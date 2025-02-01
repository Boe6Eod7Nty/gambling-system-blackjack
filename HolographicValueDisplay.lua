HolographicValueDisplay = {
    version = '1.0.0',
    digits = {}
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

local Cron = require('External/Cron.lua')

local chipsStackHoloProjector = "boe6\\gamblingsystemblackjack\\q303_chips_stacks_edit.ent"
local holographicDigit = "boe6\\gamblingsystemblackjack\\boe6_number_digit.ent"

local holoActive = false
local currentValue = 0
local digitCount = 1
local digitSpacing = 0.03
local digitBottomMargin = 0.1
local holoEntityID = nil
local holoCenter = Vector4.new(-1040.733, 1340.121, 6.085, 1) --default value to avoid nil errors
local holoFacingAngle = nil

---Counts the number of digits in a number
---@param number number number to count digits of
---@return integer number count of digits
local function countDigits(number)
    if number == 0 then
        return 1
    end
    number = math.abs(number)
    local count = 0
    while number > 0 do
        number = math.floor(number / 10)
        count = count + 1
    end
    return count
end

local function nthNumber(numberX, indexY)
    for i = 1, indexY - 1 do
        numberX = math.floor(numberX / 10)  -- Integer division to remove rightmost digit
    end
    return numberX % 10  -- Modulo to get the rightmost digit
end

local function createDigitEntity(id, digitValue, positionVector4, orientationRPY)
    local spec = StaticEntitySpec.new()
    spec.templatePath = holographicDigit
    spec.appearanceName = digitValue
    spec.position = positionVector4
    spec.orientation = EulerAngles.ToQuat(EulerAngles.new(orientationRPY.r,orientationRPY.p,orientationRPY.y))
    spec.tags = {"HolographicDisplay",tostring(id)}

    local entityID = Game.GetStaticEntitySystem():SpawnEntity(spec)
    HolographicValueDisplay.digits[id] = { id = id, entID = entityID }
end


local function destroyDigitEntity(id)
    Game.GetStaticEntitySystem():DespawnEntity(HolographicValueDisplay.digits[id].entID)
    HolographicValueDisplay.digits[id] = nil
end

--- Calculates the world position of a digit, given center, offset, and angle.
---@param numberLength number number of digits in parent number
---@param digitTensPlace number index, starting from right, of digit in parent number
local function digitWorldPositionV4(numberLength, digitTensPlace)
    local angle = holoFacingAngle * math.pi / 180
    local halfLength = (numberLength - 1) / 2
    local digitOffset = (digitTensPlace - 1) - halfLength
    local xOffset = digitOffset * digitSpacing * math.cos(angle)
    local yOffset = digitOffset * digitSpacing * math.sin(angle)
    local digitPosition = Vector4.new(
        holoCenter.x + xOffset,
        holoCenter.y + yOffset,
        holoCenter.z + digitBottomMargin,
        holoCenter.w
    )
    return digitPosition
end

function HolographicValueDisplay.Update()
    if not holoActive then
        return
    elseif BlackjackMainMenu.playerChipsMoney == nil then
        return
    elseif currentValue == BlackjackMainMenu.playerChipsMoney then
        return
    end

    local targetValue = BlackjackMainMenu.playerChipsMoney

    local animationJump = 30 --adjusts the speed of the animation
    local difference = targetValue - currentValue
    local divided = math.floor(difference / animationJump)
    if math.abs(difference) < animationJump then
        if difference > 0 then
            targetValue = currentValue + 1
        elseif difference < 0 then
            targetValue = currentValue - 1
        end
    else
        targetValue = currentValue + divided
    end

    local startingDigits = countDigits(currentValue)
    local targetDigits = countDigits(targetValue)
    currentValue = targetValue
    if targetDigits == startingDigits then
        -- SAME DIGIT COUNT
        for i, j in pairs(HolographicValueDisplay.digits) do
            local digitValue = nthNumber(targetValue, i)
            local entity = Game.FindEntityByID(j.entID)
            if entity then
                entity:ScheduleAppearanceChange(tostring(digitValue))
            end
        end
    elseif targetDigits > startingDigits then
        -- MORE DIGITS
        local amountNewDigits = targetDigits - startingDigits
        for i = 1, amountNewDigits do
            local digitValue = nthNumber(targetValue, startingDigits + i)
            local digitPosition = digitWorldPositionV4(targetDigits, startingDigits + i)
            createDigitEntity(startingDigits + i, tostring(digitValue), digitPosition, {r=0,p=0,y=holoFacingAngle+180})
        end
        for i = 1, startingDigits do
            local digitValue = nthNumber(targetValue, i)
            local entity = Game.FindEntityByID(HolographicValueDisplay.digits[i].entID)
            if entity then
                entity:ScheduleAppearanceChange(tostring(digitValue))
            end
            local digitPosition = digitWorldPositionV4(targetDigits, i)
            local EulerAngles = EulerAngles.new(0, 0, holoFacingAngle+180)
            Game.GetTeleportationFacility():Teleport(entity, digitPosition, EulerAngles)
        end
    elseif targetDigits < startingDigits then
        -- LESS DIGITS
        local amountDeletedDigits = startingDigits - targetDigits
        for i = 1, amountDeletedDigits do
            destroyDigitEntity(targetDigits + i)
        end
        for i = 1, targetDigits do
            local digitValue = nthNumber(targetValue, i)
            local entity = Game.FindEntityByID(HolographicValueDisplay.digits[i].entID)
            if entity then
                entity:ScheduleAppearanceChange(tostring(digitValue))
            end
            local digitPosition = digitWorldPositionV4(targetDigits, i)
            local EulerAngles = EulerAngles.new(0, 0, holoFacingAngle+180)
            Game.GetTeleportationFacility():Teleport(entity, digitPosition, EulerAngles)
        end
    end
end

function HolographicValueDisplay.startDisplay(locationVector4, facingDirectionAngle)
    --spawn holodisplay chip stand

    --spawn 0 digit

    --add id to list, associated with watchedVariable

    holoActive = true
    currentValue = 0
    digitCount = 1
    holoCenter = locationVector4
    holoFacingAngle = facingDirectionAngle

    local spec = StaticEntitySpec.new()
    spec.templatePath = chipsStackHoloProjector
    spec.appearanceName = 'default'
    spec.position = locationVector4
    spec.orientation = EulerAngles.ToQuat(EulerAngles.new(0,0,holoFacingAngle+180))
    spec.tags = {"HolographicDisplay","ProjectorStand"}

    holoEntityID = Game.GetStaticEntitySystem():SpawnEntity(spec)
    local digit1Position = digitWorldPositionV4(1, 1)
    createDigitEntity(1, '0', digit1Position, {r=0, p=0, y=holoFacingAngle+180})

    --DualPrint('HVD | '..tostring(digitWorldPositionV4(locationVector4, facingDirectionAngle, 4, 1)))
end

function HolographicValueDisplay.stopDisplay()

    holoActive = false
    for i, j in pairs(HolographicValueDisplay.digits) do
        destroyDigitEntity(i)
    end
    Game.GetStaticEntitySystem():DespawnEntity(holoEntityID)

end

return HolographicValueDisplay