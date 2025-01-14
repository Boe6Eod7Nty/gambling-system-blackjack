BlackjackMainMenu = {
    version = '1.0.0',
    playerChipsMoney = 0,
    previousBet = nil
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

local Cron = require('External/Cron.lua')
local interactionUI = require("External/interactionUI.lua")

local chip_values = {1,5,10,25,50,100,250,500,1000,2500,5000,10000,25000,50000,250000,1000000}
local chip_valuesStr = {"$1", "$5", "$10", "$25", "$50", "$100", "$250", "$500", "$1,000", "$2,500", "$5,000", "$10,000", "$25,000", "$50,000", "$250,000", "$1,000,000"}
local buy_values = {5,10,25,50,100,250,500,1000,2500,5000,10000,25000,50000,250000,1000000}
local buy_valuesStr = {"$5", "$10", "$25", "$50", "$100", "$250", "$500", "$1,000", "$2,500", "$5,000", "$10,000", "$25,000", "$50,000", "$250,000", "$1,000,000", "$10,000,000"}

local function newBetUI(refMidIndex)
    --local playerMoney = Game.GetTransactionSystem():GetItemQuantity(GetPlayer(), MarketSystem.Money())
    local playerMoney = BlackjackMainMenu.playerChipsMoney
    local oneText = chip_valuesStr[refMidIndex - 1]
    local twoText = chip_valuesStr[refMidIndex]
    local thrText = chip_valuesStr[refMidIndex + 1]
    local lowChoiceType = gameinteractionsChoiceType.AlreadyRead
    local oneChoiceType = gameinteractionsChoiceType.AlreadyRead
    local twoChoiceType = gameinteractionsChoiceType.AlreadyRead
    local thrChoiceType = gameinteractionsChoiceType.AlreadyRead
    local hihChoiceType = gameinteractionsChoiceType.AlreadyRead
    if refMidIndex > 3 then
        lowChoiceType = gameinteractionsChoiceType.Selected
    end
    if playerMoney >= chip_values[refMidIndex - 1] then
        oneChoiceType = gameinteractionsChoiceType.Selected
    end
    if playerMoney >= chip_values[refMidIndex] then
        twoChoiceType = gameinteractionsChoiceType.Selected
    end
    if playerMoney >= chip_values[refMidIndex + 1] then
        thrChoiceType = gameinteractionsChoiceType.Selected
    end
    if refMidIndex < 15 then
        hihChoiceType = gameinteractionsChoiceType.Selected
    end
    local choice1 = interactionUI.createChoice("Lower", nil, lowChoiceType)
    local choice2 = interactionUI.createChoice(oneText, nil, oneChoiceType)
    local choice3 = interactionUI.createChoice(twoText, nil, twoChoiceType)
    local choice4 = interactionUI.createChoice(thrText, nil, thrChoiceType)
    local choice5 = interactionUI.createChoice("Higher", nil, hihChoiceType)
    local choice6 = interactionUI.createChoice("Back", nil, gameinteractionsChoiceType.Selected)
    local hub = interactionUI.createHub("Blackjack", {choice1, choice2, choice3, choice4, choice5, choice6})
    interactionUI.setupHub(hub)
    interactionUI.showHub()
    interactionUI.callbacks[1] = function()--Lower
        if refMidIndex > 3 then
            interactionUI.hideHub()
            newBetUI(refMidIndex - 2)
        end
    end
    interactionUI.callbacks[2] = function()--One
        if playerMoney >= chip_values[refMidIndex - 1] then
            interactionUI.hideHub()
            --DO STUFF
        end
    end
    interactionUI.callbacks[3] = function()--Two
        if playerMoney >= chip_values[refMidIndex] then
            interactionUI.hideHub()
            --DO STUFF
        end
    end
    interactionUI.callbacks[4] = function()--Three
        if playerMoney >= chip_values[refMidIndex + 1] then
            interactionUI.hideHub()
            --DO STUFF
        end
    end
    interactionUI.callbacks[5] = function()--Higher
        if refMidIndex < 15 then
            interactionUI.hideHub()
            newBetUI(refMidIndex + 2)
        end
    end
    interactionUI.callbacks[6] = function()--Back
        interactionUI.hideHub()
        BlackjackMainMenu.StartMainMenu()
    end
end

local function buyChipsUI(firstIndex)
    local playerMoney = Game.GetTransactionSystem():GetItemQuantity(GetPlayer(), MarketSystem.Money())
    local lowChoiceType = gameinteractionsChoiceType.AlreadyRead
    local oneChoiceType = gameinteractionsChoiceType.AlreadyRead
    local twoChoiceType = gameinteractionsChoiceType.AlreadyRead
    local thrChoiceType = gameinteractionsChoiceType.AlreadyRead
    local forChoiceType = gameinteractionsChoiceType.AlreadyRead
    local fivChoiceType = gameinteractionsChoiceType.AlreadyRead
    local hihChoiceType = gameinteractionsChoiceType.AlreadyRead
    if firstIndex > 1  then
        lowChoiceType = gameinteractionsChoiceType.Selected
    end
    if playerMoney >= chip_values[firstIndex] then
        oneChoiceType = gameinteractionsChoiceType.Selected
    end
    if playerMoney >= chip_values[firstIndex + 1] then
        twoChoiceType = gameinteractionsChoiceType.Selected
    end
    if playerMoney >= chip_values[firstIndex + 2] then
        thrChoiceType = gameinteractionsChoiceType.Selected
    end
    if playerMoney >= chip_values[firstIndex + 3] then
        forChoiceType = gameinteractionsChoiceType.Selected
    end
    if playerMoney >= chip_values[firstIndex + 4] then
        fivChoiceType = gameinteractionsChoiceType.Selected
    end
    if firstIndex < 11 then
        hihChoiceType = gameinteractionsChoiceType.Selected
    end
    local choice1 = interactionUI.createChoice("Lower", nil, lowChoiceType)
    local choice2 = interactionUI.createChoice(buy_valuesStr[firstIndex], nil, oneChoiceType)
    local choice3 = interactionUI.createChoice(buy_valuesStr[firstIndex + 1], nil, twoChoiceType)
    local choice4 = interactionUI.createChoice(buy_valuesStr[firstIndex + 2], nil, thrChoiceType)
    local choice5 = interactionUI.createChoice(buy_valuesStr[firstIndex + 3], nil, forChoiceType)
    local choice6 = interactionUI.createChoice(buy_valuesStr[firstIndex + 4], nil, fivChoiceType)
    local choice7 = interactionUI.createChoice("Higher", nil, hihChoiceType)
    local choice8 = interactionUI.createChoice("Back", nil, gameinteractionsChoiceType.Selected)
    local hub = interactionUI.createHub("Blackjack", {choice1, choice2, choice3, choice4, choice5, choice6, choice7, choice8})
    interactionUI.setupHub(hub)
    interactionUI.showHub()
    interactionUI.callbacks[1] = function()--Lower
        if firstIndex > 1 then
            interactionUI.hideHub()
            buyChipsUI(firstIndex - 5)
        end
    end
    interactionUI.callbacks[2] = function()--One
        if playerMoney >= chip_values[firstIndex] then
            interactionUI.hideHub()
            BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + buy_values[firstIndex]
            Game.AddToInventory("Items.money", -(buy_values[firstIndex]) )
            BlackjackMainMenu.StartMainMenu()
        end
    end
    interactionUI.callbacks[3] = function()--Two
        if playerMoney >= chip_values[firstIndex + 1] then
            interactionUI.hideHub()
            BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + buy_values[firstIndex + 1]
            Game.AddToInventory("Items.money", -(buy_values[firstIndex + 1]) )
            BlackjackMainMenu.StartMainMenu()
        end
    end
    interactionUI.callbacks[4] = function()--Three    
        if playerMoney >= chip_values[firstIndex + 2] then
            interactionUI.hideHub()
            BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + buy_values[firstIndex + 2]
            Game.AddToInventory("Items.money", -(buy_values[firstIndex + 2]) )
            BlackjackMainMenu.StartMainMenu()
        end
    end
    interactionUI.callbacks[5] = function()--Four
        if playerMoney >= chip_values[firstIndex + 3] then
            interactionUI.hideHub()
            BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + buy_values[firstIndex + 3]
            Game.AddToInventory("Items.money", -(buy_values[firstIndex + 3]) )
            BlackjackMainMenu.StartMainMenu()
        end
    end
    interactionUI.callbacks[6] = function()--Five
        if playerMoney >= chip_values[firstIndex + 4] then
            interactionUI.hideHub()
            BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + buy_values[firstIndex + 4]
            Game.AddToInventory("Items.money", -(buy_values[firstIndex + 4]) )
            BlackjackMainMenu.StartMainMenu()
        end
    end
    interactionUI.callbacks[7] = function()--Higher
        if firstIndex < 11 then
            interactionUI.hideHub()
            buyChipsUI(firstIndex + 5)
        end
    end
    interactionUI.callbacks[8] = function()--Back
        interactionUI.hideHub()
        BlackjackMainMenu.StartMainMenu()
    end
end

function BlackjackMainMenu.StartMainMenu()
    DualPrint('||=3  Blackjack Main Menu Pressed =')
    local playerMoney = Game.GetTransactionSystem():GetItemQuantity(GetPlayer(), MarketSystem.Money())
    local repeatChoiceType = gameinteractionsChoiceType.AlreadyRead
    local newChoiceType = gameinteractionsChoiceType.AlreadyRead
    local buyChoiceType = gameinteractionsChoiceType.AlreadyRead
    if BlackjackMainMenu.previousBet and BlackjackMainMenu.previousBet <= playerMoney then
        --repeatChoiceType = gameinteractionsChoiceType.Selected
    end
    if BlackjackMainMenu.playerChipsMoney >= 5 then
        newChoiceType = gameinteractionsChoiceType.Selected
    end
    if playerMoney >= 5 then
        buyChoiceType = gameinteractionsChoiceType.Selected
    end
    local choice1 = interactionUI.createChoice("Repeat Bet", nil, repeatChoiceType)
    local choice2 = interactionUI.createChoice("New Bet", nil, newChoiceType)
    local choice3 = interactionUI.createChoice("Buy Chips", nil, buyChoiceType)
    local choice4 = interactionUI.createChoice("Exit", nil, gameinteractionsChoiceType.Selected)
    local hub = interactionUI.createHub("Blackjack", {choice1, choice2, choice3, choice4})
    interactionUI.setupHub(hub)
    interactionUI.showHub()
    interactionUI.callbacks[1] = function()--Repeat
        if BlackjackMainMenu.previousBet and BlackjackMainMenu.previousBet <= playerMoney then
            --interactionUI.hideHub()
            --DO STUFF
        end
    end
    interactionUI.callbacks[2] = function()--New Bet
        if BlackjackMainMenu.playerChipsMoney >= 5 then
            interactionUI.hideHub()
            newBetUI(3)
        end
    end
    interactionUI.callbacks[3] = function()--Buy Chips
        if playerMoney >= 5 then
            interactionUI.hideHub()
            buyChipsUI(1)
        end
    end
    interactionUI.callbacks[4] = function()--Exit
        interactionUI.hideHub()
        SpotManager.ExitSpot('hooh')
        if BlackjackMainMenu.playerChipsMoney > 0 then
            Game.AddToInventory("Items.money", math.floor(BlackjackMainMenu.playerChipsMoney))
            BlackjackMainMenu.playerChipsMoney = 0
        end
    end

end


return BlackjackMainMenu