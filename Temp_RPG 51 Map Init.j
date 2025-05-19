scope MapStart initializer Init

globals
    // 시간차 초기화를 위한 타이머
    private timer t = CreateTimer()
endglobals

private function Map_Init_1 takes nothing returns nothing
    // 플레이어 나감
    call Player_Dodge_Init()
    // 범용적인 프레임 작동
    call Generic_Frame_Work_Init()
    // 스탯창
    call Stat_Init()
    // 가상 인벤
    call Inventory_Init()
    // 영웅 관련
    call Hero_Init()
    // Generic Frame Show
    call Show_Generic_Frames()
endfunction

private function Map_Init_0 takes nothing returns nothing
    local integer pid
    
    // 히어로 객체 생성하고, 유저 아이디 변수에 등록하기
    set pid = -1
    loop
    set pid = pid + 1
    exitwhen pid > 6
        if Player_Playing_Check( Player(pid) ) then
            set player_hero[pid] = Hero.create(pid)
            set USER_ID[pid] = StringCase( GetPlayerName( Player(pid) ), false )
        endif
    endloop
    
    // 시간, 시야, 안개제거, 음악
    call UseTimeOfDayBJ( false )
    call SetTimeOfDay( 12 )
    call StopMusic(false)
    call FogEnableOff(  )
    call FogMaskEnableOff(  )
    
    // Object 초기화
    call Object_Init()
    
    // 시간차 초기화
    // Object Init() 이 무거워지면 이 딜레이를 좀 더 증가시켜야함
    call TimerStart(t, 0.1, false, function Map_Init_1)
endfunction

private function Init takes nothing returns nothing
    local trigger trg

    // 맵시작하고나서 0초후에 전체 초기화 실행
    set trg = CreateTrigger()
    call TriggerRegisterTimerEvent(trg, 0.00, false)
    call TriggerAddAction( trg, function Map_Init_0 )
    
    set trg = null
endfunction

endscope