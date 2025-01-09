SingleRoundLogic = {
    version = '1.0.0',
    deckShuffle = {},
    playerCardCount = 0,
    dealerCardCount = 0
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

local Cron = require('External/Cron.lua')
local topOfDeckXYZ = {x=-1041.759, y=1340.121, z=6.105}
local pFirstCardXYZ = {x=-1041.189, y=1340.711, z=6.085}
local dFirstCardXYZ = {x=-1041.247, y=1340.205, z=6.085}
local standardOri = { r = 0, p = 0, y = -90 }

--Functions
--=========

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

local function dealStartOfRound()
    local pCard01app = SingleRoundLogic.deckShuffle[1]
    local pCard01cardID = CardEngine.CreateCard('pCard01', pCard01app, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, topOfDeckXYZ.z, 1), { r = 0, p = 180, y = -90 })
    table.remove(SingleRoundLogic.deckShuffle,1)
    local dCard01app = SingleRoundLogic.deckShuffle[1]
    local dCard01cardID = CardEngine.CreateCard('dCard01', dCard01app, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, topOfDeckXYZ.z, 1), { r = 0, p = 180, y = -90 })
    table.remove(SingleRoundLogic.deckShuffle,1)
    local pCard02app = SingleRoundLogic.deckShuffle[1]
    local pCard02cardID = CardEngine.CreateCard('pCard02', pCard02app, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, topOfDeckXYZ.z, 1), { r = 0, p = 180, y = -90 })
    table.remove(SingleRoundLogic.deckShuffle,1)
    local dCard02app = SingleRoundLogic.deckShuffle[1]
    local dCard02cardID = CardEngine.CreateCard('dCard02', dCard02app, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, topOfDeckXYZ.z, 1), { r = 0, p = 180, y = -90 })
    table.remove(SingleRoundLogic.deckShuffle,1)
    SingleRoundLogic.playerCardCount = SingleRoundLogic.playerCardCount + 2
    SingleRoundLogic.dealerCardCount = SingleRoundLogic.dealerCardCount + 2

    --begin animation below
    Cron.After(0.1, function()
        CardEngine.MoveCard('pCard01', Vector4.new(pFirstCardXYZ.x, pFirstCardXYZ.y, pFirstCardXYZ.z+0.0005, 1), standardOri, 'smooth')
    end)
    Cron.After(0.5, function()
        CardEngine.MoveCard('dCard01', Vector4.new(dFirstCardXYZ.x, dFirstCardXYZ.y, dFirstCardXYZ.z, 1), standardOri, 'smooth')
    end)
    Cron.After(1.0, function()
        CardEngine.MoveCard('pCard02', Vector4.new(pFirstCardXYZ.x-0.04, pFirstCardXYZ.y-0.06, pFirstCardXYZ.z+0.001, 1), standardOri, 'smooth')
    end)
    Cron.After(1.5, function()
        CardEngine.MoveCard('dCard02', Vector4.new(dFirstCardXYZ.x-0.005, dFirstCardXYZ.y+0.004, dFirstCardXYZ.z, 1), standardOri, 'smooth')
    end)
    Cron.After(1.8, function()
        CardEngine.FlipCard('pCard01', 'horizontal', 'left')
    end)
    Cron.After(2.0, function()
        CardEngine.FlipCard('dCard01', 'horizontal', 'left')
    end)
    Cron.After(2.5, function()
        CardEngine.FlipCard('pCard02', 'horizontal', 'left')
    end)
end




---Signal the start of a round
function SingleRoundLogic.startRound(deckLocation, deckRotationRPY)
    shuffleDeckInternal()
    dealStartOfRound()
end

return SingleRoundLogic