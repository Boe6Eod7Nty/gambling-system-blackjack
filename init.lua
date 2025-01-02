-- v1.0.0
--===================
--CODE BY Boe6
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
--TweakXL   ?
--===================

--Modules
--=======
local Cron = require('External/Cron.lua') --Time handling
local SpotManager = require('SpotManager.lua') --workspot management



GamblingSystemBlackjack = {
    loaded = false,
    ready = false
}

-- Register Events
--================
registerForEvent( "onInit", function() 
    SpotManager.init()

    -- Define Hooh location
    local worldPinUI = {
        position = Vector4.new(-1041.2463, 1341.5469, 6.21331358, 1)
    }
    local animObj = {
        position = Vector4.new(-1041.2463, 1341.5469, 5.2774734, 1),
        orientation = {x=0,y=0,z=0},
        templatePath = "boe6\\GamblingSystemBlackjack\\workspot_anim.ent",
        defaultAnim = "sit_chair_table_lean0__2h_on_table__01",
        exitAnim = "sit_chair_table_lean0__2h_on_table__01__to__stand__2h_on_sides__01__turn0l__01",
        exitTime = 2.5
    }
    SpotManager.AddSpot('hooh', worldPinUI, animObj)
end)
registerForEvent('onUpdate', function(dt)
    Cron.Update(dt)
    SpotManager.update(dt)

    for i, spot in pairs(SpotManager.spots) do
        if spot.active == true and spot.startTriggered == false then
            DualPrint('spot start triggered')
            spot.startTriggered = true
        elseif spot.active == false and spot.startTriggered == true then
            DualPrint('spot end triggered')
            spot.startTriggered = false
        end
    end
end)
registerHotkey('DevHotkey1', 'Dev Hotkey 1', function()
    DualPrint('||=1  Dev hotkey 1 Pressed =')

    SpotManager.ExitSpot('hooh')
end)
registerHotkey('DevHotkey2', 'Dev Hotkey 2', function()
    DualPrint('||=2  Dev hotkey 2 Pressed =')

end)
registerHotkey('DevHotkey3', 'Dev Hotkey 3', function()
    DualPrint('||=3  Dev hotkey 3 Pressed =')

end)
registerHotkey('DevHotkey4', 'Dev Hotkey 4', function()
    DualPrint('||=4  Dev hotkey 4 Pressed =')

end)

--[[ animations tested
player stands and leaves:
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__to__stand__2h_on_sides__01__turn0l__01", 2.766, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__to__stand__2h_on_sides__01__turn0r__01", 3.766, "sit_chair_table_lean0__2h_on_table__01")
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


--Functions
--=========
function DualPrint(string) --prints to both CET console and local .log file
    if not string then return end
    print('[Gambling System] ' .. string) -- CET console
    spdlog.error('[Gambling System] ' .. string) -- .log
end

--End of File
--===========
return GamblingSystemBlackjack