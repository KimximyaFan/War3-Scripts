library TimerTools
    struct TimerTools
        private static hashtable g_Data = null

        static method onInit takes nothing returns nothing
            set thistype.g_Data = InitHashtable()
        endmethod

        static method CreateTimerEx takes integer value returns timer
            local timer t = CreateTimer()
            call SaveInteger(thistype.g_Data, GetHandleId(t), 0, value)
            return t
        endmethod

        static method GetTimerInt takes timer t returns integer
            return LoadInteger(thistype.g_Data, GetHandleId(t), 0)
        endmethod

        static method DestroyTimerEx takes timer t returns nothing
            call FlushChildHashtable(thistype.g_Data, GetHandleId(t))
            call PauseTimer(t)
            call DestroyTimer(t)
        endmethod
    endstruct
endlibrary
