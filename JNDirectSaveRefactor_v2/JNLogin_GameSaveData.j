
library GameSaveData requires JNDirectSave
    globals
        integer array g_SaveA
        integer array g_SaveB
        integer array g_SaveC

        integer array g_ServerAura
    endglobals

    struct GameSaveData

        static method onInit takes nothing returns nothing
            call JNDirectSave.RegisterCharacterInt("A")
            call JNDirectSave.RegisterCharacterInt("B")
            call JNDirectSave.RegisterCharacterInt("C")

            call JNDirectSave.RegisterUserInt("Aura")
        endmethod

        static method WriteCharacterFields takes player p returns nothing
            local integer pid = GetPlayerId(p)

            call JNDirectSave.SetCharacterInt(p, "A", g_SaveA[pid])
            call JNDirectSave.SetCharacterInt(p, "B", g_SaveB[pid])
            call JNDirectSave.SetCharacterInt(p, "C", g_SaveC[pid])

        endmethod

        static method ApplyLoaded takes player p returns nothing
            local integer pid = GetPlayerId(p)

            set g_SaveA[pid] = JNDirectSave.GetCharacterInt(p, "A")
            set g_SaveB[pid] = JNDirectSave.GetCharacterInt(p, "B")
            set g_SaveC[pid] = JNDirectSave.GetCharacterInt(p, "C")

            set g_ServerAura[pid] = JNDirectSave.GetUserInt(p, "Aura")

            call DisplayTextToPlayer(p, 0, 0, "A=" + I2S(g_SaveA[pid]) + ", B=" + I2S(g_SaveB[pid]) + ", C=" + I2S(g_SaveC[pid]))
            call DisplayTextToPlayer(p, 0, 0, "Server Aura=" + I2S(g_ServerAura[pid]))
        endmethod
    endstruct
endlibrary
