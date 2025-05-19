
library InvenWearing requires InvenGeneric, InvenToolTip, Stat

globals
    // 동기화 트리거
    private trigger sync_trg
    
    // 장착칸 백드롭, 배열임
    integer array wearing_back_drops
    // 장착칸 무슨 부위인지 알려주는 텍스트, 배열임
    integer array wearing_texts
    // 장착칸 이미지, 배열임
    integer array wearing_img
    // 장착칸 버튼, 배열임
    integer array wearing_buttons
    // 어느 장착칸 클릭했는지 인덱스 담는 변수
    integer wearing_clicked_index = -1
    // 한번의 로직만 진행되게 보장하는 불린
    private boolean exception_restriction = false
endglobals

/*
    장착칸 동기화 후처리
    
    아이템 벗는 로직
    
    인벤칸 꽉차있는지 여유있는지 판별 들어감
*/
private function Wearing_Synchronize takes nothing returns nothing
    local string sync_data = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_data, "/", 0) )
    local integer wearing_index = S2I( JNStringSplit(sync_data, "/", 1) )
    local integer inven_index
    local Object obj = player_hero[pid].Get_Wearing_Item(wearing_index)

    set inven_index = player_hero[pid].Check_Inven_Possible()
        
    if inven_index == -1 then
        // 템창 꽉참
        if GetLocalPlayer() == Player(pid) then
            set exception_restriction = false
            // 효과음
            //call PlaySoundBJ(gg_snd_Error)
        endif
    else
        call player_hero[pid].Remove_Wearing_Item( wearing_index )
        call player_hero[pid].Set_Inven_Item( inven_index, obj )

        call Stat_Refresh(pid)
        
        if GetLocalPlayer() == Player(pid) then
            set exception_restriction = false
            // 효과음
            //call PlaySoundBJ(gg_snd_HeroDropItem1)
        endif
    endif
endfunction

/*
    장착칸에 있는 오브젝트 클릭됐을 때 처리되는 함수
    
    두번 클릭되면 동기화 및 로직 진행
*/
private function Wearing_Clicked takes nothing returns nothing
    local integer event_frame = DzGetTriggerUIEventFrame()
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    local integer wearing_index = S2I( JNStringSplit(DzFrameGetName(event_frame), "/", 0) )
    
    if is_split_on == true or exception_restriction == true then
        return
    endif
    
    if wearing_clicked_index == wearing_index then
        set wearing_clicked_index = -1
        set exception_restriction = true
        call Inven_Tool_Tip_Leave()
        call Inven_Sprite_Hide()
        // 장비창 아이템 처리 관련 동기화를 해줍시다
        // 문자열 앞부분은 플레이어번호 뒷부분은 템칸 인덱스
        call DzSyncData("wearing", I2S(pid) + "/" + I2S(wearing_index))
    else
        call Inven_Sprite_Set_Position(event_frame)
        call Inven_Sprite_Show()
    
        set wearing_clicked_index = wearing_index
        set inven_clicked_index = -1
    endif
endfunction

/*
    장착칸 프레임 생성하는 함수
*/
// 장착 칸 9개, 백드롭과 버튼으로 구성됨
private function Inven_Wearing_Frames takes nothing returns nothing
    local integer i
    local real x = -0.12
    local real y = 0.095
    local real padding = 0.065
    local real array the_x
    local real array the_y
    local string array wearing_type
    
    set the_x[0] = 0
    set the_y[0] = 0.00
    
    set the_x[1] = -padding
    set the_y[1] = 0
    
    set the_x[2] = -padding
    set the_y[2] = -padding
    
    set the_x[3] = 0
    set the_y[3] = -padding
    
    set the_x[4] = padding
    set the_y[4] = -padding
    
    set the_x[5] = -padding
    set the_y[5] = -2*padding
    
    set the_x[6] = 0
    set the_y[6] = -2*padding
    
    set the_x[7] = padding
    set the_y[7] = -2*padding
    
    set the_x[8] = -padding
    set the_y[8] = -3*padding
    
    set the_x[9] = padding
    set the_y[9] = -3*padding
    
    set wearing_type[0] = "투구"
    set wearing_type[1] = "목걸이"
    set wearing_type[2] = "무기"
    set wearing_type[3] = "갑옷"
    set wearing_type[4] = "방패"
    set wearing_type[5] = "반지1"
    set wearing_type[6] = "벨트"
    set wearing_type[7] = "반지2"
    set wearing_type[8] = "장갑"
    set wearing_type[9] = "부츠"
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i > 9
        set wearing_back_drops[i] = DzCreateFrameByTagName("BACKDROP", "", inven_box, "QuestButtonPushedBackdropTemplate", 0)
        call DzFrameSetPoint(wearing_back_drops[i], JN_FRAMEPOINT_CENTER, inven_box, JN_FRAMEPOINT_CENTER, x + the_x[i], y + the_y[i] )
        call DzFrameSetSize(wearing_back_drops[i], inven_square_size, inven_square_size)
        
        set wearing_texts[i] = DzCreateFrameByTagName("TEXT", "", wearing_back_drops[i], "", 0)
        call DzFrameSetPoint(wearing_texts[i], JN_FRAMEPOINT_CENTER, wearing_back_drops[i], JN_FRAMEPOINT_CENTER, 0.0, 0.0)
        call DzFrameSetText(wearing_texts[i], "|cffffcc00" + wearing_type[i] + "|r")
        
        set wearing_img[i] = DzCreateFrameByTagName("BACKDROP", "", wearing_back_drops[i], "QuestButtonPushedBackdropTemplate", 0)
        call DzFrameSetPoint(wearing_img[i], JN_FRAMEPOINT_CENTER, wearing_back_drops[i], JN_FRAMEPOINT_CENTER, 0, 0 )
        call DzFrameSetSize(wearing_img[i], inven_item_size, inven_item_size)
        call DzFrameShow(wearing_img[i], false)
        
        set wearing_buttons[i] = DzCreateFrameByTagName("BUTTON", I2S(i) + "/wearing", wearing_back_drops[i], "ScoreScreenTabButtonTemplate", 0)
        call DzFrameSetPoint(wearing_buttons[i], JN_FRAMEPOINT_CENTER, wearing_back_drops[i], JN_FRAMEPOINT_CENTER, 0, 0)
        call DzFrameSetSize(wearing_buttons[i], inven_square_size, inven_square_size)
        call DzFrameSetScriptByCode(wearing_buttons[i], JN_FRAMEEVENT_CONTROL_CLICK, function Wearing_Clicked, false)
        // 마우스 진입, 빠져나올 때 툴팁 함수 실행됨
        call DzFrameSetScriptByCode(wearing_buttons[i], JN_FRAMEEVENT_MOUSE_ENTER, function Inven_Tool_Tip_Enter, false)
        call DzFrameSetScriptByCode(wearing_buttons[i], JN_FRAMEEVENT_MOUSE_LEAVE, function Inven_Tool_Tip_Leave, false)
        call DzFrameShow(wearing_buttons[i], false)
    endloop
endfunction

/*
    장착칸 관련 초기화
*/
function Inven_Wearing_Init takes nothing returns nothing
    call Inven_Wearing_Frames()
    
    // 장착칸 동기화
    set sync_trg = CreateTrigger()
    call DzTriggerRegisterSyncData(sync_trg, "wearing", false)
    call TriggerAddAction( sync_trg, function Wearing_Synchronize )
endfunction

endlibrary