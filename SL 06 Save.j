library SaveLoadSave requires SaveLoadGeneric, SaveLoadPreprocess


private function Save_Object_Character takes integer pid returns nothing
    local unit u = Get_Player_Unit()
    local integer i
    local integer value
    local string server_state
    
    // 초기화
    call JNObjectCharacterClearField( Get_User_Id() )
    
    // 신버전 판별용
    call JNObjectCharacterSetBoolean( Get_User_Id(), "REVISION", true )
    call JNObjectCharacterSetBoolean( Get_User_Id(), "REVISION2", true )
    
    // 저장횟수기록 
    call JNObjectCharacterSetInt(Get_User_Id(), "SAVE_COUNT_HISTORY", save_count_history[pid])
    
    // 커스텀 인트
    call JNObjectCharacterSetInt(Get_User_Id(), "GOD_INT1", udg_GOD_INT1[pid+1])
    call JNObjectCharacterSetInt(Get_User_Id(), "GOD_INT2", udg_GOD_INT2[pid+1])
    call JNObjectCharacterSetInt(Get_User_Id(), "GOD_INT3", udg_GOD_INT3[pid+1])
    call JNObjectCharacterSetInt(Get_User_Id(), "ITEM_A_COUNT", udg_ITEM_A_COUNT[pid+1])
    call JNObjectCharacterSetInt(Get_User_Id(), "ITEM_B_COUNT", udg_ITEM_B_COUNT[pid+1])
    
    // 유닛 상태 저장
    call JNObjectCharacterSetInt( Get_User_Id(), "UNIT_LEVEL", GetHeroLevel(u) )
    call JNObjectCharacterSetString( Get_User_Id(), "UNIT_TYPE", Integer_To_IDstring( GetUnitTypeId(u) ) )
    call JNObjectCharacterSetInt( Get_User_Id(), "UNIT_EXP", GetHeroXP(u) )
    call JNObjectCharacterSetInt( Get_User_Id(), "UNIT_STR", GetHeroStr(u, false) )
    call JNObjectCharacterSetInt( Get_User_Id(), "UNIT_AGI", GetHeroAgi(u, false) )
    call JNObjectCharacterSetInt( Get_User_Id(), "UNIT_INT", GetHeroInt(u, false) )
    call JNObjectCharacterSetInt( Get_User_Id(), "UNIT_HERO_STATE", udg_Hero_State[pid+1] )
    call JNObjectCharacterSetInt( Get_User_Id(), "UNIT_GOLD", GetPlayerState(Player(pid), PLAYER_STATE_RESOURCE_GOLD) )
    call JNObjectCharacterSetInt( Get_User_Id(), "UNIT_LUMBER", GetPlayerState(Player(pid), PLAYER_STATE_RESOURCE_LUMBER ) )
    
    // 유닛 아이템 저장
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 6
        set value = -1
        
        if UnitItemInSlot(u, i) != null then
            set value = GetItemTypeId( UnitItemInSlot(u, i) )
        endif
        
        call JNObjectCharacterSetString( Get_User_Id(), "UNIT_ITEM" + I2S(i), Integer_To_IDstring( value ) )
    endloop
    
    // 창고 0 아이템 저장
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 6
        set value = -1
        
        if UnitItemInSlot(udg_Player_Bag[pid+1], i) != null then
            set value = GetItemTypeId( UnitItemInSlot(udg_Player_Bag[pid+1], i) )
        endif
        
        call JNObjectCharacterSetString( Get_User_Id(), "BAG_0_ITEM" + I2S(i), Integer_To_IDstring( value ) )
    endloop
    
    // 창고 1 아이템 저장
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 6
        set value = -1
        
        if UnitItemInSlot(udg_Player_ITEM_MIX[pid+1], i) != null then
            set value = GetItemTypeId( UnitItemInSlot(udg_Player_ITEM_MIX[pid+1], i) )
        endif
        
        call JNObjectCharacterSetString( Get_User_Id(), "BAG_1_ITEM" + I2S(i), Integer_To_IDstring( value ) )
    endloop
    
    set server_state = JNObjectCharacterSave( Get_Map_Id(), Get_User_Id(), Get_Secret_Key(), Get_Characater_Index( Get_Current_Character_Index() ) )
    
    call BJDebugMsg( server_state )

    set u = null
endfunction

private function Save_Object_User takes integer pid returns nothing
    // 초기화
    call JNObjectUserClearField( Get_User_Id() )
    
    // 신버전 저장인지 판별
    call JNObjectUserSetBoolean( Get_User_Id(), "REVISION", true )
    
    // 커스텀 인트 저장
    call JNObjectUserSetInt(Get_User_Id(), "user_drop_int", udg_Player_Drop_INT[pid+1])
    call JNObjectUserSetInt(Get_User_Id(), "user_gold_int", udg_Player_Gold_INT[pid+1])
    
    // 해금 캐릭터 저장
    call Limited_Characeter_Save(pid)
    
    // 실제 저장
    call JNObjectUserSave( Get_Map_Id(), Get_User_Id(), Get_Secret_Key(), "0" )
endfunction

function Save_Load_Save takes integer pid, boolean is_count_decrease returns nothing
    if Get_Save_Count() <= 0 and is_count_decrease == true then
        call BJDebugMsg("세이브 횟수를 모두 사용하셨습니다.")
        return
    endif
    
    if is_count_decrease == true then
        call Set_Save_Count( Get_Save_Count() - 1 )
        call BJDebugMsg("저장횟수 " + I2S( Get_Save_Count() ) + " 회 남았습니다.")
    endif
    
    if Is_Battle_Net() == false then
        return
    endif
    
    set save_count_history[pid] = save_count_history[pid] + 1
    
    call JNMapServerLog( Get_Map_Id(), Get_Secret_Key(), Get_User_Id(), Get_Characater_Index( Get_Current_Character_Index() ) + " 저장횟수 : " + I2S(save_count_history[pid]) )
    
    // 오브젝트 유저 저장
    call Save_Object_User(pid)
    
    // 오브젝트 캐릭터 저장
    call Save_Object_Character(pid)
endfunction

function Save_All takes nothing returns nothing
    local integer pid
    
    set pid = -1
    loop
    set pid = pid + 1
    exitwhen pid >= 6
        if GetPlayerController(Player(pid)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(pid)) == PLAYER_SLOT_STATE_PLAYING then
            if GetLocalPlayer() == Player(pid) then
                call Save_Load_Save(pid, false)
            endif
        endif
    endloop
endfunction

endlibrary