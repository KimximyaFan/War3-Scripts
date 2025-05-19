library LoadCharacter requires LoadData

/*
    JN 오브젝트 캐릭터에 저장된 데이터들을 불러와서 동기화시킴
*/
function Load_Object_Character takes integer pid returns nothing
    local integer i
    
    call JNObjectCharacterInit( MAP_ID, USER_ID[pid], SECRET_KEY, "0" )
    
    call Sync_Data_Integer( pid, UNIT_LEVEL, JNObjectCharacterGetInt(USER_ID[pid], "UNIT_LEVEL") )
    call Sync_Data_Integer( pid, UNIT_TYPE, JNObjectCharacterGetInt(USER_ID[pid], "UNIT_TYPE") )
    call Sync_Data_Integer( pid, UNIT_EXP, JNObjectCharacterGetInt(USER_ID[pid], "UNIT_EXP") )
    call Sync_Data_Integer( pid, UNIT_GOLD, JNObjectCharacterGetInt(USER_ID[pid], "UNIT_GOLD") )
    call Sync_Data_Integer( pid, UNIT_LUMBER, JNObjectCharacterGetInt(USER_ID[pid], "UNIT_LUMBER") )
    
    // 인벤칸 템
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 25
        call Sync_Data_String( pid, INVEN + i, JNObjectCharacterGetString(USER_ID[pid], "INVEN" + I2S(i)) )
    endloop
    
    // 착용칸 템
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 10
        call Sync_Data_String( pid, WEARING + i, JNObjectCharacterGetString(USER_ID[pid], "WEARING" + I2S(i)) )
    endloop
    
    // 조합칸 템
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 11
        call Sync_Data_String( pid, COMBINATION + i, JNObjectCharacterGetString(USER_ID[pid], "COMBINATION" + I2S(i)) )
    endloop
    
    // 강화칸 템
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 1
        call Sync_Data_String( pid, UPGRADE + i, JNObjectCharacterGetString(USER_ID[pid], "UPGRADE" + I2S(i)) )
    endloop
endfunction


endlibrary