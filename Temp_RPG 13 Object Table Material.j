library ObjectTableMaterial

globals
    // 일반강화주문서
    integer UPGRADE_SCROLL_NORMAL
    // 고급강화주문서
    integer UPGRADE_SCROLL_ADVANCED
    // 희귀강화주문서
    integer UPGRADE_SCROLL_RARE
endglobals

function Object_Table_Material_Init takes nothing returns nothing
    local integer current_object_id
    local string name
    local string img
    local string explaination
    /*
        사용법은 Obejct Table Consumable 에서 다뤘으므로 생략
    */
    set current_object_id = Get_New_Object_ID()
    set UPGRADE_SCROLL_NORMAL = current_object_id
    set name = "일반 강화 주문서"
    set img = "ReplaceableTextures\\CommandButtons\\BTNSnazzyScrollGreen.blp"
    set explaination = "일반 강화 주문서다"
    call Register_Object( current_object_id, MATERIAL, name, img, explaination )
    call Set_Name_To_ID( "UPGRADE_SCROLL_NORMAL", current_object_id )
    
    set current_object_id = Get_New_Object_ID()
    set UPGRADE_SCROLL_ADVANCED = current_object_id
    set name = "고급 강화 주문서"
    set img = "ReplaceableTextures\\CommandButtons\\BTNSnazzyScrollPurple.blp"
    set explaination = "고급 강화 주문서다"
    call Register_Object( current_object_id, MATERIAL, name, img, explaination )
    call Set_Name_To_ID( "UPGRADE_SCROLL_ADVANCED", current_object_id )
    
    set current_object_id = Get_New_Object_ID()
    set UPGRADE_SCROLL_RARE = current_object_id
    set name = "희귀 강화 주문서"
    set img = "ReplaceableTextures\\CommandButtons\\BTNSnazzyScroll.blp"
    set explaination = "희귀 강화 주문서다"
    call Register_Object( current_object_id, MATERIAL, name, img, explaination )
    call Set_Name_To_ID( "UPGRADE_SCROLL_RARE", current_object_id )
    
    call BJDebugMsg("Material Table Init End")
endfunction

endlibrary