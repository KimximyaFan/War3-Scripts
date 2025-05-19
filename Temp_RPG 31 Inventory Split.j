library InvenSplit

globals
    // 아이템 나누는 프레임 켜져 있는지
    boolean is_split_on = false
    // 인벤에서 조합으로 옮기는지, 아니면 조합에서 인벤으로 옮기는지 판별
    integer split_state = -1
    // 오브젝트 인덱스 담는 변수
    integer split_index = 0
    // 상태 변수들
    integer INVEN_TO_COMBINATION = 0
    integer COMBINATION_TO_INVEN = 1
    
    // 나누는 프레임 동기화 프리픽스들 담는 배열
    private string array SPLIT_TRIGGER_PREFIX
    
    // 나누기 프레임 백드롭
    private integer split_box
    // 나누기 프레임 텍스트
    private integer split_count_text
    // -10 버튼
    private integer split_button_minus_ten
    // -1 버튼
    private integer split_button_minus
    // +1 버튼
    private integer split_button_plus
    // +10 버튼
    private integer split_button_plus_ten
    // 나누기 프레임 끄는 버튼
    private integer x_button
    // 확인 버튼
    private integer yes_button
    // 몇개 나눌건지 값 담기는 변수
    private integer split_count = 0
    // 동기화 트리거
    private trigger sync_trg
endglobals

/*
    나누기 프레임 감추는 함수
*/
function Split_Box_Off takes nothing returns nothing
    set is_split_on = false
    call DzFrameShow(split_box, false)
endfunction

/*
    나누기 프레임 보여주는 함수
*/
function Split_Box_On takes nothing returns nothing
    set split_count = 0
    set is_split_on = true
    call DzFrameSetText(split_count_text, I2S(split_count) + " 개" )
    call DzFrameShow(split_box, true)
endfunction

/*
    나누기 확인 버튼 클릭 됐을 때
*/
private function Split_Yes_Clicked takes nothing returns nothing
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    
    call DzSyncData(SPLIT_TRIGGER_PREFIX[split_state], I2S(pid) + "/" + I2S(split_index) + "/" + I2S(split_count))
    call Split_Box_Off()
endfunction

/*
    -1 +1 등 갯수 증가시키거나 감소시크는 버튼 클릭 됐을 때 실행됨
    프레임 갱신 하는 역할
*/
private function Split_Count_Button_Clicked takes nothing returns nothing
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    local integer value = S2I( JNStringSplit(DzFrameGetName(DzGetTriggerUIEventFrame()), "/", 1) )
    
    set split_count = IMaxBJ( 0, split_count + value )
    
    call DzFrameSetText(split_count_text, I2S(split_count) + " 개" )
endfunction

/*
    프레임 생성하는 함수
*/
private function Frame_Init takes nothing returns nothing
    local real split_button_y = 0.07
    local real split_button_size_y = 0.035
    local real yes_button_y = 0.02
    
    // 백드롭
    set split_box = DzCreateFrameByTagName("BACKDROP", "", inven_box, "QuestButtonBaseTemplate", 0)
    call DzFrameSetPoint(split_box, JN_FRAMEPOINT_CENTER, DzGetGameUI(), JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetSize(split_box, 0.20, 0.16)
    call DzFrameShow(split_box, false)
    
    // 갯수 텍스트
    set split_count_text = DzCreateFrameByTagName("TEXT", "", split_box, "TeamLadderRankValueTextTemplate", 0)
    call DzFrameSetPoint(split_count_text, JN_FRAMEPOINT_TOP, split_box, JN_FRAMEPOINT_TOP, 0.00, -0.025)
    call DzFrameSetText(split_count_text, "0 개" )
    
    // 끄기
    set x_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", split_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(x_button, JN_FRAMEPOINT_TOPRIGHT, split_box, JN_FRAMEPOINT_TOPRIGHT, 0, 0)
    call DzFrameSetSize(x_button, 0.032, 0.032)
    call DzFrameSetText(x_button, "X")
    call DzFrameSetScriptByCode(x_button, JN_FRAMEEVENT_CONTROL_CLICK, function Split_Box_Off, false)
    
    // -10
    set split_button_minus_ten = DzCreateFrameByTagName("GLUETEXTBUTTON", "split/-10", split_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(split_button_minus_ten, JN_FRAMEPOINT_BOTTOM, split_box, JN_FRAMEPOINT_BOTTOM, -0.06, split_button_y)
    call DzFrameSetSize(split_button_minus_ten, 0.04, split_button_size_y)
    call DzFrameSetText(split_button_minus_ten, "-10")
    call DzFrameSetScriptByCode(split_button_minus_ten, JN_FRAMEEVENT_CONTROL_CLICK, function Split_Count_Button_Clicked, false)
    
    // -1
    set split_button_minus = DzCreateFrameByTagName("GLUETEXTBUTTON", "split/-1", split_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(split_button_minus, JN_FRAMEPOINT_BOTTOM, split_box, JN_FRAMEPOINT_BOTTOM, -0.02, split_button_y)
    call DzFrameSetSize(split_button_minus, 0.04, split_button_size_y)
    call DzFrameSetText(split_button_minus, "-1")
    call DzFrameSetScriptByCode(split_button_minus, JN_FRAMEEVENT_CONTROL_CLICK, function Split_Count_Button_Clicked, false)
    
    // +1
    set split_button_plus = DzCreateFrameByTagName("GLUETEXTBUTTON", "split/1", split_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(split_button_plus, JN_FRAMEPOINT_BOTTOM, split_box, JN_FRAMEPOINT_BOTTOM, 0.02, split_button_y)
    call DzFrameSetSize(split_button_plus, 0.04, split_button_size_y)
    call DzFrameSetText(split_button_plus, "+1")
    call DzFrameSetScriptByCode(split_button_plus, JN_FRAMEEVENT_CONTROL_CLICK, function Split_Count_Button_Clicked, false)
    
    // +10
    set split_button_plus_ten = DzCreateFrameByTagName("GLUETEXTBUTTON", "split/10", split_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(split_button_plus_ten, JN_FRAMEPOINT_BOTTOM, split_box, JN_FRAMEPOINT_BOTTOM, 0.06, split_button_y)
    call DzFrameSetSize(split_button_plus_ten, 0.04, split_button_size_y)
    call DzFrameSetText(split_button_plus_ten, "+10")
    call DzFrameSetScriptByCode(split_button_plus_ten, JN_FRAMEEVENT_CONTROL_CLICK, function Split_Count_Button_Clicked, false)
    
    // 누르면 조합
    set yes_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", split_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(yes_button, JN_FRAMEPOINT_BOTTOM, split_box, JN_FRAMEPOINT_BOTTOM, 0.00, 0.02)
    call DzFrameSetSize(yes_button, 0.080, 0.04)
    call DzFrameSetText(yes_button, "확인")
    call DzFrameSetScriptByCode(yes_button, JN_FRAMEEVENT_CONTROL_CLICK, function Split_Yes_Clicked, false)
endfunction

/*
    오브젝트 나누기 관련 초기화
*/
function Inven_Split_Init takes nothing returns nothing
    
    set SPLIT_TRIGGER_PREFIX[INVEN_TO_COMBINATION] = "spi2c"
    set SPLIT_TRIGGER_PREFIX[COMBINATION_TO_INVEN] = "spc2i"
    
    call Frame_Init()
endfunction

endlibrary