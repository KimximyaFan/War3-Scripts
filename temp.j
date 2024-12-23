        set load_button_back[i] = DzCreateFrameByTagName("BACKDROP", "", load_box, "QuestButtonBaseTemplate", 0)
        call DzFrameSetPoint(load_button_back[i], JN_FRAMEPOINT_TOPLEFT, load_box, JN_FRAMEPOINT_TOPLEFT, x + ((square_size + padding) * a), y + (-(square_size + padding) * b) )
        call DzFrameSetSize(load_button_back[i], square_size, square_size)
        
        set load_img[i] = DzCreateFrameByTagName("BACKDROP", "", load_button_back[i], "QuestButtonBaseTemplate", 0)
        call DzFrameSetPoint(load_img[i], JN_FRAMEPOINT_CENTER, load_button_back[i], JN_FRAMEPOINT_CENTER, 0, 0 )
        call DzFrameSetSize(load_img[i], img_size, img_size)
        call DzFrameShow(load_img[i], false)


function Get_Icon_Img_From_Unit_Id takes integer unit_id returns string
    if unit_id == 'H000' then
        return "ReplaceableTextures\\CommandButtons\\BTNFootman.blp"
    elseif unit_id == 'H001' then
        return "ReplaceableTextures\\CommandButtons\\BTNArcher.blp"
    elseif unit_id == 'H003' then
        return "ReplaceableTextures\\CommandButtons\\BTNAcolyte.blp"
    elseif unit_id == 'H002' then
        return "ReplaceableTextures\\CommandButtons\\BTNHuntress.blp"
    elseif unit_id == 'H004' then
        return "ReplaceableTextures\\CommandButtons\\BTNSnowOwl.blp"
    endif
    
    return ""
endfunction

            // 대충 스트링에 있는 정보 추출해서, 프레임 이미지 세팅하고, 프레임 텍스트 세팅
            set is_character_loaded[i] = true
            set unit_id = S2I(JNStringSplit(str, ",", 0))
            set difficulty_cleared = S2I(JNStringSplit(str, ",", 1))
            
            // Load Generic 참조
            call DzFrameSetTexture(load_img[i], Get_Icon_Img_From_Unit_Id(unit_id), 0)
            call DzFrameShow(load_img[i], true)
            call DzFrameSetText(load_button_text[i], Get_Character_Name_From_Unit_Id(unit_id) )