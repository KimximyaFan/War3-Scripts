library Basic

    function Timer_Clear takes timer t returns nothing
        call FlushChildHashtable(HT, GetHandleId(t))
        call PauseTimer(t)
        call DestroyTimer(t)
    endfunction
    
    private function Text_Tag_Func takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local integer id = GetHandleId(t)
        local real x = LoadReal(HT, id, 0)
        local real y = LoadReal(HT, id, 1)
        local real size = LoadReal(HT, id, 2)
        local real height = LoadReal(HT, id, 3)
        local real speed = LoadReal(HT, id, 4)
        local real angle = LoadReal(HT, id, 5)
        local integer alpha = LoadInteger(HT, id, 6)
        local real fade_time = LoadReal(HT, id, 7)
        local real life_time = LoadReal(HT, id, 8)
        local string s = LoadStr(HT, id, 9)
        local texttag tt = LoadTextTagHandle(HT, id, 10)
        local integer r = LoadInteger(HT, id, 11)
        local integer g = LoadInteger(HT, id, 12)
        local integer b = LoadInteger(HT, id, 13)
        local integer pid = LoadInteger(HT, id, 14)
        
        
        call SetTextTagText(tt, s, TextTagSize2Height(size))
        call SetTextTagPos(tt, x, y, height)
        call SetTextTagVelocityBJ(tt, speed, angle)
        call SetTextTagColor(tt, r, g, b, alpha)
        
        if fade_time < 0 or life_time < 0 then
            call SetTextTagPermanent(tt, true)
        else
            call SetTextTagFadepoint(tt, fade_time)
            call SetTextTagLifespan(tt, life_time)
            call SetTextTagPermanent(tt, false)
        endif
        
        if pid >= 0 then
            call SetTextTagVisibility(tt, false)
            
            if GetLocalPlayer() == Player(pid) then
                call SetTextTagVisibility(tt, true)
            endif
        endif
        
        call Timer_Clear(t)
        
        set t = null
        set tt = null
    endfunction
    
    
    // rgb, 기본 255 255 255 기입
    // alpha 0 = 안보임
    // life_time = -1 or fade_time = -1   ->  영구
    // texttag tt 는 null 기입
    // pid 값 -1이 default
    // pid 값에 0 이상의 값이 들어가면 각플로만 보임 
    function Text_Tag takes real x, real y, integer r, integer g, integer b, real size, real height, real speed, real angle, /*
    */ integer alpha, real fade_time, real life_time, string s, texttag tt, integer pid, real delay returns texttag
        local timer t = CreateTimer()
        local integer id = GetHandleId(t)
        
        set tt = CreateTextTag()
        
        call SaveReal(HT, id, 0, x)
        call SaveReal(HT, id, 1, y)
        call SaveReal(HT, id, 2, size)
        call SaveReal(HT, id, 3, height)
        call SaveReal(HT, id, 4, speed)
        call SaveReal(HT, id, 5, angle)
        call SaveInteger(HT, id, 6, alpha)
        call SaveReal(HT, id, 7, fade_time)
        call SaveReal(HT, id, 8, life_time)
        call SaveStr(HT, id, 9, s)
        call SaveTextTagHandle(HT, id, 10, tt)
        call SaveInteger(HT, id, 11, r)
        call SaveInteger(HT, id, 12, g)
        call SaveInteger(HT, id, 13, b)
        call SaveInteger(HT, id, 14, pid)
        call TimerStart(t, delay, false, function Text_Tag_Func)
        
        set t = null
        
        return tt
    endfunction
    
    
    
    endlibrary