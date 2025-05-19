/*
================================================================================
    Damage Engine Defensive (DED) 20240606
--------------------------------------------------------------------------------
    [버전]
        2024-06-06
            1. GroupEnumUnitsInRect 함수로 잡아낼 수 없는 유닛들이 갱신 과정에서 누락되는 문제 해결
            2. 의존성 최소화
            3. non-structual API 제공
--------------------------------------------------------------------------------
    [안내]
        극도로 방어적인 데미지 엔진입니다.
        외부 개입을 원천 차단하기 위해 
        내부 기능을 절대 공개하지 않고,
        모든 유닛을 자동으로 등록하며,
        중복 등록 방지를 위해 능력 보유 여부를 체크한다는 점이 특징입니다.
--------------------------------------------------------------------------------
    [문제해결]
        Q : 모든 유닛에게 이상한 이펙트 효과가 생겼어요!
        A : 중복 등록 방지를 위해 'Asph'(휴먼-스피어) 능력을 부여하기 때문입니다.

        Q2 : 그럼 어떻게 해야 하나요?
        A2 : 눈에 보이지 않는 더미 능력을 하나 만들고, 그 능력의 코드값(Ctrl+D)을 'Asph' 대신 넣어주세요.

        Q3 : 어디에 넣나요?
        A3 : 31번 줄의 DAMAGE_TYPE_DETECTOR = 'Asph' 입니다.
*/
library DamageEngineDefensive initializer OnMapLoad
    /*
    ================================================================================
        사용자 설정
    --------------------------------------------------------------------------------
            맵 제작자가 커스텀 가능한 설정들입니다.
    */
    globals
        /*중복 등록 방지를 위한 기능으로, 휴먼 - '스피어' 같은 능력 기반의 커스텀 능력*/
        private constant integer DAMAGE_TYPE_DETECTOR = 'Asph'
        /*트리거 새로고침 간격(초)*/
        private constant real TRIGGER_REFRESH_PERIOD = 60.0
    endglobals
    /*
    ================================================================================
        부가 이벤트 격발 로직
    --------------------------------------------------------------------------------
            데미지 받음 시스템의 핵심 로직입니다.
    */
    globals
        private hashtable ET = InitHashtable()
        private trigger EAA = CreateTrigger()
        private trigger EAH = CreateTrigger()
        private constant integer EUTA = 10
        private constant integer EUTH = 11
        private constant integer EITA = 10
        private constant integer EITH = 11
        private item PT = null
    endglobals

    private function trigger_action takes unit src, unit dst returns nothing
        local integer i
        local item pt
        
        call TriggerEvaluate(EAA)
        
        call TriggerEvaluate(LoadTriggerHandle(ET, EUTA, GetUnitTypeId(src) ))
        
        if IsUnitType(src,UNIT_TYPE_HERO) then
            set pt = PT
            set i = UnitInventorySize(src)
            loop
                exitwhen i == 0
                set i = i - 1
                set PT = UnitItemInSlot(src,i)
                call TriggerEvaluate(LoadTriggerHandle(ET, EITA, GetItemTypeId(PT) ))
            endloop
            set PT = pt
            set pt = null
        endif
        
        if IsUnitType(dst,UNIT_TYPE_HERO) then
            set pt = PT
            set i = UnitInventorySize(dst)
            loop
                exitwhen i == 0
                set i = i - 1
                set PT = UnitItemInSlot(dst,i)
                call TriggerEvaluate(LoadTriggerHandle(ET, EITH, GetItemTypeId(PT) ))
            endloop
            set PT = pt
            set pt = null
        endif
        
        call TriggerEvaluate(LoadTriggerHandle(ET, EUTH, GetUnitTypeId(dst) ))
        
        call TriggerEvaluate(EAH)
    endfunction

    private function trigger_condition takes nothing returns boolean
        if GetEventDamage() != 0 then
            call trigger_action(GetEventDamageSource(),GetTriggerUnit())
        endif
        return false
    endfunction
    /*
    ================================================================================
        내부 동작
    --------------------------------------------------------------------------------
            데미지 받음 트리거의 내부 동작입니다.
    */
    globals
        private trigger de_trigger = null
        private boolexpr de_trigger_filter = null

        private boolexpr de_register_filter = null

        private group de_temp_group = CreateGroup()
    endglobals

    private function trigger_get_condition takes nothing returns boolexpr
        if de_trigger_filter == null then
            set de_trigger_filter = Condition(function trigger_condition)
        endif
        return de_trigger_filter
    endfunction

    private function trigger_init takes nothing returns nothing
        set de_trigger = CreateTrigger()
        call TriggerAddCondition(de_trigger,trigger_get_condition())
    endfunction

    private function trigger_destroy takes nothing returns nothing
        call ResetTrigger(de_trigger)
        call DestroyTrigger(de_trigger)
        set de_trigger = null
    endfunction

    private function trigger_refresh takes nothing returns nothing
        call trigger_destroy()
        call trigger_init()
    endfunction

    private function register_filter takes nothing returns boolean
        if GetUnitTypeId(GetFilterUnit()) != 0 then
            call UnitAddAbility(GetFilterUnit(),DAMAGE_TYPE_DETECTOR)
            call TriggerRegisterUnitEvent(de_trigger, GetFilterUnit(), EVENT_UNIT_DAMAGED)
        endif
        return false
    endfunction

    private function register_get_filter takes nothing returns boolexpr
        if de_register_filter == null then
            set de_register_filter = Condition( function register_filter )
        endif
        return de_register_filter
    endfunction

    private function register_all_units takes nothing returns nothing
        local integer i = 0
        loop
            exitwhen i >= bj_MAX_PLAYER_SLOTS
            call GroupEnumUnitsOfPlayer( de_temp_group, Player(i), register_get_filter() )
            set i = i + 1
        endloop
        call GroupClear( de_temp_group )
    endfunction
    /*
    ================================================================================
        뎀받 트리거의 새로고침
    --------------------------------------------------------------------------------
            데미지 받음 트리거를 새로 고침합니다.
    */
    private function refresh_action takes nothing returns nothing
        call trigger_refresh()
        call register_all_units()
    endfunction

    private function refresh_init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction( t, function refresh_action )
        call TriggerRegisterTimerEvent( t, TRIGGER_REFRESH_PERIOD, true )
        set t = null
    endfunction
    /*
    ================================================================================
        뎀받 트리거의 자동 등록
    --------------------------------------------------------------------------------
            유닛을 자동 등록합니다.
    */
    private function autoadd_action takes nothing returns nothing
        local unit u = GetEnteringUnit()
        if GetUnitAbilityLevel( u, DAMAGE_TYPE_DETECTOR ) < 1 then
            call UnitAddAbility( u, DAMAGE_TYPE_DETECTOR )
            call TriggerRegisterUnitEvent( de_trigger, u, EVENT_UNIT_DAMAGED )
        endif
        set u = null
    endfunction

    private function autoadd_init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction( t, function autoadd_action )
        call TriggerRegisterEnterRectSimple( t, GetWorldBounds() )
        set t = null
    endfunction
    
    private function OnMapLoad takes nothing returns nothing
        call trigger_init()
        call register_all_units()
        
        call autoadd_init()
        call refresh_init()
    endfunction
    /*
    ================================================================================
        API
    --------------------------------------------------------------------------------
            외부로 제공하는 기능입니다.
    */
    function DERegisterAnyUnitAttackEvent takes code trigAction returns triggercondition
        return TriggerAddCondition(EAA,Condition(trigAction))
    endfunction

    function DERegisterUnitTypeAttackEvent takes integer typeId, code trigAction returns triggercondition
        if not HaveSavedHandle(ET,EUTA,typeId) then
            call SaveTriggerHandle(ET,EUTA,typeId,CreateTrigger())
        endif
        return TriggerAddCondition(LoadTriggerHandle(ET,EUTA,typeId),Condition(trigAction))
    endfunction

    function DERegisterAnyUnitHitEvent takes code trigAction returns triggercondition
        return TriggerAddCondition(EAH,Condition(trigAction))
    endfunction

    function DERegisterUnitTypeHitEvent takes integer typeId, code trigAction returns triggercondition
        if not HaveSavedHandle(ET,EUTH,typeId) then
            call SaveTriggerHandle(ET,EUTH,typeId,CreateTrigger())
        endif
        return TriggerAddCondition(LoadTriggerHandle(ET,EUTH,typeId),Condition(trigAction))
    endfunction
    
    function DEGetEventItem takes nothing returns item
        return PT
    endfunction

    function DERegisterItemTypeAttackEvent takes integer typeId, code trigAction returns triggercondition
        if not HaveSavedHandle(ET,EITA,typeId) then
            call SaveTriggerHandle(ET,EITA,typeId,CreateTrigger())
        endif
        return TriggerAddCondition(LoadTriggerHandle(ET,EITA,typeId),Condition(trigAction))
    endfunction

    function DERegisterItemTypeHitEvent takes integer typeId, code trigAction returns triggercondition
        if not HaveSavedHandle(ET,EITH,typeId) then
            call SaveTriggerHandle(ET,EITH,typeId,CreateTrigger())
        endif
        return TriggerAddCondition(LoadTriggerHandle(ET,EITH,typeId),Condition(trigAction))
    endfunction

    struct DamageEngine extends array
        //---------------------------------------------------------
        static method RegisterAnyUnitAttackEvent /*
            */ takes code trigAction /*
            */ returns triggercondition
            return TriggerAddCondition(EAA,Condition(trigAction))
        endmethod
        static method RegisterUnitTypeAttackEvent /*
            */ takes integer typeId, code trigAction /*
            */ returns triggercondition
            if not HaveSavedHandle(ET,EUTA,typeId) then
                call SaveTriggerHandle(ET,EUTA,typeId,CreateTrigger())
            endif
            return TriggerAddCondition(LoadTriggerHandle(ET,EUTA,typeId) /*
                */ , Condition(trigAction))
        endmethod
        //---------------------------------------------------------
        static method RegisterAnyUnitHitEvent /*
            */ takes code trigAction /*
            */ returns triggercondition
            return TriggerAddCondition(EAH,Condition(trigAction))
        endmethod
        static method RegisterUnitTypeHitEvent /*
            */ takes integer typeId, code trigAction /*
            */ returns triggercondition
            if not HaveSavedHandle(ET,EUTH,typeId) then
                call SaveTriggerHandle(ET,EUTH,typeId,CreateTrigger())
            endif
            return TriggerAddCondition(LoadTriggerHandle(ET,EUTH,typeId) /*
                */ , Condition(trigAction))
        endmethod
        //---------------------------------------------------------
        static method GetEventItem takes nothing returns item
            return PT
        endmethod
        //---------------------------------------------------------
        //static method RegisterAnyItemAttackEvent /*
        //    */ takes code trigAction /*
        //    */ returns triggercondition
        //   return TriggerAddCondition(EAA,Condition(trigAction))
        //endmethod
        static method RegisterItemTypeAttackEvent /*
            */ takes integer typeId, code trigAction /*
            */ returns triggercondition
            if not HaveSavedHandle(ET,EITA,typeId) then
                call SaveTriggerHandle(ET,EITA,typeId,CreateTrigger())
            endif
            return TriggerAddCondition(LoadTriggerHandle(ET,EITA,typeId) /*
                */ , Condition(trigAction))
        endmethod
        //---------------------------------------------------------
        //static method RegisterAnyItemHitEvent /*
        //    */ takes code trigAction /*
        //    */ returns triggercondition
        //    return TriggerAddCondition(EAH,Condition(trigAction))
        //endmethod
        static method RegisterItemTypeHitEvent /*
            */ takes integer typeId, code trigAction /*
            */ returns triggercondition
            if not HaveSavedHandle(ET,EITH,typeId) then
                call SaveTriggerHandle(ET,EITH,typeId,CreateTrigger())
            endif
            return TriggerAddCondition(LoadTriggerHandle(ET,EITH,typeId) /*
                */ , Condition(trigAction))
        endmethod
        //---------------------------------------------------------
    endstruct
endlibrary