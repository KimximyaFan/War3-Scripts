library SaveLoadInit initializer Init requires SaveLoadFrame, SaveLoadSpecialItem

private function Save_Load_Init2 takes nothing returns nothing
    call DestroyTimer(GetExpiredTimer())
    call Save_Load_Delete_Init()
    call Save_Load_Frame_Init()
    call Special_Item_Command()
endfunction

private function Save_Load_Init takes nothing returns nothing
    call Save_Load_Preprocess_Init()
    
    call TimerStart(CreateTimer(), 1.0, false, function Save_Load_Init2)
endfunction

private function Init takes nothing returns nothing
    local trigger trg
    local real init_time = 0.5

    set trg = CreateTrigger()
    call TriggerRegisterTimerEvent(trg, init_time, false)
    call TriggerAddAction(trg, function Save_Load_Init)

    set trg = null
endfunction

endlibrary