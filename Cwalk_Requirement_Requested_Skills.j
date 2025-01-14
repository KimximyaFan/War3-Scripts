library RequestedSkill1 initializer Init requires Basic

    globals
        hashtable HT = InitHashtable()
        integer DAMAGE_STACK_TIME = 3
        integer DAMAGE_STACK = 2
        integer SKILL_1_SET = 1
        integer SKILL_2_SET = 4
        integer SKILL_2_EFFECT = 5
        integer IN_COMBAT = 6
        
        private integer skill_1_id = 'A066'
        private integer skill_2_id = 'A067'
        private real skill_1_cooldown = 20.0
        private real skill_2_duration = 10.0
        
        private string skill_2_eff_string = "A_0001.mdx"
    endglobals
    
    // ====================================================================
    // Skill 2
    // ====================================================================
    
    private function Skill_2_Set_Buff takes unit u, integer stack_count, integer before_stack returns nothing
        local integer pid = GetPlayerId(GetOwningPlayer(u))
        local effect eff = LoadEffectHandle(HT, GetHandleId(u), SKILL_2_EFFECT)
        
        call SaveInteger(HT, GetHandleId(u), DAMAGE_STACK, stack_count)
        call Text_Tag(GetUnitX(u) + 50, GetUnitY(u), 255, 180, 180, 10.0, 50, 50, 90, 230, 0.9, 0.9, "Stack " + I2S(stack_count), null, -1, 0.0)
        set udg__ds_dmg_buff[pid+1] = udg__ds_dmg_buff[pid+1] + 0.01 * (stack_count - before_stack)
        
        if stack_count == 5 and before_stack == 4 then
            call SaveEffectHandle(HT, GetHandleId(u), SKILL_2_EFFECT, AddSpecialEffectTarget(skill_2_eff_string, u, "chest"))
        elseif stack_count < 5 and eff != null then
            call DestroyEffect(eff)
            call SaveEffectHandle(HT, GetHandleId(u), SKILL_2_EFFECT, null)
        endif
        
        set eff = null
    endfunction
    
    private function Skill_2_Func takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local integer id = GetHandleId(t)
        local unit u = LoadUnitHandle(HT, id, 0)
        local integer count = LoadInteger(HT, id, 1)
        local integer = unit_handle_id = GetHandleId(u)
        local integer stack_count = LoadInteger(HT, unit_handle_id, DAMAGE_STACK)
        local integer before_stack = stack_count
        local real remain_time = LoadReal(HT, unit_handle_id, DAMAGE_STACK_TIME)
        local integer in_combat_flag = LoadInteger(HT, unit_handle_id, IN_COMBAT)
        
        if count != 0 then
            set remain_time = remain_time - 1.0
            call SaveReal(HT, unit_handle_id, DAMAGE_STACK_TIME, remain_time)
        endif
        
        if ModuloInteger(count, 3) == 0 and in_combat_flag > 0 then
            if stack_count < 5 then
                set stack_count = stack_count + 1
            endif
            call Skill_2_Set_Buff(u, stack_count, before_stack)
        endif
        
        set count = count + 1
        
        if remain_time <= 0.0 then
            call Timer_Clear(t)
            call Skill_2_Set_Buff(u, 0, stack_count)
        else
            call SaveInteger(HT, id, 1, count)
            call TimerStart(t, 1.0, false, function Skill_2_Func)
        endif
        
        set t = null
        set u = null
    endfunction
    
    private function Skill_2 takes unit u returns nothing
        local timer t = null
        local integer unit_handle_id = GetHandleId(u)
        local integer stack_count = LoadInteger(HT, unit_handle_id, DAMAGE_STACK)
        
        if LoadInteger(HT, GetHandleId(u), SKILL_2_SET) != 1 then
            return
        endif
        
        call SaveReal(HT, unit_handle_id, DAMAGE_STACK_TIME, skill_2_duration)
        call EXSetAbilityState(EXGetUnitAbility(u, skill_2_id), ABILITY_STATE_COOLDOWN, skill_2_duration)
        
        if stack_count > 0 then
            return
        endif
        
        set t = CreateTimer()
        call SaveUnitHandle(HT, GetHandleId(t), 0, u)
        call SaveInteger(HT, GetHandleId(t), 1, 0)
        call TimerStart(t, 0.0, false, function Skill_2_Func)
    
        set t = null
    endfunction
    
    // ====================================================================
    // Skill 1
    // ====================================================================
    
    private function Skill_1 takes unit u returns nothing
        local integer unit_handle_id = GetHandleId(u)
        local real dmg = GetEventDamage()
        local integer id
        local boolean is_passive_possible = false
        local string eff = "Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl"
        
        if JNGetUnitAbilityCooldownRemaining(u, skill_1_id) <= 0.0 then
            set is_passive_possible = true
        endif
        
        if LoadInteger(HT, GetHandleId(u), SKILL_1_SET) != 1 then
            return
        endif
        
        call EXSetAbilityState(EXGetUnitAbility(u, skill_1_id), ABILITY_STATE_COOLDOWN, skill_1_cooldown)
        
        if is_passive_possible == false then
            return
        endif
        
        call DestroyEffect( AddSpecialEffect(eff, GetUnitX(u), GetUnitY(u)) )
        call SetUnitLifeBJ( u, GetUnitStateSwap(UNIT_STATE_LIFE, u) + dmg * 0.9 )
        call Text_Tag(GetUnitX(u) + 50, GetUnitY(u), 170, 255, 170, 10.0, 50, 50, 90, 230, 0.9, 0.9, "Heal +" + I2S(R2I(dmg * 0.9 + 0.001)), null, -1, 0.0)
    endfunction
    
    private function Unit_Type_Condition takes nothing returns boolean
        return GetUnitTypeId(GetTriggerUnit()) == 'H00A' or GetUnitTypeId(GetEventDamageSource()) == 'H00A'
    endfunction
    
    // ====================================================================
    // Preprocess
    // ====================================================================
    
    private function In_Combat_Func takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local integer id = GetHandleId(t)
        local unit u = LoadUnitHandle(HT, id, 0)
        
        call SaveInteger(HT, GetHandleId(u), IN_COMBAT, LoadInteger(HT, GetHandleId(u), IN_COMBAT) - 1)
        
        call Timer_Clear(t)
        
        set t = null
        set u = null
    endfunction
    
    private function In_Combat takes unit u returns nothing
        local timer t = CreateTimer()
        local integer id = GetHandleId(t)
        
        call SaveInteger(HT, GetHandleId(u), IN_COMBAT, LoadInteger(HT, GetHandleId(u), IN_COMBAT) + 1)
        
        call SaveUnitHandle(HT, id, 0, u)
        call TimerStart(t, 1.0, false, function In_Combat_Func)
        
        set t = null
    endfunction
    
    private function Damage_Attacked_Process takes nothing returns nothing
        local unit attacked = GetTriggerUnit()
        local unit attacker = GetEventDamageSource()
        local real dmg = GetEventDamage()
        
        if dmg <= 1 then
            set attacked = null
            set attacker = null
            return
        endif
        
        if GetUnitTypeId(attacked) == 'H00A' then
            call Skill_1(attacked)
            call Skill_2(attacked)
            call In_Combat(attacked)
        else
            call Skill_2(attacker)
            call In_Combat(attacker)
        endif
        
        set attacked = null
        set attacker = null
    endfunction
    
    function Set_Passive_Skill takes unit u, integer constant_value returns nothing
        call SaveInteger(HT, GetHandleId(u), constant_value, 1)
    endfunction
    
    // ====================================================================
    // Exception
    // ====================================================================
    
    private function Reset_Cooldown_If_Clicked takes nothing returns nothing
        local integer skill_id = GetSpellAbilityId()
        
        call UnitRemoveAbility( GetTriggerUnit(), skill_id )
        call UnitAddAbility( GetTriggerUnit(), skill_id )
    endfunction
    
    private function Skill_1_Condition takes nothing returns boolean
        return GetSpellAbilityId() == skill_1_id or GetSpellAbilityId() == skill_2_id
    endfunction
    
    // ====================================================================
    // Trigger Init
    // ====================================================================
    
    private function Init takes nothing returns nothing
        local trigger trg
        
        // 패시브 스킬인데, 유저가 스킬 눌렀을 때의 처리
        set trg = CreateTrigger(  )
        call TriggerRegisterAnyUnitEventBJ( trg, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddCondition( trg, Condition( function Skill_1_Condition ) )
        call TriggerAddAction( trg, function Reset_Cooldown_If_Clicked )
        
        // 뎀받 트리거
        set trg = CreateTrigger(  )
        call TriggerRegisterAnyUnitEventBJBJ( trg, EVENT_PLAYER_UNIT_DAMAGED )
        call TriggerAddCondition( trg, Condition( function Unit_Type_Condition ) )
        call TriggerAddAction( trg, function Damage_Attacked_Process )
        
        set trg = null
    endfunction
    
    endlibrary