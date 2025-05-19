library FrameShow requires InvenButtonAndBox, StatButtonAndBox

/*
    이거 실행하면 인벤창 키는 버튼, 
    스탯창 키는 버튼
    생성됨
*/
function Show_Generic_Frames takes nothing returns nothing
    call Inven_Button_Show()
    call Stat_Button_Show()
endfunction

/*
    ESC 눌렀을 때의 처리
*/
private function ESC_Close takes nothing returns nothing
    set isInven = false
    call DzFrameShow(inven_box, false)
    
    set inven_clicked_index = -1
    set wearing_clicked_index = -1
    call Inven_Sprite_Hide()
    
    set isStat = false
    call DzFrameShow(stat_box, false)
endfunction

/*
    ESC 누름 관련 초기화
*/
function Generic_Frame_Work_Init takes nothing returns nothing
    call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_ESCAPE, 0, false, function ESC_Close)
endfunction

endlibrary