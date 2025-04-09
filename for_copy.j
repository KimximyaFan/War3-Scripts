function Hero_Pause_Func takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local unit u = LoadUnitHandle(HT, id, 0)
    local real time = LoadReal(HT, id, 1)
    local unit c = CreateUnit( GetOwningPlayer(u), 'h005', GetUnitX(u), GetUnitY(u), 0 )
    
    call UnitAddAbility(c, 'A00F')
    call IssueTargetOrderBJ( c, "magicleash", u )
    call UnitApplyTimedLifeBJ( time, 'BHwe', c )
    
    call Timer_Clear(t)
    
    set t = null
    set u = null
    set c = null
endfunction

function Hero_Pause takes unit u, real time, real delay returns nothing
    local timer t = CreateTimer()
    local integer id = GetHandleId(t)
    
    call SaveUnitHandle(HT, id, 0, u)
    call SaveReal(HT, id, 1, time)
    
    call TimerStart(t, delay, false, function Hero_Pause_Func)
    
    set t = null
endfunction

private function X_Y_Effect_Func takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local real x = LoadReal(HT, id, 0)
    local real y = LoadReal(HT, id, 1)
    //local real angle = LoadReal(HT, id, 2)
    local real eff_size = LoadReal(HT, id, 3)
    local real eff_speed = LoadReal(HT, id, 4)
    local real eff_height = LoadReal(HT, id, 5)
    local real eff_time = LoadReal(HT, id, 6)
    local real pitch = LoadReal(HT, id, 7)
    local real roll = LoadReal(HT, id, 8)
    local real yaw = LoadReal(HT, id, 9)
    local string eff = LoadStr(HT, id, 10)    
    local effect e
    
    set e = AddSpecialEffect(eff, x, y)
    call EXSetEffectSize(e, eff_size/100)
    call EXSetEffectSpeed(e, eff_speed/100)
    call EXEffectMatRotateY(e, pitch)
    call EXEffectMatRotateX(e, roll)
    call EXEffectMatRotateZ(e, yaw)
    call EXSetEffectZ(e, EXGetEffectZ(e) + eff_height)
    
    call Effect_Destroy(e, eff_time)
    call Timer_Clear(t)
    
    set t = null
    set e = null
endfunction
// yaw 가 angle 역할
function X_Y_Effect takes real x, real y, real eff_size, real eff_speed, real eff_height, real eff_time, real pitch, real roll, real yaw, /*
*/ string eff, real delay returns nothing
    local timer t = CreateTimer()
    local integer id = GetHandleId(t)
    
    call SaveReal(HT, id, 0, x)
    call SaveReal(HT, id, 1, y)
    //call SaveReal(HT, id, 2, angle)
    call SaveReal(HT, id, 3, eff_size)
    call SaveReal(HT, id, 4, eff_speed)
    call SaveReal(HT, id, 5, eff_height)
    call SaveReal(HT, id, 6, eff_time)
    call SaveReal(HT, id, 7, pitch)
    call SaveReal(HT, id, 8, roll)
    call SaveReal(HT, id, 9, yaw)
    call SaveStr(HT, id, 10, eff)
    
    call TimerStart(t, delay, false, function X_Y_Effect_Func)
    
    set t = null
endfunction

private function Effect_Attached_Func takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local unit u = LoadUnitHandle(HT, id, 0)
    local real dist = LoadReal(HT, id, 1)
    local real angle = LoadReal(HT, id, 2)
    local real eff_size = LoadReal(HT, id, 3)
    local real eff_speed = LoadReal(HT, id, 4)
    local real eff_height = LoadReal(HT, id, 5)
    local real eff_time = LoadReal(HT, id, 6)
    local real pitch = LoadReal(HT, id, 7)
    local real roll = LoadReal(HT, id, 8)
    local real yaw = LoadReal(HT, id, 9)
    local boolean isFacing = LoadBoolean(HT, id, 10)
    local string eff = LoadStr(HT, id, 11)    
    local real x
    local real y
    local effect e
    
    if GetUnitState(u, UNIT_STATE_LIFE) <= 0 then
        call Timer_Clear(t)
        set t = null
        set u = null
        set e = null
        return
    endif
    
    if isFacing == true then
        set angle = GetUnitFacing(u) + angle
        set yaw = angle
    endif
    
    set x = Polar_X(GetUnitX(u), dist, angle)
    set y = Polar_Y(GetUnitY(u), dist, angle)
    
    set e = AddSpecialEffect(eff, x, y)
    call EXSetEffectSize(e, eff_size/100)
    call EXSetEffectSpeed(e, eff_speed/100)
    call EXEffectMatRotateY(e, pitch)
    call EXEffectMatRotateX(e, roll)
    call EXEffectMatRotateZ(e, yaw)
    call EXSetEffectZ(e, EXGetEffectZ(e) + eff_height)
    
    call Effect_Destroy(e, eff_time)
    call Timer_Clear(t)
    
    set t = null
    set u = null
    set e = null
endfunction
// isFacing이 true라면 angle은 add_angle로써 작동하게된다
function Effect_Attached takes unit u, real dist, real angle, real eff_size, real eff_speed, real eff_height, real eff_time, real pitch, real roll, real yaw, /*
*/ boolean isFacing, string eff, real delay returns nothing
    local timer t = CreateTimer()
    local integer id = GetHandleId(t)
    
    call SaveUnitHandle(HT, id, 0, u)
    call SaveReal(HT, id, 1, dist)
    call SaveReal(HT, id, 2, angle)
    call SaveReal(HT, id, 3, eff_size)
    call SaveReal(HT, id, 4, eff_speed)
    call SaveReal(HT, id, 5, eff_height)
    call SaveReal(HT, id, 6, eff_time)
    call SaveReal(HT, id, 7, pitch)
    call SaveReal(HT, id, 8, roll)
    call SaveReal(HT, id, 9, yaw)
    call SaveBoolean(HT, id, 10, isFacing)
    call SaveStr(HT, id, 11, eff)
    
    call TimerStart(t, delay, false, function Effect_Attached_Func)
    
    set t = null
endfunction

function Sound_Effect_Func takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local real x = LoadReal(HT, id, 0)
    local real y = LoadReal(HT, id, 1)
    local integer skill_id = LoadInteger(HT, id, 2)
    local unit c = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'h005', x, y, 0)
    
    call UnitApplyTimedLifeBJ( 0.20, 'BHwe', c )
    call UnitAddAbilityBJ( skill_id, c )
    call IssueImmediateOrderBJ( c, "thunderclap" )
    
    call Timer_Clear(t)
    
    set t = null
    set c = null
endfunction

function Sound_Effect takes real x, real y, integer skill_id, real delay returns nothing
    local timer t = CreateTimer()
    local integer id = GetHandleId(t)
    
    call SaveReal(HT, id, 0, x)
    call SaveReal(HT, id, 1, y)
    call SaveInteger(HT, id, 2, skill_id)
    
    call TimerStart(t, delay, false, function Sound_Effect_Func)
    
    set t = null
endfunction



private function Counter_Clock_Wise takes real x1, real y1, real x2, real y2, real unit_x, real unit_y returns real
    return (x2-x1)*(unit_y-y2) - (y2-y1)*(unit_x - x2)
endfunction

private function Is_Point_In_Rectangle takes real unit_x, real unit_y, real x1, real y1, real x2, real y2, real x3, real y3, real x4, real y4 returns boolean
    if Counter_Clock_Wise(x1, y1, x2, y2, unit_x, unit_y) < 0.0 then
        return false
    endif
    if Counter_Clock_Wise(x2, y2, x3, y3, unit_x, unit_y) < 0.0 then
        return false
    endif
    if Counter_Clock_Wise(x3, y3, x4, y4, unit_x, unit_y) < 0.0 then
        return false
    endif
    if Counter_Clock_Wise(x4, y4, x1, y1, unit_x, unit_y) < 0.0 then
        return false
    endif
    return true
endfunction

private function Units_In_Rectangle takes unit u, real x, real y, real width, real height, real angle, group g returns group
    local real half_width = width/2
    local real half_height = height/2
    local real radius = SquareRoot( half_width*half_width + half_height*half_height )
    local real center_x = Polar_X(x, half_height, angle)
    local real center_y = Polar_Y(y, half_height, angle)
    local real array point_x
    local real array point_y
    local group temp_group
    local unit c
    
    set point_x[0] = Polar_X(x, half_width, angle-90)
    set point_y[0] = Polar_Y(y, half_width, angle-90)
    
    set point_x[1] = Polar_X(point_x[0], height, angle)
    set point_y[1] = Polar_Y(point_y[0], height, angle)
    
    set point_x[2] = Polar_X(point_x[1], width, angle+90)
    set point_y[2] = Polar_Y(point_y[1], width, angle+90)
    
    set point_x[3] = Polar_X(point_x[2], height, angle+180)
    set point_y[3] = Polar_Y(point_y[2], height, angle+180)
    
    set g = CreateGroup()
    set temp_group = CreateGroup()
    
    call GroupEnumUnitsInRange( temp_group, center_x, center_y, radius, null )
    
    loop
    set c = FirstOfGroup(temp_group) 
    exitwhen c == null
        call GroupRemoveUnit(temp_group, c)
        
        if IsUnitAliveBJ(c) == true and IsPlayerEnemy(GetOwningPlayer(c), GetOwningPlayer(u)) == true then
            if Is_Point_In_Rectangle(GetUnitX(c), GetUnitY(c), point_x[0], point_y[0], point_x[1], point_y[1], point_x[2], point_y[2], point_x[3], point_y[3]) == true then
                call GroupAddUnit(g, c)
            endif
        endif
    endloop
    
    call Group_Clear(temp_group)
    
    set c = null
    set temp_group = null
    
    return g
endfunction

function Get_Enemy_Units_In_Rectangle takes unit u, real x, real y, real width, real height, real angle returns group
    return Units_In_Rectangle(u, x, y, width, height, angle, null) 
endfunction


private function Unit_Area_Dmg_Rectangle_Func takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local unit u = LoadUnitHandle(HT, id, 0)
    local real dmg = LoadReal(HT, id, 1)
    local real dist = LoadReal(HT, id, 2)
    local real angle = LoadReal(HT, id, 3)
    local real width = LoadReal(HT, id, 4)
    local real height = LoadReal(HT, id, 5)
    local boolean dmg_type = LoadBoolean(HT, id, 6)
    local boolean is_add_angle = LoadBoolean(HT, id, 7)
    local real x
    local real y
    local group g = null
    local unit c
    local integer pid = GetPlayerId(GetOwningPlayer(u))

    if GetUnitState(u, UNIT_STATE_LIFE) <= 0 then
        call Group_Clear(g)
        call Timer_Clear(t)
        set t = null
        set u = null
        set g = null
        set c = null
        return
    endif
    
    
    if is_add_angle == true then
        set angle = GetUnitFacing(u) + angle
    endif
    
    set x = Polar_X( GetUnitX(u), dist, angle )
    set y = Polar_Y( GetUnitY(u), dist, angle )
    
    set g = Get_Enemy_Units_In_Rectangle(u, x, y, width, height, angle)
    
    loop
    set c = FirstOfGroup(g) 
    exitwhen c == null
        call GroupRemoveUnit(g, c)
        call Unit_Dmg_Target( u, c, dmg, dmg_type)
    endloop
    
    call Group_Clear(g)
    call Timer_Clear(t)
    
    set t = null
    set u = null
    set g = null
    set c = null
endfunction

// is_add_angle == true 이면 angle 은 add angle 로 작동
function Unit_Area_Dmg_Rectangle takes unit u, real dmg, real dist, real angle, real width, real height, boolean dmg_type, boolean is_add_angle, real delay returns nothing
    local timer t = CreateTimer()
    local integer id = GetHandleId(t)
    
    call SaveUnitHandle(HT, id, 0, u)
    call SaveReal(HT, id, 1, dmg)
    call SaveReal(HT, id, 2, dist)
    call SaveReal(HT, id, 3, angle)
    call SaveReal(HT, id, 4, width)
    call SaveReal(HT, id, 5, height)
    call SaveBoolean(HT, id, 6, dmg_type)
    call SaveBoolean(HT, id, 7, is_add_angle)
    
    call TimerStart(t, delay, false, function Unit_Area_Dmg_Rectangle_Func)
    
    set t = null
endfunction

function X_Y_Dmg_Func takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local unit u = LoadUnitHandle(HT, id, 0)
    local real dmg = LoadReal(HT, id, 1)
    local real x = LoadReal(HT, id, 2)
    local real y = LoadReal(HT, id, 3)
    local real size = LoadReal(HT, id, 4)
    local boolean dmg_type = LoadBoolean(HT, id, 5)
    local group g = CreateGroup()
    local unit c
    
    call GroupEnumUnitsInRange( g, x, y, size, null )
    
    loop
    set c = FirstOfGroup(g) 
    exitwhen c == null
        call GroupRemoveUnit(g, c)
        
        if IsUnitAliveBJ(c) == true and IsPlayerEnemy(GetOwningPlayer(c), GetOwningPlayer(u)) == true then
            call Unit_Dmg_Target( u, c, dmg, dmg_type)
        endif
    endloop
    
    call Group_Clear(g)
    call Timer_Clear(t)
    
    set t = null
    set u = null
    set g = null
    set c = null
endfunction

function X_Y_Dmg takes unit u, real dmg, real x, real y,  real size, boolean dmg_type, real delay returns nothing
    local timer t = CreateTimer()
    local integer id = GetHandleId(t)
    
    call SaveUnitHandle(HT, id, 0, u)
    call SaveReal(HT, id, 1, dmg)
    call SaveReal(HT, id, 2, x)
    call SaveReal(HT, id, 3, y)
    call SaveReal(HT, id, 4, size)
    call SaveBoolean(HT, id, 5, dmg_type)
    
    call TimerStart(t, delay, false, function X_Y_Dmg_Func)
    
    set t = null
endfunction

private function Unit_Area_Dmg_Func takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local unit u = LoadUnitHandle(HT, id, 0)
    local real dmg = LoadReal(HT, id, 1)
    local real dist = LoadReal(HT, id, 2)
    local real angle = LoadReal(HT, id, 3)
    local real size = LoadReal(HT, id, 4)
    local boolean dmg_type = LoadBoolean(HT, id, 5)
    local boolean is_facing = LoadBoolean(HT, id, 6)
    local real x
    local real y
    local group g = CreateGroup()
    local unit c
    local integer pid = GetPlayerId(GetOwningPlayer(u))

    if GetUnitState(u, UNIT_STATE_LIFE) <= 0 then
        call Group_Clear(g)
        call Timer_Clear(t)
        set t = null
        set u = null
        set g = null
        set c = null
        return
    endif
    
    if is_facing == true then
        set angle = GetUnitFacing(u) + angle
    endif
    
    set x = Polar_X( GetUnitX(u), dist, angle )
    set y = Polar_Y( GetUnitY(u), dist, angle )
    
    call GroupEnumUnitsInRange( g, x, y, size, null )
    
    loop
    set c = FirstOfGroup(g) 
    exitwhen c == null
        call GroupRemoveUnit(g, c)
        
        if IsUnitAliveBJ(c) == true and IsPlayerEnemy(GetOwningPlayer(c), GetOwningPlayer(u)) == true then
            call Unit_Dmg_Target( u, c, dmg, dmg_type)
        endif
    endloop
    
    call Group_Clear(g)
    call Timer_Clear(t)
    
    set t = null
    set u = null
    set g = null
    set c = null
endfunction

// is_facing == true 이면 angle 은 add angle 로 작동
function Unit_Area_Dmg takes unit u, real dmg, real dist, real angle, real size, boolean dmg_type, boolean is_facing, real delay returns nothing
    local timer t = CreateTimer()
    local integer id = GetHandleId(t)
    
    call SaveUnitHandle(HT, id, 0, u)
    call SaveReal(HT, id, 1, dmg)
    call SaveReal(HT, id, 2, dist)
    call SaveReal(HT, id, 3, angle)
    call SaveReal(HT, id, 4, size)
    call SaveBoolean(HT, id, 5, dmg_type)
    call SaveBoolean(HT, id, 6, is_facing)
    
    call TimerStart(t, delay, false, function Unit_Area_Dmg_Func)
    
    set t = null
endfunction

function Unit_Motion_Func takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local unit u = LoadUnitHandle(HT, id, 0)
    local integer motion = LoadInteger(HT, id, 1)
    local real ani_speed = LoadReal(HT, id, 2)
    
    call SetUnitAnimationByIndex( u, motion )
    call SetUnitTimeScalePercent( u, ani_speed )
    
    call Timer_Clear(t)
    
    set t = null
    set u = null
endfunction

function Unit_Motion takes unit u, integer motion, real ani_speed, real delay returns nothing
    local timer t = CreateTimer()
    local integer id = GetHandleId(t)
    
    call SaveUnitHandle(HT, id, 0, u)
    call SaveInteger(HT, id, 1, motion)
    call SaveReal(HT, id, 2, ani_speed)
    
    call TimerStart(t, delay, false, function Unit_Motion_Func)
    
    set t = null
endfunction











private function Q_Act takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local integer pid = GetPlayerId( GetOwningPlayer(u) )
    local boolean dmg_type = AD_TYPE
    local real base_dmg = Q_BASE_DMG
    local real coef = 1.25
    local real dmg = Get_Unit_Dmg(u, base_dmg, coef, dmg_type)
    local real as = Get_Unit_Property(u, AS) / 2
    local real delay = 0.25 * ( 100 / (100 + as) )
    local real ani_speed = 130 * ( (100 + as) / 100 )
    local real pause_time = 0.3 * ( 100 / (100 + as) )
    local real cool_time = 1.0 * ( 100 / (100 + as) )
    local real dist = 175
    local real size = 175
    local real angle = Closest_Angle(u, 400)
    local string eff = "A_0001.mdx"
    local integer skill_id = GetSpellAbilityId()
    
    call SetUnitFacing(u, angle)
    call Hero_Pause(u, pause_time, 0.01)
    call Unit_Motion(u, 5, ani_speed, 0.01)
    call Effect_Attached(u, dist, angle, 70, 100, 0, 0, 0, 0, angle, false, eff, delay)
    call Unit_Area_Dmg(u, dmg, dist, angle, size, dmg_type, false, delay)
    
    call Cooldown_Reset(u, skill_id, cool_time)
    
    set u = null
endfunction

private function Q_Con takes nothing returns boolean
    return GetSpellAbilityId() == 'A00C'
endfunction

function Foot_Man_Skills_Init takes nothing returns nothing
    local trigger trg

    set trg = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( trg , EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( trg, Condition( function Q_Con ) )
    call TriggerAddAction( trg, function Q_Act )

    set trg = null
endfunction