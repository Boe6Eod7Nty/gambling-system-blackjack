SingleRoundLogic = {
    version = '1.0.0',
    deckShuffle = {},
    dealerCardCount = 0,
    dealerBoardCards = {},
    playerHands = {{}},
    bustedHands = {false,false,false,false},
    blackjackHandsPaid = {false,false,false,false},
    doubledHands = {false,false,false,false},
    activePlayerHandIndex = 1
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
                        'Ad','2d','3d','4d','5d','6d','7d','8d','9d','Td','Jd','Qd','Kd'
                    }
    --alignment comment.
    local devRiggedIndex = {10,10,6,4,8,1,7} --player busts and dealer hits if game broken lmao
    --local devRiggedIndex = {5,10,4,1} --dealer gets blackjack
    --local devRiggedIndex = {8,34,20,47,3,42,10} --2 8s to player
    --local devRiggedIndex = {1,48,13,46,25,47,45,37} --4 aces all split
    local newDeck = {}
    for i = 1, 52 do
        if i <= #devRiggedIndex then --the rigging stuff is just for development debugging. This should always be 0.
            local selectedCard = devRiggedIndex[i]
            newDeck[i] = allCards[selectedCard]
            table.remove(allCards, selectedCard)
        else
            local selectedCard = math.random(#allCards)
            newDeck[i] = allCards[selectedCard]
            table.remove(allCards, selectedCard)
        end
    end
    SingleRoundLogic.deckShuffle = newDeck
end

--- Animate first round deal.
local function dealStartOfRound()
    local pCard01app = SingleRoundLogic.deckShuffle[1]
    local pCard01cardID = CardEngine.CreateCard('playerCard_h01_c01', pCard01app, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1), { r = 0, p = 180, y = -90 })
    table.remove(SingleRoundLogic.deckShuffle,1)
    table.insert(SingleRoundLogic.playerHands[1], pCard01app)
    local dCard01app = SingleRoundLogic.deckShuffle[1]
    local dCard01cardID = CardEngine.CreateCard('dCard01', dCard01app, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1), { r = 0, p = 180, y = -90 })
    table.remove(SingleRoundLogic.deckShuffle,1)
    table.insert(SingleRoundLogic.dealerBoardCards, dCard01app)
    local pCard02app = SingleRoundLogic.deckShuffle[1]
    local pCard02cardID = CardEngine.CreateCard('playerCard_h01_c02', pCard02app, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1), { r = 0, p = 180, y = -90 })
    table.remove(SingleRoundLogic.deckShuffle,1)
    table.insert(SingleRoundLogic.playerHands[1], pCard02app)
    local dCard02app = SingleRoundLogic.deckShuffle[1]
    local dCard02cardID = CardEngine.CreateCard('dCard02', dCard02app, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1), { r = 0, p = 180, y = -90 })
    table.remove(SingleRoundLogic.deckShuffle,1)
    table.insert(SingleRoundLogic.dealerBoardCards, dCard02app)
    SingleRoundLogic.dealerCardCount = SingleRoundLogic.dealerCardCount + 2

    --begin animation below
    Cron.After(0.1, function()
        CardEngine.MoveCard('playerCard_h01_c01', Vector4.new(pFirstCardXYZ.x, pFirstCardXYZ.y, pFirstCardXYZ.z, 1), standardOri, 'smooth', true)
    end)
    Cron.After(0.5, function()
        CardEngine.MoveCard('dCard01', Vector4.new(dFirstCardXYZ.x, dFirstCardXYZ.y, dFirstCardXYZ.z, 1), standardOri, 'smooth', true)
    end)
    Cron.After(1.0, function()
        CardEngine.MoveCard('playerCard_h01_c02', Vector4.new(pFirstCardXYZ.x-0.04, pFirstCardXYZ.y-0.06, pFirstCardXYZ.z+0.0005, 1), standardOri, 'smooth', true)
    end)
    Cron.After(1.5, function()
        CardEngine.MoveCard('dCard02', Vector4.new(dFirstCardXYZ.x-0.005, dFirstCardXYZ.y+0.004, dFirstCardXYZ.z, 1), standardOri, 'smooth', false)
    end)
end

--- Animate all cards back to the deck & delete
local function collectRoundCards()
    for j = 1, #(SingleRoundLogic.playerHands) do
        for i = 1, #(SingleRoundLogic.playerHands[j]) do
            local curCard = 'playerCard_h'..string.format("%02d", j)..'_c'..string.format("%02d", i)
            CardEngine.MoveCard(curCard, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1), standardOri, 'smooth', false)
        end
    end
    for i = 1, SingleRoundLogic.dealerCardCount do
        local curCard = 'dCard'..string.format("%02d", i)
        CardEngine.MoveCard(curCard, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, dFirstCardXYZ.z, 1), standardOri, 'smooth', false)
    end
    Cron.After(3, function()
        for j = 1, #(SingleRoundLogic.playerHands) do
            for i = 1, #(SingleRoundLogic.playerHands[j]) do
                CardEngine.DeleteCard('playerCard_h'..string.format("%02d", j)..'_c'..string.format("%02d", i))
            end
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
    if #board ~= 2 then
        return false
    end
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

local function isSplitable(board)
    if #board == 2 then
        local rank1 = string.sub(board[1],1,1)
        local rank2 = string.sub(board[2],1,1)
        if rank1 == rank2 then
            return true
        end
    end
    return false
end

---Prompt player UI for turn action
---@param hitCallback function callback for when player hits
---@param standCallback function callback for when player stands
local function promptPlayerActionUI(handIndex, hitCallback, standCallback, splitCallback)
    local allChoices = {}
    local allChoicesRef = {"Hit", "Stand"}
    allChoices[1] = interactionUI.createChoice("Hit", nil, gameinteractionsChoiceType.Selected) --change from Selected to AlreadyRead later
    allChoices[2] = interactionUI.createChoice("Stand", nil, gameinteractionsChoiceType.Selected)
    if isSplitable(SingleRoundLogic.playerHands[SingleRoundLogic.activePlayerHandIndex]) then
        if BlackjackMainMenu.playerChipsMoney >= BlackjackMainMenu.currentBet then
            table.insert(allChoices, interactionUI.createChoice("Split", nil, gameinteractionsChoiceType.Selected))
        else
            table.insert(allChoices, interactionUI.createChoice("Split", nil, gameinteractionsChoiceType.AlreadyRead))
        end
        table.insert(allChoicesRef, "Split")
    end
    --local choice4 = interactionUI.createChoice("Double", nil, gameinteractionsChoiceType.Selected)
    --local choice5 = interactionUI.createChoice("Surrender", nil, gameinteractionsChoiceType.Selected)
    --local choice6 = interactionUI.createChoice("Insurance", nil, gameinteractionsChoiceType.Selected)

    local hub = interactionUI.createHub("Hand #"..tostring(handIndex), allChoices)
    interactionUI.setupHub(hub)
    interactionUI.showHub()

    interactionUI.callbacks[1] = function()--Hit
        interactionUI.hideHub()
        hitCallback()
    end
    interactionUI.callbacks[2] = function()--Stand
        interactionUI.hideHub()
        standCallback()
    end
    interactionUI.callbacks[3] = function()
        if allChoicesRef[3] == "Split" and BlackjackMainMenu.playerChipsMoney >= BlackjackMainMenu.currentBet then
            interactionUI.hideHub()
            splitCallback()
        end
    end
end

---Returns BJ game value of a set of cards
---@param board table table list of card faces
---@return number number hand value, 21, 18, etc.
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

--- animation for dealer to flip two cards
local function flipDealerTwoCards()
    Cron.After(0.1, function()
        CardEngine.MoveCard('dCard01', Vector4.new(dFirstCardXYZ.x+0.09, dFirstCardXYZ.y, dFirstCardXYZ.z, 1), standardOri, 'smooth', false)
    end)
    Cron.After(0.6, function()
        CardEngine.MoveCard('dCard01',Vector4.new(dFirstCardXYZ.x, dFirstCardXYZ.y, dFirstCardXYZ.z, 1), standardOri, 'smooth', false)
    end)
    Cron.After(0.8, function()
        CardEngine.MoveCard('dCard02',Vector4.new(dFirstCardXYZ.x-0.09, dFirstCardXYZ.y, dFirstCardXYZ.z, 1), standardOri, 'smooth', true)
    end)
end

---After player and dealer have finished, calculate scores, determine winner hands and payout.
---@param instaBlackjack boolean if player OR dealer has instant blackjack
local function ProcessRoundResult(instaBlackjack)
    DualPrint('--End Round!--')
    local dealerScore = calculateBoardScore(SingleRoundLogic.dealerBoardCards)
    --isBoardBJ(SingleRoundLogic.dealerBoardCards)
    if instaBlackjack then
        Cron.After(1, flipDealerTwoCards)
        local dealerBJ = isBoardBJ(SingleRoundLogic.dealerBoardCards)
        local playerBJ = isBoardBJ(SingleRoundLogic.playerHands[1])
        if dealerBJ and playerBJ then
            DualPrint('End Round: Both Blackjack. Push')
            BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + BlackjackMainMenu.currentBet
        elseif dealerBJ then
            DualPrint('End Round: Dealer Blackjack.')
        elseif playerBJ then
            DualPrint('End Round: Player Blackjack.')
            BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + BlackjackMainMenu.currentBet * 2
        end
    else--not instaBlackjack then
        for i, hand in pairs(SingleRoundLogic.playerHands) do
            local continueHandCheck = true
            if SingleRoundLogic.bustedHands[i] then
                DualPrint('End Hand #'..tostring(i)..': Player Busted.')
                continueHandCheck = false
            end
            if isBoardBJ(SingleRoundLogic.dealerBoardCards) and continueHandCheck then
                if isBoardBJ(hand) then
                    DualPrint('End Hand #'..tostring(i)..': Both Blackjack. Push')
                    BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + BlackjackMainMenu.currentBet
                    continueHandCheck = false
                end
                DualPrint('End Hand #'..tostring(i)..': Dealer Blackjack.')
                continueHandCheck = false
            end
            if isBoardBJ(hand) and continueHandCheck then
                DualPrint('End Hand #'..tostring(i)..': Player Blackjack.')
                continueHandCheck = false
            end
    
            local playerScore = calculateBoardScore(hand)
            if continueHandCheck then
                if dealerScore > 21 then
                    DualPrint('End Hand #'..tostring(i)..': Dealer Busted!')
                    BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + BlackjackMainMenu.currentBet * 2
                    if SingleRoundLogic.doubledHands[i] then
                        BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + BlackjackMainMenu.currentBet * 2
                    end
                elseif playerScore > dealerScore then
                    DualPrint('End Hand #'..tostring(i)..': Player Wins!')
                    BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + BlackjackMainMenu.currentBet * 2
                    if SingleRoundLogic.doubledHands[i] then
                        BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + BlackjackMainMenu.currentBet * 2
                    end
                elseif playerScore < dealerScore then
                    DualPrint('End Hand #'..tostring(i)..': Dealer Wins.')
                else
                    DualPrint('End Hand #'..tostring(i)..': Tie, Push.')
                    BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + BlackjackMainMenu.currentBet
                    if SingleRoundLogic.doubledHands[i] then
                        BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + BlackjackMainMenu.currentBet
                    end
                end
            end
            DualPrint(' - Player score: '..tostring(playerScore)..', Dealer score: '..tostring(dealerScore))
        end
    end
    if instaBlackjack then
        Cron.After(7, collectRoundCards)
        Cron.After(11, BlackjackMainMenu.RoundEnded)
    else
        Cron.After(4, collectRoundCards)
        Cron.After(8, BlackjackMainMenu.RoundEnded)
    end
end

--- 1 Step of dealer's action. Hit/Stand
local function dealerAction()
    local score = calculateBoardScore(SingleRoundLogic.dealerBoardCards)
    local isSoft = isBoardSoft(SingleRoundLogic.dealerBoardCards)
    if score < 17 or (score == 17 and isSoft) then
        local dCardXapp = SingleRoundLogic.deckShuffle[1]
        local dCardXname = 'dCard'..string.format("%02d", SingleRoundLogic.dealerCardCount+1)
        local cardsNum = SingleRoundLogic.dealerCardCount
        table.remove(SingleRoundLogic.deckShuffle,1)
        local pCardXcardID = CardEngine.CreateCard(dCardXname,dCardXapp,Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1),{ r = 0, p = 180, y = -90 })
        table.insert(SingleRoundLogic.dealerBoardCards, dCardXapp)
        local newLocation = Vector4.new(dFirstCardXYZ.x+((cardsNum-1)*0.09), dFirstCardXYZ.y, dFirstCardXYZ.z, 1)
        SingleRoundLogic.dealerCardCount = SingleRoundLogic.dealerCardCount + 1
        Cron.After(0.1, CardEngine.MoveCard(dCardXname, newLocation, standardOri, 'smooth', true))
        Cron.After(0.6, function()
            dealerAction()
        end)
    else
        ProcessRoundResult(false)
    end
end


--- 1 Step of player's action. Hit/Stand/Etc
local function playerAction(handIndex)
    local function hitCallback()
        local cardsNum = #(SingleRoundLogic.playerHands[handIndex])
        local pCardXapp = SingleRoundLogic.deckShuffle[1]
        local pCardXname = 'playerCard_h'..string.format("%02d", handIndex)..'_c'..string.format("%02d", cardsNum+1)
        table.remove(SingleRoundLogic.deckShuffle,1)
        local pCardXcardID = CardEngine.CreateCard(pCardXname,pCardXapp,Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1),{ r = 0, p = 180, y = -90 })
        table.insert(SingleRoundLogic.playerHands[handIndex], pCardXapp)
        local newLocation = Vector4.new(
            pFirstCardXYZ.x-(cardsNum*0.04)+(0.18*(handIndex-1)),
            pFirstCardXYZ.y-(cardsNum*0.06),
            pFirstCardXYZ.z+(cardsNum*0.0005),
            1)
        Cron.After(0.1, CardEngine.MoveCard(pCardXname, newLocation, standardOri, 'smooth', true))
        --Cron.After(2.0, CardEngine.FlipCard(pCardXname, 'horizontal', 'left'))

        Cron.After(3, function()
            local playerScore = calculateBoardScore(SingleRoundLogic.playerHands[handIndex])
            if playerScore == 21 then
                -- 21 !
                DualPrint('sRL | 21! handIndex: '..tostring(handIndex))
                --SingleRoundLogic.blackjackHandsPaid[handIndex] = true
                --BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + BlackjackMainMenu.currentBet * 2.5
                DualPrint('sRL | activePlayerHandIndex: '..tostring(SingleRoundLogic.activePlayerHandIndex))
                if SingleRoundLogic.activePlayerHandIndex == #SingleRoundLogic.playerHands then
                    DualPrint('sRL | triggered dealer turn')
                    flipDealerTwoCards()
                    Cron.After(1.8, function()
                        dealerAction()
                    end)
                else
                    --next player hand
                    DualPrint('sRL | triggered next player hand')
                    SingleRoundLogic.activePlayerHandIndex = SingleRoundLogic.activePlayerHandIndex + 1
                    playerAction(SingleRoundLogic.activePlayerHandIndex)
                end
            elseif isBoardBusted(SingleRoundLogic.playerHands[handIndex]) then
                DualPrint('sRL | End Hand: Player Busted!')
                SingleRoundLogic.bustedHands[handIndex] = true
                if SingleRoundLogic.activePlayerHandIndex == #SingleRoundLogic.playerHands then
                    local allBusted = true
                    for i = 1, #SingleRoundLogic.playerHands do
                        if SingleRoundLogic.bustedHands[i] == false then
                            allBusted = false
                        end
                    end
                    if allBusted then
                        DualPrint('sRL | All Busted!')
                        ProcessRoundResult(false)
                    else
                        flipDealerTwoCards()
                        Cron.After(1.8, function()
                            dealerAction()
                        end)
                    end
                else
                    --next player hand
                    SingleRoundLogic.activePlayerHandIndex = SingleRoundLogic.activePlayerHandIndex + 1
                    playerAction(SingleRoundLogic.activePlayerHandIndex)
                end
            else
                playerAction(handIndex)
            end
        end)

    end
    local function standCallback()
        if SingleRoundLogic.activePlayerHandIndex == #SingleRoundLogic.playerHands then
            flipDealerTwoCards()
            Cron.After(1.8, function()
                dealerAction()
            end)
        else
            --next player hand
            SingleRoundLogic.activePlayerHandIndex = SingleRoundLogic.activePlayerHandIndex + 1
            playerAction(SingleRoundLogic.activePlayerHandIndex)
        end
    end
    local function splitCallback()
        BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney - BlackjackMainMenu.currentBet

        local curHandIndex = SingleRoundLogic.activePlayerHandIndex
        if curHandIndex == #SingleRoundLogic.playerHands then

            --IF SPACE AVAILABLE LEFT

            SingleRoundLogic.playerHands[curHandIndex+1] = {SingleRoundLogic.playerHands[curHandIndex][1]}
            local card1app = SingleRoundLogic.playerHands[curHandIndex][1]
            local card2app = SingleRoundLogic.playerHands[curHandIndex][2]
            local card1id = 'playerCard_h'..string.format("%02d", curHandIndex)..'_c'..string.format("%02d", 1)
            local card2id = 'playerCard_h'..string.format("%02d", curHandIndex)..'_c'..string.format("%02d", 2)
            local card1pos = Vector4.new(pFirstCardXYZ.x+(0.18*curHandIndex),pFirstCardXYZ.y, pFirstCardXYZ.z, 1)
            local card2pos = Vector4.new(pFirstCardXYZ.x+(0.18*(curHandIndex-1)), pFirstCardXYZ.y, pFirstCardXYZ.z, 1)
            CardEngine.MoveCard(card1id,card1pos,standardOri,'smooth',false)
            CardEngine.MoveCard(card2id,card2pos,standardOri,'smooth',false)
            Cron.After(0.5, function()
                CardEngine.CreateCard(
                    'playerCard_h'..string.format("%02d", curHandIndex+1)..'_c'..string.format("%02d", 1),
                    card1app,
                    card1pos,
                    standardOri
                )
                CardEngine.DeleteCard(card1id)
                Cron.After(0.5, function()
                    CardEngine.DeleteCard(card2id)
                    CardEngine.CreateCard(
                        card1id,
                        card2app,
                        card2pos,
                        standardOri
                    )
                end)
            end)
            Cron.After(1, function() --deal 2 cards, 1 to each hand
                table.remove(SingleRoundLogic.playerHands[curHandIndex],1)
                local cardsNum = 1
                local pCardXapp = SingleRoundLogic.deckShuffle[1]
                local pCardXname = 'playerCard_h'..string.format("%02d", handIndex)..'_c02'
                table.remove(SingleRoundLogic.deckShuffle,1)
                local pCardXcardID = CardEngine.CreateCard(pCardXname,pCardXapp,Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1),{ r = 0, p = 180, y = -90 })
                table.insert(SingleRoundLogic.playerHands[handIndex], pCardXapp)
                local newLocation = Vector4.new(
                    pFirstCardXYZ.x-(cardsNum*0.04)+(0.18*(handIndex-1)),
                    pFirstCardXYZ.y-(cardsNum*0.06),
                    pFirstCardXYZ.z+(cardsNum*0.0005),
                    1)
                Cron.After(0.1, function()
                    CardEngine.MoveCard(pCardXname, newLocation, standardOri, 'smooth', true)
                end)
            end)
            Cron.After(1.2, function()
                local cardsNum = 1
                local pCardXapp = SingleRoundLogic.deckShuffle[1]
                local pCardXname = 'playerCard_h'..string.format("%02d", handIndex+1)..'_c02'
                table.remove(SingleRoundLogic.deckShuffle,1)
                local pCardXcardID = CardEngine.CreateCard(pCardXname,pCardXapp,Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1),{ r = 0, p = 180, y = -90 })
                table.insert(SingleRoundLogic.playerHands[handIndex+1], pCardXapp)
                local newLocation = Vector4.new(
                    pFirstCardXYZ.x-(cardsNum*0.04)+(0.18*handIndex),
                    pFirstCardXYZ.y-(cardsNum*0.06),
                    pFirstCardXYZ.z+(cardsNum*0.0005),
                    1)
                Cron.After(0.1, function()
                    CardEngine.MoveCard(pCardXname, newLocation, standardOri, 'smooth', true)
                end)
            end)
            Cron.After(2, function()
                playerAction(handIndex)
            end)
        else

            --IF LEFT SPACE NOT AVAILABLE, CARD JUMPS TO LAST SPACE

            local maxHandIndex = #SingleRoundLogic.playerHands
            local cardID = 'playerCard_h'..string.format("%02d", handIndex)..'_c02'
            local cardApp = SingleRoundLogic.playerHands[handIndex][2]
            local cardPos = Vector4.new(
                pFirstCardXYZ.x+(0.18*(maxHandIndex)),
                pFirstCardXYZ.y,
                pFirstCardXYZ.z,
                1)
            SingleRoundLogic.playerHands[maxHandIndex+1] = {SingleRoundLogic.playerHands[curHandIndex][2]}
            CardEngine.MoveCard(cardID,cardPos,standardOri,'smooth',false)
            table.remove(SingleRoundLogic.playerHands[curHandIndex],2)
            Cron.After(0.8, function()
                CardEngine.CreateCard(
                    'playerCard_h'..string.format("%02d", maxHandIndex+1)..'_c'..string.format("%02d", 1),
                    cardApp,
                    cardPos,
                    standardOri
                )
                CardEngine.DeleteCard(cardID)
            end)
            Cron.After(1, function()
                local cardsNum = 1
                local pCardXapp = SingleRoundLogic.deckShuffle[1]
                local pCardXname = 'playerCard_h'..string.format("%02d", handIndex)..'_c02'
                table.remove(SingleRoundLogic.deckShuffle,1)
                local pCardXcardID = CardEngine.CreateCard(pCardXname,pCardXapp,Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1),{ r = 0, p = 180, y = -90 })
                table.insert(SingleRoundLogic.playerHands[handIndex], pCardXapp)
                local newLocation = Vector4.new(
                    pFirstCardXYZ.x-(cardsNum*0.04)+(0.18*(handIndex-1)),
                    pFirstCardXYZ.y-(cardsNum*0.06),
                    pFirstCardXYZ.z+(cardsNum*0.0005),
                    1)
                Cron.After(0.1, function()
                    CardEngine.MoveCard(pCardXname, newLocation, standardOri, 'smooth', true)
                end)
            end)
            Cron.After(2, function()
                local cardsNum = 1
                local pCardXapp = SingleRoundLogic.deckShuffle[1]
                local pCardXname = 'playerCard_h'..string.format("%02d", maxHandIndex+1)..'_c02'
                table.remove(SingleRoundLogic.deckShuffle,1)
                local pCardXcardID = CardEngine.CreateCard(pCardXname,pCardXapp,Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1),{ r = 0, p = 180, y = -90 })
                table.insert(SingleRoundLogic.playerHands[maxHandIndex+1], pCardXapp)
                local newLocation = Vector4.new(
                    pFirstCardXYZ.x-(cardsNum*0.04)+(0.18*(maxHandIndex)),
                    pFirstCardXYZ.y-(cardsNum*0.06),
                    pFirstCardXYZ.z+(cardsNum*0.0005),
                    1)
                Cron.After(0.1, function()
                    CardEngine.MoveCard(pCardXname, newLocation, standardOri, 'smooth', true)
                end)
            end)
            Cron.After(2.5, function()
                playerAction(handIndex)
            end)
        end
    end
    DualPrint('sRL | PromptUI; HandIndex: '..tostring(handIndex))
    promptPlayerActionUI(handIndex,hitCallback, standCallback, splitCallback)
end

---Signal the start of a round
---@param deckLocation Vector4 location of physical card deck
---@param deckRotationRPY Vector3 rotation of physical card deck
function SingleRoundLogic.startRound(deckLocation, deckRotationRPY)
    SingleRoundLogic.dealerCardCount = 0
    SingleRoundLogic.dealerBoardCards = {}
    SingleRoundLogic.playerHands = {{}}
    SingleRoundLogic.activePlayerHandIndex = 1
    SingleRoundLogic.bustedHands = {false,false,false,false}
    SingleRoundLogic.blackjackHandsPaid = {false,false,false,false}
    SingleRoundLogic.doubledHands = {false,false,false,false}

    shuffleDeckInternal()
    CardEngine.TriggerDeckShuffle()

    Cron.After(2.1, function ()
        dealStartOfRound()
    end)

    Cron.After(4, function()
        if isBoardBJ(SingleRoundLogic.playerHands[1]) or isBoardBJ(SingleRoundLogic.dealerBoardCards) then
            ProcessRoundResult(true)
        else
            playerAction(1)
        end
    end)
end

return SingleRoundLogic