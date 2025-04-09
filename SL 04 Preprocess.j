library SaveLoadPreprocess requires SaveLoadLimited

function Get_Img_From_Unit_Type takes integer unit_type returns string
    if unit_type == 'H001' then
        return "BTNHero_A.blp"
    // 쑤 무청
    elseif unit_type == 'H005' then
        return "BTNHero_B.blp"
    // 아담    
    elseif unit_type == 'H006' then
        return "BTNHero_C.blp"
    // 카밀라
    elseif unit_type == 'H00I' then
        return "BTNHero_D.blp"
    // 뫼비우스
    elseif unit_type == 'H011' then
        return "BTNHero_E.blp"
    // 보레아스
    elseif unit_type == 'H01M' then
        return "BTNHero_F.blp"
    // 아르카나
    elseif unit_type == 'H01R' then
        return "BTNHero_G.blp"
    // 홍련
    elseif unit_type == 'H01S' then
        return "BTNHero_H.blp"
    // 프로메테우스
    elseif unit_type == 'H01T' then
        return "BTNHero_I.blp"
    // 엘리시아
    elseif unit_type == 'H04K' then
        return "BTNHero_J.blp"
    endif
    
    return ""
endfunction

function Get_Name_From_Unit_Type takes integer unit_type returns string
    local string unit_name
    
    if unit_type == 'H001' then
        set unit_name = "라이더"
    elseif unit_type == 'H005' then
        set unit_name = "쑤 무청"
    elseif unit_type == 'H006' then
        set unit_name = "아담"
    elseif unit_type == 'H00I' then
        set unit_name = "카밀라"
    elseif unit_type == 'H011' then
        set unit_name = "뫼비우스"
    elseif unit_type == 'H01M' then
        set unit_name = "보레아스"
    elseif unit_type == 'H01R' then
        set unit_name = "아르카나"
    elseif unit_type == 'H01S' then
        set unit_name = "홍련"
    elseif unit_type == 'H01T' then
        set unit_name = "프로메테우스"
    elseif unit_type == 'H04K' then
        set unit_name = "엘리시아"
    endif
    
    return unit_name
endfunction

// =====================================================================



private function User_Custom_Int_Sync takes nothing returns nothing
    local string sync_str = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_str, "#", 0) )
    local integer drop_int = S2I( JNStringSplit(sync_str, "#", 1) )
    local integer gold_int = S2I( JNStringSplit(sync_str, "#", 2) )
    local integer GOD_INT1 = S2I( JNStringSplit(sync_str, "#", 3) )
    local integer GOD_INT2 = S2I( JNStringSplit(sync_str, "#", 4) )
    local integer GOD_INT3 = S2I( JNStringSplit(sync_str, "#", 5) )
    local integer ITEM_A_COUNT = S2I( JNStringSplit(sync_str, "#", 6) )
    local integer ITEM_B_COUNT = S2I( JNStringSplit(sync_str, "#", 7) )
    local integer is_revision = S2I( JNStringSplit(sync_str, "#", 8) )

    set udg_Player_Drop_INT[pid+1] = drop_int
    set udg_Player_Gold_INT[pid+1] = gold_int
    
    if is_revision == 0 then
        set udg_GOD_INT1[pid+1] = GOD_INT1
        set udg_GOD_INT2[pid+1] = GOD_INT2
        set udg_GOD_INT3[pid+1] = GOD_INT3
        set udg_ITEM_A_COUNT[pid+1] = ITEM_A_COUNT
        set udg_ITEM_B_COUNT[pid+1] = ITEM_B_COUNT
    endif
endfunction

private function User_Custom_Int_Register takes integer pid returns nothing
    local string str = ""
    local string drop_int
    local string gold_int
    local string GOD_INT1
    local string GOD_INT2
    local string GOD_INT3
    local string ITEM_A_COUNT
    local string ITEM_B_COUNT
    local boolean is_revision = false
    
    call JNObjectUserInit( Get_Map_Id(), Get_User_Id(), Get_Secret_Key(), "0" )
    
    set is_revision = JNObjectUserGetBoolean( Get_User_Id(), "REVISION" )
    
    set drop_int = I2S(JNObjectUserGetInt(Get_User_Id(), "user_drop_int"))
    set gold_int = I2S(JNObjectUserGetInt(Get_User_Id(), "user_gold_int"))
    set GOD_INT1 = I2S(JNObjectUserGetInt(Get_User_Id(), "GOD_INT1"))
    set GOD_INT2 = I2S(JNObjectUserGetInt(Get_User_Id(), "GOD_INT2"))
    set GOD_INT3 = I2S(JNObjectUserGetInt(Get_User_Id(), "GOD_INT3"))
    set ITEM_A_COUNT = I2S(JNObjectUserGetInt(Get_User_Id(), "ITEM_A_COUNT"))
    set ITEM_B_COUNT = I2S(JNObjectUserGetInt(Get_User_Id(), "ITEM_B_COUNT"))
    
    set str = I2S(pid) + "#" + drop_int + "#" + gold_int + "#" + GOD_INT1 + "#" + GOD_INT2 + "#" + GOD_INT3
    set str = str + "#" + ITEM_A_COUNT + "#" + ITEM_B_COUNT
    
    if is_revision == true then
        set str = str + "#" + "1"
    else
        set str = str + "#" + "0"
    endif
    
    call DzSyncData( "cusint", str )
endfunction

private function Load_User_Object takes nothing returns nothing
    local integer pid
    
    set pid = -1
    loop
    set pid = pid + 1
    exitwhen pid >= 6
        if GetPlayerController(Player(pid)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(pid)) == PLAYER_SLOT_STATE_PLAYING then
            if GetLocalPlayer() == Player(pid) then
                call User_Custom_Int_Register(pid)
                call User_Limited_Character_Register(pid)
            endif
        endif
    endloop
endfunction

private function User_Character_Data_Sync takes nothing returns nothing
    local string sync_str = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_str, "#", 0) )
    local integer index = S2I( JNStringSplit(sync_str, "#", 1) )
    local integer field = S2I( JNStringSplit(sync_str, "#", 2) )
    local integer value = S2I( JNStringSplit(sync_str, "#", 3) )

    call Set_Character_Data( pid, index, field, value )
endfunction

private function Sync_The_Data takes integer pid, integer index, integer field, integer value returns nothing
    call DzSyncData( "char", I2S(pid) + "#" + I2S(index) + "#" + I2S(field) + "#" + I2S(value) )
endfunction

private function User_Character_Data_Register takes integer pid, integer index returns nothing
    local integer i
    local boolean is_revision
    local boolean is_revision2
    local integer unit_level
    local integer unit_type
    local integer unit_exp
    local integer unit_str
    local integer unit_agi
    local integer unit_int
    local integer unit_hero_state
    local integer unit_gold
    local integer unit_lumber
    local integer array unit_item
    local integer array bag_0_item
    local integer array bag_1_item
    local string str
    
    // =================
    // 캐릭터 정보 로드
    // =================
    
    call JNObjectCharacterInit( Get_Map_Id(), Get_User_Id(), Get_Secret_Key(), Get_Characater_Index(index) )
    
    set is_revision = JNObjectCharacterGetBoolean( Get_User_Id(), "REVISION" )
    set is_revision2 = JNObjectCharacterGetBoolean( Get_User_Id(), "REVISION2" )
    
    call Sync_The_Data( pid, index, CHARACTER_DATA_SAVE_COUNT_HISTORY, JNObjectCharacterGetInt(Get_User_Id(), "SAVE_COUNT_HISTORY") )
    
    if is_revision == true then
        call Sync_The_Data( pid, index, CHARACTER_DATA_REVISION, 1 )
        call Sync_The_Data( pid, index, CHARACTER_DATA_GOD_INT1, JNObjectCharacterGetInt(Get_User_Id(), "GOD_INT1") )
        call Sync_The_Data( pid, index, CHARACTER_DATA_GOD_INT2, JNObjectCharacterGetInt(Get_User_Id(), "GOD_INT2") )
        call Sync_The_Data( pid, index, CHARACTER_DATA_GOD_INT3, JNObjectCharacterGetInt(Get_User_Id(), "GOD_INT3") )
        call Sync_The_Data( pid, index, CHARACTER_DATA_ITEM_A_COUNT, JNObjectCharacterGetInt(Get_User_Id(), "ITEM_A_COUNT") )
        call Sync_The_Data( pid, index, CHARACTER_DATA_ITEM_B_COUNT, JNObjectCharacterGetInt(Get_User_Id(), "ITEM_B_COUNT") )
    endif
    
    
    call Sync_The_Data( pid, index, CHARACTER_DATA_LEVEL, JNObjectCharacterGetInt(Get_User_Id(), "UNIT_LEVEL") )
    
    if is_revision2 == true then
        call Sync_The_Data( pid, index, CHARACTER_DATA_UNIT_TYPE, IDstring_To_Integer( JNObjectCharacterGetString(Get_User_Id(), "UNIT_TYPE") ) )
    else
        call Sync_The_Data( pid, index, CHARACTER_DATA_UNIT_TYPE, JNObjectCharacterGetInt(Get_User_Id(), "UNIT_TYPE") )
    endif
    
    call Sync_The_Data( pid, index, CHARACTER_DATA_EXP, JNObjectCharacterGetInt(Get_User_Id(), "UNIT_EXP") )
    call Sync_The_Data( pid, index, CHARACTER_DATA_STR, JNObjectCharacterGetInt(Get_User_Id(), "UNIT_STR") )
    call Sync_The_Data( pid, index, CHARACTER_DATA_AGI, JNObjectCharacterGetInt(Get_User_Id(), "UNIT_AGI") )
    call Sync_The_Data( pid, index, CHARACTER_DATA_INT, JNObjectCharacterGetInt(Get_User_Id(), "UNIT_INT") )
    call Sync_The_Data( pid, index, CHARACTER_DATA_HERO_STATE, JNObjectCharacterGetInt(Get_User_Id(), "UNIT_HERO_STATE") )
    call Sync_The_Data( pid, index, CHARACTER_DATA_GOLD, JNObjectCharacterGetInt(Get_User_Id(), "UNIT_GOLD") )
    call Sync_The_Data( pid, index, CHARACTER_DATA_LUMBER, JNObjectCharacterGetInt(Get_User_Id(), "UNIT_LUMBER") )
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 6
        if is_revision == true then
            call Sync_The_Data( pid, index, CHARACTER_DATA_USER_ITEM_0 + i, IDstring_To_Integer( JNObjectCharacterGetString(Get_User_Id(), "UNIT_ITEM" + I2S(i)) ) )
            call Sync_The_Data( pid, index, CHARACTER_DATA_BAG_0_ITEM_0 + i, IDstring_To_Integer( JNObjectCharacterGetString(Get_User_Id(), "BAG_0_ITEM" + I2S(i)) ) )
            call Sync_The_Data( pid, index, CHARACTER_DATA_BAG_1_ITEM_0 + i, IDstring_To_Integer( JNObjectCharacterGetString(Get_User_Id(), "BAG_1_ITEM" + I2S(i)) ) )
        else
            call Sync_The_Data( pid, index, CHARACTER_DATA_USER_ITEM_0 + i, JNObjectCharacterGetInt(Get_User_Id(), "UNIT_ITEM" + I2S(i)) )
            call Sync_The_Data( pid, index, CHARACTER_DATA_BAG_0_ITEM_0 + i, JNObjectCharacterGetInt(Get_User_Id(), "BAG_0_ITEM" + I2S(i)) )
            call Sync_The_Data( pid, index, CHARACTER_DATA_BAG_1_ITEM_0 + i, JNObjectCharacterGetInt(Get_User_Id(), "BAG_1_ITEM" + I2S(i)) )
        endif
    endloop
    
    call JNObjectCharacterResetCharacter( Get_User_Id() )
endfunction

private function Upper_Alphabet_Matching takes string char returns string
    if char == "A" then
        return "a"
    elseif char == "B" then
        return "b"
    elseif char == "C" then
        return "c"
    elseif char == "D" then
        return "d"
    elseif char == "E" then
        return "e"
    elseif char == "F" then
        return "f"
    elseif char == "G" then
        return "g"
    elseif char == "H" then
        return "h"
    elseif char == "I" then
        return "i"
    elseif char == "J" then
        return "j"
    elseif char == "K" then
        return "k"
    elseif char == "L" then
        return "l"
    elseif char == "M" then
        return "m"
    elseif char == "N" then
        return "n"
    elseif char == "O" then
        return "o"
    elseif char == "P" then
        return "p"
    elseif char == "Q" then
        return "q"
    elseif char == "R" then
        return "r"
    elseif char == "S" then
        return "s"
    elseif char == "T" then
        return "t"
    elseif char == "U" then
        return "u"
    elseif char == "V" then
        return "v"
    elseif char == "W" then
        return "w"
    elseif char == "X" then
        return "x"
    elseif char == "Y" then
        return "y"
    elseif char == "Z" then
        return "z"
    endif
    
    return char
endfunction

private function Lower_Case_Work takes string str returns string
    local integer i
    local string lower_case_str = ""
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= StringLength(str)
        set lower_case_str = lower_case_str + Upper_Alphabet_Matching( SubString(str, i, i+1) )
    endloop
    
    return lower_case_str
endfunction

// 유저의 아이디 기록
private function User_Id_Register takes integer j returns nothing
    if JNCheckNameHack( GetPlayerName( Player(j) ) ) == false then
        call Set_User_ID( Lower_Case_Work( GetPlayerName( Player(j) ) ) )
    endif
endfunction

// 유저 데이터들을 일단 로드해온후 기록
private function User_Data_Load takes nothing returns nothing
    local integer count = Get_Character_Count()
    local integer pid
    local integer index
    
    // 일단 잘 모르니 1번 플레이어 부터 12번 플레이어까지 돌림
    set pid = -1
    loop
    set pid = pid + 1
    exitwhen pid >= 6
        
        // 실제 사용자인지 판별하는 if 문
        if GetPlayerController(Player(pid)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(pid)) == PLAYER_SLOT_STATE_PLAYING then
            // 각플
            if GetLocalPlayer() == Player(pid) then
                call User_Id_Register(pid)
                
                set index = -1
                loop
                set index = index + 1
                exitwhen index >= count
                    call User_Character_Data_Register(pid, index)
                endloop
            endif
        endif
    endloop
    
    // 유저 오브젝트
    call TimerStart(CreateTimer(), 1.0, false, function Load_User_Object)
endfunction

private function Sync_Trigger_Init takes nothing returns nothing
    local trigger trg
    
    // 캐릭터 정보 동기화
    set trg = CreateTrigger()
    call DzTriggerRegisterSyncData(trg, "char", false)
    call TriggerAddAction( trg, function User_Character_Data_Sync )
    
    // 커스텀 정수 동기화
    set trg = CreateTrigger()
    call DzTriggerRegisterSyncData(trg, "cusint", false)
    call TriggerAddAction( trg, function User_Custom_Int_Sync )
    
    // 해금 캐릭터 동기화
    set trg = CreateTrigger()
    call DzTriggerRegisterSyncData(trg, "lchar", false)
    call TriggerAddAction( trg, function User_Limited_Character_Sync )
    
    set trg = null
endfunction

function Save_Load_Preprocess_Init takes nothing returns nothing
    if Is_Battle_Net() == false then
        return
    endif

    call Sync_Trigger_Init()
    call User_Data_Load()
endfunction

endlibrary