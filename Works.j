scope PassiveCooldownSkill initializer Init

globals
    private real passive_skill_cooldown = 1.5
endglobals

// ====================================================================
// Passive Skill Work
// ====================================================================

private function Passive_Cooldown_Skill takes nothing returns nothing
    local unit u = GetAttacker()
    local unit target = GetTriggerUnit()
    local real dmg = 100
    local real time = 1.0
    local real radius = 600
    local integer count = 8
    local string eff
    
    if JNGetUnitAbilityCooldownRemaining(u, 'A000') != 0.0 then
        set u = null
        return
    endif
    
    set eff = "Void Spear.mdx"
    
    call EXSetAbilityState(EXGetUnitAbility(u, 'A000'), ABILITY_STATE_COOLDOWN, passive_skill_cooldown)
    
    call Guided_Projectile(u, target, GetUnitX(target), GetUnitY(target), dmg, time, radius, GetRandomDirectionDeg(), count, eff, 100, 50, false, eff, 0.0)
    call Guided_Projectile(u, target, GetUnitX(target), GetUnitY(target), dmg, time, radius, GetRandomDirectionDeg(), count, eff, 100, 50, false, eff, 1.0)
    call Guided_Projectile(u, target, GetUnitX(target), GetUnitY(target), dmg, time, radius, GetRandomDirectionDeg(), count, eff, 100, 50, false, eff, 2.0)
    
    set u = null
endfunction

private function Unit_Type_Condition takes nothing returns boolean
    return GetUnitTypeId(GetAttacker()) == 'h000'
endfunction

// ====================================================================
// Exception
// ====================================================================

private function Reset_Cooldown_If_Clicked takes nothing returns nothing
    call UnitRemoveAbility( GetTriggerUnit(), 'A000' )
    call UnitAddAbility( GetTriggerUnit(), 'A000' )
endfunction

private function Skill_Condition takes nothing returns boolean
    return GetSpellAbilityId() == 'A000'
endfunction

// ====================================================================
// Trigger Init
// ====================================================================

private function Init takes nothing returns nothing
    local trigger trg
    
    // 패시브 스킬인데, 유저가 스킬 눌렀을 때의 처리
    set trg = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( trg, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( trg, Condition( function Skill_Condition ) )
    call TriggerAddAction( trg, function Reset_Cooldown_If_Clicked )
    
    // 패시브 스킬 평타 작동
    set trg = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( trg, EVENT_PLAYER_UNIT_ATTACKED )
    call TriggerAddCondition( trg, Condition( function Unit_Type_Condition ) )
    call TriggerAddAction( trg, function Passive_Cooldown_Skill )
    
    set trg = null
endfunction
    
    
endscope