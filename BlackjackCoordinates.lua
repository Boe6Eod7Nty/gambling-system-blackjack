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
    --Card locations
    RelativeCoordinateCalulator.registerOffset(
        'deck_position',
        Vector4.new(-0.512, 0.446, 0.802, 0),
        EulerAngles.new(0, 180, -90):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'player_first_card_position',
        Vector4.new(0.058, 1.036, 0.802, 0),
        EulerAngles.new(0, 180, -90):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'dealer_first_card_position',
        Vector4.new(0, 0.530, 0.802, 0),
        EulerAngles.new(0, 180, -90):ToQuat()
    )
    --Card spacing offsets
    RelativeCoordinateCalulator.registerOffset(
        'card_spacing_player',
        Vector4.new(-0.04, -0.06, 0.0005, 0),  -- per card in player hand
        EulerAngles.new(0, 0, 0):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'card_spacing_dealer',
        Vector4.new(0.09, 0, 0, 0),  -- per card in dealer hand
        EulerAngles.new(0, 0, 0):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'dealer_second_card_offset',
        Vector4.new(-0.005, 0.004, 0, 0),  -- slight offset for dealer's 2nd card animation
        EulerAngles.new(0, 0, 0):ToQuat()
    )
    --Card orientations
    RelativeCoordinateCalulator.registerOffset(
        'card_orientation_face_up',
        Vector4.new(0, 0, 0, 0),  -- no position, just orientation reference
        EulerAngles.new(0, 0, -90):ToQuat()  -- standardOri: face up
    )
    --Double down card offset
    RelativeCoordinateCalulator.registerOffset(
        'card_double_down_offset',
        Vector4.new(0.04, 0, 0, 0),  -- additional X offset for 3rd card in doubled hand
        EulerAngles.new(0, 0, 0):ToQuat()
    )
    --Chip locations
    RelativeCoordinateCalulator.registerOffset(
        'chip_player_center_position',
        Vector4.new(0, 1.178, 0.802, 0),
        EulerAngles.new(0, 0, 0):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'chip_player_left1_up1',
        Vector4.new(0.02, -0.035, 0, 0),
        EulerAngles.new(0, 0, 0):ToQuat()
    )
    RelativeCoordinateCalulator.registerOffset(
        'chip_player_left1',
        Vector4.new(0.04, 0, 0, 0),
        EulerAngles.new(0, 0, 0):ToQuat()
    )
    --Space between split hands on board
    RelativeCoordinateCalulator.registerOffset(
        'space_between_hands',
        Vector4.new(0.18, 0, 0, 0),
        EulerAngles.new(0, 0, 0):ToQuat()
    )

end

return BlackjackCoordinates

