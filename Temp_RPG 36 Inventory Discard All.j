library DiscardAll requires InvenGeneric

globals
    // 동기화 트리거
    private trigger sync_trg
    // 일괄 버리기 버튼
    private integer discard_all_button
endglobals

/*
    일괄 버리기 동기화 후처리
    
    Discard All Check 쪽에서 체크된 속성에 따라 오브젝트를 버릴지 말지 판별함
    
    일단 장비 아이템만 버려짐
*/
private function Discard_All_Synchronize takes nothing returns nothing
    local string sync_data = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_data, "/", 0) )
    local integer i
    local integer grade
    local integer star_grade
    local Object obj
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i > 24
        if player_hero[pid].Check_Inven_Item(i) == true then
            set obj = player_hero[pid].Get_Inven_Item(i)
            set grade = obj.Get_Object_Property(GRADE)
            set star_grade = obj.Get_Object_Property(STAR_GRADE)
            
            if obj.Get_Object_Property(OBJECT_TYPE) == EQUIP and (discard_all_grade_check[pid][grade] == true or discard_all_star_grade_check[pid][star_grade]) then
                call player_hero[pid].Delete_Inven_Item(i)
            endif
        endif
    endloop
    
    if GetLocalPlayer() == Player(pid) then
        // 효과음
        //call PlaySoundBJ(gg_snd_AlchemistTransmuteDeath1)
    endif
endfunction

/*
    일괄 버리기 클릭됨
*/
private function Discard_All_Clicked takes nothing returns nothing
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    local integer i
    
    if is_upgrade_on == 1 then
        return
    endif
    
    call Inven_Sprite_Hide()
    set inven_clicked_index = -1
    set wearing_clicked_index = -1

    call DzSyncData("all", I2S(pid) + "/" )
endfunction

/*
    일괄 버리기 버튼 생성되는 함수
*/
private function Inven_Discard_All_Button takes nothing returns nothing
    set discard_all_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", inven_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(discard_all_button, JN_FRAMEPOINT_CENTER, inven_box, JN_FRAMEPOINT_CENTER, inven_button_standard_x - 0.045, inven_button_standard_y)
    call DzFrameSetSize(discard_all_button, inven_function_button_size_x, inven_function_button_size_y)
    call DzFrameSetText(discard_all_button, "일괄\n버림")
    call DzFrameSetScriptByCode(discard_all_button, JN_FRAMEEVENT_CONTROL_CLICK, function Discard_All_Clicked, false)
endfunction

/*
    일괄 버리기 관련 초기화
*/
function Inven_Discard_All_Init takes nothing returns nothing
    call Inven_Discard_All_Button()
    
    // 일괄 버리기 동기화
    set sync_trg = CreateTrigger()
    call DzTriggerRegisterSyncData(sync_trg, "all", false)
    call TriggerAddAction( sync_trg, function Discard_All_Synchronize )
endfunction

endlibrary