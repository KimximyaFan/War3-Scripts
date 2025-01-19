library Command requires EquipRandomize, InvenGeneric, Stat

globals
    private unit motion_unit
    private integer global_motion
    
    private real test_field_x = -6221.0
    private real test_field_y = 7916.0
endglobals

private function Test_Zone takes nothing returns nothing
    call SetUnitX(player_hero[0].Get_Hero_Unit(), test_field_x)
    call SetUnitY(player_hero[0].Get_Hero_Unit(), test_field_y)
    call CreateFogModifierRectBJ( true, Player(0), FOG_OF_WAR_VISIBLE, gg_rct_TestZone )
endfunction

private function Set_Motion takes nothing returns nothing
    local string str = GetEventPlayerChatString()
    local integer motion = S2I(JNStringSplit(str, " ", 1))
    
    set global_motion = motion
    call BJDebugMsg(I2S(motion) + " 번 모션 세팅됨")
endfunction

private function Play_Motion takes nothing returns nothing
    local string str = GetEventPlayerChatString()
    local integer motion = S2I(JNStringSplit(str, " ", 1))
    
    call SetUnitAnimationByIndex(motion_unit, motion)
    call BJDebugMsg(I2S(motion) + " 번 모션 재생함")
endfunction

private function Set_Motion_Unit takes nothing returns nothing
    set motion_unit = GetTriggerUnit()
    //call BJDebugMsg("선택됨")
endfunction

private function Exp takes nothing returns nothing
    local string str = GetEventPlayerChatString()
    local integer value = S2I(JNStringSplit(str, " ", 1))
    local player p = GetTriggerPlayer()
    local integer pid = GetPlayerId(p)
    
    call AddHeroXP(player_hero[pid].Get_Hero_Unit(), value, true)

    set p = null
endfunction

private function Atk_Speed takes nothing returns nothing
    local player p = GetTriggerPlayer()
    local integer pid = GetPlayerId(p)
    
    call player_hero[pid].Set_AS(player_hero[pid].Get_AS() + 100)
    call Stat_Refresh(pid)
    call BJDebugMsg("공속 오름")
    
    set p = null
endfunction

private function Regen takes nothing returns nothing
    local string str = GetEventPlayerChatString()
    local integer value = S2I(JNStringSplit(str, " ", 1))
    local integer pid = GetPlayerId(GetTriggerPlayer())
    
    call Hero(pid+1).Set_HP_REGEN( Hero(pid+1).Get_HP_REGEN() + value )
    call Hero(pid+1).Set_MP_REGEN( Hero(pid+1).Get_MP_REGEN() + value )
    
    call Stat_Refresh(pid)
    call BJDebugMsg("체리젠 마리젠 오름")
endfunction

private function Ad takes nothing returns nothing
    local player p = GetTriggerPlayer()
    local integer pid = GetPlayerId(p)
    local integer ad
    
    set ad = Hero(pid+1).Get_AD()
    call Hero(pid+1).Set_AD( ad + 10 )
    
    set p = null
endfunction

private function Def_Ad takes nothing returns nothing
    local string str = GetEventPlayerChatString()
    local integer value = S2I(JNStringSplit(str, " ", 1))
    local integer pid = GetPlayerId(GetTriggerPlayer())

    call Hero(pid+1).Set_DEF_AD( Hero(pid+1).Get_DEF_AD() + value )
    call Hero(pid+1).Set_DEF_AP( Hero(pid+1).Get_DEF_AP() + value )
    call Stat_Refresh(pid)
    
    call BJDebugMsg("방어력 오름")
endfunction

private function Log takes nothing returns nothing
    local player p = GetTriggerPlayer()
    
    if GetLocalPlayer() == p then
        call JNMapServerLog("MPT", SECRET_KEY, "1.0", "로그 테스트")
    endif
    
    set p = null
endfunction

private function Debug takes nothing returns nothing
    local player p = GetTriggerPlayer()
    local integer pid = GetPlayerId(p)
    
    call Hero(pid+1).Exist_Show()
    
    set p = null
endfunction

private function View takes nothing returns nothing
    local player p = GetTriggerPlayer()
    local string str = GetEventPlayerChatString()
    local integer value = S2I( SubString(str, 8, StringLength(str)) )
    
    if value < 80 or value > 150 then
        return
    endif
    
    call SetCameraFieldForPlayer( p, CAMERA_FIELD_TARGET_DISTANCE, 20 * value, 0.25 )
    
    set p = null
endfunction

private function Suicide takes nothing returns nothing
    local player p = GetTriggerPlayer()
    local integer pid = GetPlayerId(p)
    local unit u = Hero(pid+1).Get_Hero_Unit()
    
    if Get_Unit_Property(u, IN_COURTYARD) == 0 then
        call KillUnit(u)
    endif

    set u = null
endfunction

// 돈치트
private function Money takes nothing returns nothing
    call AdjustPlayerStateBJ( 900000, GetTriggerPlayer(), PLAYER_STATE_RESOURCE_GOLD )
endfunction

function Command_Init takes nothing returns nothing
    local integer i
    local trigger trg
    
    set trg = CreateTrigger()
    // 자살
    set i = -1
    loop
    set i = i + 1
    exitwhen i > 5
        call TriggerRegisterPlayerChatEvent(trg, Player(i), "-자살", true)
    endloop
    call TriggerAddAction( trg, function Suicide )
    
    // 시야
    set i = -1
    loop
    set i = i + 1
    exitwhen i > 3
        set trg = CreateTrigger()
        call TriggerRegisterPlayerChatEvent(trg, Player(i), "-시야", false)
        call TriggerAddAction( trg, function View )
    endloop
    
    
    
    
    
    
    if is_Test == true then
        // 돈
        set trg = CreateTrigger()
        call TriggerRegisterPlayerChatEvent(trg, Player(0), "-돈", true)
        call TriggerAddAction( trg, function Money )
        
            
        // 경험치
        set trg = CreateTrigger()
        call TriggerRegisterPlayerChatEvent(trg, Player(0), "-경험치 ", false)
        call TriggerAddAction( trg, function Exp )
    endif
    
    
    
    // 디버깅
    set i = -1
    loop
    set i = i + 1
    exitwhen i > 3
        set trg = CreateTrigger()
        call TriggerRegisterPlayerChatEvent(trg, Player(i), "-디버그", false)
        call TriggerAddAction( trg, function Debug )
    endloop
    
    // 로그
    set i = -1
    loop
    set i = i + 1
    exitwhen i > 3
        set trg = CreateTrigger()
        call TriggerRegisterPlayerChatEvent(trg, Player(i), "-로그", false)
        call TriggerAddAction( trg, function Log )
    endloop
    
    set trg = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(trg, Player(0), "-방어 ", false)
    call TriggerAddAction( trg, function Def_Ad )
    
    // 공격테스트
    set i = -1
    loop
    set i = i + 1
    exitwhen i > 3
        set trg = CreateTrigger()
        call TriggerRegisterPlayerChatEvent(trg, Player(i), "-공격", false)
        call TriggerAddAction( trg, function Ad )
    endloop
    
    // 리젠테스트
    set i = -1
    loop
    set i = i + 1
    exitwhen i > 3
        set trg = CreateTrigger()
        call TriggerRegisterPlayerChatEvent(trg, Player(i), "-리젠 ", false)
        call TriggerAddAction( trg, function Regen )
    endloop
    
    // 공속테스트
    set i = -1
    loop
    set i = i + 1
    exitwhen i > 3
        set trg = CreateTrigger()
        call TriggerRegisterPlayerChatEvent(trg, Player(i), "-공속", false)
        call TriggerAddAction( trg, function Atk_Speed )
    endloop

    
    
    set trg = CreateTrigger(  )
    call TriggerRegisterPlayerSelectionEventBJ( trg, Player(0), true )
    call TriggerAddAction( trg, function Set_Motion_Unit )
    
    set trg = CreateTrigger(  )
    call TriggerRegisterPlayerChatEvent( trg, Player(0), "-motion ", false )
    call TriggerAddAction( trg, function Play_Motion )
    
    set trg = CreateTrigger(  )
    call TriggerRegisterPlayerChatEvent( trg, Player(0), "-set_motion ", false )
    call TriggerAddAction( trg, function Set_Motion )
    
    set trg = CreateTrigger(  )
    call TriggerRegisterPlayerChatEvent( trg, Player(0), "테스트", false )
    call TriggerAddAction( trg, function Test_Zone )

    
    
    
    set trg = null
endfunction

endlibrary