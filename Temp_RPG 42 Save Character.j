library SaveCharacter

/*
    오브젝트로부터 저장 문자열 생성하는 함수
*/
private function Make_String_From_Object takes Object obj returns string
    local integer i
    local string str = ""
    
    if obj == -1 then
        return "-1"
    endif
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= OBJECT_PROPERTY_SIZE
        set str = str + I2S(obj.Get_Object_Property(i)) + ","
    endloop
    
    return str
endfunction

/*
    JN 오브젝트 캐릭터 기반 저장
*/
function Save_Object_Character takes integer pid returns nothing
    local unit u = player_hero[pid].Get_Hero_Unit()
    local string server_state
    local integer i
    local integer value
    local Object obj
    
    call JNObjectCharacterInit( MAP_ID, USER_ID[pid], SECRET_KEY, "0" )
    
    // 유닛 상태 저장
    call JNObjectCharacterSetInt( USER_ID[pid], "UNIT_LEVEL", GetHeroLevel(u) )
    call JNObjectCharacterSetInt( USER_ID[pid], "UNIT_TYPE", GetUnitTypeId(u) )
    call JNObjectCharacterSetInt( USER_ID[pid], "UNIT_EXP", GetHeroXP(u) )
    call JNObjectCharacterSetInt( USER_ID[pid], "UNIT_GOLD", GetPlayerState(Player(pid), PLAYER_STATE_RESOURCE_GOLD) )
    call JNObjectCharacterSetInt( USER_ID[pid], "UNIT_LUMBER", GetPlayerState(Player(pid), PLAYER_STATE_RESOURCE_LUMBER ) )
    
    // 인벤칸 템 저장
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 25
        set obj = player_hero[pid].Get_Inven_Item(i)
        call JNObjectCharacterSetString( USER_ID[pid], "INVEN" + I2S(i), Make_String_From_Object(obj) )
    endloop
    
    // 착용칸 템 저장
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 10
        set obj = player_hero[pid].Get_Wearing_Item(i)
        call JNObjectCharacterSetString( USER_ID[pid], "WEARING" + I2S(i), Make_String_From_Object(obj) )
    endloop
    
    // 조합칸 템 저장
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 11
        set obj = player_hero[pid].Get_Combination_Item(i)
        call JNObjectCharacterSetString( USER_ID[pid], "COMBINATION" + I2S(i), Make_String_From_Object(obj) )
    endloop
    
    // 강화칸 템 저장
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 1
        set obj = player_hero[pid].Get_Upgrade_Object(i)
        call JNObjectCharacterSetString( USER_ID[pid], "UPGRADE" + I2S(i), Make_String_From_Object(obj) )
    endloop

    set server_state = JNObjectCharacterSave( MAP_ID, USER_ID[pid], SECRET_KEY, "0" )
    call BJDebugMsg( server_state )
    
    set u = null
endfunction

endlibrary