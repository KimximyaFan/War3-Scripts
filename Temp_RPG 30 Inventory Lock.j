library InventoryLock requires InvenToolTip

globals
    // 우클릭 한 아이템 인덱스 담는 변수
    private integer lock_index
    // 우클릭 프레임 백드롭
    private integer lock_back_drop
    // 잠금 버튼
    private integer lock_button
    // 잠금 해제 버튼
    private integer unlock_button
    // 우클릭 프레임 닫는 버튼
    private integer x_button
    // 동기화 트리거
    private trigger sync_trg
endglobals


/*
    우클릭 프레임 숨기는 함수
*/
function Inven_Hide_Lock_Box takes nothing returns nothing
    call DzFrameShow(lock_back_drop, false)
endfunction
/*
    우클림 프레임 보여주는 함수
*/
function Inven_Show_Lock_Box takes nothing returns nothing
    set lock_index = current_tool_tip_index
    call Inven_Tool_Tip_Leave()
    call DzFrameSetPoint(lock_back_drop, JN_FRAMEPOINT_CENTER, item_buttons[lock_index], JN_FRAMEPOINT_CENTER, 0.04, 0.04)
    call DzFrameShow(lock_back_drop, true)
endfunction
/*
    잠금해제 버튼 클릭 동기화 후처리
    해당 아이템을 잠금해제 한다
*/
private function Unlock_Clicked_Synchronize takes nothing returns nothing
    local string sync_data = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_data, "/", 0) )
    local integer index = S2I( JNStringSplit(sync_data, "/", 1) )
    local Object obj = player_hero[pid].Get_Inven_Item(index)
    
    call obj.Set_Object_Property(LOCK, 0)
endfunction
/*
    잠금 버튼 클릭 동기화 후처리
    해당 아이템을 잠근다
*/
private function Lock_Clicked_Synchronize takes nothing returns nothing
    local string sync_data = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_data, "/", 0) )
    local integer index = S2I( JNStringSplit(sync_data, "/", 1) )
    local Object obj = player_hero[pid].Get_Inven_Item(index)
    
    call obj.Set_Object_Property(LOCK, 1)
endfunction
/*
    잠금 해제 클릭됨 처리하는 함수
*/
private function Unlock_Clicked takes nothing returns nothing
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    
    call Inven_Hide_Lock_Box()
    call DzSyncData( "ulok" , I2S(pid) + "/" + I2S(lock_index) )
endfunction
/*
    잠금 클릭됨 처리하는 함수
*/
private function Lock_Clicked takes nothing returns nothing
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    
    call Inven_Hide_Lock_Box()
    call DzSyncData( "lok" , I2S(pid) + "/" + I2S(lock_index) )
endfunction
/*
    해당 아이템 우클릭 했을 때, 프레임을 보여주는 함수
*/
private function Mouse_Right_Clicked takes nothing returns nothing
    if current_tool_tip_index == -1 then
        return
    endif
    
    call Inven_Show_Lock_Box()
endfunction
/*
    잠금 프레임 생성 하는 함수
*/
private function Inven_Lock_Frame takes nothing returns nothing
    local real lock_x = 0.01
    local real lock_y = -0.01
    local real unlock_x = 0.01
    local real unlock_y = -0.045
    
    set lock_back_drop = DzCreateFrameByTagName("BACKDROP", "", inven_box, "QuestButtonBaseTemplate", 0)
    call DzFrameSetSize(lock_back_drop, 0.08, 0.085)
    call DzFrameShow(lock_back_drop, false)
    
    // 끄기
    set x_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", lock_back_drop, "ScriptDialogButton", 0)
    call DzFrameSetPoint(x_button, JN_FRAMEPOINT_TOPRIGHT, lock_back_drop, JN_FRAMEPOINT_TOPRIGHT, 0, 0)
    call DzFrameSetSize(x_button, 0.032, 0.032)
    call DzFrameSetText(x_button, "X")
    call DzFrameSetScriptByCode(x_button, JN_FRAMEEVENT_CONTROL_CLICK, function Inven_Hide_Lock_Box, false)
    
    set lock_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", lock_back_drop, "ScriptDialogButton", 0)
    call DzFrameSetPoint(lock_button, JN_FRAMEPOINT_TOPLEFT, lock_back_drop, JN_FRAMEPOINT_TOPLEFT, lock_x, lock_y)
    call DzFrameSetSize(lock_button, 0.040, 0.035)
    call DzFrameSetText(lock_button, "잠금")
    call DzFrameSetScriptByCode(lock_button, JN_FRAMEEVENT_CONTROL_CLICK, function Lock_Clicked, false)
    
    set unlock_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", lock_back_drop, "ScriptDialogButton", 0)
    call DzFrameSetPoint(unlock_button, JN_FRAMEPOINT_TOPLEFT, lock_back_drop, JN_FRAMEPOINT_TOPLEFT, unlock_x, unlock_y)
    call DzFrameSetSize(unlock_button, 0.040, 0.035)
    call DzFrameSetText(unlock_button, "해제")
    call DzFrameSetScriptByCode(unlock_button, JN_FRAMEEVENT_CONTROL_CLICK, function Unlock_Clicked, false)
endfunction
/*
    잠금 관련 초기화
*/
function Inven_Lock_Init takes nothing returns nothing

    call Inven_Lock_Frame()
    
    call DzTriggerRegisterMouseEventByCode(null, JN_MOUSE_BUTTON_TYPE_MIDDLE, 0, false, function Mouse_Right_Clicked)
    
    // 동기화
    set sync_trg = CreateTrigger()
    call DzTriggerRegisterSyncData(sync_trg, "lok", false)
    call TriggerAddAction( sync_trg, function Lock_Clicked_Synchronize )
    
    // 동기화
    set sync_trg = CreateTrigger()
    call DzTriggerRegisterSyncData(sync_trg, "ulok", false)
    call TriggerAddAction( sync_trg, function Unlock_Clicked_Synchronize )
endfunction

endlibrary