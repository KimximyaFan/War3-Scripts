
library InvenUpgrade requires SaveAPI, Base, ObjectPreprocess

globals
    // 계속강화 업그레이드 딜레이
    private real upgrade_delay = 0.5
    // 일반강화 안전강화 선택창 켜져있는지
    private boolean is_selection = false
    // 강화창 켜져있는지
    integer is_upgrade_on = 0
    // 플레이어별 강화창 상태 담는 변수
    integer array upgrade_state[11]
    
    // 해당 상수들은 강화 상태를 의미함
    private constant integer NORMAL_UPGRADE = 0
    private constant integer SAFE_UPGRADE = 1
    private constant integer BOX_OFF = 2
    
    // 강화 선택창 여는 버튼
    private integer upgrade_button
    // 강화 선택창 백드롭
    private integer upgrade_selection_box
    // 강화 선택창 끄는 버튼
    private integer x_button_in_selection
    // 일반강화창 여는 버튼
    private integer normal_upgrade_button
    // 안전강화창 여는 버튼
    private integer safe_upgrade_button
    // 강화창 백드롭
    private integer upgrade_box
    // 강화창 끄는 버튼
    private integer x_button
    // 강화 상태 나타내는 텍스트
    private integer upgrade_state_text
    
    // 강화 오브젝트 백드롭
    integer upgrade_object_back_drop
    // 강화 오브젝트 이미지
    integer upgrade_object_img
    // 강화 오브젝트 버튼
    integer upgrade_object_button
    
    // 필요 재료 텍스트
    private integer required_text
    // 필요 재료 백드롭, 배열임
    integer array required_back_drop
    // 필요 재료 이미지, 배열임
    integer array required_img
    // 필요 재료 버튼, 배열임
    integer array required_button
    // 필요 재료 갯수, 배열임
    integer array required_count_text
    // 필요 재료 오브젝트 ID를 담는 변수, 플레이어 별로 가지고 있음
    integer array required_id[10][10]
    // 필요 재료 갯수를 담는 변수, 플레이어 별로 가짐
    integer array required_count[10][10]
    // 인벤칸에 필요재료 오브젝트가 있을 때, 그 오브젝트의 인벤칸 인덱스를 담는 배열
    integer array required_object_index[10][10]
    
    // 1회 강화 버튼
    private integer upgrade_one_button
    // 계속 강화 버튼
    private integer upgrade_until_button
    // 동기화 트리거
    private trigger sync_trg
endglobals

/*
    오브젝트에 강화를 적용하는 함수
*/
private function Apply_Upgrade takes Object obj returns nothing
    local integer star_grade = obj.Get_Object_Property(STAR_GRADE)
    local integer grade = obj.Get_Object_Property(GRADE)
    local integer equip_type = obj.Get_Object_Property(EQUIP_TYPE)
    local integer array property_arr
    local integer i
    local integer count = -1
    local integer choosen_index
    local integer choosen_property
    local integer min_value
    local integer max_value
    local integer upgrade_value
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= EQUIP_PROPERTY_SIZE
        if obj.Get_Object_Property(i) != -1 then
            set count = count + 1
            set property_arr[count] = i
        endif
    endloop
    
    set choosen_index = GetRandomInt(0, count)
    set choosen_property = property_arr[ choosen_index ]
    set min_value = Get_Option_Upgrade_Min( star_grade, grade, choosen_property )
    set max_value = Get_Option_Upgrade_Max( star_grade, grade, choosen_property )
    set upgrade_value = GetRandomInt(min_value, max_value)
    
    call obj.Set_Object_Property( choosen_property, obj.Get_Object_Property(choosen_property) + upgrade_value )
    call obj.Set_Object_Property( UPGRADE_COUNT, obj.Get_Object_Property(UPGRADE_COUNT) + 1 )
endfunction

/*
    확률에 근거해서, 강화가 성공했는지 판별하는 함수
*/
private function Is_Upgrade_Success takes integer pid, Object obj returns boolean
    local integer star_grade = obj.Get_Object_Property(STAR_GRADE)
    local integer grade = obj.Get_Object_Property(GRADE)
    local integer equip_type = obj.Get_Object_Property(EQUIP_TYPE)
    local integer weight = Get_Upgrade_Probability_Weight(star_grade, grade, equip_type)
    local integer total = Get_Upgrade_Probability_Total(star_grade, grade, equip_type)
    
    if upgrade_state[pid] == SAFE_UPGRADE then
        return true
    endif
    
    return GetRandomInt(1, total) <= weight
endfunction

/*
    강화 재료를 소모하는 함수
*/
private function Consume_Required_Object takes integer pid returns nothing
    local integer i
    local integer index
    local Object obj
    
    set i = -1
    loop
    set i = i + 1
    exitwhen required_id[pid][i] == -1
        set index = required_object_index[pid][i]
        set obj = player_hero[pid].Get_Inven_Item(index)
        
        call obj.Set_Object_Property(COUNT, obj.Get_Object_Property(COUNT) - required_count[pid][i] )
        
        if obj.Get_Object_Property(COUNT) == 0 then
            call player_hero[pid].Delete_Inven_Item(index)
        else
            call Inven_Item_Count_Refresh(pid, index)
        endif
    endloop
endfunction

/*
    강화가 가능한지 판별하는 함수
*/
private function Is_Upgrade_Possible takes integer pid, Object obj returns boolean
    local integer i
    local integer j
    local boolean is_possible = true
    local integer star_grade = obj.Get_Object_Property(STAR_GRADE)
    local integer grade = obj.Get_Object_Property(GRADE)
    
    if upgrade_state[pid] == BOX_OFF then
        call Msg("창 닫힘 강화 취소")
        return false
    endif
    
    // 최대 강화횟수 판별
    if obj.Get_Object_Property(UPGRADE_COUNT) >= Get_Max_Upgrade_Count(star_grade, grade) then
        return false
    endif
    
    // 강화재료 판별
    set i = -1
    loop
    set i = i + 1
    exitwhen required_id[pid][i] == -1 or is_possible == false
    
        set is_possible = false
        
        set j = -1
        loop
        set j = j + 1
        exitwhen j >= 25
            set obj = player_hero[pid].Get_Inven_Item(j)
            
            if obj != -1 then
                if obj.Get_Object_Property(ID) == required_id[pid][i] and obj.Get_Object_Property(COUNT) >= required_count[pid][i] then
                    set is_possible = true
                    set required_object_index[pid][i] = j
                endif
            endif
        endloop
    endloop
    
    return is_possible
endfunction

/*
    Is_Upgrade_Possible() 로 강화가 가능한지 판별함
    
    만약 강화가 가능하다면
    
    Consume_Required_Object() 를 통해서 인벤에 있는 강화 재료를 소모함
    
    그 후,
    
    Is_Upgrade_Success() 통해서 강화가 성공했는지 판별함
    해당 정보는 success_flag 에 담김
    
    만약 강화가 성공했다면 Apply_Upgrade() 를 통해서 강화 수치가 업글됨
    
    그 후, 
    
    success_flag 그리고 is_upgrade_until 를 통해서 계속해서 강화할건지 판별함
    만약 강화가 실패했고, '계속강화' 상태라면 강화가 타이머를 통해서 계속 시도됨
    
    그 후, 
    
    Save 쪽 API를 호출해서 강제 저장을 실행함
*/
private function Upgrade_Process takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer tid = GetHandleId(t)
    local integer pid = LoadInteger(HT, tid, 0)
    local integer is_upgrade_until = LoadInteger(HT, tid, 1)
    local integer upgrade_index = 0
    local Object obj = player_hero[pid].Get_Upgrade_Object(upgrade_index)
    local boolean success_flag
    
    if Is_Upgrade_Possible(pid, obj) == false then
        call Timer_Clear(t)
        set t = null
        return
    endif
    
    call Consume_Required_Object(pid)
    
    set success_flag = Is_Upgrade_Success(pid, obj)
    
    if success_flag == true then
        call Apply_Upgrade(obj)
        call Msg("강화 성공")
    else
        call Msg("강화 실패")
    endif
    
    if success_flag == true or is_upgrade_until == 0 then
        call Timer_Clear(t)
    else
        call TimerStart(t, upgrade_delay, false, function Upgrade_Process)
    endif

    call Save(pid)
    
    set t = null
endfunction

/*
    강화하기 클릭됨 동기화 후처리
    
    1회 강화라면 기본적으로 여기서 로직이 끝나도 되나
    
    계속강화라는 기능도 있으므로
    
    함수 재사용성을 위해서 
    
    upgrade_delay 만큼 기다리면서 timer 기반으로 
    
    Upgrade Process 에서 모두 다룰 수 있게 구현됨
    
    upgrade_delay는 계속강화시 강화 시도 딜레이를 의미함
*/
private function Upgrade_Up_Synchronize takes nothing returns nothing
    local string sync_data = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_data, "/", 0) )
    local integer is_upgrade_until = S2I( JNStringSplit(sync_data, "/", 1) )
    local timer t = CreateTimer()
    local integer tid = GetHandleId(t)
    
    call SaveInteger(HT, tid, 0, pid)
    call SaveInteger(HT, tid, 1, is_upgrade_until)
    call TimerStart(t, upgrade_delay, false, function Upgrade_Process)
    
    set t = null
endfunction

/*
    강화하기 버튼 클릭됨
    1회 강화인지, 계속강화인지에 대한 정보도 전달
*/
private function Upgrade_Up_Clicked takes nothing returns nothing
    local string frame_name = DzFrameGetName(DzGetTriggerUIEventFrame()) 
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    local integer is_upgrade_until = 0
    
    if frame_name == "upgraone" then
        set is_upgrade_until = 0
    elseif frame_name == "upgrauntil" then
        set is_upgrade_until = 1
    endif
    
    call DzSyncData("upgraup", I2S(pid) + "/" + I2S(is_upgrade_until))
endfunction

/*
    필요재료를 숨기는 함수
*/
function Hide_Required_Materials takes integer pid returns nothing
    local integer i
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 10
        set required_id[pid][i] = -1
        set required_count[pid][i] = -1
        set required_object_index[pid][i] = -1
        call Required_Remove_Img(pid, i)
    endloop
endfunction

/*
    오브젝트를 강화하기 위한 필요재료를 보여주는 함수
*/
function Show_Required_Materials takes integer pid returns nothing
    local integer upgrade_index = 0
    local Object obj = player_hero[pid].Get_Upgrade_Object(upgrade_index)
    local integer star_grade
    local integer grade
    local string material_str
    local string str
    local integer i
    
    if obj == -1 then
        return
    endif
    
    set star_grade = obj.Get_Object_Property(STAR_GRADE)
    set grade = obj.Get_Object_Property(GRADE)
    
    if upgrade_state[pid] == NORMAL_UPGRADE then
        set material_str = Get_Normal_Upgrade_Material(star_grade, grade)
    elseif upgrade_state[pid] == SAFE_UPGRADE then
        set material_str = Get_Safe_Upgrade_Material(star_grade, grade)
    endif
    
    set i = -1
    loop
    set i = i + 1
    set str = JNStringSplit(material_str, "#", i)
    exitwhen str == ""
         set required_id[pid][i] = S2I( JNStringSplit(str, ",", 0) )
         set required_count[pid][i] = S2I( JNStringSplit(str, ",", 1) )
         call Required_Set_Img(pid, i, required_id[pid][i], required_count[pid][i])
    endloop
endfunction

/*
    강화칸 오브젝트 클릭됨 후처리
    
    기본적으로 강화칸에 있는걸 인벤칸으로 옮기나
    만약 인벤칸 꽉차있으면 옮겨지지 않음
*/
private function Upgrade_Object_Clicked_Synchronize takes nothing returns nothing
    local string sync_data = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_data, "/", 0) )
    local integer upgrade_index = S2I( JNStringSplit(sync_data, "/", 1) )
    local Object obj = player_hero[pid].Get_Upgrade_Object(upgrade_index)
    local integer object_type = obj.Get_Object_Property(OBJECT_TYPE)
    local integer inven_index = player_hero[pid].Check_Inven_Possible()
    
    if inven_index == -1 then
        return
    endif
    
    call player_hero[pid].Remove_Upgrade_Object( upgrade_index )
    call player_hero[pid].Set_Inven_Item( inven_index, obj )
    call Hide_Required_Materials(pid)
endfunction

/*
    강화칸에 있는 오브젝트 클릭됨
*/
private function Upgrade_Object_Clicked takes nothing returns nothing
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    local integer index = 0

    call Inven_Tool_Tip_Leave()
    call DzSyncData("upgra", I2S(pid) + "/" + I2S(index))
endfunction

/*
    강화창 끔에 대한 동기화
    
    이걸 하는 이유는, "계속 강화" 를 클릭 했을 때
    
    중간에 강화창을 닫으면 계속 강화도 중단되어야함
    
    강화 관련은 동기화 지역에서 진행되는데
    
    프레임은 조작은 local에서 진행되므로
    
    이에 대한 프레임이 닫혔음에 대한 정보는 동기화가 필요함
*/
private function Upgrade_Box_Off_Synchronize takes nothing returns nothing
    local string sync_data = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_data, "/", 0) )
    
    set upgrade_state[pid] = BOX_OFF
endfunction

/*
    강화창 숨기는 함수
    동기화가 들어감
*/
private function Upgrade_Box_Off takes nothing returns nothing
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    
    set is_upgrade_on = 0
    call DzFrameShow(upgrade_box, false)
    call DzSyncData("upoff", I2S(pid) + "/")
endfunction

/*
    강화창 보여주는 함수
*/
private function Upgrade_Box_On takes nothing returns nothing
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )

    set is_upgrade_on = 1
    set inven_clicked_index = -1
    call DzFrameShow(upgrade_box, true)
endfunction

/*
    일반강화 안전강화 선택하는 프레임 숨기는 함수
*/
private function Selection_Box_Off takes nothing returns nothing
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )

    set is_selection = false
    call DzFrameShow(upgrade_selection_box, false)
endfunction

/*
    일반강화 안전강화 선택하는 프레임 보여주는 함수
*/
private function Selection_Box_On takes nothing returns nothing
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )

    set is_selection = true
    set inven_clicked_index = -1
    call DzFrameShow(upgrade_selection_box, true)
endfunction

/*
    강화창 여는 동기화 후처리
    
    일반강화인지 안전강화인지 상태를 기록
    
    그 후 강화 프레임 열고
    
    Show_Required_Materials() 는
    강화 칸에 오브젝트 등록하고나서 강화창 닫았을 때,
    일반강화로 했던걸 안전강화로 바꿔서 킬 수 있고
    안전강화였던게 일반강화로 할 수도 있어서
    이때 필요재료가 달라지므로 그에 대한 갱신 함수를 콜하는 것임
*/
private function Upgrade_Box_Open_Synchronize takes nothing returns nothing
    local string sync_data = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_data, "/", 0) )
    local integer state = S2I( JNStringSplit(sync_data, "/", 1) )
    
    set upgrade_state[pid] = state
    
    if GetLocalPlayer() == Player(pid) then
        call Upgrade_Box_On()
    endif
    
    call Show_Required_Materials(pid)
endfunction

/*
    일반강화 안전강화 선택하는 곳에서
    특정 버튼이 선택됐을 때의 로직
    
    그 후 동기화 처리 들어감
*/
private function Upgrade_Box_Open_Button_Clicked takes nothing returns nothing
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    local string frame_name = DzFrameGetName(DzGetTriggerUIEventFrame())
    local integer state 
    
    if frame_name == "normalupgra" then
        set state = NORMAL_UPGRADE
        call DzFrameSetText(upgrade_state_text, "일반강화" )
        call DzFrameShow(upgrade_until_button, true)
        call DzFrameSetPoint(upgrade_one_button, JN_FRAMEPOINT_BOTTOM, upgrade_box, JN_FRAMEPOINT_BOTTOM, -0.05, 0.02)
    else
        set state = SAFE_UPGRADE
        call DzFrameSetText(upgrade_state_text, "안전강화" )
        call DzFrameShow(upgrade_until_button, false)
        call DzFrameSetPoint(upgrade_one_button, JN_FRAMEPOINT_BOTTOM, upgrade_box, JN_FRAMEPOINT_BOTTOM, 0.0, 0.02)
    endif
    
    call Selection_Box_Off()
    
    call DzSyncData("upon", I2S(pid) + "/" + I2S(state))
endfunction

/*
    강화창 여는 버튼 클릭됨
    
    일반강화, 안전강화로 일단 한번 분기하고
    그 후 강화창이 열려있는지에 대한 판별
*/
private function Selection_Box_Open_Button_Clicked takes nothing returns nothing
    if is_selection == false and is_upgrade_on == 0 then
        call Selection_Box_On()
    elseif is_selection == false and is_upgrade_on == 1 then
        call Upgrade_Box_Off()
    elseif is_selection == true and is_upgrade_on == 0 then
        call Selection_Box_Off()
    endif
endfunction

/*
    변수 초기화, 
    필요재료 관련 변수들임
*/
private function Variable_Init takes nothing returns nothing
    local integer i
    local integer j
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 10
        set j = -1
        loop
        set j = j + 1
        exitwhen j >= 10
            set required_id[i][j] = -1
            set required_count[i][j] = -1
            set required_object_index[i][j] = -1
        endloop
    endloop
endfunction

/*
    강화 관련 프레임 만드는 함수
*/
private function Upgrade_Frame takes nothing returns nothing
    local real x = 0.03
    local real y = -0.125
    local integer i
    local integer a
    local integer b
    
    // 장비강화창 여는 버튼
    set upgrade_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", inven_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(upgrade_button, JN_FRAMEPOINT_CENTER, inven_box, JN_FRAMEPOINT_CENTER, inven_button_standard_x - 0.18, inven_button_standard_y)
    call DzFrameSetSize(upgrade_button, inven_function_button_size_x, inven_function_button_size_y)
    call DzFrameSetText(upgrade_button, "장비\n강화")
    call DzFrameSetScriptByCode(upgrade_button, JN_FRAMEEVENT_CONTROL_CLICK, function Selection_Box_Open_Button_Clicked, false)
    
    // 백드롭
    set upgrade_selection_box = DzCreateFrameByTagName("BACKDROP", "", inven_box, "QuestButtonBaseTemplate", 0)
    call DzFrameSetPoint(upgrade_selection_box, JN_FRAMEPOINT_CENTER, DzGetGameUI(), JN_FRAMEPOINT_CENTER, 0.0, 0.02)
    call DzFrameSetSize(upgrade_selection_box, 0.20, 0.10)
    call DzFrameShow(upgrade_selection_box, false)
    // 일반강화
    set normal_upgrade_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "normalupgra", upgrade_selection_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(normal_upgrade_button, JN_FRAMEPOINT_CENTER, upgrade_selection_box, JN_FRAMEPOINT_CENTER, -0.045, -0.01)
    call DzFrameSetSize(normal_upgrade_button, 0.08, 0.04)
    call DzFrameSetText(normal_upgrade_button, "일반강화")
    call DzFrameSetScriptByCode(normal_upgrade_button, JN_FRAMEEVENT_CONTROL_CLICK, function Upgrade_Box_Open_Button_Clicked, false)
    // 안전강화
    set safe_upgrade_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "safeupgra", upgrade_selection_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(safe_upgrade_button, JN_FRAMEPOINT_CENTER, upgrade_selection_box, JN_FRAMEPOINT_CENTER, 0.045, -0.01)
    call DzFrameSetSize(safe_upgrade_button, 0.08, 0.04)
    call DzFrameSetText(safe_upgrade_button, "안전강화")
    call DzFrameSetScriptByCode(safe_upgrade_button, JN_FRAMEEVENT_CONTROL_CLICK, function Upgrade_Box_Open_Button_Clicked, false)
    // 끄기
    set x_button_in_selection = DzCreateFrameByTagName("GLUETEXTBUTTON", "", upgrade_selection_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(x_button_in_selection, JN_FRAMEPOINT_TOPRIGHT, upgrade_selection_box, JN_FRAMEPOINT_TOPRIGHT, 0, 0)
    call DzFrameSetSize(x_button_in_selection, 0.032, 0.032)
    call DzFrameSetText(x_button_in_selection, "X")
    call DzFrameSetScriptByCode(x_button_in_selection, JN_FRAMEEVENT_CONTROL_CLICK, function Selection_Box_Off, false)
    
    
    // 백드롭
    set upgrade_box = DzCreateFrameByTagName("BACKDROP", "", inven_box, "QuestButtonBaseTemplate", 0)
    call DzFrameSetPoint(upgrade_box, JN_FRAMEPOINT_CENTER, DzGetGameUI(), JN_FRAMEPOINT_CENTER, -0.235, 0.07)
    call DzFrameSetSize(upgrade_box, 0.30, 0.30)
    call DzFrameShow(upgrade_box, false)
    // 강화상태 텍스트
    set upgrade_state_text = DzCreateFrameByTagName("TEXT", "", upgrade_box, "ScoreScreenTabTextSelectedTemplate", 0)
    call DzFrameSetPoint(upgrade_state_text, JN_FRAMEPOINT_TOPLEFT, upgrade_box, JN_FRAMEPOINT_TOPLEFT, 0.02, -0.02)
    call DzFrameSetText(upgrade_state_text, "일반강화" )
    
    // 끄기
    set x_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", upgrade_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(x_button, JN_FRAMEPOINT_TOPRIGHT, upgrade_box, JN_FRAMEPOINT_TOPRIGHT, 0, 0)
    call DzFrameSetSize(x_button, 0.032, 0.032)
    call DzFrameSetText(x_button, "X")
    call DzFrameSetScriptByCode(x_button, JN_FRAMEEVENT_CONTROL_CLICK, function Upgrade_Box_Off, false)
    
    // 강화 칸
    set upgrade_object_back_drop = DzCreateFrameByTagName("BACKDROP", "", upgrade_box, "QuestButtonBaseTemplate", 0)
    call DzFrameSetPoint(upgrade_object_back_drop, JN_FRAMEPOINT_TOP, upgrade_box, JN_FRAMEPOINT_TOP, 0.0, -0.03 )
    call DzFrameSetSize(upgrade_object_back_drop, inven_square_size, inven_square_size)
    set upgrade_object_img = DzCreateFrameByTagName("BACKDROP", "", upgrade_object_back_drop, "QuestButtonBaseTemplate", 0)
    call DzFrameSetPoint(upgrade_object_img, JN_FRAMEPOINT_CENTER, upgrade_object_back_drop, JN_FRAMEPOINT_CENTER, 0, 0 )
    call DzFrameSetSize(upgrade_object_img, inven_item_size, inven_item_size)
    call DzFrameShow(upgrade_object_img, false)
    set upgrade_object_button = DzCreateFrameByTagName("BUTTON", "0/upgrade", upgrade_object_back_drop, "ScoreScreenTabButtonTemplate", 0)
    call DzFrameSetPoint(upgrade_object_button, JN_FRAMEPOINT_CENTER, upgrade_object_back_drop, JN_FRAMEPOINT_CENTER, 0, 0)
    call DzFrameSetSize(upgrade_object_button, inven_square_size, inven_square_size)
    call DzFrameSetScriptByCode(upgrade_object_button, JN_FRAMEEVENT_MOUSE_DOUBLECLICK, function Upgrade_Object_Clicked, false)
    call DzFrameSetScriptByCode(upgrade_object_button, JN_FRAMEEVENT_MOUSE_ENTER, function Inven_Tool_Tip_Enter, false)
    call DzFrameSetScriptByCode(upgrade_object_button, JN_FRAMEEVENT_MOUSE_LEAVE, function Inven_Tool_Tip_Leave, false)
    call DzFrameShow(upgrade_object_button, false)
    

    // 필요재료 각 칸
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 10
        set a = ModuloInteger(i, 5)
        set b = (i / 5)
        set required_back_drop[i] = DzCreateFrameByTagName("BACKDROP", "", upgrade_box, "QuestButtonPushedBackdropTemplate", 0)
        call DzFrameSetPoint(required_back_drop[i], JN_FRAMEPOINT_TOPLEFT, upgrade_box, JN_FRAMEPOINT_TOPLEFT, x + (inven_square_size * a), y + (-inven_square_size * b) )
        call DzFrameSetSize(required_back_drop[i], inven_square_size, inven_square_size)
        call DzFrameShow(required_back_drop[i], false)
        
        set required_img[i] = DzCreateFrameByTagName("BACKDROP", "", required_back_drop[i], "QuestButtonPushedBackdropTemplate", 0)
        call DzFrameSetPoint(required_img[i], JN_FRAMEPOINT_CENTER, required_back_drop[i], JN_FRAMEPOINT_CENTER, 0, 0 )
        call DzFrameSetSize(required_img[i], inven_item_size, inven_item_size)
        call DzFrameShow(required_img[i], false)
        
        set required_button[i] = DzCreateFrameByTagName("BUTTON", I2S(i) + "/required", required_back_drop[i], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetPoint(required_button[i], JN_FRAMEPOINT_CENTER, required_back_drop[i], JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameSetSize(required_button[i], inven_square_size, inven_square_size)
        call DzFrameSetScriptByCode(required_button[i], JN_FRAMEEVENT_MOUSE_ENTER, function Inven_Tool_Tip_Enter, false)
        call DzFrameSetScriptByCode(required_button[i], JN_FRAMEEVENT_MOUSE_LEAVE, function Inven_Tool_Tip_Leave, false)
        call DzFrameShow(required_button[i], false)
        
        set required_count_text[i] = DzCreateFrameByTagName("TEXT", "", required_back_drop[i], "ScoreScreenColumnHeaderTemplate", 0)
        call DzFrameSetPoint(required_count_text[i], JN_FRAMEPOINT_CENTER, required_back_drop[i], JN_FRAMEPOINT_CENTER, 0.0125, -0.0125)
        call DzFrameSetText(required_count_text[i], "0" )
        call DzFrameShow(required_count_text[i], false)
    endloop
    
    // 필요재료 텍스트
    set required_text = DzCreateFrameByTagName("TEXT", "", upgrade_box, "LadderNameTextTemplate", 0)
    call DzFrameSetPoint(required_text, JN_FRAMEPOINT_TOPLEFT, required_back_drop[0], JN_FRAMEPOINT_TOPLEFT, 0.0, 0.015)
    call DzFrameSetText(required_text, "필요재료" )

    // 1 회 강화
    set upgrade_one_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "upgraone", upgrade_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(upgrade_one_button, JN_FRAMEPOINT_BOTTOM, upgrade_box, JN_FRAMEPOINT_BOTTOM, -0.05, 0.02)
    call DzFrameSetSize(upgrade_one_button, 0.080, 0.04)
    call DzFrameSetText(upgrade_one_button, "1회 강화")
    call DzFrameSetScriptByCode(upgrade_one_button, JN_FRAMEEVENT_CONTROL_CLICK, function Upgrade_Up_Clicked, false)
    
    // until 강화
    set upgrade_until_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "upgrauntil", upgrade_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(upgrade_until_button, JN_FRAMEPOINT_BOTTOM, upgrade_box, JN_FRAMEPOINT_BOTTOM, 0.05, 0.02)
    call DzFrameSetSize(upgrade_until_button, 0.080, 0.04)
    call DzFrameSetText(upgrade_until_button, "계속 강화")
    call DzFrameSetScriptByCode(upgrade_until_button, JN_FRAMEEVENT_CONTROL_CLICK, function Upgrade_Up_Clicked, false)
endfunction

/*
    강화 관련 초기화
*/
function Inven_Upgrade_Init takes nothing returns nothing
    call Upgrade_Frame()
    call Variable_Init()
    
    set sync_trg = CreateTrigger()
    call DzTriggerRegisterSyncData(sync_trg, "upgra", false)
    call TriggerAddAction( sync_trg, function Upgrade_Object_Clicked_Synchronize )
    
    set sync_trg = CreateTrigger()
    call DzTriggerRegisterSyncData(sync_trg, "upon", false)
    call TriggerAddAction( sync_trg, function Upgrade_Box_Open_Synchronize )
    
    set sync_trg = CreateTrigger()
    call DzTriggerRegisterSyncData(sync_trg, "upoff", false)
    call TriggerAddAction( sync_trg, function Upgrade_Box_Off_Synchronize )
    
    set sync_trg = CreateTrigger()
    call DzTriggerRegisterSyncData(sync_trg, "upgraup", false)
    call TriggerAddAction( sync_trg, function Upgrade_Up_Synchronize )
endfunction

endlibrary
