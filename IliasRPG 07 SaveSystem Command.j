scope SaveSystemCommand initializer Init

private function Load_Command takes nothing returns nothing
    local integer pid = GetPlayerId(GetTriggerPlayer())
    call Build_Unit(pid)
endfunction

private function Save_Command takes nothing returns nothing
    local integer pid = GetPlayerId(GetTriggerPlayer())
    call Save(pid)
endfunction

private function Init takes nothing returns nothing
    local trigger trg
    local integer i
        
    set trg = CreateTrigger(  )
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 12
        call TriggerRegisterPlayerChatEvent( trg, Player(i), "-save", false )
    endloop
    call TriggerAddAction( trg, function Save_Command )
    
    set trg = CreateTrigger(  )
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 12
        call TriggerRegisterPlayerChatEvent( trg, Player(i), "-load", false )
    endloop
    call TriggerAddAction( trg, function Load_Command )
    
    set trg = null
endfunction

endscope