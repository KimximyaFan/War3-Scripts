library SummonLoad initializer Init

private function Load_Works_Based_On_Sync_Data takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer tid = GetHandleId(t)
    local integer pid = LoadInteger(SHT, tid, 0)
    
    set is_load_summon[pid] = true
    
    // 창고존 건물에 무기 넣기
    // 아이템 습득 이벤트로 소환물쪽에서 처리 
    
    
    call FlushChildHashtable(SHT, tid)
    call PauseTimer(t)
    call DestroyTimer(t)
    
    set t = null
endfunction

private function Object_Character_Data_Sync takes nothing returns nothing
    local string sync_str = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_str, "#", 0) )
    local integer field = S2I( JNStringSplit(sync_str, "#", 1) )
    local integer value = S2I( JNStringSplit(sync_str, "#", 2) )

    call Set_Summon_Data(pid, field, value)
endfunction

private function Sync_The_Data takes integer pid, integer field, integer value returns nothing
    call DzSyncData( "obchda", I2S(pid) + "#" + I2S(field) + "#" + I2S(value) )
endfunction

private function Load_Object_Character_Data takes integer pid returns nothing
    local string player_name = GetPlayerName( Player(pid) )
    local integer is_summon_saved
    
    call JNObjectCharacterInit( MapId, player_name, SecretKey, SUMMON_OBJECT )
    
    set is_summon_saved = JNObjectCharacterGetInt(player_name, "IS_SUMMON_SAVED")
    
    call Sync_The_Data( pid, IS_SUMMON_SAVED, is_summon_saved )
    
    if is_summon_saved == 0 then
        return
    endif

    call Sync_The_Data( pid, SUMMON_EXP, JNObjectCharacterGetInt(player_name, "SUMMON_EXP") )
    call Sync_The_Data( pid, SUMMON_INVEN_0, JNObjectCharacterGetInt(player_name, "SUMMON_INVEN_0") )
    call Sync_The_Data( pid, SUMMON_INVEN_1, JNObjectCharacterGetInt(player_name, "SUMMON_INVEN_1") )
    call Sync_The_Data( pid, SUMMON_INVEN_2, JNObjectCharacterGetInt(player_name, "SUMMON_INVEN_2") )
    call Sync_The_Data( pid, SUMMON_INVEN_3, JNObjectCharacterGetInt(player_name, "SUMMON_INVEN_3") )
    call Sync_The_Data( pid, SUMMON_INVEN_4, JNObjectCharacterGetInt(player_name, "SUMMON_INVEN_4") )
    call Sync_The_Data( pid, SUMMON_INVEN_5, JNObjectCharacterGetInt(player_name, "SUMMON_INVEN_5") )
    call Sync_The_Data( pid, BAG_INVEN_WEAPON, JNObjectCharacterGetInt(player_name, "BAG_INVEN_WEAPON") )
    
    //call JNObjectCharacterResetCharacter( GetPlayerName(p) )
endfunction

private function Init takes nothing returns nothing
    local trigger trg
    
    set trg = CreateTrigger()
    call DzTriggerRegisterSyncData(trg, "obchda", false)
    call TriggerAddAction( trg, function Object_Character_Data_Sync )
    
    set trg = null
endfunction

// ============================================
// API
// ============================================

function Summon_Load takes integer pid returns nothing
    local timer t
    local integer tid
    
    if ServerLoad == false then
        return
    endif
    
    set pid = pid - PLAYER_NUM_PAD
    
    if GetLocalPlayer() == Player(pid) then
        call Load_Object_Character_Data(pid)
    endif
    
    set t = CreateTimer()
    set tid = GetHandleId(t)
    call SaveInteger(SHT, tid, 0, pid)
    call TimerStart(t, 1.5, false, function Load_Works_Based_On_Sync_Data)
endfunction

endlibrary