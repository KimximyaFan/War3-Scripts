library InvenGeneric requires ObjectRegister

globals
    // 인벤 한칸 프레임 크기
    real inven_square_size = 0.048
    // 인벤 한칸 아이템 프레임 크기
    real inven_item_size = 0.046
    // 인벤 상단 여러 기능들 버튼 x 사이즈
    real inven_function_button_size_x = 0.045
    // 인벤 상단 여러 기능들 버튼 y 사이즈
    real inven_function_button_size_y = 0.040
    // 인벤 켜지는 버튼 x 사이즈
    real inven_button_standard_x = 0.205
    // 인벤 키는 버튼 y 사이즈
    real inven_button_standard_y = 0.12
endglobals

// ===================================
// Upgrade
// ===================================

/*
    강화창에서 필요재료 이미지아이콘 프레임 없애는 함수
*/
function Required_Remove_Img takes integer pid, integer i returns nothing
    if GetLocalPlayer() == Player(pid) then
        call DzFrameShow(required_img[i], false)
        call DzFrameShow(required_button[i], false)
        call DzFrameShow(required_count_text[i], false)
        call DzFrameShow(required_back_drop[i], false)
    endif
endfunction

/*
    강화창에서 필요재료 이미지아이콘 세팅하는 함수
*/
function Required_Set_Img takes integer pid, integer i, integer object_id, integer count returns nothing
    if GetLocalPlayer() == Player(pid) then
        call DzFrameSetTexture(required_img[i], Get_Object_String_Data(object_id, IMG), 0)
        call DzFrameShow(required_img[i], true)
        call DzFrameShow(required_button[i], true)
        call DzFrameShow(required_back_drop[i], true)
        
        if Get_Object_Data(object_id, OBJECT_TYPE) == EQUIP then
            set count = 0
        endif
        
        if count >= 1 then
            call DzFrameSetText(required_count_text[i], I2S(count) )
            call DzFrameShow(required_count_text[i], true)
        endif
    endif
endfunction

/*
    강화칸 이미지아이콘 없애는 함수
*/
function Upgrade_Remove_Img takes integer pid, integer i returns nothing
    if GetLocalPlayer() == Player(pid) then
        call DzFrameShow(upgrade_object_img, false)
        call DzFrameShow(upgrade_object_button, false)
    endif
endfunction

/*
    강화칸 이미지아이콘 보여주는 함수
*/
function Upgrade_Set_Img takes integer pid, integer i, Object obj returns nothing
    if GetLocalPlayer() == Player(pid) then
        call DzFrameSetTexture(upgrade_object_img, Get_Object_String_Data(obj.Get_Object_Property(ID), IMG), 0)
        call DzFrameShow(upgrade_object_img, true)
        call DzFrameShow(upgrade_object_button, true)
    endif
endfunction

// ===================================
// Combination
// ===================================

/*
    조합칸에서 오브젝트 갯수 갱신하는 함수
*/
function Combination_Item_Count_Refresh takes integer pid, integer i returns nothing
    local Object obj = player_hero[pid].Get_Combination_Item(i)
    if GetLocalPlayer() == Player(pid) then
        call DzFrameSetText(combi_count_text[i], I2S(obj.Get_Object_Property(COUNT)) )
    endif
endfunction

/*
    조합칸 이미지아이콘 없애는 함수
*/
function Combination_Remove_Img takes integer pid, integer i returns nothing
    if GetLocalPlayer() == Player(pid) then
        call DzFrameShow(combi_img[i], false)
        call DzFrameShow(combi_button[i], false)
        call DzFrameShow(combi_count_text[i], false)
    endif
endfunction

/*
    조합칸 이미지아이콘 보여주는 함수
*/
function Combination_Set_Img takes integer pid, integer i, Object obj returns nothing
    if GetLocalPlayer() == Player(pid) then
        call DzFrameSetTexture(combi_img[i], Get_Object_String_Data(obj.Get_Object_Property(ID), IMG), 0)
        call DzFrameShow(combi_img[i], true)
        call DzFrameShow(combi_button[i], true)
        
        if obj.Get_Object_Property(COUNT) >= 1 then
            call DzFrameShow(combi_count_text[i], true)
            call Combination_Item_Count_Refresh(pid, i)
        endif
    endif
endfunction

// ====================================
// Wearing
// ====================================

/*
    장착칸 이미지 아이콘 없애는 함수
*/
function Wearing_Remove_Img takes integer pid, integer i returns nothing
    if GetLocalPlayer() == Player(pid) then
        call DzFrameShow(wearing_img[i], false)
        call DzFrameShow(wearing_buttons[i], false)
    endif
endfunction

/*
    장착칸 이미지 아이콘 보여주는 함수
*/
function Wearing_Set_Img takes integer pid, integer i, Object obj returns nothing
    if GetLocalPlayer() == Player(pid) then
        call DzFrameSetTexture(wearing_img[i], Get_Object_String_Data(obj.Get_Object_Property(ID), IMG), 0)
        call DzFrameShow(wearing_img[i], true)
        call DzFrameShow(wearing_buttons[i], true)
    endif
endfunction

// ==============================
// Inven
// ==============================

/*
    인벤칸 오브젝트 갯수 갱신하는 함수
*/
function Inven_Item_Count_Refresh takes integer pid, integer i returns nothing
    local Object obj = player_hero[pid].Get_Inven_Item(i)
    if GetLocalPlayer() == Player(pid) then
        call DzFrameSetText(item_count_text[i], I2S(obj.Get_Object_Property(COUNT)) )
    endif
endfunction

/*
    인벤칸 이미지아이콘 없애는 함수
*/
function Inven_Remove_Img takes integer pid, integer i returns nothing
    if GetLocalPlayer() == Player(pid) then
        call DzFrameShow(item_img[i], false)
        call DzFrameShow(item_buttons[i], false)
        call DzFrameShow(item_count_text[i], false)
    endif
endfunction

/*
    인벤칸 이미지아이콘 보여주는 함수
*/
function Inven_Set_Img takes integer pid, integer i, Object obj returns nothing
    if GetLocalPlayer() == Player(pid) then
        call DzFrameSetTexture(item_img[i], Get_Object_String_Data(obj.Get_Object_Property(ID), IMG), 0)
        call DzFrameShow(item_img[i], true)
        call DzFrameShow(item_buttons[i], true)
        
        if obj.Get_Object_Property(COUNT) >= 1 then
            call DzFrameShow(item_count_text[i], true)
            call Inven_Item_Count_Refresh(pid, i)
        endif
    endif
endfunction

endlibrary