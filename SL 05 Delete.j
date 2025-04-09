library SaveLoadDelete requires SaveLoadGeneric, SaveLoadPreprocess

private function Save_Data_Delete takes nothing returns nothing
    local integer pid = GetPlayerId( GetTriggerPlayer() )
    
    call RemoveUnit(udg_Player_Hero[pid+1])
    call RemoveUnit(udg_Player_Bag[pid+1])

    if GetLocalPlayer() == Player(pid) then
        call JNObjectCharacterClearField( Get_User_Id() )
        call JNObjectCharacterSave( Get_Map_Id(), Get_User_Id(), Get_Secret_Key(), Get_Characater_Index( Get_Current_Character_Index() ) )
        set is_save_possible = false

        call BJDebugMsg("캐릭터 " + Get_Name_From_Unit_Type( Get_Character_Data(pid, Get_Current_Character_Index(), CHARACTER_DATA_UNIT_TYPE) ) + "가 삭제되었습니다.")
    endif
endfunction

function Save_Load_Delete_Init takes nothing returns nothing
    local trigger trg
    local integer i
    
    set trg = CreateTrigger()
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 6
        call TriggerRegisterPlayerChatEvent( trg, Player(i), "-캐릭터 삭제", true )
    endloop
    
    call TriggerAddAction(trg, function Save_Data_Delete)
endfunction

endlibrary