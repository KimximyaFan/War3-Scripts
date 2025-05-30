library InvenDiscard requires InvenGeneric

globals
    private trigger sync_trg

    private integer discard_button
    private integer discard_tool_tip_back_drop
    private integer discard_tool_tip_text
endglobals

/*
    버리기 설명 툴팁 가림
*/
private function Discard_Tool_Tip_Leave takes nothing returns nothing
    call DzFrameShow(discard_tool_tip_back_drop, false)
endfunction

/*
    버리기 설명 툴팁 보여줌
*/
private function Discard_Tool_Tip_Enter takes nothing returns nothing
    call DzFrameShow(discard_tool_tip_back_drop, true)
endfunction

/*
    버리기 동기화 후처리
    아이템 버림
*/
private function Discard_Synchronize takes nothing returns nothing
    local string sync_data = DzGetTriggerSyncData()
    local integer pid = S2I( SubString(sync_data, 0, 1) )
    local integer discard_index = S2I( SubString(sync_data, StringLength(sync_data) - 2, StringLength(sync_data)) )
        
    call player_hero[pid].Delete_Inven_Item( discard_index ) /* 동기화 필요 */
    
    
    
    if GetLocalPlayer() == Player(pid) then
        // 효과음
        //call PlaySoundBJ(gg_snd_WayPointBling)
    endif
endfunction

/*
    버리기 클릭됨
*/
private function Discard_Clicked takes nothing returns nothing
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    
    if is_upgrade_on == 1 then
        return
    endif
    
    if inven_clicked_index != -1 then
        call Inven_Sprite_Hide()
        // 인벤창 아이템 처리 관련 동기화를 해줍시다
        // 문자열 앞부분은 플레이어번호 뒷부분은 템칸 인덱스
        call DzSyncData("discard", I2S(pid) + " 0" + I2S(inven_clicked_index))
        set inven_clicked_index = -1
    endif
endfunction

// 버리기 버튼 가져다대면 설명해주는 툴팁
private function Inven_Discard_Tool_Tip takes nothing returns nothing
    set discard_tool_tip_back_drop = DzCreateFrameByTagName("BACKDROP", "", inven_box, "QuestButtonBaseTemplate", 0)
    call DzFrameSetPoint(discard_tool_tip_back_drop, JN_FRAMEPOINT_CENTER, discard_button, JN_FRAMEPOINT_CENTER, -0.03, 0.04)
    call DzFrameSetSize(discard_tool_tip_back_drop, 0.14, 0.05)

    set discard_tool_tip_text = DzCreateFrameByTagName("TEXT", "", discard_tool_tip_back_drop, "", 0)
    call DzFrameSetPoint(discard_tool_tip_text, JN_FRAMEPOINT_CENTER, discard_tool_tip_back_drop, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(discard_tool_tip_text, "아이템을 한번 클릭 후\n 버리기 버튼을 클릭")
    
    call DzFrameShow(discard_tool_tip_back_drop, false)
endfunction

// 버리기 버튼
private function Inven_Discard_Button takes nothing returns nothing
    set discard_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", inven_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(discard_button, JN_FRAMEPOINT_CENTER, inven_box, JN_FRAMEPOINT_CENTER, inven_button_standard_x, inven_button_standard_y)
    call DzFrameSetSize(discard_button, inven_function_button_size_x, inven_function_button_size_y)
    call DzFrameSetText(discard_button, "버림")
    call DzFrameSetScriptByCode(discard_button, JN_FRAMEEVENT_CONTROL_CLICK, function Discard_Clicked, false)
    // 마우스 나갔다 들어왔다, 툴팁 생성
    call DzFrameSetScriptByCode(discard_button, JN_FRAMEEVENT_MOUSE_ENTER, function Discard_Tool_Tip_Enter, false)
    call DzFrameSetScriptByCode(discard_button, JN_FRAMEEVENT_MOUSE_LEAVE, function Discard_Tool_Tip_Leave, false)
endfunction

/*
    아이템 버리기 관련 초기화
*/
function Inven_Discard_Init takes nothing returns nothing
    call Inven_Discard_Button()
    call Inven_Discard_Tool_Tip()
    
    // 버리기 동기화
    set sync_trg = CreateTrigger()
    call DzTriggerRegisterSyncData(sync_trg, "discard", false)
    call TriggerAddAction( sync_trg, function Discard_Synchronize )
endfunction

endlibrary