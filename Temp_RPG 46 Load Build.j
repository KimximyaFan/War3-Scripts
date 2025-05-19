library LoadBuild requires LoadData

/*
    오브젝트문자열로부터 오브젝트를 생성하는 함수
*/
private function Make_Object_From_String takes string str returns Object
    local integer i
    local Object obj
    
    if str == "-1" then
        return -1
    endif
    
    set obj = Object.create()
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= OBJECT_PROPERTY_SIZE
        call obj.Set_Object_Property( i, S2I(JNStringSplit(str, ",", i)) )
    endloop
    
    return obj
endfunction

/*
    로드한 후 동기화된 데이터로부터 저장된 유닛을 다시 빌드하는 함수
*/
function Create_Unit_From_Data takes integer pid returns nothing
    local unit u
    local integer unit_type
    local integer exp
    local integer gold
    local integer lumber
    local integer i
    local Object obj
    
    set unit_type = Get_Character_Data_Integer(pid, UNIT_LEVEL)
    set exp = Get_Character_Data_Integer(pid, UNIT_EXP)
    set gold = Get_Character_Data_Integer(pid, UNIT_GOLD)
    set lumber = Get_Character_Data_Integer(pid, UNIT_LUMBER)
    
    // 유닛 생성
    set u = CreateUnit(Player(pid), unit_type, 0, 0, 270)
    call player_hero[pid].Set_Hero_Unit(u)
    
    // 레벨 설정
    call SetHeroXP(u, exp, true)
    
    // 골드, 나무
    call AdjustPlayerStateBJ( gold, Player(pid), PLAYER_STATE_RESOURCE_GOLD )
    call AdjustPlayerStateBJ( lumber, Player(pid), PLAYER_STATE_RESOURCE_LUMBER )
    
    // 인벤칸 아이템
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 25
        set obj = Make_Object_From_String( Get_Character_Data_String(pid, INVEN) )
        
        if obj != -1 then
            call player_hero[pid].Set_Inven_Item(i, obj)
        endif
    endloop
    
    // 착용칸 아이템
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 10
        set obj = Make_Object_From_String( Get_Character_Data_String(pid, WEARING) )
        
        if obj != -1 then
            call player_hero[pid].Set_Wearing_Item(i, obj)
        endif
    endloop
    
    // 조합칸 아이템
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 11
        set obj = Make_Object_From_String( Get_Character_Data_String(pid, COMBINATION) )
        
        if obj != -1 then
            call player_hero[pid].Set_Combination_Item(i, obj)
        endif
    endloop
    
    // 강화칸 아이템
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 1
        set obj = Make_Object_From_String( Get_Character_Data_String(pid, UPGRADE) )
        
        if obj != -1 then
            call player_hero[pid].Set_Upgrade_Object(i, obj)
        endif
    endloop
endfunction

endlibrary