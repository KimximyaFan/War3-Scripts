scope MapStart initializer Init

globals
    private timer t = CreateTimer()
endglobals

function Player_Playing_Check takes player p returns boolean
    return GetPlayerController(p) == MAP_CONTROL_USER and GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING
endfunction

private function Map_Init_0 takes nothing returns nothing
    local integer pid

    set pid = -1
    loop
    set pid = pid + 1
    exitwhen pid > 11
        if SaveSystem.Is_Player_Playing( pid ) and SaveSystem.IS_TEST == false then
            set SaveSystem.USER_ID[pid] = StringCase( GetPlayerName( Player(pid) ), false )
            call JNObjectCharacterInit( SaveSystem.MAP_ID, SaveSystem.USER_ID[pid], SaveSystem.SECRET_KEY, "0" )
            call Load(pid)
        endif
    endloop

endfunction

private function Init takes nothing returns nothing
    local trigger trg

    set trg = CreateTrigger()
    call TriggerRegisterTimerEvent(trg, 0.00, false)
    call TriggerAddAction( trg, function Map_Init_0 )
    
    set trg = null
endfunction

endscope