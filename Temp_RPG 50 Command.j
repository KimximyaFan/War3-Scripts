scope Command initializer Init

globals
    // 실험용 우선순위 큐
    private PriorityQueue pq
endglobals

// 우선순위 큐 테스트
private function Temp_Test2 takes nothing returns nothing
    local string str = JNStringSplit( GetEventPlayerChatString(), " ", 1)
    local string str2 = JNStringSplit( GetEventPlayerChatString(), " ", 2)
    local integer k
    local integer v
    local Pair p
    
    if str == "show" then
        loop
        exitwhen pq.Is_Empty() == true
            set p = pq.Pop()
            call Msg( I2S( p.Key ) + " " + I2S( p.Value ) )
            call p.destroy()
        endloop
        
        return
    endif
    
    set k = S2I(str)
    set v = S2I(str2)
    
    call Msg("key : " + I2S(k) + " value : " + I2S(v) )
    
    call pq.Push(Pair.create(k, v))
endfunction

// 랜덤박스, 강화 주문서 생성하는 테스트용 함수
private function Test_0 takes nothing returns nothing
    local integer pid = 0
    local Object obj
    
    call player_hero[pid].Add_Object_To_Hero(Create_Object(Get_Name_To_ID("RANDOM_NORMAL_BOX"), 50))
    call player_hero[pid].Add_Object_To_Hero(Create_Object(Get_Name_To_ID("UPGRADE_SCROLL_NORMAL"), 50))
    call player_hero[pid].Add_Object_To_Hero(Create_Object(Get_Name_To_ID("UPGRADE_SCROLL_ADVANCED"), 50))
    call player_hero[pid].Add_Object_To_Hero(Create_Object(Get_Name_To_ID("UPGRADE_SCROLL_RARE"), 50))
endfunction

// 임의의 오브젝트 생성하는 함수
private function Test_Create_Object takes nothing returns nothing
    local integer pid = 0
    local integer object_id = Get_Name_To_ID( JNStringSplit( GetEventPlayerChatString(), " ", 1) )
    local integer count = S2I( JNStringSplit( GetEventPlayerChatString(), " ", 2) )
    local Object obj
    
    set obj = Create_Object(object_id, count)
    call player_hero[pid].Add_Object_To_Hero(obj)
endfunction

// -시야 150 
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

// 자살
private function Suicide takes nothing returns nothing
    local player p = GetTriggerPlayer()
    local integer pid = GetPlayerId(p)
    local unit u = Hero(pid+1).Get_Hero_Unit()
    
    call KillUnit(u)
    
    set p = null
    set u = null
endfunction

// 돈치트
private function Money takes nothing returns nothing
    call AdjustPlayerStateBJ( 1000, GetTriggerPlayer(), PLAYER_STATE_RESOURCE_GOLD )
endfunction

/*
    명령어 관련 초기화
*/
private function Init takes nothing returns nothing
    local integer i
    local trigger trg
    
    set pq = PriorityQueue.create(false)
    
    set trg = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(trg, Player(0), "-obj ", false)
    call TriggerAddAction( trg, function Test_Create_Object )
    
    set trg = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(trg, Player(0), "-test", true)
    call TriggerAddAction( trg, function Test_0 )
    
    set trg = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(trg, Player(0), "-pq ", false)
    call TriggerAddAction( trg, function Temp_Test2 )
    
    // 돈
    set trg = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(trg, Player(0), "-돈", true)
    call TriggerAddAction( trg, function Money )
    
    // 자살
    set i = -1
    loop
    set i = i + 1
    exitwhen i > 3
        set trg = CreateTrigger()
        call TriggerRegisterPlayerChatEvent(trg, Player(i), "-자살", true)
        call TriggerAddAction( trg, function Suicide )
    endloop
    
    // 시야
    set i = -1
    loop
    set i = i + 1
    exitwhen i > 3
        set trg = CreateTrigger()
        call TriggerRegisterPlayerChatEvent(trg, Player(i), "-시야", false)
        call TriggerAddAction( trg, function View )
    endloop
    
    set trg = null
endfunction

endscope