library HandleLibrary
    struct HandleEnum
        static timer toolsTimer = null
    endstruct
endlibrary

library TimerTools requires HandleLibrary
    struct TimerTools
        public static method CreateTimerEx takes integer value returns timer
            set HandleEnum.toolsTimer = CreateTimer()
            call TimerStart(HandleEnum.toolsTimer, value, false, null)
            call PauseTimer(HandleEnum.toolsTimer)
            return HandleEnum.toolsTimer
        endmethod

        public static method GetTimerInt takes timer expiedTimer returns integer
            return R2I(TimerGetRemaining(expiedTimer) + 0.5)
        endmethod
    endstruct
endlibrary