library HeroRevive requires Base, UnitProperty

/*
    영웅 부활 관련 스크립트
*/

// 영웅 체력 마나 풀로 꽉채우고 부활시킴
private function Revive_Func takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local unit u = LoadUnitHandle(HT, id, 0)
    
    call ReviveHero(u, -640, -1280, true)
    
    call Set_HP( u, JNGetUnitMaxHP(u) )
    call Set_MP( u, JNGetUnitMaxMana(u) )
    
    call Timer_Clear(t)
    
    set t = null
    set u = null
endfunction

// 부활 딜레이 2초
private function Revive takes nothing returns nothing
    local timer t = CreateTimer()
    local integer id = GetHandleId(t)
    local unit u = GetTriggerUnit()
    local real delay = 2.00
    
    call SaveUnitHandle(HT, id, 0, u)
    call TimerStart(t, delay, false, function Revive_Func)
    
    set t = null
    set u = null
endfunction

// 트리거 초기화
function Revive_Init takes nothing returns nothing
    local trigger trg
    
    set trg = CreateTrigger()
    call TriggerRegisterPlayerUnitEvent(trg, Player(0), EVENT_PLAYER_UNIT_DEATH, null)
    call TriggerRegisterPlayerUnitEvent(trg, Player(1), EVENT_PLAYER_UNIT_DEATH, null)
    call TriggerRegisterPlayerUnitEvent(trg, Player(2), EVENT_PLAYER_UNIT_DEATH, null)
    call TriggerRegisterPlayerUnitEvent(trg, Player(3), EVENT_PLAYER_UNIT_DEATH, null)
    call TriggerAddAction( trg, function Revive )
    
    set trg = null
endfunction

endlibrary