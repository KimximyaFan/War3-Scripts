library StatButtonAndBox 

globals
    // 스탯창 켜져있는지 판별하는 변수
    boolean isStat = false
    // 누르면 스탯창 나오는 버튼 변수
    integer stat_button
    // 누르면 스탯창 꺼지는 버튼 변수
    private integer x_button
    
    // 스탯창 백드롭
    integer stat_box
endglobals

// 스탯창 여는 버튼을 보여줄 것인지 함수
function Stat_Button_Show takes nothing returns nothing
    call DzFrameShow(stat_button, true)
endfunction

// 인벤 박스 껐다 켰다 
private function Stat_Button_Clicked takes nothing returns nothing
    if isStat == true then
        set isStat = false
        call DzFrameShow(stat_box, false)
    else
        set isStat = true
        call DzFrameShow(stat_box, true)
    endif
endfunction

// 끄기 버튼
private function Stat_X_Button takes nothing returns nothing
    set x_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", stat_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(x_button, JN_FRAMEPOINT_TOPRIGHT, stat_box, JN_FRAMEPOINT_TOPRIGHT, 0, 0)
    call DzFrameSetSize(x_button, 0.032, 0.032)
    call DzFrameSetText(x_button, "X")
    call DzFrameSetScriptByCode(x_button, JN_FRAMEEVENT_CONTROL_CLICK, function Stat_Button_Clicked, false)
endfunction

// 스탯 백드롭
private function Stat_Box takes nothing returns nothing
    set stat_box = DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "QuestButtonBaseTemplate", 0)
    call DzFrameSetPoint(stat_box, JN_FRAMEPOINT_CENTER, DzGetGameUI(), JN_FRAMEPOINT_CENTER, -0.235, 0.07)
    call DzFrameSetSize(stat_box, 0.31, 0.30)
    call DzFrameShow(stat_box, false)
endfunction

// 스탯 버튼
private function Stat_Button takes nothing returns nothing
    set stat_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", DzGetGameUI(), "ScriptDialogButton", 0)
    call DzFrameSetPoint(stat_button, JN_FRAMEPOINT_CENTER, DzGetGameUI(), JN_FRAMEPOINT_CENTER, -0.33, -0.1)
    call DzFrameSetSize(stat_button, 0.050, 0.040)
    call DzFrameSetText(stat_button, "스탯")
    call DzFrameSetScriptByCode(stat_button, JN_FRAMEEVENT_CONTROL_CLICK, function Stat_Button_Clicked, false)
    call DzFrameShow(stat_button, false)
endfunction

// 스탯 버튼과 박스 초기화 하는 함수
function Stat_Button_And_Box_Init takes nothing returns nothing
    call Stat_Button()
    call Stat_Box()
    call Stat_X_Button()
endfunction

endlibrary