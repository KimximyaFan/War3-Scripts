library StatText

/*
    해당 스크립트는 스탯 프레임과 관련되어있음
*/

globals
    /*
        프레임 관련 변수들
    */
    
    // 레벨 백드롭
    integer level_back_drop
    // 레벨 텍스트
    integer level_texts
    // 레벨 숫자 백드롭
    integer level_value_back_drop
    // 레벨 숫자 값 텍스트
    integer level_value
    
    // 스텟 백드롭 배열
    private integer array stat_back_drop
    // 스탯 텍스트 배열
    private integer array stat_texts
    // 텍스트 박스 가로 크기
    private real text_box_width = 0.082
    // 박스 크기 세로 크기
    private real box_height = 0.026
    
    // 스탯 값 백드롭 배열
    private integer array stat_value_back_drop
    // 스탯 값 배열
    integer array stat_values
    // 밸류 백드롭 가로 크기
    private real value_box_width = 0.048
endglobals

/*
    스탯관력 프레임 만드는 함수
*/
private function Stat_Text takes nothing returns nothing
    local integer i
    local real x = 0.02
    local real y = -0.08
    local real a
    local real b
    local string array the_stat

    set i = -1
    loop
    set i = i + 1
    exitwhen i > 15
        set a = (i / 8)
        set b = ModuloInteger(i, 8)
        set stat_back_drop[i] = DzCreateFrameByTagName("BACKDROP", "", stat_box, "ScoreScreenButtonBackdropTemplate", 0)
        call DzFrameSetPoint(stat_back_drop[i], JN_FRAMEPOINT_TOPLEFT, stat_box, JN_FRAMEPOINT_TOPLEFT, x + (a * 0.14), y - (b * 0.025))
        call DzFrameSetSize(stat_back_drop[i], text_box_width, box_height)
        
        set stat_texts[i] = DzCreateFrameByTagName("TEXT", "", stat_back_drop[i], "", 0)
        call DzFrameSetPoint(stat_texts[i], JN_FRAMEPOINT_CENTER, stat_back_drop[i], JN_FRAMEPOINT_CENTER, 0, 0 )
        call DzFrameSetText(stat_texts[i], "|cffffcc00" + EQUIP_PROPERTY_STRING[i] + "|r")
        
        set stat_value_back_drop[i] = DzCreateFrameByTagName("BACKDROP", "", stat_back_drop[i], "ScoreScreenButtonBackdropTemplate", 0)
        call DzFrameSetPoint(stat_value_back_drop[i], JN_FRAMEPOINT_LEFT, stat_back_drop[i], JN_FRAMEPOINT_RIGHT, 0.0, 0.0)
        call DzFrameSetSize(stat_value_back_drop[i], value_box_width, box_height)
        
        set stat_values[i] = DzCreateFrameByTagName("TEXT", "", stat_value_back_drop[i], "", 0)
        call DzFrameSetPoint(stat_values[i], JN_FRAMEPOINT_CENTER, stat_value_back_drop[i], JN_FRAMEPOINT_CENTER, 0, 0 )
        call DzFrameSetText(stat_values[i], "0")
    endloop
    
endfunction

/*
    레벨 관련 프레임 만드는 함수
*/
private function Level_Text takes nothing returns nothing
    local real x = 0.035
    local real y = -0.03
    
    set level_back_drop = DzCreateFrameByTagName("BACKDROP", "", stat_box, "QuestButtonDisabledBackdropTemplate", 0)
    call DzFrameSetPoint(level_back_drop, JN_FRAMEPOINT_TOPLEFT, stat_box, JN_FRAMEPOINT_TOPLEFT, x, y)
    call DzFrameSetSize(level_back_drop, 0.041, 0.031)
    
    set level_texts = DzCreateFrameByTagName("TEXT", "", level_back_drop, "", 0)
    call DzFrameSetPoint(level_texts, JN_FRAMEPOINT_CENTER, level_back_drop, JN_FRAMEPOINT_CENTER, 0, 0 )
    call DzFrameSetText(level_texts, "레벨")
    
    set level_value_back_drop = DzCreateFrameByTagName("BACKDROP", "", level_back_drop, "QuestButtonDisabledBackdropTemplate", 0)
    call DzFrameSetPoint(level_value_back_drop, JN_FRAMEPOINT_LEFT, level_back_drop, JN_FRAMEPOINT_RIGHT, 0.01, 0.0)
    call DzFrameSetSize(level_value_back_drop, 0.046, 0.031)
    
    set level_value = DzCreateFrameByTagName("TEXT", "", level_value_back_drop, "", 0)
    call DzFrameSetPoint(level_value, JN_FRAMEPOINT_CENTER, level_value_back_drop, JN_FRAMEPOINT_CENTER, 0, 0 )
    call DzFrameSetText(level_value, "0")
endfunction

/*
    이 함수 실행시 프레임 생성됨
*/
function Stat_Text_Init takes nothing returns nothing
    call Level_Text()
    call Stat_Text()
endfunction

endlibrary