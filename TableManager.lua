TableManager = {
    version = '1.0.0',
    activeTableID = nil,
    dealerEntIDs = {}, -- Track dealer entity IDs per table: dealerEntIDs[tableID] = entID
    dealerSpawned = {} -- Track spawn state per table: dealerSpawned[tableID] = true/false
}

-- Required modules for spot creation
local RelativeCoordinateCalulator = require('RelativeCoordinateCalulator.lua')
local SpotManager = require('SpotManager.lua')
local HolographicValueDisplay = require('HolographicValueDisplay.lua')
local CardEngine = require('CardEngine.lua')
local BlackjackMainMenu = require("BlackjackMainMenu.lua")
local GameLocale = require("External/GameLocale.lua")
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

---Initializes the TableManager
function TableManager.init()
    -- TODO: Initialize table management system
end

---Loads tables from BlackjackCoordinates
function TableManager.LoadTables()
    -- TODO: Load tables registered in BlackjackCoordinates
end

---Sets the active table
---@param tableID string tableID to set as active
function TableManager.SetActiveTable(tableID)
    TableManager.activeTableID = tableID
end

---Clears the active table
function TableManager.ClearActiveTable()
    TableManager.activeTableID = nil
end

---Gets the currently active table ID
---@return string|nil active table ID or nil if no table is active
function TableManager.GetActiveTable()
    return TableManager.activeTableID
end

--- Spawns NPC dealer behind the blackjack table.
---@param tableID string table ID to spawn dealer at
function TableManager.spawnDealer(tableID)
    if TableManager.dealerSpawned[tableID] then
        return -- Dealer already spawned for this table
    end
    
    local RelativeCoordinateCalulator = require('RelativeCoordinateCalulator.lua')
    local dealerPosition, dealerOrientation = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, 'dealer_spawn_position')
    local dynamicEntitySystem = Game.GetDynamicEntitySystem()
    local spec = DynamicEntitySpec.new()
    spec.recordID = "Character.sts_wat_kab_07_croupiers"
    spec.appearanceName = "Random"
    spec.position = dealerPosition
    spec.orientation = dealerOrientation
    spec.tags = {"Blackjack","dealer"};
    local entID = dynamicEntitySystem:CreateEntity(spec)
    
    TableManager.dealerEntIDs[tableID] = entID
    TableManager.dealerSpawned[tableID] = true
end

--- Despawns the dealer for a specific table
---@param tableID string table ID to despawn dealer for
function TableManager.despawnDealer(tableID)
    if not TableManager.dealerSpawned[tableID] then
        return -- No dealer spawned for this table
    end
    
    local entID = TableManager.dealerEntIDs[tableID]
    if entID ~= nil then
        Game.GetDynamicEntitySystem():DeleteEntity(entID)
        TableManager.dealerEntIDs[tableID] = nil
    end
    TableManager.dealerSpawned[tableID] = false
end

--- Cleans up all dealers across all tables
function TableManager.cleanupAllDealers()
    for tableID, _ in pairs(TableManager.dealerSpawned) do
        TableManager.despawnDealer(tableID)
    end
end

--- Checks if a dealer is spawned for a specific table
---@param tableID string table ID to check
---@return boolean true if dealer is spawned for this table
function TableManager.isDealerSpawned(tableID)
    return TableManager.dealerSpawned[tableID] == true
end

--- Gets the dealer entity ID for a specific table
---@param tableID string table ID
---@return EntityID|nil dealer entity ID or nil if not spawned
function TableManager.getDealerEntID(tableID)
    return TableManager.dealerEntIDs[tableID]
end

return TableManager