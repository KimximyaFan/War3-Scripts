library SummonSave

private function Save_Object_Character_Data takes integer pid returns nothing
    local unit summon = udg_Summon[pid]
    local string player_name = GetPlayerName( Player(pid) )
    local integer is_saved = 0
    local string server_state
    local integer i
    local integer value

    // 
    
    // 만약 소환물이 존재 한다면
    if summon != null then
        set is_saved = 1

        call JNObjectCharacterSetInt(player_name, "SUMMON_EXP", GetHeroXP(summon) )
        
        set i = -1
        loop
        set i = i + 1
        exitwhen i >= 6
            set value = -1
            
            if UnitItemInSlot(summon, i) != null then
                set value = GetItemTypeId( UnitItemInSlot(summon, i) )
            endif
            
            call JNObjectCharacterSetInt( player_name, "SUMMON_INVEN_" + I2S(i), value )
        endloop
        
        call JNObjectCharacterSetInt(player_name, "BAG_INVEN_WEAPON", 1)
    endif
    
    call JNObjectCharacterSetInt(player_name, "IS_SUMMON_SAVED", is_saved)

    set server_state = JNObjectCharacterSave( MapId, player_name, SecretKey, SUMMON_OBJECT )
    call BJDebugMsg( server_state )
    
    set summon = null
endfunction

function Summon_Save takes integer pid returns nothing
    if ServerLoad == false then
        return
    endif
    
    set pid = pid - PLAYER_NUM_PAD
    
    if GetLocalPlayer() == Player(pid) then
        call Save_Object_Character_Data(pid)
    endif
endfunction

endlibrary