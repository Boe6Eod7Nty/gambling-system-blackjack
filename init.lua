-- v0.1.0
--===================
--Copyright (c) 2025 Boe6
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
--TweakXL
--===================

--Modules
--=======
GameLocale = require("External/GameLocale.lua") --Psiberx's language script from 'cet-kit'github
CardEngine = require('CardEngine.lua') --Card Entity Handler
local Cron = require('External/Cron.lua') --Time handling
local interactionUI = require("External/interactionUI.lua")
local GameUI = require("External/GameUI.lua") --Reactive Game UI State Observer
local SpotManager = require('SpotManager.lua') --workspot management
local SingleRoundLogic = require('singleRoundLogic.lua') --Handles 1 round of blackjack
local BlackjackMainMenu = require("BlackjackMainMenu.lua")
local HolographicValueDisplay = require('HolographicValueDisplay.lua')
local SimpleCasinoChip = require('SimpleCasinoChip.lua')
local HandCountDisplay = require('HandCountDisplay.lua')

local inMenu = true --libaries requirement
local inGame = false
local dealerEntID = nil
Global_temp_Counter_ent = nil
local temp_counter_app = 0
local dealerSpawned = false

GamblingSystemBlackjack = {
    loaded = false,
    ready = false
}

--Functions
--=========
--- Prints string to both CET console and local .log file
---@param string string String to print
function DualPrint(string) --prints to both CET console and local .log file
    if not string then return end
    print('[Gambling System] ' .. string) -- CET console
    spdlog.error('[Gambling System] ' .. string) -- .log
end

--[[    removed due to bugged. future fix.
            NPC ends up breifly T-posing before animation starts.
            My guess is the transitions aren't setup correctly
                likely the wrong .anims file linked to the .workspot file, i hope.
local function attachedDealerToWorkspot()
    local dynamicEntitySystem = Game.GetDynamicEntitySystem()
    local foldHandsEntPath = "boe6\\gamblingsystemblackjack\\npc_handsfolded_workspot.ent"
    local spec2 = DynamicEntitySpec.new()
    spec2.templatePath = foldHandsEntPath
    spec2.position = Vector4.new(-1041.247,1339.675,5.283,1)
    spec2.orientation = EulerAngles.new(0.0, 0.0, 180.0):ToQuat()
    spec2.tags = {"Blackjack","dealerAnimation"}
    local animEntID = dynamicEntitySystem:CreateEntity(spec2)
    local function callback1()
        local npcEntity = Game.FindEntityByID(dealerEntID)
        local animEntity = Game.FindEntityByID(animEntID)
        local workspotSystem = Game.GetWorkspotSystem()
        workspotSystem:PlayInDevice(animEntity, npcEntity) --Play workspot
    end
    Cron.After(0.5, callback1)
end
]]--

--- Spawns NPC dealer behind the blackjack table.
local function spawnNPCdealer()
    local dynamicEntitySystem = Game.GetDynamicEntitySystem()
    local spec = DynamicEntitySpec.new()
    spec.recordID = "Character.sts_wat_kab_07_croupiers"
    spec.appearanceName = "Random"
    spec.position = Vector4.new(-1041.247,1339.675,5.283,1)
    spec.orientation = EulerAngles.new(0.0, 0.0, 0.0):ToQuat()
    --spec.persistState = true;
    --spec.persistSpawn = true;
    spec.tags = {"Blackjack","dealer"};
    dealerEntID = dynamicEntitySystem:CreateEntity(spec)
end

-- Register Events
--================
registerForEvent( "onInit", function() 
    SpotManager.init()
    CardEngine.init()
    interactionUI.init()
	GameLocale.Initialize()
    HandCountDisplay.init()

    -- Setup observer and GameUI to detect inGame / inMenu, credit: keanuwheeze | init.lua from the sitAnywhere mod
    Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu)
        inMenu = isInMenu
    end)
    --Setup observer and GameUI to detect inGame / inMenu
    --credit: keanuwheeze | init.lua from the sitAnywhere mod
    inGame = false
    GameUI.OnSessionStart(function()
        inGame = true
    end)
    GameUI.OnSessionEnd(function()
        inGame = false
    end)
    inGame = not GameUI.IsDetached() -- Required to check if ingame after reloading all mods

    -- Define Hooh location
    local worldPinUI = {
        position = Vector4.new(-1041.2463, 1341.5469, 6.21331358, 1)
    }
    local animObj = {
        position = Vector4.new(-1041.2463, 1341.5469, 5.2774734, 1),
        orientation = {x=0,y=0,z=0},
        templatePath = "boe6\\gamblingsystemblackjack\\sit_workspot.ent",
        defaultAnim = "sit_chair_table_lean0__2h_on_table__01",
        exitAnim = "sit_chair_table_lean0__2h_on_table__01__to__stand__2h_on_sides__01__turn0l__01",
        exitTime = 2.5
    }
    SpotManager.AddSpot('hooh', worldPinUI, animObj)

    -- Save and Load detection, coutesy of psiberx; available in #cet-snippets in discord
    local isLoaded = Game.GetPlayer() and Game.GetPlayer():IsAttached() and not Game.GetSystemRequestsHandler():IsPreGame()
    Observe('QuestTrackerGameController', 'OnInitialize', function()
        if not isLoaded then
            --save loaded and launched
            --DualPrint('Game Session Started')
            isLoaded = true

            --reset all variables to default to avoid save/load bugs
            SingleRoundLogic.dealerCardCount = 0
            SingleRoundLogic.dealerBoardCards = {}
            SingleRoundLogic.playerHands = {{}}
            SingleRoundLogic.activePlayerHandIndex = 1
            SingleRoundLogic.bustedHands = {false,false,false,false}
            SingleRoundLogic.blackjackHandsPaid = {false,false,false,false}
            SingleRoundLogic.doubledHands = {false,false,false,false}
            SingleRoundLogic.dealerHandRevealed = false
            SpotManager.forcedCam = false
            StatusEffectHelper.RemoveStatusEffect(GetPlayer(), "GameplayRestriction.NoCameraControl")
            if not dealerSpawned then
                spawnNPCdealer()
                dealerSpawned = true
            end

            interactionUI.hideHub()
        end
    end)
    Observe('QuestTrackerGameController', 'OnUninitialize', function()
        if Game.GetPlayer() == nil then
            --loading new save initiated
            --print('Game Session Ended')
            isLoaded = false

            Game.GetDynamicEntitySystem():DeleteEntity(dealerEntID)
            dealerSpawned = false
        end
    end)
end)
registerForEvent('onUpdate', function(dt)
    if  not inMenu and inGame then
        Cron.Update(dt)
        SpotManager.update(dt)
        CardEngine.update(dt)
        interactionUI.update()
        HolographicValueDisplay.Update()
        BlackjackMainMenu.Update()
        HandCountDisplay.update()
        SingleRoundLogic.update()
    end
end)
registerHotkey('DevHotkey1', 'Dev Hotkey 1', function()
    DualPrint('||=1  Dev hotkey 1 Pressed =')

    SpotManager.ExitSpot('hooh')
    BlackjackMainMenu.playerChipsMoney = 0
end)
registerHotkey('DevHotkey2', 'Dev Hotkey 2', function()
    DualPrint('||=2  Dev hotkey 2 Pressed =')
    -- in case I need them script graveyard

    --[[
    local cardID = CardEngine.CreateCard('TEMP', '7h', Vector4.new(-1041.759, 1340.121, 6.085, 1), { r = 0, p = 180, y = -90 })
    Cron.After(1, function()
        DualPrint('cardID: '..cardID)
    end)]]--

    --CardEngine.DeleteCard('TEMP')
    --[[
    for i=1, SingleRoundLogic.playerCardCount do
        CardEngine.DeleteCard('pCard'..string.format("%02d", i))
    end
    for i=1, SingleRoundLogic.dealerCardCount do
        CardEngine.DeleteCard('dCard'..string.format("%02d", i))
    end]]--

    --CardEngine.PrintAllCards(true)

    --spawnNPCdealer()
    --Game.GetDynamicEntitySystem():DeleteEntity(dealerEntID)
end)
registerHotkey('DevHotkey3', 'Dev Hotkey 3', function()
    DualPrint('||=3  Dev hotkey 3 Pressed =')

    local spec = StaticEntitySpec.new()
    spec.templatePath = "boe6\\gamblingsystemblackjack\\boe6_number_digit_vanilla.ent"
    spec.appearanceName = "0"
    spec.position = Vector4.new(-1041.175, 1340.821, 6.085, 1)
    spec.orientation = EulerAngles.new(0,60,0):ToQuat()
    spec.tags = {"ValueCounter"}

    Global_temp_Counter_ent = Game.GetStaticEntitySystem():SpawnEntity(spec)
end)
registerHotkey('DevHotkey4', 'Dev Hotkey 4', function()
    DualPrint('||=4  Dev hotkey 4 Pressed =')

    temp_counter_app = temp_counter_app + 1
    if temp_counter_app > 9 then
        temp_counter_app = 0
    end
    local entity = Game.FindEntityByID(Global_temp_Counter_ent)
    entity:ScheduleAppearanceChange(tostring(temp_counter_app))
    DualPrint('app changed to: '..tostring(temp_counter_app))
end)
registerHotkey('DevHotkey5', 'Dev Hotkey 5', function()
    DualPrint('||=5  Dev hotkey 5 Pressed =')

    local spec = StaticEntitySpec.new()
    spec.templatePath = "boe6\\gamblingsystemblackjack\\boe6_number_digit_vanilla.ent"
    spec.appearanceName = "8"
    spec.position = Vector4.new(-1041.215, 1340.821, 6.085, 1)
    spec.orientation = EulerAngles.new(0,60,0):ToQuat()
    spec.tags = {"ValueCounter"}

    local secondNumberSpotted = Game.GetStaticEntitySystem():SpawnEntity(spec)

end)
registerHotkey('DevHotkey6', 'Dev Hotkey 6', function()
    DualPrint('||=6  Dev hotkey 6 Pressed =')

    DualPrint('HandCountDisplay.displays[\'dealerHand\'].value: '..tostring(HandCountDisplay.displays['dealerHand'].value))
    DualPrint('SingleRoundLogic.dealerCardsValue: '..tostring(SingleRoundLogic.dealerCardsValue))
end)
registerHotkey('DevHotkey7', 'Dev Hotkey 7', function()
    DualPrint('||=7  Dev hotkey 7 Pressed =')

end)
registerHotkey('DevHotkey8', 'Dev Hotkey 8', function()
    DualPrint('||=8  Dev hotkey 8 Pressed =')

end)
registerHotkey('DevHotkey9', 'Dev Hotkey 9', function()
    DualPrint('||=9  Dev hotkey 9 Pressed =')

    Cron.After(2, function()
        SingleRoundLogic.startRound(Vector4.new(-1041.759, 1340.121, 6.085, 1), { r = 0, p = 180, y = -90 })
    end)
end)

--[[ animations tested
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


--End of File
--===========
return GamblingSystemBlackjack