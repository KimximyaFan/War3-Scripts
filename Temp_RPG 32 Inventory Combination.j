library InvenCombination requires InvenSprite, InvenToolTip, ObjectAPI

globals
    // 조합창 켜져있는지
    boolean is_combination = false
    // 조합칸 클릭된 오브젝트 인덱스 담는 변수
    integer combi_clicked_index = -1
    // 조합칸 백드롭, 배열임
    integer array combi_back_drop
    // 조합칸 이미지, 배열임
    integer array combi_img
    // 조합칸 버튼, 배열임
    integer array combi_button
    // 조합칸 갯수텍스트, 배열임
    integer array combi_count_text
    // 조합창 키는 버튼
    private integer combination_button
    // 조합창 백드롭
    private integer combination_box
    // 조합창 끄는 버튼
    private integer x_button
    // 조합 실행 버튼
    private integer combination_execute_button
    // 동기화 트리거
    private trigger sync_trg
endglobals

/*
    조합 조건 충족시, 조합된 오브젝트 생성하는 함수
*/
private function Result_Object_Create takes integer pid, integer object_id, integer count returns nothing
    local Object obj
    
    if Get_Object_Data(object_id, OBJECT_TYPE) == EQUIP then
        set obj = Create_Equip(object_id)
        
    elseif Get_Object_Data(object_id, OBJECT_TYPE) == CONSUMABLE then
        set obj = Create_Consumable(object_id, count)
        
    elseif Get_Object_Data(object_id, OBJECT_TYPE) == MATERIAL then
    
    endif
    
    call player_hero[pid].Set_Combination_Item(COMBINATION_END, obj)
endfunction

/*
    조합 조건 충족시, 조합 재료들 다 삭제하는 함수
*/
private function Remove_All_Combination_Components takes integer pid returns nothing
    local integer i
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= COMBINATION_END
        call player_hero[pid].Delete_Combination_Item(i)
    endloop
endfunction
/*
    조합칸에 있는 오브젝트들로 조합스트링을 만드는 함수
    조합 테이블을 참조하기 위함
*/
private function Make_Combination_String takes integer pid returns string
    local PriorityQueue pq = PriorityQueue.create(true)
    local Object obj
    local Pair p
    local integer i
    local integer object_id
    local integer count
    local string str = ""
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 10
        set obj = player_hero[pid].Get_Combination_Item(i)
        
        if obj != -1 then
            set object_id = obj.Get_Object_Property(ID)
            
            if obj.Get_Object_Property(OBJECT_TYPE) == EQUIP then
                set count = 0
            else
                set count = obj.Get_Object_Property(COUNT)
            endif
            
            call pq.Push( Pair.create( object_id, count ) )
        endif
    endloop
    
    loop
    exitwhen pq.Is_Empty() == true
        set p = pq.Pop()
        set str = str + Integer_To_Alphabet26(p.Key) + I2S(p.Value)
        call p.destroy()
    endloop
    
    call pq.destroy()
    
    return str
endfunction

/*
    조합 버튼 클릭 후, 동기화 후처리
    
    조합칸에 있는 아이템들로 조합스트링을 만들고
    
    해당 조합스트링으로 조합이 가능한지 판별을 한다
    
    Is_Combination_Possible() 함수는 조합이 가능하다면 제대로 된 오브젝트 ID를 반환한다
    
    만약 ID 가 -1 이면 조합이 안된다는 뜻
    
    만약 조합 성공시 조합칸 모든 아이템 삭제하고, 조합 오브젝트를 생성한다
*/
private function Combination_Synchronize takes nothing returns nothing
    local string sync_data = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_data, "/", 0) )
    local string combination_str
    local integer combination_id
    local integer object_count
    
    set combination_str = Make_Combination_String(pid)
    
    set combination_id = Is_Combination_Possible( combination_str )
    
    if combination_id == -1 then
        return
    endif
    
    set object_count = Get_Combination_Object_Count( combination_str )
    
    call Remove_All_Combination_Components(pid)
    
    call Result_Object_Create(pid, combination_id, object_count)
endfunction

/*
    조합하기 클릭 됐을 때 실행하는 함수
*/
private function Combination_Clicked takes nothing returns nothing
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )

    if player_hero[pid].Get_Combination_Item(COMBINATION_END) != -1 then
        return
    endif

    call DzSyncData("combi2", I2S(pid) + "/")
endfunction

/*
    조합창 숨기는 함수
*/
private function Combination_Box_Off takes nothing returns nothing
    set combi_clicked_index = -1
    set is_combination = false
    call DzFrameShow(combination_box, false)
endfunction

/*
    조합창 키는 함수
*/
private function Combination_Box_On takes nothing returns nothing
    set is_combination = true
    set inven_clicked_index = -1
    set wearing_clicked_index = -1
    call Inven_Sprite_Hide()
    call DzFrameShow(combination_box, true)
endfunction

/*
    조합칸에 있는 오브젝트 인벤칸으로 옮길때 동기화 후처리
    해당 함수는 split 쪽에서 DzSyncData로 호출된다
*/
private function Combination_To_Inven_Synchronize takes nothing returns nothing
    local string sync_data = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_data, "/", 0) )
    local integer combination_index = S2I( JNStringSplit(sync_data, "/", 1) )
    local integer split_count = S2I( JNStringSplit(sync_data, "/", 2) )
    local Object obj = player_hero[pid].Get_Combination_Item(combination_index)
    local Object new_obj
    local integer inven_index
    
    if obj.Get_Object_Property(COUNT) < split_count or split_count == 0 then
        return
    endif
    
    set inven_index = player_hero[pid].Check_Same_Id_In_Inven(obj)
    
    if inven_index == -1 then
        set inven_index = player_hero[pid].Check_Inven_Possible()
        set new_obj = Detach_Object( obj, split_count )
        call player_hero[pid].Set_Inven_Item(inven_index, new_obj)
    else
        call Split_Object( obj, player_hero[pid].Get_Inven_Item(inven_index), split_count )
        call Inven_Item_Count_Refresh(pid, inven_index)
    endif
    
    call Combination_Item_Count_Refresh(pid, combination_index)
    
    if obj.Get_Object_Property(COUNT) == 0 then
        call player_hero[pid].Delete_Combination_Item(combination_index)
    endif
endfunction

/*
    조합칸에서 오브젝트 더블클릭 됐을 때, 동기화 후처리
    오브젝트 타입이 EQUIP 이면 바로 인벤칸으로 옮겨가지만
    소모품이나 재료면 Split 관련 처리를 거친다
*/
private function Combination_Object_Clicked_Synchronize takes nothing returns nothing
    local string sync_data = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_data, "/", 0) )
    local integer combination_index = S2I( JNStringSplit(sync_data, "/", 1) )
    local Object obj = player_hero[pid].Get_Combination_Item(combination_index)
    local integer object_type = obj.Get_Object_Property(OBJECT_TYPE)
    local integer inven_index = player_hero[pid].Check_Inven_Possible()
    
    if inven_index == -1 then
        return
    endif
    
    if object_type == EQUIP then
        call player_hero[pid].Remove_Combination_Item( combination_index )
        call player_hero[pid].Set_Inven_Item( inven_index, obj )
    else
        if GetLocalPlayer() == Player(pid) then
            set split_state = COMBINATION_TO_INVEN
            set split_index = combination_index
            
            call Split_Box_On()
        endif
    endif
endfunction

/*
    조합칸 오브젝트 클릭됨 함수
    두번 클릭되면 로직 진행함
*/
private function Combination_Object_Clicked takes nothing returns nothing
    local integer event_frame = DzGetTriggerUIEventFrame()
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    local integer index = S2I( JNStringSplit(DzFrameGetName(event_frame), "/", 0) )
    
    if is_split_on == true then
        return
    endif

    if combi_clicked_index == index then
        set combi_clicked_index = -1
        call Inven_Tool_Tip_Leave()
        call Inven_Sprite_Hide()
        call DzSyncData("combi", I2S(pid) + "/" + I2S(index))
    else
        // 클릭 사운드 재생
        //call PlaySoundBJ(gg_snd_AutoCastButtonClick1)
        call Inven_Sprite_Set_Position(event_frame)
        call Inven_Sprite_Show()
        // 클릭한 인벤의 인덱스
        set combi_clicked_index = index
        // 착용 아이템 인덱스는 -1로
        set wearing_clicked_index = -1
        set inven_clicked_index = -1
    endif
endfunction

/*
    인벤창 기능버튼들에 있는 조합버튼 클릭 됐을 때
    조합창 껐다 켰다
*/
private function Combination_Button_In_Inven_Clicked takes nothing returns nothing
    if is_combination == true then
        call Combination_Box_Off()
    else
        call Combination_Box_On()
    endif
endfunction

/*
    프레임 생성하는 함수
*/
private function Inven_Combination_Frame_Init takes nothing returns nothing
    local integer i
    local integer a
    local integer b
    local real x = 0.010
    local real y = -0.125
    
    // 인벤창에 있는 조합창 여는 버튼
    set combination_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", inven_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(combination_button, JN_FRAMEPOINT_CENTER, inven_box, JN_FRAMEPOINT_CENTER, inven_button_standard_x - 0.225, inven_button_standard_y)
    call DzFrameSetSize(combination_button, inven_function_button_size_x, inven_function_button_size_y)
    call DzFrameSetText(combination_button, "조합")
    call DzFrameSetScriptByCode(combination_button, JN_FRAMEEVENT_CONTROL_CLICK, function Combination_Button_In_Inven_Clicked, false)
    
    // 백드롭
    set combination_box = DzCreateFrameByTagName("BACKDROP", "", inven_box, "QuestButtonBaseTemplate", 0)
    call DzFrameSetPoint(combination_box, JN_FRAMEPOINT_CENTER, DzGetGameUI(), JN_FRAMEPOINT_CENTER, -0.235, 0.07)
    call DzFrameSetSize(combination_box, 0.26, 0.30)
    call DzFrameShow(combination_box, false)
    
    // 끄기
    set x_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", combination_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(x_button, JN_FRAMEPOINT_TOPRIGHT, combination_box, JN_FRAMEPOINT_TOPRIGHT, 0, 0)
    call DzFrameSetSize(x_button, 0.032, 0.032)
    call DzFrameSetText(x_button, "X")
    call DzFrameSetScriptByCode(x_button, JN_FRAMEEVENT_CONTROL_CLICK, function Combination_Box_Off, false)
    
    // 누르면 조합
    set combination_execute_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", combination_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(combination_execute_button, JN_FRAMEPOINT_BOTTOM, combination_box, JN_FRAMEPOINT_BOTTOM, 0.00, 0.02)
    call DzFrameSetSize(combination_execute_button, 0.080, 0.04)
    call DzFrameSetText(combination_execute_button, "조합하기")
    call DzFrameSetScriptByCode(combination_execute_button, JN_FRAMEEVENT_CONTROL_CLICK, function Combination_Clicked, false)
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 10
        
        set a = ModuloInteger(i, 5)
        set b = (i / 5)
        set combi_back_drop[i] = DzCreateFrameByTagName("BACKDROP", "", combination_box, "QuestButtonPushedBackdropTemplate", 0)
        call DzFrameSetPoint(combi_back_drop[i], JN_FRAMEPOINT_TOPLEFT, combination_box, JN_FRAMEPOINT_TOPLEFT, x + (inven_square_size * a), y + (-inven_square_size * b) )
        call DzFrameSetSize(combi_back_drop[i], inven_square_size, inven_square_size)
        
        set combi_img[i] = DzCreateFrameByTagName("BACKDROP", "", combi_back_drop[i], "QuestButtonPushedBackdropTemplate", 0)
        call DzFrameSetPoint(combi_img[i], JN_FRAMEPOINT_CENTER, combi_back_drop[i], JN_FRAMEPOINT_CENTER, 0, 0 )
        call DzFrameSetSize(combi_img[i], inven_item_size, inven_item_size)
        call DzFrameShow(combi_img[i], false)
        
        set combi_button[i] = DzCreateFrameByTagName("BUTTON", I2S(i) + "/combi", combi_back_drop[i], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetPoint(combi_button[i], JN_FRAMEPOINT_CENTER, combi_back_drop[i], JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameSetSize(combi_button[i], inven_square_size, inven_square_size)
        call DzFrameSetScriptByCode(combi_button[i], JN_FRAMEEVENT_CONTROL_CLICK, function Combination_Object_Clicked, false)
        // 마우스 진입, 빠져나올 때 툴팁 함수 실행됨
        call DzFrameSetScriptByCode(combi_button[i], JN_FRAMEEVENT_MOUSE_ENTER, function Inven_Tool_Tip_Enter, false)
        call DzFrameSetScriptByCode(combi_button[i], JN_FRAMEEVENT_MOUSE_LEAVE, function Inven_Tool_Tip_Leave, false)
        call DzFrameShow(combi_button[i], false)
        
        set combi_count_text[i] = DzCreateFrameByTagName("TEXT", "", combi_back_drop[i], "ScoreScreenColumnHeaderTemplate", 0)
        call DzFrameSetPoint(combi_count_text[i], JN_FRAMEPOINT_CENTER, combi_back_drop[i], JN_FRAMEPOINT_CENTER, 0.0125, -0.0125)
        call DzFrameSetText(combi_count_text[i], "0" )
        call DzFrameShow(combi_count_text[i], false)
    endloop
    
    // 결과 오브젝트
    set combi_back_drop[10] = DzCreateFrameByTagName("BACKDROP", "", combination_box, "QuestButtonBaseTemplate", 0)
    call DzFrameSetPoint(combi_back_drop[10], JN_FRAMEPOINT_TOP, combination_box, JN_FRAMEPOINT_TOP, 0.0, -0.03 )
    call DzFrameSetSize(combi_back_drop[10], inven_square_size, inven_square_size)
    
    set combi_img[10] = DzCreateFrameByTagName("BACKDROP", "", combi_back_drop[10], "QuestButtonBaseTemplate", 0)
    call DzFrameSetPoint(combi_img[10], JN_FRAMEPOINT_CENTER, combi_back_drop[10], JN_FRAMEPOINT_CENTER, 0, 0 )
    call DzFrameSetSize(combi_img[10], inven_item_size, inven_item_size)
    call DzFrameShow(combi_img[10], false)
    
    set combi_button[10] = DzCreateFrameByTagName("BUTTON", I2S(10) + "/combi", combi_back_drop[10], "ScoreScreenTabButtonTemplate", 0)
    call DzFrameSetPoint(combi_button[10], JN_FRAMEPOINT_CENTER, combi_back_drop[10], JN_FRAMEPOINT_CENTER, 0, 0)
    call DzFrameSetSize(combi_button[10], inven_square_size, inven_square_size)
    call DzFrameSetScriptByCode(combi_button[10], JN_FRAMEEVENT_CONTROL_CLICK, function Combination_Object_Clicked, false)
    // 마우스 진입, 빠져나올 때 툴팁 함수 실행됨
    call DzFrameSetScriptByCode(combi_button[10], JN_FRAMEEVENT_MOUSE_ENTER, function Inven_Tool_Tip_Enter, false)
    call DzFrameSetScriptByCode(combi_button[10], JN_FRAMEEVENT_MOUSE_LEAVE, function Inven_Tool_Tip_Leave, false)
    call DzFrameShow(combi_button[10], false)
    
    set combi_count_text[10] = DzCreateFrameByTagName("TEXT", "", combi_back_drop[10], "ScoreScreenColumnHeaderTemplate", 0)
    call DzFrameSetPoint(combi_count_text[10], JN_FRAMEPOINT_CENTER, combi_back_drop[10], JN_FRAMEPOINT_CENTER, 0.0125, -0.0125)
    call DzFrameSetText(combi_count_text[10], "0" )
    call DzFrameShow(combi_count_text[10], false)
endfunction

/*
    조합 관련 초기화
*/
function Inven_Combination_Init takes nothing returns nothing

    call Inven_Combination_Frame_Init()
    
    // 아이템 더블클릭 동기화
    set sync_trg = CreateTrigger()
    call DzTriggerRegisterSyncData(sync_trg, "combi", false)
    call TriggerAddAction( sync_trg, function Combination_Object_Clicked_Synchronize )
    
    // 조합 -> 인벤
    set sync_trg = CreateTrigger()
    call DzTriggerRegisterSyncData(sync_trg, "spc2i", false)
    call TriggerAddAction( sync_trg, function Combination_To_Inven_Synchronize )
    
    // 조합 동기화
    set sync_trg = CreateTrigger()
    call DzTriggerRegisterSyncData(sync_trg, "combi2", false)
    call TriggerAddAction( sync_trg, function Combination_Synchronize )
endfunction

endlibrary
