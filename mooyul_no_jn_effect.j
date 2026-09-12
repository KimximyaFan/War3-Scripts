library Effect

globals
    private hashtable HT = InitHashtable()
endglobals

private function PercentTo255 takes real p returns integer
    return R2I(p * 2.55)
endfunction

private function Timer_Clear takes timer t returns nothing
    call FlushChildHashtable(HT, GetHandleId(t))
    call PauseTimer(t)
    call DestroyTimer(t)
endfunction

private function Dist takes real x, real y, real end_x, real end_y returns real
    return SquareRoot( (end_x - x)*(end_x - x) + (end_y - y)*(end_y - y) )
endfunction

private function Angle takes real x, real y, real end_x, real end_y returns real
    return bj_RADTODEG * Atan2( end_y - y, end_x - x )
endfunction

private function Polar_Y takes real y, real dist, real angle returns real
    return y + dist * Sin(angle * bj_DEGTORAD)
endfunction

private function Polar_X takes real x, real dist, real angle returns real
    return x + dist * Cos(angle * bj_DEGTORAD)
endfunction

private function Effect_Scale_Loop takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local real start_size = LoadReal(HT, id, 3)
    local real end_size = LoadReal(HT, id, 4)
    local real scalingTime = LoadReal(HT, id, 5)
    local real effTime = LoadReal(HT, id, 24)
    local unit dummy = LoadUnitHandle(HT, id, 10)
    local real elapsed = LoadReal(HT, id, 11) + 0.02
    local real cur_size
    
    if elapsed >= effTime or effTime <= 0.0 then
        call SetUnitScale(dummy, end_size / 100.0, end_size / 100.0, end_size / 100.0)
        call UnitApplyTimedLifeBJ(0.01, 'BHwe', dummy)
        call Timer_Clear(t)
    else
        if elapsed < scalingTime and scalingTime > 0.0 then
            set cur_size = start_size + (end_size - start_size) * (elapsed / scalingTime)
            call SetUnitScale(dummy, cur_size / 100.0, cur_size / 100.0, cur_size / 100.0)
        else
            call SetUnitScale(dummy, end_size / 100.0, end_size / 100.0, end_size / 100.0)
        endif
        
        call SaveReal(HT, id, 11, elapsed)
        call TimerStart(t, 0.02, false, function Effect_Scale_Loop)
    endif

    set t = null
    set dummy = null
endfunction

private function Effect_Scale_Init takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local real x = LoadReal(HT, id, 0)
    local real y = LoadReal(HT, id, 1)
    local real height = LoadReal(HT, id, 2)
    local real start_size = LoadReal(HT, id, 3)
    local real effAngle = LoadReal(HT, id, 6)
    local integer effUnitTypeId = LoadInteger(HT, id, 7)
    local real r = LoadReal(HT, id, 20)
    local real g = LoadReal(HT, id, 21)
    local real b = LoadReal(HT, id, 22)
    local real trans = LoadReal(HT, id, 23)
    local unit dummy
    
    set dummy = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), effUnitTypeId, x, y, effAngle)
    call SetUnitScale(dummy, start_size / 100.0, start_size / 100.0, start_size / 100.0)
    call SetUnitVertexColor(dummy, PercentTo255(r), PercentTo255(g), PercentTo255(b), PercentTo255(100.0 - trans))
    call SetUnitX(dummy, x)
    call SetUnitY(dummy, y)
    
    call UnitAddAbility(dummy, 'Amrf')
    call UnitRemoveAbility(dummy, 'Amrf')
    call SetUnitFlyHeight(dummy, height, 0.0)
    
    call SaveUnitHandle(HT, id, 10, dummy)
    call SaveReal(HT, id, 11, 0.0)
    
    call TimerStart(t, 0.02, false, function Effect_Scale_Loop)
    
    set t = null
    set dummy = null
endfunction

private function Effect_Attached_Func takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local unit u = LoadUnitHandle(HT, id, 0)
    local real dist = LoadReal(HT, id, 1)
    local real angle = LoadReal(HT, id, 2)
    local real effSize = LoadReal(HT, id, 3)
    local real effSpeed = LoadReal(HT, id, 4)
    local real effHeight = LoadReal(HT, id, 5)
    local real eff_time = LoadReal(HT, id, 6)
    local real effAngle = LoadReal(HT, id, 7)
    local boolean isFacing = LoadBoolean(HT, id, 8)
    local integer effUnitTypeId = LoadInteger(HT, id, 9)
    local real r = LoadReal(HT, id, 20)
    local real g = LoadReal(HT, id, 21)
    local real b = LoadReal(HT, id, 22)
    local real trans = LoadReal(HT, id, 23)
    
    local real x
    local real y
    local unit dummy
    
    if GetUnitState(u, UNIT_STATE_LIFE) <= 0 then
        call Timer_Clear(t)
        set t = null
        set u = null
        return
    endif
    
    if isFacing == true then
        set angle = GetUnitFacing(u) + angle
        set effAngle = GetUnitFacing(u) + effAngle
    endif
    
    set x = Polar_X(GetUnitX(u), dist, angle)
    set y = Polar_Y(GetUnitY(u), dist, angle)
    
    set dummy = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), effUnitTypeId, x, y, effAngle)
    
    call SetUnitScale(dummy, effSize / 100.0, effSize / 100.0, effSize / 100.0)
    call SetUnitTimeScale(dummy, effSpeed / 100.0)
    call SetUnitVertexColor(dummy, PercentTo255(r), PercentTo255(g), PercentTo255(b), PercentTo255(100.0 - trans))
    
    call SetUnitX(dummy, x)
    call SetUnitY(dummy, y)
    
    call UnitAddAbility(dummy, 'Amrf')
    call UnitRemoveAbility(dummy, 'Amrf')
    call SetUnitFlyHeight(dummy, effHeight, 0.0)
    
    call UnitApplyTimedLifeBJ(eff_time, 'BHwe', dummy)
    
    call Timer_Clear(t)
    
    set t = null
    set u = null
    set dummy = null
endfunction

private function GetEasingProgress takes real t, real ei, real eo returns real
    local real A
    local real vp
    local real p = 0.0
    local real p1
    local real y
    
    if ei + eo > 1.0 then
        set ei = ei / (ei + eo)
        set eo = eo / (ei + eo)
    endif
    
    set A = 1.0 - (ei / 2.0) - (eo / 2.0)
    set vp = 1.0 / A
    
    if ei > 0.0 then
        set p1 = 0.5 * vp * ei
    else
        set p1 = 0.0
    endif

    if t <= ei and ei > 0.0 then
        set p = 0.5 * vp * (t * t) / ei
    elseif t <= 1.0 - eo then
        set p = p1 + vp * (t - ei)
    else
        set y = t - (1.0 - eo)
        if eo > 0.0 then
            set p = p1 + vp * (1.0 - ei - eo) + vp * y - 0.5 * vp * (y * y) / eo
        else
            set p = p1 + vp * (t - ei)
        endif
    endif

    return p
endfunction

private function Effect_Move_Func2 takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local real start_x = LoadReal(HT, id, 0)
    local real start_y = LoadReal(HT, id, 1)
    local real end_x = LoadReal(HT, id, 2)
    local real end_y = LoadReal(HT, id, 3)
    local real ease_in = LoadReal(HT, id, 5)
    local real ease_out = LoadReal(HT, id, 6)
    local real start_height = LoadReal(HT, id, 8)
    local real end_height = LoadReal(HT, id, 11)
    local unit dummy = LoadUnitHandle(HT, id, 14)
    local real elapsed = LoadReal(HT, id, 15) + 0.02
    local real duration = LoadReal(HT, id, 16)
    local real total_dist = LoadReal(HT, id, 17)
    local real angle = LoadReal(HT, id, 18)
    local real progress_time
    local real progress_dist
    local real cur_x
    local real cur_y
    local real cur_height
    
    if elapsed >= duration or duration <= 0.0 then
        call SetUnitX(dummy, end_x)
        call SetUnitY(dummy, end_y)
        call SetUnitFlyHeight(dummy, end_height, 0.0)
        
        call UnitApplyTimedLifeBJ(0.01, 'BHwe', dummy)
        
        call Timer_Clear(t) 
    else
        set progress_time = elapsed / duration
        set progress_dist = GetEasingProgress(progress_time, ease_in, ease_out)
        
        set cur_x = Polar_X(start_x, total_dist * progress_dist, angle)
        set cur_y = Polar_Y(start_y, total_dist * progress_dist, angle)
        set cur_height = start_height + (end_height - start_height) * progress_dist
        
        call SetUnitX(dummy, cur_x)
        call SetUnitY(dummy, cur_y)
        call SetUnitFlyHeight(dummy, cur_height, 0.0)
        call SaveReal(HT, id, 15, elapsed)
        
        call TimerStart(t, 0.02, false, function Effect_Move_Func2)
    endif

    set t = null
    set dummy = null
endfunction

private function Effect_Move_Func takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local real x = LoadReal(HT, id, 0)
    local real y = LoadReal(HT, id, 1)
    local real end_x = LoadReal(HT, id, 2)
    local real end_y = LoadReal(HT, id, 3)
    local real max_speed = LoadReal(HT, id, 4)
    local real ease_in = LoadReal(HT, id, 5)
    local real ease_out = LoadReal(HT, id, 6)
    local real effSize = LoadReal(HT, id, 7)
    local real start_height = LoadReal(HT, id, 8)
    local real effAngle = LoadReal(HT, id, 9)
    local integer effUnitTypeId = LoadInteger(HT, id, 10)
    local real r = LoadReal(HT, id, 20)
    local real g = LoadReal(HT, id, 21)
    local real b = LoadReal(HT, id, 22)
    local real trans = LoadReal(HT, id, 23)
    local unit dummy
    local real total_dist = Dist(x, y, end_x, end_y)
    local real angle = Angle(x, y, end_x, end_y)
    local real duration = 0.0
    
    if max_speed > 0.0 then
        set duration = total_dist / (max_speed * (1.0 - ease_in / 2.0 - ease_out / 2.0))
    endif
    
    set dummy = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), effUnitTypeId, x, y, effAngle)
    call SetUnitScale(dummy, effSize / 100.0, effSize / 100.0, effSize / 100.0)
    call SetUnitVertexColor(dummy, PercentTo255(r), PercentTo255(g), PercentTo255(b), PercentTo255(100.0 - trans))
    
    call UnitAddAbility(dummy, 'Amrf')
    call UnitRemoveAbility(dummy, 'Amrf')
    call SetUnitFlyHeight(dummy, start_height, 0.0)
    
    call SetUnitX(dummy, x)
    call SetUnitY(dummy, y)
    
    call SaveUnitHandle(HT, id, 14, dummy)
    call SaveReal(HT, id, 15, 0.0)
    call SaveReal(HT, id, 16, duration)
    call SaveReal(HT, id, 17, total_dist)
    call SaveReal(HT, id, 18, angle)
    
    call TimerStart(t, 0.02, false, function Effect_Move_Func2)
    
    set t = null
    set dummy = null
endfunction

private function Effect_X_Y_Func takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local unit u = LoadUnitHandle(HT, id, 0)
    local real x = LoadReal(HT, id, 1)
    local real y = LoadReal(HT, id, 2)
    local real effSize = LoadReal(HT, id, 3)
    local real effSpeed = LoadReal(HT, id, 4)
    local real effHeight = LoadReal(HT, id, 5)
    local real eff_time = LoadReal(HT, id, 6)
    local real effAngle = LoadReal(HT, id, 7)
    local integer effUnitTypeId = LoadInteger(HT, id, 9)
    local real r = LoadReal(HT, id, 20)
    local real g = LoadReal(HT, id, 21)
    local real b = LoadReal(HT, id, 22)
    local real trans = LoadReal(HT, id, 23)
    local unit dummy
    
    // u의 플레이어를 참조하여 더미 유닛 생성
    set dummy = CreateUnit(GetOwningPlayer(u), effUnitTypeId, x, y, effAngle)
    
    call SetUnitScale(dummy, effSize / 100.0, effSize / 100.0, effSize / 100.0)
    call SetUnitTimeScale(dummy, effSpeed / 100.0)
    call SetUnitVertexColor(dummy, PercentTo255(r), PercentTo255(g), PercentTo255(b), PercentTo255(100.0 - trans))
    
    call SetUnitX(dummy, x)
    call SetUnitY(dummy, y)
    
    call UnitAddAbility(dummy, 'Amrf')
    call UnitRemoveAbility(dummy, 'Amrf')
    call SetUnitFlyHeight(dummy, effHeight, 0.0)
    
    call UnitApplyTimedLifeBJ(eff_time, 'BHwe', dummy)
    
    call Timer_Clear(t)
    
    set t = null
    set u = null
    set dummy = null
endfunction

// ==============================
// API
// ==============================

function Effect_X_Y takes unit u, real x, real y, real effSize, real effSpeed, real effHeight, real eff_time, real effAngle, integer effUnitTypeId, real r, real g, real b, real trans, real delay returns nothing
    local timer t = CreateTimer()
    local integer id = GetHandleId(t)
    
    call SaveUnitHandle(HT, id, 0, u)
    call SaveReal(HT, id, 1, x)
    call SaveReal(HT, id, 2, y)
    call SaveReal(HT, id, 3, effSize)
    call SaveReal(HT, id, 4, effSpeed)
    call SaveReal(HT, id, 5, effHeight)
    call SaveReal(HT, id, 6, eff_time)
    call SaveReal(HT, id, 7, effAngle)
    call SaveInteger(HT, id, 9, effUnitTypeId)
    call SaveReal(HT, id, 20, r)
    call SaveReal(HT, id, 21, g)
    call SaveReal(HT, id, 22, b)
    call SaveReal(HT, id, 23, trans)
    
    if delay > 0.0 then
        call TimerStart(t, delay, false, function Effect_X_Y_Func)
    else
        call TimerStart(t, 0.0, false, function Effect_X_Y_Func)
    endif
    
    set t = null
endfunction

function Effect_Scale takes real x, real y, real height, real start_size, real end_size, real scalingTime, real effTime, real effAngle, integer effUnitTypeId, real r, real g, real b, real trans, real delay returns nothing
    local timer t = CreateTimer()
    local integer id = GetHandleId(t)
    
    if scalingTime > effTime then
        set scalingTime = effTime
    endif
    
    call SaveReal(HT, id, 0, x)
    call SaveReal(HT, id, 1, y)
    call SaveReal(HT, id, 2, height)
    call SaveReal(HT, id, 3, start_size)
    call SaveReal(HT, id, 4, end_size)
    call SaveReal(HT, id, 5, scalingTime)
    call SaveReal(HT, id, 6, effAngle)
    call SaveInteger(HT, id, 7, effUnitTypeId)
    call SaveReal(HT, id, 20, r)
    call SaveReal(HT, id, 21, g)
    call SaveReal(HT, id, 22, b)
    call SaveReal(HT, id, 23, trans)
    call SaveReal(HT, id, 24, effTime)
    
    if delay > 0.0 then
        call TimerStart(t, delay, false, function Effect_Scale_Init)
    else
        call TimerStart(t, 0.0, false, function Effect_Scale_Init)
    endif
    
    set t = null
endfunction

function Effect_Attached takes unit u, real dist, real angle, real effSize, real effSpeed, real effHeight, real eff_time, real effAngle, boolean isFacing, integer effUnitTypeId, real r, real g, real b, real trans, real delay returns nothing
    local timer t = CreateTimer()
    local integer id = GetHandleId(t)
    
    call SaveUnitHandle(HT, id, 0, u)
    call SaveReal(HT, id, 1, dist)
    call SaveReal(HT, id, 2, angle)
    call SaveReal(HT, id, 3, effSize)
    call SaveReal(HT, id, 4, effSpeed)
    call SaveReal(HT, id, 5, effHeight)
    call SaveReal(HT, id, 6, eff_time)
    call SaveReal(HT, id, 7, effAngle)
    call SaveBoolean(HT, id, 8, isFacing)
    call SaveInteger(HT, id, 9, effUnitTypeId)
    call SaveReal(HT, id, 20, r)
    call SaveReal(HT, id, 21, g)
    call SaveReal(HT, id, 22, b)
    call SaveReal(HT, id, 23, trans)
    
    call TimerStart(t, delay, false, function Effect_Attached_Func)
    
    set t = null
endfunction

function Effect_Move takes real x, real y, real end_x, real end_y, real start_height, real end_height, real max_speed, real ease_in, real ease_out, real effSize, real effAngle, integer effUnitTypeId, real r, real g, real b, real trans, real delay returns nothing
    local timer t = CreateTimer()
    local integer id = GetHandleId(t)
    
    call SaveReal(HT, id, 0, x)
    call SaveReal(HT, id, 1, y)
    call SaveReal(HT, id, 2, end_x)
    call SaveReal(HT, id, 3, end_y)
    call SaveReal(HT, id, 4, max_speed)
    call SaveReal(HT, id, 5, ease_in)
    call SaveReal(HT, id, 6, ease_out)
    call SaveReal(HT, id, 7, effSize)
    call SaveReal(HT, id, 8, start_height)
    call SaveReal(HT, id, 9, effAngle)
    call SaveInteger(HT, id, 10, effUnitTypeId)
    call SaveReal(HT, id, 11, end_height)
    call SaveReal(HT, id, 20, r)
    call SaveReal(HT, id, 21, g)
    call SaveReal(HT, id, 22, b)
    call SaveReal(HT, id, 23, trans)
    
    if delay > 0.0 then
        call TimerStart(t, delay, false, function Effect_Move_Func)
    else
        call TimerStart(t, 0.0, false, function Effect_Move_Func)
    endif
    
    set t = null
endfunction

endlibrary