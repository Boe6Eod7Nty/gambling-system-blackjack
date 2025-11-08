RelativeCoordinateCalulator = {
    version = '1.0.0',
    registeredTables = {},
    registeredOffsets = {},
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

---Registers a table with the RelativeCoordinateCalulator
---@param tableID string tableID
---@param tablePosition Vector4 table position
---@param tableOrientation Quaternion table orientation
function RelativeCoordinateCalulator.registerTable(tableID, tablePosition, tableOrientation)
    RelativeCoordinateCalulator.registeredTables[tableID] = {
        position = tablePosition,
        orientation = tableOrientation,
    }
end

---Registers an offset with the RelativeCoordinateCalulator
---@param offsetID string offsetID
---@param offsetPosition Vector4 offset position
---@param offsetOrientation Quaternion offset orientation
function RelativeCoordinateCalulator.registerOffset(offsetID, offsetPosition, offsetOrientation)
    RelativeCoordinateCalulator.registeredOffsets[offsetID] = {
        position = offsetPosition,
        orientation = offsetOrientation,
    }
end

---Calculates the relative coordinate and rotation of an entity relative to a table
---@param tableID string tableID
---@param offsetID string offsetID
---@return Vector4 relativePosition world position
---@return Quaternion relativeOrientation world orientation
function RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, offsetID)
    local table = RelativeCoordinateCalulator.registeredTables[tableID]
    local offset = RelativeCoordinateCalulator.registeredOffsets[offsetID]
    -- Add the position of the offset to the world position of the table
    local relativePosition = Vector4.new(
        table.position.x + offset.position.x,
        table.position.y + offset.position.y,
        table.position.z + offset.position.z,
        table.position.w
    )
    -- Convert quaternions to EulerAngles, combine components, then convert back
    local tableEuler = table.orientation:ToEulerAngles()
    local offsetEuler = offset.orientation:ToEulerAngles()
    local combinedEuler = EulerAngles.new(
        tableEuler.roll + offsetEuler.roll,
        tableEuler.pitch + offsetEuler.pitch,
        tableEuler.yaw + offsetEuler.yaw
    )
    local relativeOrientation = combinedEuler:ToQuat()
    return relativePosition, relativeOrientation
end

return RelativeCoordinateCalulator