scope Settings initializer Init

    private function Setting takes nothing returns nothing
        local unit u = GetTriggerUnit()
        local trigger trg = GetTriggeringTrigger()
        
        call Set_Passive_Skill(GetTriggerUnit(), SKILL_1_SET)
        
        
        call Set_Passive_Skill(u, SKILL_2_SET)
        
        call UnitAddAbility(u, 'A066')
        call UnitAddAbility(u, 'A067')
        
        /*
        call TriggerClearConditions(trg)
        call TriggerClearActions(trg)
        call DestroyTrigger(trg)
        */
        
        
        set trg = null
        set u = null
    endfunction
    
    private function Init takes nothing returns nothing
        local trigger trg
        
        set trg = CreateTrigger(  )
        call TriggerRegisterPlayerSelectionEventBJ( trg, Player(0), true )
        call TriggerAddAction( trg, function Setting )
        
        set trg = null
    endfunction
    
    endscope