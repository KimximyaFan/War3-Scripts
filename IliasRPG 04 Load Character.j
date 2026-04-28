library LoadCharacter requires LoadData

/*
    JN 오브젝트 캐릭터에 저장된 데이터들을 불러와서 동기화시킴
*/
function Load_Object_Character takes integer pid returns nothing
    local integer i
    
    // 영웅 정보
    call Sync_Data_Integer( pid, SaveSystem.UNIT_LEVEL, JNObjectCharacterGetInt(SaveSystem.USER_ID[pid], "UNIT_LEVEL") )
    call Sync_Data_Integer( pid, SaveSystem.UNIT_TYPE, JNObjectCharacterGetInt(SaveSystem.USER_ID[pid], "UNIT_TYPE") )
    call Sync_Data_Integer( pid, SaveSystem.UNIT_EXP, JNObjectCharacterGetInt(SaveSystem.USER_ID[pid], "UNIT_EXP") )
    call Sync_Data_Integer( pid, SaveSystem.UNIT_GOLD, JNObjectCharacterGetInt(SaveSystem.USER_ID[pid], "UNIT_GOLD") )
    call Sync_Data_Integer( pid, SaveSystem.UNIT_LUMBER, JNObjectCharacterGetInt(SaveSystem.USER_ID[pid], "UNIT_LUMBER") )
    
    // 영웅 인벤칸 템
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 6
        call Sync_Data_Integer( pid, SaveSystem.INVEN + i, JNObjectCharacterGetInt(SaveSystem.USER_ID[pid], "INVEN" + I2S(i)) )
        call Sync_Data_Integer( pid, SaveSystem.INVEN_CHARGE + i, JNObjectCharacterGetInt(SaveSystem.USER_ID[pid], "INVEN_CHARGE" + I2S(i)) )
    endloop
endfunction


endlibrary