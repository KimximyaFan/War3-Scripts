library SummonGeneric initializer Init

function Get_Summon_Data takes integer pid, integer field returns integer
    return LoadInteger(SHT, pid, field)
endfunction

function Set_Summon_Data takes integer pid, integer field, integer value returns nothing
    call SaveInteger(SHT, pid, field, value)
endfunction

private function Reset_Object_Character_Data takes nothing returns nothing
    local string player_name = GetPlayerName( GetTriggerPlayer() )
    
    call JNObjectCharacterResetCharacter( player_name )
endfunction

private function Init takes nothing returns nothing
    local trigger trg
    local integer i = -1
    
    set trg = CreateTrigger(  )
    loop
    set i = i + 1
    exitwhen i > 11
        call TriggerRegisterPlayerEvent( trg, Player(i), EVENT_PLAYER_LEAVE )
    endloop
    
    call TriggerAddAction( trg, function Reset_Object_Character_Data )
    
    set trg = null
endfunction

endlibrary