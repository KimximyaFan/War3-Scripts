library InvenButtonAndBox requires InvenSprite

globals
    // 끄기버튼
    private integer x_button
    // 인벤창 켜져있는지
    boolean isInven = false
    // 인벤창 키는 버튼
    integer inven_button
    // 인벤토리 프레임 백드롭
    integer inven_box
endglobals

// 인벤창 키는 버튼 보여줄껀지
function Inven_Button_Show takes nothing returns nothing
    call DzFrameShow(inven_button, true)
endfunction

// 인벤 박스 껐다 켰다 
private function Inventory_Button_Clicked takes nothing returns nothing
    if isInven == true then
        set isInven = false
        call DzFrameShow(inven_box, false)
        set inven_clicked_index = -1
        set wearing_clicked_index = -1
        call Inven_Sprite_Hide()
    else
        set isInven = true
        call DzFrameShow(inven_box, true)
    endif
endfunction

// 끄기 버튼
private function Inven_X_Button takes nothing returns nothing
    set x_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", inven_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(x_button, JN_FRAMEPOINT_TOPLEFT, inven_box, JN_FRAMEPOINT_TOPLEFT, 0, 0)
    call DzFrameSetSize(x_button, 0.032, 0.032)
    call DzFrameSetText(x_button, "X")
    call DzFrameSetScriptByCode(x_button, JN_FRAMEEVENT_CONTROL_CLICK, function Inventory_Button_Clicked, false)
endfunction

// 인벤 백드롭
private function Inven_Box takes nothing returns nothing
    set inven_box = DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "QuestButtonBaseTemplate", 0)
    call DzFrameSetPoint(inven_box, JN_FRAMEPOINT_CENTER, DzGetGameUI(), JN_FRAMEPOINT_CENTER, 0.16, 0.07)
    call DzFrameSetSize(inven_box, 0.47, 0.30)
    call DzFrameShow(inven_box, false)
endfunction

// 인벤 버튼
private function Inven_Button takes nothing returns nothing
    set inven_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", DzGetGameUI(), "ScriptDialogButton", 0)
    call DzFrameSetPoint(inven_button, JN_FRAMEPOINT_CENTER, DzGetGameUI(), JN_FRAMEPOINT_CENTER, -0.28, -0.1)
    call DzFrameSetSize(inven_button, 0.05, 0.04)
    call DzFrameSetText(inven_button, "인벤")
    call DzFrameSetScriptByCode(inven_button, JN_FRAMEEVENT_CONTROL_CLICK, function Inventory_Button_Clicked, false)
    call DzFrameShow(inven_button, false)
endfunction

/*
    인벤 프레임 관련 초기화
*/
function Inven_Button_And_Box_Init takes nothing returns nothing
    call Inven_Button()
    call Inven_Box()
    call Inven_X_Button()
endfunction

endlibrary