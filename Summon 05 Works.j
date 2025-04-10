library SummonWorks initializer Init

// ======================================
// Remove Summon
// ======================================

private function Remove_Summon takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
    
    call RemoveUnit( udg_Summon[ pid + PLAYER_NUM_PAD ] )
    set udg_Summon[pid + PLAYER_NUM_PAD ] = null
endfunction

// ======================================
// Create Summon
// ======================================

private function Create_Summon takes nothing returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
    local real dist = 30
    local real angle = GetUnitFacing( udg_hero[pid + PLAYER_NUM_PAD] )
    local real x = GetUnitX( udg_hero[pid + PLAYER_NUM_PAD] ) + dist * Cos(angle * bj_DEGTORAD)
    local real y = GetUnitY( udg_hero[pid + PLAYER_NUM_PAD] ) + dist * Sin(angle * bj_DEGTORAD)
    local integer item_type = GetItemTypeId(GetManipulatedItem())
    local integer unit_type
    local integer load_item_type
    local integer i
    
    // ==============================
    // 아이템 타입에 따른 유닛 타입
    // ==============================
    
    if item_type == 'I028' then
        set unit_type = 'H00Y'
        
    elseif item_type == 'I00R' then
        set unit_type = 'H010'
        
        
    endif
    
    // ==============================
    
    set udg_Summon[pid + PLAYER_NUM_PAD ] = CreateUnit(Player(pid), unit_type, x, y, 270.0)
    
    // 소환물 로드 처리
    if is_load_summon[pid] == true then
        set is_load_summon[pid] = false
        
        call SetHeroXP( udg_Summon[pid + PLAYER_NUM_PAD], Get_Summon_Data(pid, SUMMON_EXP), false )
        
        set i = -1
        loop
        set i = i + 1
        exitwhen i >= 6
            set load_item_type = Get_Summon_Data( pid, SUMMON_INVEN_0 + i )
            
            if load_item_type != -1 then
                call UnitAddItemToSlotById(udg_Summon[pid + PLAYER_NUM_PAD], load_item_type, i )
            endif
        endloop
    endif
endfunction

// ======================================
// Init
// ======================================

private function Unit_Type_Con takes nothing returns boolean
    return GetUnitTypeId(GetTriggerUnit()) == 'h01J'
endfunction

private function Init takes nothing returns nothing
    local trigger trg
    
    set trg = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( trg, EVENT_PLAYER_UNIT_PICKUP_ITEM )
    call TriggerAddCondition( trg, Condition( function Unit_Type_Con ) )
    call TriggerAddAction( trg, function Create_Summon )
    
    set trg = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( trg, EVENT_PLAYER_UNIT_DROP_ITEM )
    call TriggerAddCondition( trg, Condition( function Unit_Type_Con ) )
    call TriggerAddAction( trg, function Remove_Summon )
    
    set trg = null
endfunction

endlibrary