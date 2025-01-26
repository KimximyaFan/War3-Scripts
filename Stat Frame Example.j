//! import "DzAPIFrameHandle.j"
//! import "DzAPISync.j"

library FrameTest initializer Frame_Test_Init requires DzAPISync

globals
    // 루트 프레임
    private integer frame_root
    // 활력 수치 프레임
    private integer frame_str_text
    // 공격력 수치 프레임
    private integer frame_dex_text
    // 정신력 수치 프레임
    private integer frame_int_text
    // 스탯포인트 수치 프레임
    private integer frame_stat_text
    // 충전량 수치 프레임
    private integer frame_flaskInc_text
    // 회복량 수치 프레임
    private integer frame_flaskUp_text
    // 플라스크 파편 수치 프레임
    private integer frame_flaskCount_text
    // 치확 수치 프레임
    private integer frame_crit_text
    // 치피 수치 프레임
    private integer frame_coef_text
    // 힘의 파편 수치 프레임
    private integer frame_powerCount_text
    // 스탯 박스 프레임
    private integer frame_stat_box
    // 스탯 증가 버튼 프레임 (배열)
    private integer array frame_stat_button
    // 스탯 아이콘 툴팁 프레임 (배열)
    private integer array frame_stat_tip_frame
    // 파편 박스 프레임
    private integer frame_fragment_box
    // 파편 증가 버튼 프레임 (배열)
    private integer array frame_fragment_button
    // 파편 아이콘 툴팁 프레임 (배열)
    private integer array frame_fragment_tip_frame
    // 스탯창 다시 누르면 꺼지게 하는 불린변수
    private boolean isOpen_stat = false
    // 파편창 다시 누르면 꺼지게 하는 불린변수
    private boolean isOpen_fragment = false
    
    // 스탯 포인트 (배열)
    public integer array stat_point
    // 플라스크 충전량 (배열)
    public integer array flask_count
    // 플라스크 회복량 (배열)
    public integer array flask_power
    // 플라스크 파편 (배열)
    public integer array flask_fragment
    // 치확 (배열)
    public integer array crit
    // 치피 (배열)
    public real array coef
    // 힘의 파편 (배열)
    public integer array power_fragment
    // 영웅 (배열)
    public unit array Hero
endglobals

function Hero_Set_Str takes unit u, integer add returns nothing
    call ModifyHeroStat( bj_HEROSTAT_STR, u, bj_MODIFYMETHOD_ADD, add )
    
    if GetLocalPlayer() == GetOwningPlayer(u) then
        call DzFrameSetText(frame_str_text, I2S(GetHeroStatBJ(bj_HEROSTAT_STR, u, false)) )
    endif
endfunction

function Hero_Set_Dex takes unit u, integer add returns nothing
    call ModifyHeroStat( bj_HEROSTAT_AGI, u, bj_MODIFYMETHOD_ADD, add )
    
    if GetLocalPlayer() == GetOwningPlayer(u) then
        call DzFrameSetText(frame_dex_text, I2S(GetHeroStatBJ(bj_HEROSTAT_AGI, u, false)) )
    endif
endfunction

function Hero_Set_Int takes unit u, integer add returns nothing
    call ModifyHeroStat( bj_HEROSTAT_INT, u, bj_MODIFYMETHOD_ADD, add )
    
    if GetLocalPlayer() == GetOwningPlayer(u) then
        call DzFrameSetText(frame_int_text, I2S(GetHeroStatBJ(bj_HEROSTAT_INT, u, false)) )
    endif
endfunction

function Player_Set_Stat_Point takes player p, integer add returns nothing
    local integer p_num = GetConvertedPlayerId(p)
    
    set stat_point[p_num] = stat_point[p_num] + add
    
    if GetLocalPlayer() == Player(p_num - 1) then
        call DzFrameSetText(frame_stat_text, I2S( stat_point[p_num] ) )
    endif
endfunction

function Player_Set_Flask_Fragment takes player p, integer add returns nothing
    local integer p_num = GetConvertedPlayerId(p)
    
    set flask_fragment[p_num] = flask_fragment[p_num] + add
    
    if GetLocalPlayer() == Player(p_num - 1) then
        call DzFrameSetText(frame_flaskCount_text, I2S( flask_fragment[p_num] ) )
    endif
endfunction

function Player_Set_Flask_Count takes player p, integer add returns nothing
    local integer p_num = GetConvertedPlayerId(p)
    
    set flask_count[p_num] = flask_count[p_num] + add
    
    if GetLocalPlayer() == Player(p_num - 1) then
        call DzFrameSetText(frame_flaskInc_text, I2S( flask_count[p_num] ) )
    endif
endfunction

function Player_Set_Flask_Power takes player p, integer add returns nothing
    local integer p_num = GetConvertedPlayerId(p)
    
    set flask_power[p_num] = flask_power[p_num] + add
    
    if GetLocalPlayer() == Player(p_num - 1) then
        call DzFrameSetText(frame_flaskUp_text, I2S( flask_power[p_num] ) )
    endif
endfunction

function Player_Set_Power_Fragment takes player p, integer add returns nothing
    local integer p_num = GetConvertedPlayerId(p)
    
    set power_fragment[p_num] = power_fragment[p_num] + add
    
    if GetLocalPlayer() == Player(p_num - 1) then
        call DzFrameSetText(frame_powerCount_text, I2S( power_fragment[p_num] ) )
    endif
endfunction

function Player_Set_Crit takes player p, integer add returns nothing
    local integer p_num = GetConvertedPlayerId(p)
    
    set crit[p_num] = crit[p_num] + add
    
    if GetLocalPlayer() == Player(p_num - 1) then
        call DzFrameSetText(frame_crit_text, I2S(crit[p_num]) + "%" )
    endif
endfunction

function Player_Set_Coef takes player p, integer add returns nothing
    local integer p_num = GetConvertedPlayerId(p)
    
    set coef[p_num] = coef[p_num] + (add/100.0)
    
    if GetLocalPlayer() == Player(p_num - 1) then
        call DzFrameSetText(frame_coef_text, I2S( R2I(coef[p_num] * 100 + 0.0001) ) + "%" )
    endif
endfunction

function Frame_Stat_Increase_Clicked takes nothing returns nothing
    local integer A = S2I( DzGetTriggerSyncData() )
    local integer p_num = A / 10
    local integer stat_type = ModuloInteger(A, 10)
    
    if stat_point[p_num] <= 0 then
        return
    endif
    
    call Player_Set_Stat_Point(Player(p_num - 1), -1)
    
    if stat_type == 0 then
        call Hero_Set_Str(Hero[p_num], 1)
    elseif stat_type == 1 then
        call Hero_Set_Dex(Hero[p_num], 1)
    elseif stat_type == 2 then
        call Hero_Set_Int(Hero[p_num], 1)
    endif
endfunction

function Frame_Stat_On takes nothing returns nothing
    // isOpen_stat -> true 라면
    // 스탯창이 열려있다는 뜻이다
    if isOpen_stat == true then
        set isOpen_stat = false
        call DzFrameShow(frame_stat_box, false)
    else
        set isOpen_stat = true
        call DzFrameShow(frame_stat_box, true)
    endif
endfunction

function Frame_Stat_Close takes nothing returns nothing
    set isOpen_stat = false
    call DzFrameShow(frame_stat_box, false)
endfunction

function Frame_Stat_Str_Clicked takes nothing returns nothing
    local integer p_num = GetConvertedPlayerId( DzGetTriggerUIEventPlayer() )
    call DzSyncData("Stat", I2S(p_num) + "0")
endfunction

function Frame_Stat_Dex_Clicked takes nothing returns nothing
    local integer p_num = GetConvertedPlayerId( DzGetTriggerUIEventPlayer() )
    call DzSyncData("Stat", I2S(p_num) + "1")
endfunction

function Frame_Stat_Int_Clicked takes nothing returns nothing
    local integer p_num = GetConvertedPlayerId( DzGetTriggerUIEventPlayer() )
    call DzSyncData("Stat", I2S(p_num) + "2")
endfunction

function Frame_Stat_Str_Tip_Enter takes nothing returns nothing
    call DzFrameShow(frame_stat_tip_frame[0], true)
endfunction

function Frame_Stat_Str_Tip_Leave takes nothing returns nothing
    call DzFrameShow(frame_stat_tip_frame[0], false)
endfunction

function Frame_Stat_Dex_Tip_Enter takes nothing returns nothing
    call DzFrameShow(frame_stat_tip_frame[1], true)
endfunction

function Frame_Stat_Dex_Tip_Leave takes nothing returns nothing
    call DzFrameShow(frame_stat_tip_frame[1], false)
endfunction

function Frame_Stat_Int_Tip_Enter takes nothing returns nothing
    call DzFrameShow(frame_stat_tip_frame[2], true)
endfunction

function Frame_Stat_Int_Tip_Leave takes nothing returns nothing
    call DzFrameShow(frame_stat_tip_frame[2], false)
endfunction

function Frame_Stat takes nothing returns nothing
    local integer frame
    local integer back_frame
    local integer relative_frame

    // 스탯 박스 프레임
    set frame_stat_box = DzCreateFrameByTagName("BACKDROP", "", frame_root, "EscMenuBackdrop", 0)
    call DzFrameSetSize(frame_stat_box, 0.35, 0.32)
    call DzFrameSetPoint(frame_stat_box, JN_FRAMEPOINT_LEFT, DzGetGameUI(), JN_FRAMEPOINT_LEFT, 0.03, 0.06)
    
    
    // 활력 아이콘
    set relative_frame = DzCreateFrameByTagName("BACKDROP", "", frame_stat_box, "", 0)
    call DzFrameSetSize(relative_frame, 0.04, 0.04)
    call DzFrameSetPoint(relative_frame, JN_FRAMEPOINT_TOPLEFT, frame_stat_box, JN_FRAMEPOINT_TOPLEFT, 0.05, -0.05)
    call DzFrameSetTexture(relative_frame, "UI\\Widgets\\Console\\Human\\infocard-heroattributes-str.blp", 0)
    // 활력 아이콘 툴팁용 (마우스 진입, 빠져나올 때 툴팁 함수 실행됨)
    set frame = DzCreateFrameByTagName("TEXT", "", relative_frame, "", 0)
    call DzFrameSetSize(frame, 0.04, 0.04)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, relative_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_ENTER, function Frame_Stat_Str_Tip_Enter, false)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_LEAVE, function Frame_Stat_Str_Tip_Leave, false)
    // 활력 텍스트 백드롭
    set back_frame = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(back_frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.075, 0)
    call DzFrameSetSize(back_frame, 0.05, 0.03)
    // 활력 텍스트 (마우스 진입, 빠져나올 때 툴팁 함수 실행됨)
    set frame = DzCreateFrameByTagName("TEXT", "", back_frame, "", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, back_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame, "|cffffcc00" + "활력" + "|r")
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_ENTER, function Frame_Stat_Str_Tip_Enter, false)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_LEAVE, function Frame_Stat_Str_Tip_Leave, false)
    // 활력 수치 백드롭
    set back_frame = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(back_frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.13, 0)
    call DzFrameSetSize(back_frame, 0.04, 0.03)
    // 활력 수치
    set frame_str_text = DzCreateFrameByTagName("TEXT", "", back_frame, "", 0)
    call DzFrameSetPoint(frame_str_text, JN_FRAMEPOINT_CENTER, back_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame_str_text, I2S(22) )
    // 활력 증가 버튼 (클릭 되면 함수 실행됨)
    set frame = DzCreateFrameByTagName("GLUETEXTBUTTON", "", relative_frame, "ScriptDialogButton", 0)
    call DzFrameSetSize(frame, 0.06, 0.04)
    call DzFrameSetText(frame, "증가")
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.21, 0)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_CONTROL_CLICK, function Frame_Stat_Str_Clicked, false)
    // 활력 툴팁 백드롭
    set frame_stat_tip_frame[0] = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(frame_stat_tip_frame[0], JN_FRAMEPOINT_CENTER, relative_frame, JN_FRAMEPOINT_CENTER, 0.03, 0.04)
    call DzFrameSetSize(frame_stat_tip_frame[0], 0.16, 0.03)
    // 활력 툴팁 텍스트
    set frame = DzCreateFrameByTagName("TEXT", "", frame_stat_tip_frame[0], "", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, frame_stat_tip_frame[0], JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame, "활력 1 당 HP 30 증가")
    call DzFrameShow(frame_stat_tip_frame[0], false)
    
    
    // 공격력 아이콘
    set relative_frame = DzCreateFrameByTagName("BACKDROP", "", frame_stat_box, "", 0)
    call DzFrameSetSize(relative_frame, 0.04, 0.04)
    call DzFrameSetPoint(relative_frame, JN_FRAMEPOINT_TOPLEFT, frame_stat_box, JN_FRAMEPOINT_TOPLEFT, 0.05, -0.11)
    call DzFrameSetTexture(relative_frame, "UI\\Widgets\\Console\\Human\\infocard-heroattributes-agi.blp", 0)
    // 공격력 아이콘 툴팁용 (마우스 진입, 빠져나올 때 툴팁 함수 실행됨)
    set frame = DzCreateFrameByTagName("TEXT", "", relative_frame, "", 0)
    call DzFrameSetSize(frame, 0.04, 0.04)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, relative_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_ENTER, function Frame_Stat_Dex_Tip_Enter, false)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_LEAVE, function Frame_Stat_Dex_Tip_Leave, false)
    // 공격력 텍스트 백드롭
    set back_frame = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(back_frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.075, 0)
    call DzFrameSetSize(back_frame, 0.05, 0.03)
    // 공격력 텍스트 (마우스 진입, 빠져나올 때 툴팁 함수 실행됨)
    set frame = DzCreateFrameByTagName("TEXT", "", back_frame, "", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, back_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame, "|cffffcc00" + "공격력" + "|r")
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_ENTER, function Frame_Stat_Dex_Tip_Enter, false)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_LEAVE, function Frame_Stat_Dex_Tip_Leave, false)
    // 공격력 수치 백드롭
    set back_frame = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(back_frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.13, 0)
    call DzFrameSetSize(back_frame, 0.04, 0.03)
    // 공격력 수치
    set frame_dex_text = DzCreateFrameByTagName("TEXT", "", back_frame, "", 0)
    call DzFrameSetPoint(frame_dex_text, JN_FRAMEPOINT_CENTER, back_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame_dex_text, I2S(13) )
    // 공격력 증가 버튼 (클릭 되면 함수 실행됨)
    set frame = DzCreateFrameByTagName("GLUETEXTBUTTON", "", relative_frame, "ScriptDialogButton", 0)
    call DzFrameSetSize(frame, 0.06, 0.04)
    call DzFrameSetText(frame, "증가")
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.21, 0)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_CONTROL_CLICK, function Frame_Stat_Dex_Clicked, false)
    // 공격력 툴팁 백드롭
    set frame_stat_tip_frame[1] = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(frame_stat_tip_frame[1], JN_FRAMEPOINT_CENTER, relative_frame, JN_FRAMEPOINT_CENTER, 0.03, 0.04)
    call DzFrameSetSize(frame_stat_tip_frame[1], 0.20, 0.03)
    // 공격력 툴팁 텍스트
    set frame = DzCreateFrameByTagName("TEXT", "", frame_stat_tip_frame[1], "", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, frame_stat_tip_frame[1], JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame, "공격력*스킬계수 데미지 증가")
    call DzFrameShow(frame_stat_tip_frame[1], false)
    
    
    // 정신력 아이콘
    set relative_frame = DzCreateFrameByTagName("BACKDROP", "", frame_stat_box, "", 0)
    call DzFrameSetPoint(relative_frame, JN_FRAMEPOINT_TOPLEFT, frame_stat_box, JN_FRAMEPOINT_TOPLEFT, 0.05, -0.17)
    call DzFrameSetSize(relative_frame, 0.04, 0.04)
    call DzFrameSetTexture(relative_frame, "UI\\Widgets\\Console\\Human\\infocard-heroattributes-int.blp", 0)
    // 정신력 아이콘 툴팁용 (마우스 진입, 빠져나올 때 툴팁 함수 실행됨)
    set frame = DzCreateFrameByTagName("TEXT", "", relative_frame, "", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, relative_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetSize(frame, 0.04, 0.04)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_ENTER, function Frame_Stat_Int_Tip_Enter, false)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_LEAVE, function Frame_Stat_Int_Tip_Leave, false)
    // 정신력 텍스트 백드롭
    set back_frame = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(back_frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.075, 0)
    call DzFrameSetSize(back_frame, 0.05, 0.03)
    // 정신력 텍스트 (마우스 진입, 빠져나올 때 툴팁 함수 실행됨)
    set frame = DzCreateFrameByTagName("TEXT", "", back_frame, "", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, back_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame, "|cffffcc00" + "정신력" + "|r")
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_ENTER, function Frame_Stat_Int_Tip_Enter, false)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_LEAVE, function Frame_Stat_Int_Tip_Leave, false)
    // 정신력 수치 백드롭
    set back_frame = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(back_frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.13, 0)
    call DzFrameSetSize(back_frame, 0.04, 0.03)
    // 정신력 수치
    set frame_int_text = DzCreateFrameByTagName("TEXT", "", back_frame, "", 0)
    call DzFrameSetPoint(frame_int_text, JN_FRAMEPOINT_CENTER, back_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame_int_text, I2S(17) )
    // 정신력 증가 버튼 (클릭 되면 함수 실행됨)
    set frame = DzCreateFrameByTagName("GLUETEXTBUTTON", "", relative_frame, "ScriptDialogButton", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.21, 0)
    call DzFrameSetSize(frame, 0.06, 0.04)
    call DzFrameSetText(frame, "증가")
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_CONTROL_CLICK, function Frame_Stat_Int_Clicked, false)
    // 정신력 툴팁 백드롭
    set frame_stat_tip_frame[2] = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(frame_stat_tip_frame[2], JN_FRAMEPOINT_CENTER, relative_frame, JN_FRAMEPOINT_CENTER, 0.03, 0.04)
    call DzFrameSetSize(frame_stat_tip_frame[2], 0.16, 0.03)
    // 정신력 툴팁 텍스트
    set frame = DzCreateFrameByTagName("TEXT", "", frame_stat_tip_frame[2], "", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, frame_stat_tip_frame[2], JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame, "정신력 1 당 마나 5 증가")
    call DzFrameShow(frame_stat_tip_frame[2], false)
    

    // 스탯포인트 텍스트 백드롭
    set relative_frame = DzCreateFrameByTagName("BACKDROP", "", frame_stat_box, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(relative_frame, JN_FRAMEPOINT_TOPLEFT, frame_stat_box, JN_FRAMEPOINT_TOPLEFT, 0.08, -0.235)
    call DzFrameSetSize(relative_frame, 0.09, 0.03)
    // 스탯포인트 텍스트
    set frame = DzCreateFrameByTagName("TEXT", "", relative_frame, "", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, relative_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame, "|cffffcc00" + "스탯 포인트" + "|r")
    // 스탯포인트 수치 백드롭
    set back_frame = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(back_frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.075, 0)
    call DzFrameSetSize(back_frame, 0.04, 0.03)
    // 스탯포인트 수치
    set frame_stat_text = DzCreateFrameByTagName("TEXT", "", back_frame, "", 0)
    call DzFrameSetPoint(frame_stat_text, JN_FRAMEPOINT_CENTER, back_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame_stat_text, I2S(stat_point[0]) )
    
    
    // 종료 버튼 (클릭 되면 함수 실행됨)
    set frame = DzCreateFrameByTagName("GLUETEXTBUTTON", "", frame_stat_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_BOTTOMRIGHT, frame_stat_box, JN_FRAMEPOINT_BOTTOMRIGHT, 0, 0)
    call DzFrameSetSize(frame, 0.032, 0.032)
    call DzFrameSetText(frame, "X")
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_CONTROL_CLICK, function Frame_Stat_Close, false)
    
    // 처음엔 안보이게
    call DzFrameShow(frame_stat_box, false)
endfunction


function Frame_Fragment_On takes nothing returns nothing
    // isOpen_fragment -> true 라면
    // 파편창이 열려있다는 뜻이다
    if isOpen_fragment == true then
        set isOpen_fragment = false
        call DzFrameShow(frame_fragment_box, false)
    else
        set isOpen_fragment = true
        call DzFrameShow(frame_fragment_box, true)
    endif
endfunction

function Frame_Fragment_Close takes nothing returns nothing
    set isOpen_fragment = false
    call DzFrameShow(frame_fragment_box, false)
endfunction

function Frame_Fragment_Flask_Inc_Tip_Enter takes nothing returns nothing
    call DzFrameShow(frame_fragment_tip_frame[0], true)
endfunction

function Frame_Fragment_Flask_Inc_Tip_Leave takes nothing returns nothing
    call DzFrameShow(frame_fragment_tip_frame[0], false)
endfunction

function Frame_Fragment_Flask_Upgrade_Tip_Enter takes nothing returns nothing
    call DzFrameShow(frame_fragment_tip_frame[1], true)
endfunction

function Frame_Fragment_Flask_Upgrade_Tip_Leave takes nothing returns nothing
    call DzFrameShow(frame_fragment_tip_frame[1], false)
endfunction

function Frame_Fragment_Flask_Inc_Clicked takes nothing returns nothing
    local integer p_num = GetConvertedPlayerId( DzGetTriggerUIEventPlayer() )
    call DzSyncData("Flask", I2S(p_num) + "0")
endfunction

function Frame_Fragment_Flask_Upgrade_Clicked takes nothing returns nothing
    local integer p_num = GetConvertedPlayerId( DzGetTriggerUIEventPlayer() )
    call DzSyncData("Flask", I2S(p_num) + "1")
endfunction

function Frame_Fragment_Power_Crit_Clicked takes nothing returns nothing
    local integer p_num = GetConvertedPlayerId( DzGetTriggerUIEventPlayer() )
    call DzSyncData("Power", I2S(p_num) + "0")
endfunction

function Frame_Fragment_Power_Coef_Clicked takes nothing returns nothing
    local integer p_num = GetConvertedPlayerId( DzGetTriggerUIEventPlayer() )
    call DzSyncData("Power", I2S(p_num) + "1")
endfunction

function Frame_Fragment_Flask_Clicked takes nothing returns nothing
    local integer A = S2I( DzGetTriggerSyncData() )
    local integer p_num = A / 10
    local integer Type = ModuloInteger(A, 10)
    
    if flask_fragment[p_num] <= 0 then
        return
    endif
    
    call Player_Set_Flask_Fragment(Player(p_num - 1), -1)
    
    if Type == 0 then
        call Player_Set_Flask_Count(Player(p_num - 1), 1)
    elseif Type == 1 then
        call Player_Set_Flask_Power(Player(p_num - 1), 5)
    endif
endfunction

function Frame_Fragment_Power_Clicked takes nothing returns nothing
    local integer A = S2I( DzGetTriggerSyncData() )
    local integer p_num = A / 10
    local integer Type = ModuloInteger(A, 10)
    
    if power_fragment[p_num] <= 0 then
        return
    endif
    
    call Player_Set_Power_Fragment(Player(p_num - 1), -1)
    
    if Type == 0 then
        call Player_Set_Crit(Player(p_num - 1), 1)
    elseif Type == 1 then
        call Player_Set_Coef(Player(p_num - 1), 1)
    endif
endfunction

function Frame_Fragment takes nothing returns nothing
    local integer frame
    local integer back_frame
    local integer relative_frame

    // 파편 박스 프레임
    set frame_fragment_box = DzCreateFrameByTagName("BACKDROP", "", frame_root, "EscMenuBackdrop", 0)
    call DzFrameSetSize(frame_fragment_box, 0.35, 0.40)
    call DzFrameSetPoint(frame_fragment_box, JN_FRAMEPOINT_RIGHT, DzGetGameUI(), JN_FRAMEPOINT_RIGHT, -0.03, 0.08)
    
    
    // 충전량 아이콘
    set relative_frame = DzCreateFrameByTagName("BACKDROP", "", frame_fragment_box, "", 0)
    call DzFrameSetPoint(relative_frame, JN_FRAMEPOINT_TOPLEFT, frame_fragment_box, JN_FRAMEPOINT_TOPLEFT, 0.05, -0.05)
    call DzFrameSetSize(relative_frame, 0.04, 0.04)
    call DzFrameSetTexture(relative_frame, "ReplaceableTextures\\CommandButtons\\BTNVialFull.blp", 0)
    // 충전량 아이콘 툴팁용 (마우스 진입, 빠져나올 때 툴팁 함수 실행됨)
    set frame = DzCreateFrameByTagName("TEXT", "", relative_frame, "", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, relative_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetSize(frame, 0.04, 0.04)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_ENTER, function Frame_Fragment_Flask_Inc_Tip_Enter, false)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_LEAVE, function Frame_Fragment_Flask_Inc_Tip_Leave, false)
    // 충전량 텍스트 백드롭
    set back_frame = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(back_frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.075, 0)
    call DzFrameSetSize(back_frame, 0.05, 0.03)
    // 충전량 텍스트 (마우스 진입, 빠져나올 때 툴팁 함수 실행됨)
    set frame = DzCreateFrameByTagName("TEXT", "", back_frame, "", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, back_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame, "|cffffcc00" + "충전량" + "|r")
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_ENTER, function Frame_Fragment_Flask_Inc_Tip_Enter, false)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_LEAVE, function Frame_Fragment_Flask_Inc_Tip_Leave, false)
    // 충전량 수치 백드롭
    set back_frame = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(back_frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.13, 0)
    call DzFrameSetSize(back_frame, 0.04, 0.03)
    // 충전량 수치
    set frame_flaskInc_text = DzCreateFrameByTagName("TEXT", "", back_frame, "", 0)
    call DzFrameSetPoint(frame_flaskInc_text, JN_FRAMEPOINT_CENTER, back_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame_flaskInc_text, I2S(2) )
    // 충전량 증가 버튼 (클릭 되면 함수 실행됨)
    set frame = DzCreateFrameByTagName("GLUETEXTBUTTON", "", relative_frame, "ScriptDialogButton", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.21, 0)
    call DzFrameSetSize(frame, 0.06, 0.04)
    call DzFrameSetText(frame, "증가")
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_CONTROL_CLICK, function Frame_Fragment_Flask_Inc_Clicked, false)
    // 충전량 툴팁 백드롭
    set frame_fragment_tip_frame[0] = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(frame_fragment_tip_frame[0], JN_FRAMEPOINT_CENTER, relative_frame, JN_FRAMEPOINT_CENTER, 0.03, 0.04)
    call DzFrameSetSize(frame_fragment_tip_frame[0], 0.16, 0.03)
    // 충전량 툴팁 텍스트
    set frame = DzCreateFrameByTagName("TEXT", "", frame_fragment_tip_frame[0], "", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, frame_fragment_tip_frame[0], JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame, "충전량 1 증가, 최대 15개")
    call DzFrameShow(frame_fragment_tip_frame[0], false)
    
    
    // 회복량 아이콘
    set relative_frame = DzCreateFrameByTagName("BACKDROP", "", frame_fragment_box, "", 0)
    call DzFrameSetPoint(relative_frame, JN_FRAMEPOINT_TOPLEFT, frame_fragment_box, JN_FRAMEPOINT_TOPLEFT, 0.05, -0.11)
    call DzFrameSetSize(relative_frame, 0.04, 0.04)
    call DzFrameSetTexture(relative_frame, "ReplaceableTextures\\CommandButtons\\BTNVialEmpty.blp", 0)
    // 회복량 아이콘 툴팁용 (마우스 진입, 빠져나올 때 툴팁 함수 실행됨)
    set frame = DzCreateFrameByTagName("TEXT", "", relative_frame, "", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, relative_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetSize(frame, 0.04, 0.04)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_ENTER, function Frame_Fragment_Flask_Upgrade_Tip_Enter, false)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_LEAVE, function Frame_Fragment_Flask_Upgrade_Tip_Leave, false)
    // 회복량 텍스트 백드롭
    set back_frame = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(back_frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.075, 0)
    call DzFrameSetSize(back_frame, 0.05, 0.03)
    // 회복량 텍스트 (마우스 진입, 빠져나올 때 툴팁 함수 실행됨)
    set frame = DzCreateFrameByTagName("TEXT", "", back_frame, "", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, back_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame, "|cffffcc00" + "회복량" + "|r")
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_ENTER, function Frame_Fragment_Flask_Upgrade_Tip_Enter, false)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_MOUSE_LEAVE, function Frame_Fragment_Flask_Upgrade_Tip_Leave, false)
    // 회복량 수치 백드롭
    set back_frame = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(back_frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.13, 0)
    call DzFrameSetSize(back_frame, 0.04, 0.03)
    // 회복량 수치
    set frame_flaskUp_text = DzCreateFrameByTagName("TEXT", "", back_frame, "", 0)
    call DzFrameSetPoint(frame_flaskUp_text, JN_FRAMEPOINT_CENTER, back_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame_flaskUp_text, I2S(200) )
    // 회복량 증가 버튼 (클릭 되면 함수 실행됨)
    set frame = DzCreateFrameByTagName("GLUETEXTBUTTON", "", relative_frame, "ScriptDialogButton", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.21, 0)
    call DzFrameSetSize(frame, 0.06, 0.04)
    call DzFrameSetText(frame, "증가")
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_CONTROL_CLICK, function Frame_Fragment_Flask_Upgrade_Clicked, false)
    // 회복량 툴팁 백드롭
    set frame_fragment_tip_frame[1] = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(frame_fragment_tip_frame[1], JN_FRAMEPOINT_CENTER, relative_frame, JN_FRAMEPOINT_CENTER, 0.03, 0.04)
    call DzFrameSetSize(frame_fragment_tip_frame[1], 0.16, 0.03)
    // 회복량 툴팁 텍스트
    set frame = DzCreateFrameByTagName("TEXT", "", frame_fragment_tip_frame[1], "", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, frame_fragment_tip_frame[1], JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame, "플라스크 회복량 5 증가")
    call DzFrameShow(frame_fragment_tip_frame[1], false)
    
    
    // 플라스크 파편 텍스트 백드롭
    set relative_frame = DzCreateFrameByTagName("BACKDROP", "", frame_fragment_box, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(relative_frame, JN_FRAMEPOINT_TOPLEFT, frame_fragment_box, JN_FRAMEPOINT_TOPLEFT, 0.085, -0.165)
    call DzFrameSetSize(relative_frame, 0.09, 0.03)
    // 플라스크 파편 텍스트
    set frame = DzCreateFrameByTagName("TEXT", "", relative_frame, "", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, relative_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame, "|cffffcc00" + "플라스크 파편" + "|r")
    // 플라크스 파편 수치 백드롭
    set back_frame = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(back_frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.075, 0)
    call DzFrameSetSize(back_frame, 0.04, 0.03)
    // 플라스크 파편 수치
    set frame_flaskCount_text = DzCreateFrameByTagName("TEXT", "", back_frame, "", 0)
    call DzFrameSetPoint(frame_flaskCount_text, JN_FRAMEPOINT_CENTER, back_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame_flaskCount_text, I2S(flask_fragment[1]) )
    
    
    // 치확 아이콘
    set relative_frame = DzCreateFrameByTagName("BACKDROP", "", frame_fragment_box, "", 0)
    call DzFrameSetSize(relative_frame, 0.04, 0.04)
    call DzFrameSetPoint(relative_frame, JN_FRAMEPOINT_TOPLEFT, frame_fragment_box, JN_FRAMEPOINT_TOPLEFT, 0.05, -0.215)
    call DzFrameSetTexture(relative_frame, "ReplaceableTextures\\CommandButtons\\BTNCriticalStrike.blp", 0)
    // 치확 텍스트 백드롭
    set back_frame = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(back_frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.075, 0)
    call DzFrameSetSize(back_frame, 0.06, 0.03)
    // 치확 텍스트
    set frame = DzCreateFrameByTagName("TEXT", "", back_frame, "", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, back_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame, "|cffffcc00" + "치명확률" + "|r")
    // 치확 수치 백드롭
    set back_frame = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(back_frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.13, 0)
    call DzFrameSetSize(back_frame, 0.045, 0.03)
    // 치확 수치
    set frame_crit_text = DzCreateFrameByTagName("TEXT", "", back_frame, "", 0)
    call DzFrameSetPoint(frame_crit_text, JN_FRAMEPOINT_CENTER, back_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame_crit_text, I2S(crit[1]) + "%" )
    // 치확 증가 버튼 (클릭 되면 함수 실행됨)
    set frame = DzCreateFrameByTagName("GLUETEXTBUTTON", "", relative_frame, "ScriptDialogButton", 0)
    call DzFrameSetSize(frame, 0.06, 0.04)
    call DzFrameSetText(frame, "증가")
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.21, 0)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_CONTROL_CLICK, function Frame_Fragment_Power_Crit_Clicked, false)
    
    
    // 치피 아이콘
    set relative_frame = DzCreateFrameByTagName("BACKDROP", "", frame_fragment_box, "", 0)
    call DzFrameSetSize(relative_frame, 0.04, 0.04)
    call DzFrameSetPoint(relative_frame, JN_FRAMEPOINT_TOPLEFT, frame_fragment_box, JN_FRAMEPOINT_TOPLEFT, 0.05, -0.275)
    call DzFrameSetTexture(relative_frame, "ReplaceableTextures\\CommandButtons\\BTNCleavingAttack.blp", 0)
    // 치피 텍스트 백드롭
    set back_frame = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(back_frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.075, 0)
    call DzFrameSetSize(back_frame, 0.06, 0.03)
    // 치피 텍스트
    set frame = DzCreateFrameByTagName("TEXT", "", back_frame, "", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, back_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame, "|cffffcc00" + "치명피해" + "|r")
    // 치피 수치 백드롭
    set back_frame = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(back_frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.13, 0)
    call DzFrameSetSize(back_frame, 0.045, 0.03)
    // 치피 수치
    set frame_coef_text = DzCreateFrameByTagName("TEXT", "", back_frame, "", 0)
    call DzFrameSetPoint(frame_coef_text, JN_FRAMEPOINT_CENTER, back_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame_coef_text, I2S( R2I(coef[1] * 100 + 0.0001) ) + "%" )
    // 치피 증가 버튼 (클릭 되면 함수 실행됨)
    set frame = DzCreateFrameByTagName("GLUETEXTBUTTON", "", relative_frame, "ScriptDialogButton", 0)
    call DzFrameSetSize(frame, 0.06, 0.04)
    call DzFrameSetText(frame, "증가")
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.21, 0)
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_CONTROL_CLICK, function Frame_Fragment_Power_Coef_Clicked, false)
    
    
    // 힘의 파편 텍스트 백드롭
    set relative_frame = DzCreateFrameByTagName("BACKDROP", "", frame_fragment_box, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(relative_frame, JN_FRAMEPOINT_TOPLEFT, frame_fragment_box, JN_FRAMEPOINT_TOPLEFT, 0.085, -0.33)
    call DzFrameSetSize(relative_frame, 0.09, 0.03)
    // 힘의 파편 텍스트
    set frame = DzCreateFrameByTagName("TEXT", "", relative_frame, "", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, relative_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame, "|cffffcc00" + "힘의 파편" + "|r")
    // 힘의 파편 수치 백드롭
    set back_frame = DzCreateFrameByTagName("BACKDROP", "", relative_frame, "ScoreScreenButtonBackdropTemplate", 0)
    call DzFrameSetPoint(back_frame, JN_FRAMEPOINT_RIGHT, relative_frame, JN_FRAMEPOINT_RIGHT, 0.075, 0)
    call DzFrameSetSize(back_frame, 0.04, 0.03)
    // 힘의 파편 수치
    set frame_powerCount_text = DzCreateFrameByTagName("TEXT", "", back_frame, "", 0)
    call DzFrameSetPoint(frame_powerCount_text, JN_FRAMEPOINT_CENTER, back_frame, JN_FRAMEPOINT_CENTER, 0.0, 0.0)
    call DzFrameSetText(frame_powerCount_text, I2S(power_fragment[1]) )
    
    
    // 종료 버튼 (클릭 되면 함수 실행됨)
    set frame = DzCreateFrameByTagName("GLUETEXTBUTTON", "", frame_fragment_box, "ScriptDialogButton", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_BOTTOMLEFT, frame_fragment_box, JN_FRAMEPOINT_BOTTOMLEFT, 0, 0)
    call DzFrameSetSize(frame, 0.032, 0.032)
    call DzFrameSetText(frame, "X")
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_CONTROL_CLICK, function Frame_Fragment_Close, false)
    
    
    // 처음엔 안보이게
    call DzFrameShow(frame_fragment_box, false)
endfunction

function Frame_Set_Stat_Button takes nothing returns nothing
    local integer frame
    
    // 스탯창 나오는 버튼 (클릭 되면 함수 실행됨)
    set frame = DzCreateFrameByTagName("GLUETEXTBUTTON", "", DzGetGameUI(), "ScriptDialogButton", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, DzGetGameUI(), JN_FRAMEPOINT_CENTER, -0.1, -0.15)
    call DzFrameSetSize(frame, 0.05, 0.04)
    call DzFrameSetText(frame, "스탯")
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_CONTROL_CLICK, function Frame_Stat_On, false)
endfunction

function Frame_Set_Fragment_Button takes nothing returns nothing
    local integer frame
    
    // 파편창 나오는 버튼 (클릭 되면 함수 실행됨)
    set frame = DzCreateFrameByTagName("GLUETEXTBUTTON", "", DzGetGameUI(), "ScriptDialogButton", 0)
    call DzFrameSetPoint(frame, JN_FRAMEPOINT_CENTER, DzGetGameUI(), JN_FRAMEPOINT_CENTER, 0.1, -0.15)
    call DzFrameSetSize(frame, 0.05, 0.04)
    call DzFrameSetText(frame, "파편")
    call DzFrameSetScriptByCode(frame, JN_FRAMEEVENT_CONTROL_CLICK, function Frame_Fragment_On, false)
endfunction

function Trig_Set_Stat_Actions takes nothing returns nothing
    call Player_Set_Stat_Point(GetTriggerPlayer(), 10)
endfunction

function Trig_Set_Stat_Actions2 takes nothing returns nothing
    call Player_Set_Flask_Fragment(GetTriggerPlayer(), 10)
endfunction

function Trig_Set_Stat_Actions3 takes nothing returns nothing
    call Player_Set_Power_Fragment(GetTriggerPlayer(), 10)
endfunction

function Variable_Initialize takes nothing returns nothing
    local integer i = 0
    
    set Hero[1] = gg_unit_Hpal_0002
    
    loop
    set i = i + 1
    exitwhen i > 5
        set stat_point[i] = 0
        set flask_count[i] = 2
        set flask_power[i] = 200
        set flask_fragment[i] = 0
        set crit[i] = 0
        set coef[i] = 1.20
        set power_fragment[i] = 0
    endloop
endfunction

function Frame_Test_Init takes nothing returns nothing
    local trigger trg
    
    // 변수를 초기화 해주는 함수
    call Variable_Initialize()
    // 루트프레임 만듬
    set frame_root = DzCreateFrameByTagName("FRAME", "", DzGetGameUI(), "", 0)
    // 스탯 프레임 만드는 함수
    call Frame_Stat()
    // 파편 프레임 만드는 함수
    call Frame_Fragment()
    // 스탯창 뜨게하는 버튼을 만드는 함수
    call Frame_Set_Stat_Button()
    // 파편창 뜨게하는 버튼을 만드는 함수
    call Frame_Set_Fragment_Button()

    set trg = CreateTrigger()
    call JNTriggerRegisterSyncData(trg, "Stat", false)
    call TriggerAddAction( trg, function Frame_Stat_Increase_Clicked )
    
    set trg = CreateTrigger()
    call JNTriggerRegisterSyncData(trg, "Flask", false)
    call TriggerAddAction( trg, function Frame_Fragment_Flask_Clicked )
    
    set trg = CreateTrigger()
    call JNTriggerRegisterSyncData(trg, "Power", false)
    call TriggerAddAction( trg, function Frame_Fragment_Power_Clicked )
    
    set trg = CreateTrigger(  )
    call TriggerRegisterPlayerChatEvent( trg, Player(0), "-스탯", true )
    call TriggerAddAction( trg, function Trig_Set_Stat_Actions )
    
    set trg = CreateTrigger(  )
    call TriggerRegisterPlayerChatEvent( trg, Player(0), "-플파편", true )
    call TriggerAddAction( trg, function Trig_Set_Stat_Actions2 )
    
    set trg = CreateTrigger(  )
    call TriggerRegisterPlayerChatEvent( trg, Player(0), "-힘파편", true )
    call TriggerAddAction( trg, function Trig_Set_Stat_Actions3 )

    set trg = null
endfunction

endlibrary