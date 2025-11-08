BlackjackCoordinates = {
    version = '1.0.0',
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

---Initializes all blackjack table coordinates and offsets
function BlackjackCoordinates.init()
    --Table
    RelativeCoordinateCalulator.registerTable(
        'hooh',
        Vector4.new(-1041.247,1339.675,5.283,1), --actual position of table mesh
        Quaternion.new(0, 0, 0, 1) --actual orientation of table mesh
    )
    --Holographic Value Display
    RelativeCoordinateCalulator.registerOffset(
        'top_down_holo_display',
        Vector4.new(0.514, 0.446, 0.792, 0), 
        EulerAngles.new(0, 0, 20):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'standard_holo_display',
        Vector4.new(0.457, 1.11, 0.792, 0), 
        EulerAngles.new(0, 0, 30):ToQuat()
    )
    --Hand Count Display
    RelativeCoordinateCalulator.registerOffset(
        'hand_count_display_base_player',
        Vector4.new(0.072, 1.146, 0.802, 0),
        EulerAngles.new(0, 60, 0):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'hand_count_display_base_dealer',
        Vector4.new(-0.060, -0.511, 0, 0),
        EulerAngles.new(0, 60, 0):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'hand_count_display_spacing_players',
        Vector4.new(0.18, 0, 0, 0),
        EulerAngles.new(0, 60, 0):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'hand_count_display_digit2_spacing',
        Vector4.new(-0.04, 0, 0, 0),
        EulerAngles.new(0, 60, 0):ToQuat()
    )
end

return BlackjackCoordinates

