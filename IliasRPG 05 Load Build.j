library LoadBuild requires LoadData

/*
    로드한 후 동기화된 데이터로부터 저장된 유닛을 다시 빌드하는 함수
*/
function Create_Unit_From_Data takes integer pid returns nothing
    local unit u
    local item the_item
    local integer unit_type
    local integer exp
    local integer gold
    local integer lumber
    local integer i
    local integer item_type
    local integer item_charge
    
    set unit_type = Get_Character_Data_Integer(pid, SaveSystem.UNIT_TYPE)
    set exp = Get_Character_Data_Integer(pid, SaveSystem.UNIT_EXP)
    set gold = Get_Character_Data_Integer(pid, SaveSystem.UNIT_GOLD)
    set lumber = Get_Character_Data_Integer(pid, SaveSystem.UNIT_LUMBER)
    
    if unit_type == 0 then
        return
    endif
    
    // 유닛 생성
    set u = CreateUnit(Player(pid), unit_type, -28425, 23866, 270)
    set udg_hero[pid+1] = u
    
    // 레벨 설정
    call SetHeroXP(u, exp, true)
    
    // 골드, 나무
    call AdjustPlayerStateBJ( gold, Player(pid), PLAYER_STATE_RESOURCE_GOLD )
    call AdjustPlayerStateBJ( lumber, Player(pid), PLAYER_STATE_RESOURCE_LUMBER )
    
    // 인벤칸 아이템
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= 6
        set item_type = Get_Character_Data_Integer(pid, SaveSystem.INVEN + i)
        set item_charge = Get_Character_Data_Integer(pid, SaveSystem.INVEN_CHARGE + i)
        
        if item_type != -1 then
            set the_item = CreateItem(item_type, GetUnitX(u), GetUnitY(u))
            call UnitAddItem(u, the_item)
            call SetItemCharges(the_item, item_charge)
            call UnitDropItemSlot(u, the_item, i)
            call SetItemPlayer(the_item, Player(pid), false)
        endif
    endloop
    
    set u = null
    set the_item = null
endfunction

endlibrary