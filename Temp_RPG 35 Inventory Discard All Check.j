library DiscardAllCheck requires InvenGeneric

globals
    // 플레이어별 등급 체크박스 판별
    boolean array discard_all_grade_check[12][10]
    // 플레이어별 성급 체크박스 판별
    boolean array discard_all_star_grade_check[12][10]
    
    // 체크박스 창 켜져있는지?
    private boolean isCheckBox = false
    
    // 체크박스창 여는 버튼
    private integer discard_all_check_button
    // 체크박스 창 백드롭
    private integer discard_all_check_back_drop
    // 등급 체크 텍스트, 배열임
    private integer array grade_check_text
    // 등큽 체크 체크박스, 배열임
    private integer array grade_check_box
    // 성급 체크 텍스트, 배열임
    private integer array star_grade_check_text
    // 성급 체크 체크박스, 배열임
    private integer array star_grade_check_box
    // 습득시 자동버림 텍스트
    private integer auto_remove_text
    // 습득시 자동버림 체크박스
    private integer auto_remove_box
    // 체크박스창 닫는 버튼
    private integer x_button
    // 동기화 트리거
    private trigger sync_trg
endglobals

/*
    체크박스 체크해제됨 동기화 후처리
    
    등급 관련 체크박스 체크해제됐는지
    성급 관련 체크박스 체크해제됐는지
    습득시 자동 버림 체크해제됐는지
    
    판별함
*/
private function Check_Box_Unchecked_Synchronize takes nothing returns nothing
    local string sync_data = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_data, "/", 0) )
    local integer index = S2I( JNStringSplit(sync_data, "/", 1) )
    local string str = JNStringSplit(sync_data, "/", 2)
    
    if str == "gradecheck" then
        set discard_all_grade_check[pid][index] = false
        
    elseif str == "stargradecheck" then
        set discard_all_star_grade_check[pid][index] = false
        
    elseif str == "auto_remove" then
        call player_hero[pid].Set_Auto_Remove(false)
        
    endif
endfunction

/*
    체크박스 체크됨 동기화 후처리
    
    등급 관련 체크박스 체크됐는지
    성급 관련 체크박스 체크됐는지
    습득시 자동 버림 체크됐는지
    
    판별함
*/
private function Check_Box_Checked_Synchronize takes nothing returns nothing
    local string sync_data = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_data, "/", 0) )
    local integer index = S2I( JNStringSplit(sync_data, "/", 1) )
    local string str = JNStringSplit(sync_data, "/", 2)
    
    if str == "gradecheck" then
        set discard_all_grade_check[pid][index] = true
        
    elseif str == "stargradecheck" then
        set discard_all_star_grade_check[pid][index] = true
        
    elseif str == "auto_remove" then
        call player_hero[pid].Set_Auto_Remove(true)
        
    endif
endfunction

/*
    체크박스 체크해제됨
    해당 함수 하나로 돌려 씀
*/
private function Check_Box_Unchecked takes nothing returns nothing
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    local integer index = S2I( JNStringSplit(DzFrameGetName(DzGetTriggerUIEventFrame()), "/", 0) )
    local string str = JNStringSplit(DzFrameGetName(DzGetTriggerUIEventFrame()), "/", 1)
    
    call DzSyncData( "dauchk", I2S(pid) + "/" + I2S(index) + "/" + str )
endfunction

/*
    체크박스 체크됨
    해당 함수 하나로 돌려 씀
*/
private function Check_Box_Checked takes nothing returns nothing
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    local integer index = S2I( JNStringSplit(DzFrameGetName(DzGetTriggerUIEventFrame()), "/", 0) )
    local string str = JNStringSplit(DzFrameGetName(DzGetTriggerUIEventFrame()), "/", 1)
    
    call DzSyncData( "dachk" , I2S(pid) + "/" + I2S(index) + "/" + str )
endfunction

/*
    일괄버리기창 여는 버튼 클릭됨
    껐다 켰다
*/
private function Discard_All_Check_Button_Clicked takes nothing returns nothing
    if is_upgrade_on == 1 then
        return
    endif
    
    if isCheckBox == true then
        set isCheckBox = false
        call DzFrameShow(discard_all_check_back_drop, false)
    else
        set isCheckBox = true
        call DzFrameShow(discard_all_check_back_drop, true)
    endif
endfunction

/*
    일괄버리기 옵션 체크 프레임 생성되는 함수
*/
private function Inven_Discard_All_Check_Frame takes nothing returns nothing
    local real grade_x = 0.1
    local real grade_y = -0.02
    local real star_grade_x = 0.02
    local real star_grade_y = -0.02
    local real auto_remove_x = 0.02
    local real auto_remove_y = 0.02
    local integer i
    
    set discard_all_check_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", inven_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(discard_all_check_button, JN_FRAMEPOINT_CENTER, inven_box, JN_FRAMEPOINT_CENTER, inven_button_standard_x - 0.09, inven_button_standard_y)
    call DzFrameSetSize(discard_all_check_button, inven_function_button_size_x, inven_function_button_size_y)
    call DzFrameSetText(discard_all_check_button, "일괄\n체크")
    call DzFrameSetScriptByCode(discard_all_check_button, JN_FRAMEEVENT_CONTROL_CLICK, function Discard_All_Check_Button_Clicked, false)

    set discard_all_check_back_drop = DzCreateFrameByTagName("BACKDROP", "", discard_all_check_button, "QuestButtonBaseTemplate", 0)
    call DzFrameSetPoint(discard_all_check_back_drop, JN_FRAMEPOINT_CENTER, DzGetGameUI(), JN_FRAMEPOINT_CENTER, 0.00, 0.00)
    call DzFrameSetSize(discard_all_check_back_drop, 0.20, 0.20)
    call DzFrameShow(discard_all_check_back_drop, false)
    
    // 끄기
    set x_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", discard_all_check_back_drop, "ScriptDialogButton", 0)
    call DzFrameSetPoint(x_button, JN_FRAMEPOINT_TOPRIGHT, discard_all_check_back_drop, JN_FRAMEPOINT_TOPRIGHT, 0, 0)
    call DzFrameSetSize(x_button, 0.032, 0.032)
    call DzFrameSetText(x_button, "X")
    call DzFrameSetScriptByCode(x_button, JN_FRAMEEVENT_CONTROL_CLICK, function Discard_All_Check_Button_Clicked, false)
    
    // 성급
    set i = 0
    loop
    set i = i + 1
    exitwhen i >= 8
        set star_grade_check_text[i] = DzCreateFrameByTagName("TEXT", "", discard_all_check_back_drop, "", 0)
        call DzFrameSetPoint(star_grade_check_text[i], JN_FRAMEPOINT_TOPLEFT, discard_all_check_back_drop, JN_FRAMEPOINT_TOPLEFT, star_grade_x, star_grade_y + (i-1) * -0.02)
        call DzFrameSetText(star_grade_check_text[i], I2S(i) + " 성")
        
        set star_grade_check_box[i] = DzCreateFrameByTagName("GLUECHECKBOX", I2S(i) + "/stargradecheck", discard_all_check_back_drop, "QuestCheckBox", 0)
        call DzFrameSetPoint(star_grade_check_box[i], JN_FRAMEPOINT_LEFT, star_grade_check_text[i], JN_FRAMEPOINT_RIGHT, 0.01, 0.0)
        call DzFrameSetScriptByCode(star_grade_check_box[i], JN_FRAMEEVENT_CHECKBOX_CHECKED, function Check_Box_Checked, false)
        call DzFrameSetScriptByCode(star_grade_check_box[i], JN_FRAMEEVENT_CHECKBOX_UNCHECKED, function Check_Box_Unchecked, false)
    endloop
    
    // 등급
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 7
        set grade_check_text[i] = DzCreateFrameByTagName("TEXT", "", discard_all_check_back_drop, "", 0)
        call DzFrameSetPoint(grade_check_text[i], JN_FRAMEPOINT_TOPLEFT, discard_all_check_back_drop, JN_FRAMEPOINT_TOPLEFT, grade_x, grade_y + i * -0.02)
        call DzFrameSetText(grade_check_text[i], EQUIP_GRADE_STRING[i])
        
        set grade_check_box[i] = DzCreateFrameByTagName("GLUECHECKBOX", I2S(i) + "/gradecheck", discard_all_check_back_drop, "QuestCheckBox", 0)
        call DzFrameSetPoint(grade_check_box[i], JN_FRAMEPOINT_LEFT, grade_check_text[i], JN_FRAMEPOINT_RIGHT, 0.01, 0.0)
        call DzFrameSetScriptByCode(grade_check_box[i], JN_FRAMEEVENT_CHECKBOX_CHECKED, function Check_Box_Checked, false)
        call DzFrameSetScriptByCode(grade_check_box[i], JN_FRAMEEVENT_CHECKBOX_UNCHECKED, function Check_Box_Unchecked, false)
    endloop
    
    set auto_remove_text = DzCreateFrameByTagName("TEXT", "", discard_all_check_back_drop, "", 0)
    call DzFrameSetPoint(auto_remove_text, JN_FRAMEPOINT_BOTTOMLEFT, discard_all_check_back_drop, JN_FRAMEPOINT_BOTTOMLEFT, auto_remove_x, auto_remove_y)
    call DzFrameSetText(auto_remove_text, "장비 습득시 자동 분해")
    
    set auto_remove_box = DzCreateFrameByTagName("GLUECHECKBOX", "0/auto_remove", discard_all_check_back_drop, "QuestCheckBox", 0)
    call DzFrameSetPoint(auto_remove_box, JN_FRAMEPOINT_LEFT, auto_remove_text, JN_FRAMEPOINT_RIGHT, 0.01, 0.0)
    call DzFrameSetScriptByCode(auto_remove_box, JN_FRAMEEVENT_CHECKBOX_CHECKED, function Check_Box_Checked, false)
    call DzFrameSetScriptByCode(auto_remove_box, JN_FRAMEEVENT_CHECKBOX_UNCHECKED, function Check_Box_Unchecked, false)
endfunction

/*
    일괄버리기 옵션 체크 관련 초기화
*/
function Inven_Discard_All_Check_Init takes nothing returns nothing
    local integer pid
    
    set pid = -1
    loop
    set pid = pid + 1
    exitwhen pid > 10
        set discard_all_grade_check[pid][NORMAL] = false
        set discard_all_grade_check[pid][ADVANCED] = false
        set discard_all_grade_check[pid][RARE] = false
        set discard_all_grade_check[pid][LEGEND] = false
        set discard_all_grade_check[pid][HEROIC] = false
        set discard_all_grade_check[pid][EPIC] = false
        set discard_all_grade_check[pid][ONLY] = false
        
        set discard_all_star_grade_check[pid][1] = false
        set discard_all_star_grade_check[pid][2] = false
        set discard_all_star_grade_check[pid][3] = false
        set discard_all_star_grade_check[pid][4] = false
        set discard_all_star_grade_check[pid][5] = false
        set discard_all_star_grade_check[pid][6] = false
        set discard_all_star_grade_check[pid][7] = false
    endloop
    
    set sync_trg = CreateTrigger()
    call DzTriggerRegisterSyncData(sync_trg, "dachk", false)
    call TriggerAddAction( sync_trg, function Check_Box_Checked_Synchronize )
    
    set sync_trg = CreateTrigger()
    call DzTriggerRegisterSyncData(sync_trg, "dauchk", false)
    call TriggerAddAction( sync_trg, function Check_Box_Unchecked_Synchronize )
    

    call Inven_Discard_All_Check_Frame()
endfunction

endlibrary