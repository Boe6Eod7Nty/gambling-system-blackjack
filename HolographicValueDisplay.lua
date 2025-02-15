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

local chipsStackHoloProjector = "boe6\\gamblingsystemblackjack\\q303_chips_stacks_edit.ent"
local holographicDigit = "boe6\\gamblingsystemblackjack\\boe6_number_digit.ent"

local holoActive = false
local currentValue = 0
local digitCount = 1
local digitSpacing = 0.03
local digitBottomMargin = 0.1
local holoEntityID = nil
local holoChipsEntityID = nil
local holoCenter = nil
local holoFacingAngle = nil
local animationJumpDivisor = 30 --adjusts the speed of the animation

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

---Returns the nth digit of a number
---@param numberX number number to count digits of
---@param indexY integer index of digit to return
---@return integer digit digit at specified index
local function nthNumber(numberX, indexY)
    for i = 1, indexY - 1 do
        numberX = math.floor(numberX / 10)  -- Integer division to remove rightmost digit
    end
    return numberX % 10  -- Modulo to get the rightmost digit
end

---Create digit's entity and store entID in digits[]
---@param id any unique id for entity
---@param digitValue string interger as string for digit appearance
---@param positionVector4 Vector4 world position
---@param orientationRPY any orientationRPY table
local function createDigitEntity(id, digitValue, positionVector4, orientationRPY)
    local spec = StaticEntitySpec.new()
    spec.templatePath = holographicDigit
    spec.appearanceName = digitValue
    spec.position = positionVector4
    spec.orientation = EulerAngles.new(orientationRPY.r,orientationRPY.p,orientationRPY.y):ToQuat()
    spec.tags = {"HolographicDisplay",tostring(id)}

    local entityID = Game.GetStaticEntitySystem():SpawnEntity(spec)
    HolographicValueDisplay.digits[id] = { id = id, entID = entityID }
end

--- Given digit's id, despawn and remove from digits[]
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
    if holoCenter == nil then
        --shouldn't ever trigger
        holoCenter = Vector4.new(-1040.733, 1340.121, 6.085, 1)
    end
    local digitPosition = Vector4.new(
        holoCenter.x + xOffset,
        holoCenter.y + yOffset,
        holoCenter.z + digitBottomMargin,
        holoCenter.w
    )
    return digitPosition
end

--- Updates the display's value
function HolographicValueDisplay.Update(targetValue)
    if not holoActive then
        return
    elseif targetValue == nil then
        return
    elseif currentValue == targetValue then
        return
    end

    local difference = targetValue - currentValue
    local divided = math.floor(difference / animationJumpDivisor)
    if math.abs(difference) < animationJumpDivisor then
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

---Spawns the initial display of the player's chips. (zero)
---@param locationVector4 Vector4 world position of display stand
---@param facingDirectionAngle number 360 degree angle(yaw) of display stand's facing direction.
function HolographicValueDisplay.startDisplay(locationVector4, facingDirectionAngle)
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
    holoEntityID = Game.GetStaticEntitySystem():SpawnEntity(spec) --spawn holodisplay chip stand

    local spec2 = StaticEntitySpec.new()
    spec2.templatePath = holographicDigit
    spec2.appearanceName = 'chips'
    spec2.position = Vector4.new(holoCenter.x,holoCenter.y,holoCenter.z + (digitBottomMargin*1.5),holoCenter.w)
    spec2.orientation = EulerAngles.ToQuat(EulerAngles.new(0,0,holoFacingAngle+180))
    spec2.tags = {"HolographicDisplay","chips"}
    holoChipsEntityID = Game.GetStaticEntitySystem():SpawnEntity(spec2) --spawn holodisplay chips sign


    createDigitEntity(1, '0', digit1Position, {r=0, p=0, y=holoFacingAngle+180}) --spawn 0 digit
end

---Stop showing the holographic display
function HolographicValueDisplay.stopDisplay()

    holoActive = false
    for i, j in pairs(HolographicValueDisplay.digits) do
        destroyDigitEntity(i)
    end
    Game.GetStaticEntitySystem():DespawnEntity(holoEntityID)
    Game.GetStaticEntitySystem():DespawnEntity(holoChipsEntityID)

end

return HolographicValueDisplay