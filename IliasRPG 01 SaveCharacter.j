library SaveCharacter

/*
    JN 오브젝트 캐릭터 기반 저장
*/
function Save_Object_Character takes integer pid returns nothing
    local unit u = udg_hero[pid+1]
    local string server_state
    local integer i
    local integer value
    local integer item_type
    local integer item_charge
    
    // 유닛 상태 저장
    call JNObjectCharacterSetInt( SaveSystem.USER_ID[pid], "UNIT_LEVEL", GetHeroLevel(u) )
    call JNObjectCharacterSetInt( SaveSystem.USER_ID[pid], "UNIT_TYPE", GetUnitTypeId(u) )
    call JNObjectCharacterSetInt( SaveSystem.USER_ID[pid], "UNIT_EXP", GetHeroXP(u) )
    call JNObjectCharacterSetInt( SaveSystem.USER_ID[pid], "UNIT_GOLD", GetPlayerState(Player(pid), PLAYER_STATE_RESOURCE_GOLD) )
    call JNObjectCharacterSetInt( SaveSystem.USER_ID[pid], "UNIT_LUMBER", GetPlayerState(Player(pid), PLAYER_STATE_RESOURCE_LUMBER ) )
    
    // 인벤칸 템 저장
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 6
        set item_type = SaveSystem.Get_Item_Type_In_Slot(u, i)
        set item_charge = SaveSystem.Get_Item_Charge_In_Slot(u, i)
        call JNObjectCharacterSetInt( SaveSystem.USER_ID[pid], "INVEN" + I2S(i), item_type )
        call JNObjectCharacterSetInt( SaveSystem.USER_ID[pid], "INVEN_CHARGE" + I2S(i), item_charge )
    endloop

    set server_state = JNObjectCharacterSave( SaveSystem.MAP_ID, SaveSystem.USER_ID[pid], SaveSystem.SECRET_KEY, "0" )
    call BJDebugMsg( server_state )
    
    set u = null
endfunction

endlibrary