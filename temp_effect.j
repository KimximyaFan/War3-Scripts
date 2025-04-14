function Stop_Effect_Attached_On_Unit takes integer id returns nothing
    call SaveBoolean(HT, id, 13, true)
endfunction

private function Effect_Attached_On_Unit_Func2 takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local unit u = LoadUnitHandle(HT, id, 0)
    local real dist = LoadReal(HT, id, 1)
    local real angle = LoadReal(HT, id, 2)
    local real pitch = LoadReal(HT, id, 7)
    local real roll = LoadReal(HT, id, 8)
    local real yaw = LoadReal(HT, id, 9)
    local real eff_time = LoadReal(HT, id, 6) - 0.02
    local effect e = LoadEffectHandle(HT, id, 11)
    local boolean is_facing = LoadBoolean(HT, id, 12)
    local boolean is_stop = LoadBoolean(HT, id, 13)
    
    call EXSetEffectXY(e, Polar_X(GetUnitX(u), dist, angle), Polar_Y(GetUnitY(u), dist, angle))
    
    if is_facing == true then
        set angle = GetUnitFacing(u) + angle
        set yaw = angle
    endif
    
    call EXEffectMatReset(e)
    call EXEffectMatRotateY(e, pitch)
    call EXEffectMatRotateX(e, roll)
    call EXEffectMatRotateZ(e, yaw)
    
    if is_stop == true then
        set eff_time = 0.0
    endif
    
    if eff_time <= 0.0 then
        call Timer_Clear(t)
        call DestroyEffect(e)
    else
        call SaveReal(HT, id, 6, eff_time)
        call TimerStart(t, 0.02, false, function Effect_Attached_On_Unit_Func2)
    endif

    set t = null
    set u = null
    set e = null
endfunction

private function Effect_Attached_On_Unit_Func takes nothing returns nothing
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
    local string eff = LoadStr(HT, id, 10)    
    local boolean is_facing = LoadBoolean(HT, id, 12)
    local effect e
    
    if is_facing == true then
        set angle = GetUnitFacing(u) + angle
        set yaw = angle
    endif
    
    set e = AddSpecialEffect(eff, Polar_X(GetUnitX(u), dist, angle), Polar_Y(GetUnitY(u), dist, angle))
    call EXSetEffectSize(e, eff_size/100)
    call EXSetEffectSpeed(e, eff_speed/100)
    call EXEffectMatRotateY(e, pitch)
    call EXEffectMatRotateX(e, roll)
    call EXEffectMatRotateZ(e, yaw)
    call EXSetEffectZ(e, EXGetEffectZ(e) + eff_height)
    
    call SaveEffectHandle(HT, id, 11, e)
    call TimerStart(t, 0.02, false, function Effect_Attached_On_Unit_Func2)
    
    set t = null
    set u = null
    set e = null
endfunction

// 돌진기같은거 만들 때, 찌르기 이펙같은거
// is_facing 이 true면 angle은 add_angle로 작동
// 타이머 핸들 값을 리턴한다, Stop_Effect_Attached_On_Unit() 을 이용해서 중간에 이펙트를 중단 시킬 수 있다
function Effect_Attached_On_Unit takes unit u, real dist, real angle, real eff_size, real eff_speed, real eff_height, real eff_time, real pitch, real roll, real yaw, /*
*/boolean is_facing, string eff, real delay returns integer
    local timer t = CreateTimer()
    local integer id = GetHandleId(t)
    local boolean is_stop = false
    
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
    call SaveStr(HT, id, 10, eff)
    call SaveBoolean(HT, id, 12, is_facing)
    call SaveBoolean(HT, id, 13, is_stop)
    
    call TimerStart(t, delay, false, function Effect_Attached_On_Unit_Func)
    
    set t = null
    return id
endfunction