library InvenSort requires InvenSprite

globals
    // 동기화 트리거
    private trigger sync_trg
    // 정렬버튼
    private integer sort_button
    // 정렬 쿨타임 판별용 불린
    private boolean sort_possible = true
endglobals

/*
    정렬 쿨타임 지나면 불린 다시 true로
*/
private function Sort_Cooldown takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local integer pid = LoadInteger(HT, id, 0)
    
    if GetLocalPlayer() == Player(pid) then
        set sort_possible = true
    endif
    
    call Timer_Clear(t)
    
    set t = null
endfunction

/*
    정렬 동기화 후처리
    정렬을 진행함
*/
private function Sort_Synchronize takes nothing returns nothing
    local timer t = CreateTimer()
    local integer id = GetHandleId(t)
    local string sync_data = DzGetTriggerSyncData()
    local integer pid = S2I( SubString(sync_data, 0, 1) )
    local integer i
    local integer j
    local integer max_grade
    local integer max_index
    local integer min_type_num
    local boolean i_exist
    local Object obj
    
    /*
        간단한 Selection Sort
    */
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i > 24
        set max_grade = -1
        set min_type_num = 10
        set max_index = i
        set i_exist = false
        if player_hero[pid].Check_Inven_Item(i) == true then
            set i_exist = true
            set max_grade = player_hero[pid].Get_Inven_Item(i).Get_Object_Property(GRADE)
            set min_type_num = player_hero[pid].Get_Inven_Item(i).Get_Object_Property(EQUIP_TYPE)
        endif
        
        set j = i
        loop 
        set j = j + 1
        exitwhen j > 24
            if player_hero[pid].Check_Inven_Item(j) == true then
                set obj = player_hero[pid].Get_Inven_Item(j)
                
                if max_grade <= obj.Get_Object_Property(GRADE) and min_type_num > obj.Get_Object_Property(EQUIP_TYPE) then
                    set max_grade = obj.Get_Object_Property(GRADE)
                    set min_type_num = obj.Get_Object_Property(EQUIP_TYPE)
                    set max_index = j
                endif
            endif
        endloop
        
        if i != max_index then
            if i_exist == true then
                set obj = player_hero[pid].Get_Inven_Item(i)
            endif
            
            call player_hero[pid].Set_Inven_Item( i, player_hero[pid].Get_Inven_Item(max_index) )
            
            if i_exist == true then
                call player_hero[pid].Set_Inven_Item( max_index, obj )
            else
                call player_hero[pid].Remove_Inven_Item( max_index )
            endif
            
            call Inven_Set_Img( pid, i, player_hero[pid].Get_Inven_Item(i) )
            
            if i_exist == true then
                call Inven_Set_Img( pid, max_index, obj )
            else
                call Inven_Remove_Img( pid, max_index )
            endif
        endif
    endloop
    
    call SaveInteger(HT, id, 0, pid)
    call TimerStart(t, 1.0, false, function Sort_Cooldown)
    
    set t = null
endfunction

/*
    정렬 버튼 클릭됨
*/
private function Sort_Clicked takes nothing returns nothing
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    
    if is_upgrade_on == 1 then
        return
    endif
    
    if sort_possible == false then
        return
    endif
    
    set sort_possible = false
    set inven_clicked_index = -1
    set wearing_clicked_index = -1
    call Inven_Sprite_Hide()
    
    call DzSyncData("sort", I2S(pid) + " 0" )
endfunction

/*
    정렬 버튼 생성하는 함수
*/
private function Inven_Sort_Button takes nothing returns nothing
    set sort_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", inven_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(sort_button, JN_FRAMEPOINT_CENTER, inven_box, JN_FRAMEPOINT_CENTER, inven_button_standard_x - 0.135, inven_button_standard_y)
    call DzFrameSetSize(sort_button, inven_function_button_size_x, inven_function_button_size_y)
    call DzFrameSetText(sort_button, "정렬")
    call DzFrameSetScriptByCode(sort_button, JN_FRAMEEVENT_CONTROL_CLICK, function Sort_Clicked, false)
endfunction

/*
    정렬 관련 초기화
*/
function Inven_Sort_Init takes nothing returns nothing
    call Inven_Sort_Button()
    
    // 정렬 동기화
    set sync_trg = CreateTrigger()
    call DzTriggerRegisterSyncData(sync_trg, "sort", false)
    call TriggerAddAction( sync_trg, function Sort_Synchronize )
endfunction

endlibrary