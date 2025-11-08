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
    -- Compose rotations properly: get basis vectors from offset, transform by table rotation
    -- This applies offset rotation first, then table rotation (equivalent to table * offset)
    local offsetForward = offset.orientation:GetForward()
    local offsetUp = offset.orientation:GetUp()
    
    -- Transform the offset's basis vectors by the table's rotation
    local transformedForward = table.orientation:Transform(offsetForward)
    local transformedUp = table.orientation:Transform(offsetUp)
    
    -- Build the composed quaternion from the transformed vectors
    local relativeOrientation = Quaternion.BuildFromDirectionVector(transformedForward, transformedUp)
    
    return relativePosition, relativeOrientation
end

return RelativeCoordinateCalulator