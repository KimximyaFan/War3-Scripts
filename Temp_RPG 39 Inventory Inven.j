
library InvenInven requires InvenGeneric, InvenToolTip, Stat, InvenUpgrade

globals
    private trigger sync_trg

    integer array item_back_drops
    integer array item_img
    integer array item_buttons
    integer array item_count_text
    
    integer inven_clicked_index = -1
    
    private boolean exception_restriction = false
endglobals

/*
    Lock 해제
*/
private function Logic_Lock_Free takes integer pid returns nothing
    if GetLocalPlayer() == Player(pid) then
        set exception_restriction = false
    endif
endfunction

/*
    한번의 프로세스만 진행됨을 보장하기 위한 Lock 함수
*/
private function Logic_Lock takes integer pid returns nothing
    if GetLocalPlayer() == Player(pid) then
        set exception_restriction = true
    endif
endfunction

/*
    조합창 켜져있을 때, 인벤칸에서 조합칸으로 오브젝트 옮길때 관련한 함수
    
    이 함수는 split 쪽에서 DzSyncData로 호출됨
*/
private function Inven_To_Combination_Synchronize takes nothing returns nothing
    local string sync_data = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_data, "/", 0) )
    local integer inven_index = S2I( JNStringSplit(sync_data, "/", 1) )
    local integer split_count = S2I( JNStringSplit(sync_data, "/", 2) )
    local Object obj = player_hero[pid].Get_Inven_Item(inven_index)
    local Object new_obj
    local integer combination_index
    
    if obj.Get_Object_Property(COUNT) < split_count or split_count == 0 then
        return
    endif
    
    set combination_index = player_hero[pid].Check_Same_Id_In_Combination(obj)
    
    if combination_index == -1 then
        set combination_index = player_hero[pid].Check_Combination_Space_Possible()
        set new_obj = Detach_Object( obj, split_count )
        call player_hero[pid].Set_Combination_Item(combination_index, new_obj)
    else
        call Split_Object( obj, player_hero[pid].Get_Combination_Item(combination_index), split_count )
        call Combination_Item_Count_Refresh(pid, combination_index)
    endif
    
    call Inven_Item_Count_Refresh(pid, inven_index)
    
    if obj.Get_Object_Property(COUNT) == 0 then
        call player_hero[pid].Delete_Inven_Item(inven_index)
    endif
    
    call Logic_Lock_Free(pid)
endfunction

/*
    장비창이 켜져있을 때의 처리
*/
private function Upgrade_Process takes integer pid, integer inven_index, Object obj returns nothing
    local integer upgrade_index = 0
    local Object upgrade_obj
    
    if obj.Get_Object_Property(OBJECT_TYPE) != EQUIP then
        return
    endif
    
    if player_hero[pid].Check_Upgrade_Object(upgrade_index) == false then
        call player_hero[pid].Remove_Inven_Item(inven_index)
        call player_hero[pid].Set_Upgrade_Object( upgrade_index, obj )
    else
        set upgrade_obj = player_hero[pid].Get_Upgrade_Object( upgrade_index )
        call player_hero[pid].Set_Inven_Item( inven_index, upgrade_obj )
        call player_hero[pid].Set_Upgrade_Object( upgrade_index, obj )
    endif

    call Show_Required_Materials(pid)
endfunction

/*
    조합창이 켜져있을 때의 처리
*/
private function Combination_Process takes integer pid, integer inven_index, Object obj returns nothing
    local integer combination_index = player_hero[pid].Check_Combination_Space_Possible()
    
    if combination_index == -1 then
        return
    endif
    
    if obj.Get_Object_Property(LOCK) == 1 then
        return
    endif
        
    if obj.Get_Object_Property(OBJECT_TYPE) == EQUIP then
        call player_hero[pid].Remove_Inven_Item(inven_index)
        call player_hero[pid].Set_Combination_Item( combination_index, obj )
    else
        if GetLocalPlayer() == Player(pid) then
            set split_state = INVEN_TO_COMBINATION
            set split_index = inven_index
            
            call Split_Box_On()
            call Logic_Lock(pid)
        endif
    endif
endfunction

/*
    클릭한 오브젝트가 소모품일경우의 처리
*/
private function Consumable_Process takes integer pid, integer inven_index, Object obj returns nothing
    local integer current_type = obj.Get_Object_Property(CONSUMABLE_TYPE)
    
    if obj.Get_Object_Property(LOCK) == 1 then
        return
    endif
    
    if current_type == RANDOM_BOX then
        call Random_Box_Process_In_Inventory( pid, inven_index, obj )
    elseif current_type == 2 then
    
    endif
    
    call Inven_Item_Count_Refresh(pid, inven_index)
endfunction

/*
    클릭한 오브젝트가 장비일경우의 처리
*/
private function Equip_Process takes integer pid, integer inven_index, Object obj returns nothing
    local integer wearing_index = player_hero[pid].Check_Wearing( obj.Get_Object_Property(EQUIP_TYPE) )
    
    if wearing_index == -1 then
        // 이미 장착 칸에 아이템을 낀경우
        
        set wearing_index = obj.Get_Object_Property(EQUIP_TYPE)
        
        call player_hero[pid].Set_Inven_Item( inven_index, player_hero[pid].Get_Wearing_Item(wearing_index) )
        call player_hero[pid].Remove_Wearing_Item( wearing_index )
        call player_hero[pid].Set_Wearing_Item( wearing_index, obj )

        call Stat_Refresh(pid)
    else
        // 장착 칸이 빈 경우
        call player_hero[pid].Remove_Inven_Item( inven_index )
        call player_hero[pid].Set_Wearing_Item( wearing_index, obj )

        call Stat_Refresh(pid)
    endif

    if GetLocalPlayer() == Player(pid) then
        // 효과음
        //call PlaySoundBJ(gg_snd_PickUpItem)
    endif
endfunction

/*
    인벤칸 클릭됨 동기화 후처리
    
    조함창 켜져있는지
    업글창 켜져있는지
    오브젝트가 장비인지
    오브젝트가 소모품인지
    오브젝트가 재료인지
    
    등등에 따라서 처리 로직이 달라짐
*/
private function Inven_Item_Synchronize takes nothing returns nothing
    local string sync_data = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_data, "/", 0) )
    local integer inven_index = S2I( JNStringSplit(sync_data, "/", 1) )
    local integer is_combi_box_on = S2I( JNStringSplit(sync_data, "/", 2) )
    local Object obj = player_hero[pid].Get_Inven_Item(inven_index)
    local integer object_type = obj.Get_Object_Property(OBJECT_TYPE)
    
    
    
    if is_combi_box_on == 1 then
        call Combination_Process(pid, inven_index, obj)
        
    elseif is_upgrade_on == 1 then
        call Upgrade_Process(pid, inven_index, obj)
        
    elseif object_type == EQUIP then
        call Equip_Process(pid, inven_index, obj)
        
    elseif object_type == CONSUMABLE then
        call Consumable_Process(pid, inven_index, obj)
        
    elseif object_type == MATERIAL then

    endif
    
    call Logic_Lock_Free(pid)
endfunction

/*
    인벤칸 오브젝트 클릭됐을 때 처리
    두번 클릭되면 동기화로직 진행됨
*/
private function Inven_Item_Clicked takes nothing returns nothing
    local integer event_frame = DzGetTriggerUIEventFrame()
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    local integer index = S2I( JNStringSplit(DzFrameGetName(event_frame), "/", 0) )
    local integer is_combi_box_on = 0
    
    if is_split_on == true or exception_restriction == true  then
        return
    endif

    if inven_clicked_index == index then
        set inven_clicked_index = -1
        call Logic_Lock(pid)
        call Inven_Tool_Tip_Leave()
        call Inven_Sprite_Hide()
        
        if is_combination == true then
            set is_combi_box_on = 1
        endif
        
        call DzSyncData("inven", I2S(pid) + "/" + I2S(index) + "/" + I2S(is_combi_box_on))
    else
        // 클릭 사운드 재생
        //call PlaySoundBJ(gg_snd_AutoCastButtonClick1)
        call Inven_Sprite_Set_Position(event_frame)
        call Inven_Sprite_Show()
        // 클릭한 인벤의 인덱스
        set inven_clicked_index = index
        // 착용 아이템 인덱스는 -1로
        set wearing_clicked_index = -1
    endif
endfunction

// 아이템칸 25개, 백드롭과 버튼으로 구성됨
private function Inven_Inven_Frames takes nothing returns nothing
    local integer i
    local integer a
    local integer b
    local real x = 0.010
    local real y = 0.075
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i > 24
        
        set a = ModuloInteger(i, 5)
        set b = (i / 5)
        set item_back_drops[i] = DzCreateFrameByTagName("BACKDROP", "", inven_box, "QuestButtonPushedBackdropTemplate", 0)
        call DzFrameSetPoint(item_back_drops[i], JN_FRAMEPOINT_CENTER, inven_box, JN_FRAMEPOINT_CENTER, x + (inven_square_size * a), y + (-inven_square_size * b) )
        call DzFrameSetSize(item_back_drops[i], inven_square_size, inven_square_size)
        
        set item_img[i] = DzCreateFrameByTagName("BACKDROP", "", item_back_drops[i], "QuestButtonPushedBackdropTemplate", 0)
        call DzFrameSetPoint(item_img[i], JN_FRAMEPOINT_CENTER, item_back_drops[i], JN_FRAMEPOINT_CENTER, 0, 0 )
        call DzFrameSetSize(item_img[i], inven_item_size, inven_item_size)
        call DzFrameShow(item_img[i], false)
        
        set item_buttons[i] = DzCreateFrameByTagName("BUTTON", I2S(i) + "/item", item_back_drops[i], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetPoint(item_buttons[i], JN_FRAMEPOINT_CENTER, item_back_drops[i], JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameSetSize(item_buttons[i], inven_square_size, inven_square_size)
        call DzFrameSetScriptByCode(item_buttons[i], JN_FRAMEEVENT_CONTROL_CLICK, function Inven_Item_Clicked, false)
        // 마우스 진입, 빠져나올 때 툴팁 함수 실행됨
        call DzFrameSetScriptByCode(item_buttons[i], JN_FRAMEEVENT_MOUSE_ENTER, function Inven_Tool_Tip_Enter, false)
        call DzFrameSetScriptByCode(item_buttons[i], JN_FRAMEEVENT_MOUSE_LEAVE, function Inven_Tool_Tip_Leave, false)
        call DzFrameShow(item_buttons[i], false)
        
        set item_count_text[i] = DzCreateFrameByTagName("TEXT", "", item_back_drops[i], "ScoreScreenColumnHeaderTemplate", 0)
        call DzFrameSetPoint(item_count_text[i], JN_FRAMEPOINT_CENTER, item_back_drops[i], JN_FRAMEPOINT_CENTER, 0.0125, -0.0125)
        call DzFrameSetText(item_count_text[i], "0" )
        call DzFrameShow(item_count_text[i], false)
    endloop
endfunction

/*
    인벤칸 관련 초기화
*/
function Inven_Inven_Init takes nothing returns nothing
    call Inven_Inven_Frames()
    
    // 아이템칸 동기화
    set sync_trg = CreateTrigger()
    call DzTriggerRegisterSyncData(sync_trg, "inven", false)
    call TriggerAddAction( sync_trg, function Inven_Item_Synchronize )
    
    // 인벤 -> 조합
    set sync_trg = CreateTrigger()
    call DzTriggerRegisterSyncData(sync_trg, "spi2c", false)
    call TriggerAddAction( sync_trg, function Inven_To_Combination_Synchronize )
endfunction

endlibrary