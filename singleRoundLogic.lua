SingleRoundLogic = {
    version = '1.0.0',
    deckShuffle = {},
    playerCardCount = 0,
    dealerCardCount = 0,
    playerBoardCards = {},
    dealerBoardCards = {}
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

local topOfDeckXYZ = {x=-1041.759, y=1340.121, z=6.105}
local pFirstCardXYZ = {x=-1041.189, y=1340.711, z=6.085}
local dFirstCardXYZ = {x=-1041.247, y=1340.205, z=6.085}
local standardOri = { r = 0, p = 0, y = -90 }

--Functions
--=========

---Shuffle the deck referenced for card order
local function shuffleDeckInternal()
    local allCards = {  'As','2s','3s','4s','5s','6s','7s','8s','9s','Ts','Js','Qs','Ks',
                        'Ah','2h','3h','4h','5h','6h','7h','8h','9h','Th','Jh','Qh','Kh',
                        'Ac','2c','3c','4c','5c','6c','7c','8c','9c','Tc','Jc','Qc','Kc',
                        'Ad','2d','3d','4d','5d','6d','7d','8d','9d','Td','Jd','Qd','Kd'}
    local newDeck = {}
    for i = 1, 52 do
        local selectedCard = math.random(#allCards)
        newDeck[i] = allCards[selectedCard]
        table.remove(allCards, selectedCard)
    end
    SingleRoundLogic.deckShuffle = newDeck
end

--- Animate first round deal.
local function dealStartOfRound()
    local pCard01app = SingleRoundLogic.deckShuffle[1]
    local pCard01cardID = CardEngine.CreateCard('pCard01', pCard01app, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1), { r = 0, p = 180, y = -90 })
    table.remove(SingleRoundLogic.deckShuffle,1)
    table.insert(SingleRoundLogic.playerBoardCards, pCard01app)
    local dCard01app = SingleRoundLogic.deckShuffle[1]
    local dCard01cardID = CardEngine.CreateCard('dCard01', dCard01app, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1), { r = 0, p = 180, y = -90 })
    table.remove(SingleRoundLogic.deckShuffle,1)
    table.insert(SingleRoundLogic.dealerBoardCards, dCard01app)
    local pCard02app = SingleRoundLogic.deckShuffle[1]
    local pCard02cardID = CardEngine.CreateCard('pCard02', pCard02app, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1), { r = 0, p = 180, y = -90 })
    table.remove(SingleRoundLogic.deckShuffle,1)
    table.insert(SingleRoundLogic.playerBoardCards, pCard02app)
    local dCard02app = SingleRoundLogic.deckShuffle[1]
    local dCard02cardID = CardEngine.CreateCard('dCard02', dCard02app, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1), { r = 0, p = 180, y = -90 })
    table.remove(SingleRoundLogic.deckShuffle,1)
    table.insert(SingleRoundLogic.dealerBoardCards, dCard02app)
    SingleRoundLogic.playerCardCount = SingleRoundLogic.playerCardCount + 2
    SingleRoundLogic.dealerCardCount = SingleRoundLogic.dealerCardCount + 2

    --begin animation below
    Cron.After(0.1, function()
        CardEngine.MoveCard('pCard01', Vector4.new(pFirstCardXYZ.x, pFirstCardXYZ.y, pFirstCardXYZ.z, 1), standardOri, 'smooth', true)
    end)
    Cron.After(0.5, function()
        CardEngine.MoveCard('dCard01', Vector4.new(dFirstCardXYZ.x, dFirstCardXYZ.y, dFirstCardXYZ.z, 1), standardOri, 'smooth', true)
    end)
    Cron.After(1.0, function()
        CardEngine.MoveCard('pCard02', Vector4.new(pFirstCardXYZ.x-0.04, pFirstCardXYZ.y-0.06, pFirstCardXYZ.z+0.0005, 1), standardOri, 'smooth', true)
    end)
    Cron.After(1.5, function()
        CardEngine.MoveCard('dCard02', Vector4.new(dFirstCardXYZ.x-0.005, dFirstCardXYZ.y+0.004, dFirstCardXYZ.z, 1), standardOri, 'smooth', false)
    end)
end

--- Animate all cards back to the deck & delete
local function collectRoundCards()
    for i = 1, SingleRoundLogic.playerCardCount do
        local curCard = 'pCard'..string.format("%02d", i)
        CardEngine.MoveCard(curCard, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1), standardOri, 'smooth', false)
    end
    for i = 1, SingleRoundLogic.dealerCardCount do
        local curCard = 'dCard'..string.format("%02d", i)
        CardEngine.MoveCard(curCard, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, dFirstCardXYZ.z, 1), standardOri, 'smooth', false)
    end
    Cron.After(2, function()
        for i = 1, SingleRoundLogic.playerCardCount do
            CardEngine.DeleteCard('pCard'..string.format("%02d", i))
        end
        for i = 1, SingleRoundLogic.dealerCardCount do
            CardEngine.DeleteCard('dCard'..string.format("%02d", i))
        end
    end)
end

---Check if the 2 card board is blackjack
---@param board table 2 card table list of card faces
---@return boolean
local function isBoardBJ(board)
    local twoCards = {string.sub(board[1],1,1),string.sub(board[2],1,1)}
    local totalValue = 0

    for i = 1, 2 do
        if twoCards[i] == 'T' or twoCards[i] == 'J' or twoCards[i] == 'Q' or twoCards[i] == 'K' then
            totalValue = totalValue + 10
        elseif twoCards[i] == 'A' then
            totalValue = totalValue + 11
        else
            totalValue = totalValue + tonumber(twoCards[i])
        end
    end

    if totalValue == 21 then
        return true
    else
        return false
    end
end

---Checks if the board is busted, aka over 21
---@param board table table list of card faces
---@return boolean
local function isBoardBusted(board)
    local runningTotal = 0
    for k,v in pairs(board) do
        if string.sub(v,1,1) == 'A' then
            runningTotal = runningTotal + 1
        elseif string.sub(v,1,1) == 'T' or string.sub(v,1,1) == 'J' or string.sub(v,1,1) == 'Q' or string.sub(v,1,1) == 'K' then
            runningTotal = runningTotal + 10
        else
            runningTotal = runningTotal + tonumber(string.sub(v,1,1))
        end
    end

    if runningTotal > 21 then
        return true
    else
        return false
    end
end

---Prompt player UI for turn action
---@param hitCallback function callback for when player hits
---@param standCallback function callback for when player stands
local function promptPlayerActionUI(hitCallback, standCallback)
    local choice1 = interactionUI.createChoice("Hit", nil, gameinteractionsChoiceType.Selected) --change from Selected to AlreadyRead later
    local choice2 = interactionUI.createChoice("Stand", nil, gameinteractionsChoiceType.Selected)
    --local choice3 = interactionUI.createChoice("Double", nil, gameinteractionsChoiceType.Selected)
    --local choice4 = interactionUI.createChoice("Split", nil, gameinteractionsChoiceType.Selected)
    --local choice5 = interactionUI.createChoice("Surrender", nil, gameinteractionsChoiceType.Selected)
    --local choice6 = interactionUI.createChoice("Insurance", nil, gameinteractionsChoiceType.Selected)

    local hub = interactionUI.createHub("Blackjack", {choice1, choice2})
    interactionUI.setupHub(hub)
    interactionUI.showHub()

    interactionUI.callbacks[1] = function()
        interactionUI.hideHub()
        hitCallback()
    end
    interactionUI.callbacks[2] = function()
        interactionUI.hideHub()
        standCallback()
    end
end

---Returns BJ game value of a set of cards
---@param board table table list of card faces
local function calculateBoardScore(board)
    --board = {"7h","Ts"} example
    local runningTotal = 0
    local aceCount = 0
    for k,card in pairs(board) do
        local rank = string.sub(card,1,1)
        if rank == 'A' then
            aceCount = aceCount + 1
        elseif rank == 'T' or rank == 'J' or rank == 'Q' or rank == 'K' then
            runningTotal = runningTotal + 10
        else
            runningTotal = runningTotal + tonumber(rank)
        end
    end

    for i = 1, aceCount do
        if runningTotal + 11 + (aceCount-i) <= 21 then
            runningTotal = runningTotal + 11
        else
            runningTotal = runningTotal + 1
        end
    end

    return runningTotal
end

---If the value of current cards is soft, aka using an Ace as an 11 instead of 1.
---@param board table table list of card faces
local function isBoardSoft(board)
    local runningTotal = 0
    local aceCount = 0
    local isSoft = false
    for k,card in pairs(board) do
        local rank = string.sub(card,1,1)
        if rank == 'A' then
            aceCount = aceCount + 1
        elseif rank == 'T' or rank == 'J' or rank == 'Q' or rank == 'K' then
            runningTotal = runningTotal + 10
        else
            runningTotal = runningTotal + tonumber(rank)
        end
    end

    for i = 1, aceCount do
        if runningTotal + 11 + (aceCount-i) <= 21 then
            runningTotal = runningTotal + 11
            isSoft = true
        else
            runningTotal = runningTotal + 1
        end
    end

    return isSoft
end

--- 1 Step of dealer's action. Hit/Stand
local function DealerAction()
    local score = calculateBoardScore(SingleRoundLogic.dealerBoardCards)
    local isSoft = isBoardSoft(SingleRoundLogic.dealerBoardCards)
    if score < 17 or (score == 17 and isSoft) then
        local dCardXapp = SingleRoundLogic.deckShuffle[1]
        local dCardXname = 'dCard'..string.format("%02d", SingleRoundLogic.dealerCardCount+1)
        local cardsNum = SingleRoundLogic.dealerCardCount
        table.remove(SingleRoundLogic.deckShuffle,1)
        local pCardXcardID = CardEngine.CreateCard(dCardXname,dCardXapp,Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, topOfDeckXYZ.z, 1),{ r = 0, p = 180, y = -90 })
        table.insert(SingleRoundLogic.dealerBoardCards, dCardXapp)
        local newLocation = Vector4.new(dFirstCardXYZ.x+((cardsNum-1)*0.09), dFirstCardXYZ.y, dFirstCardXYZ.z, 1)
        SingleRoundLogic.dealerCardCount = SingleRoundLogic.dealerCardCount + 1
        Cron.After(0.1, CardEngine.MoveCard(dCardXname, newLocation, standardOri, 'smooth', true))
        Cron.After(0.6, function()
            DealerAction()
        end)
    else
        --stand
        local playerScore = calculateBoardScore(SingleRoundLogic.playerBoardCards)
        if score > 21 then
            DualPrint('End Round: Dealer Busted!')
            Cron.After(5, collectRoundCards)
        elseif playerScore > score then
            DualPrint('End Round: Player Wins!')
            Cron.After(5, collectRoundCards)
        elseif playerScore < score then
            DualPrint('End Round: Dealer Wins!')
            Cron.After(5, collectRoundCards)
        else
            DualPrint('End Round: Tie!')
            Cron.After(5, collectRoundCards)
        end
    end
end

--- Start dealer's turn, animation then dealer action
local function startDealerTurn()
    Cron.After(0.1, function()
        CardEngine.MoveCard('dCard01', Vector4.new(dFirstCardXYZ.x+0.09, dFirstCardXYZ.y, dFirstCardXYZ.z, 1), standardOri, 'smooth', false)
    end)
    Cron.After(0.6, function()
        CardEngine.MoveCard('dCard01',Vector4.new(dFirstCardXYZ.x, dFirstCardXYZ.y, dFirstCardXYZ.z, 1), standardOri, 'smooth', false)
    end)
    Cron.After(0.8, function()
        CardEngine.MoveCard('dCard02',Vector4.new(dFirstCardXYZ.x-0.09, dFirstCardXYZ.y, dFirstCardXYZ.z, 1), standardOri, 'smooth', true)
    end)
    Cron.After(1.8, function()
        DealerAction()
    end)
end

--- 1 Step of player's action. Hit/Stand/Etc
local function playerAction()
    local function hitCallback()
        local pCardXapp = SingleRoundLogic.deckShuffle[1]
        local pCardXname = 'pCard'..string.format("%02d", SingleRoundLogic.playerCardCount+1)
        local cardsNum = SingleRoundLogic.playerCardCount
        table.remove(SingleRoundLogic.deckShuffle,1)
        local pCardXcardID = CardEngine.CreateCard(pCardXname,pCardXapp,Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, topOfDeckXYZ.z, 1),{ r = 0, p = 180, y = -90 })
        table.insert(SingleRoundLogic.playerBoardCards, pCardXapp)
        local newLocation = Vector4.new(pFirstCardXYZ.x-(cardsNum*0.04), pFirstCardXYZ.y-(cardsNum*0.06), pFirstCardXYZ.z+(cardsNum*0.0005), 1)
        SingleRoundLogic.playerCardCount = SingleRoundLogic.playerCardCount + 1
        Cron.After(0.1, CardEngine.MoveCard(pCardXname, newLocation, standardOri, 'smooth', true))
        --Cron.After(2.0, CardEngine.FlipCard(pCardXname, 'horizontal', 'left'))

        Cron.After(5, function()
            local playerScore = calculateBoardScore(SingleRoundLogic.playerBoardCards)
            if playerScore == 21 then
                playerAction()
            end
            if isBoardBusted(SingleRoundLogic.playerBoardCards) then
                DualPrint('End Round: Player Busted!')
                Cron.After(5, collectRoundCards)
            else
                playerAction()
            end
        end)

    end
    local function standCallback()
        --player done
        startDealerTurn()
    end
    promptPlayerActionUI(hitCallback, standCallback)
end

---Signal the start of a round
---@param deckLocation Vector4 location of physical card deck
---@param deckRotationRPY Vector3 rotation of physical card deck
function SingleRoundLogic.startRound(deckLocation, deckRotationRPY)
    SingleRoundLogic.playerCardCount = 0
    SingleRoundLogic.dealerCardCount = 0
    SingleRoundLogic.playerBoardCards = {}
    SingleRoundLogic.dealerBoardCards = {}
    shuffleDeckInternal()

    CardEngine.TriggerDeckShuffle()

    Cron.After(2, function ()
        dealStartOfRound()
    end)

    Cron.After(4, function()
        if isBoardBJ(SingleRoundLogic.playerBoardCards) and isBoardBJ(SingleRoundLogic.dealerBoardCards) then
            DualPrint('End Round: Both Blackjack! tie')
            Cron.After(5, collectRoundCards)
        elseif isBoardBJ(SingleRoundLogic.playerBoardCards) then
            DualPrint('End Round: Player Blackjack!')
            Cron.After(5, collectRoundCards)
        elseif isBoardBJ(SingleRoundLogic.dealerBoardCards) then
            DualPrint('End Round: Dealer Blackjack!')
            Cron.After(5, collectRoundCards)
        else
            playerAction()
        end
    end)

    --Cron.After(2, collectRoundCards)
end

return SingleRoundLogic