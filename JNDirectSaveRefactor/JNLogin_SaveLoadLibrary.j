///////////////////////////////////////////////////////////////////////////
// SaveLoadLibrary
// 1) 캐릭터 슬롯 목록 조회
// 2) 로컬 JNObject Get 결과를 DzSyncData로 모든 클라이언트에 동기화
///////////////////////////////////////////////////////////////////////////
library SaveLoadLibrary requires Settings, SaveLoadData

    struct ServerPlayerInfo
        private string array m_CharacterName[Settings.MAXIMUM_SAVE_CHARACTER_COUNT]
        private integer m_CharacterCount = 0
        private player m_Player = null

        static method Create takes player whichPlayer returns ServerPlayerInfo
            local ServerPlayerInfo this = ServerPlayerInfo.allocate()
            set this.m_Player = whichPlayer
            return this
        endmethod

        method Update takes nothing returns nothing
            local integer i = 0
            set this.m_CharacterCount = SaveLoadManager.GetCharacterSize(this.m_Player)
            loop
                exitwhen i >= Settings.MAXIMUM_SAVE_CHARACTER_COUNT
                if i < this.m_CharacterCount then
                    set this.m_CharacterName[i] = SaveLoadManager.GetCharacterName(this.m_Player, i)
                else
                    set this.m_CharacterName[i] = ""
                endif
                set i = i + 1
            endloop
        endmethod

        method GetCharacterName takes integer index returns string
            if index < 0 or index >= this.m_CharacterCount then
                return ""
            endif
            return this.m_CharacterName[index]
        endmethod

        method GetCharacterCount takes nothing returns integer
            return this.m_CharacterCount
        endmethod
    endstruct

    struct SaveLoadCache
        private static hashtable g_Cache = null
        private static boolean array g_Finished[Settings.PLAYER_COUNT]

        static method PreloadStart takes player p returns nothing
            call FlushChildHashtable(thistype.g_Cache, GetPlayerId(p))
            set thistype.g_Finished[GetPlayerId(p)] = false
        endmethod

        static method ClearPreloadData takes player p returns nothing
            call FlushChildHashtable(thistype.g_Cache, GetPlayerId(p))
            set thistype.g_Finished[GetPlayerId(p)] = false
        endmethod

        static method IsPreloadFinished takes player p returns boolean
            return thistype.g_Finished[GetPlayerId(p)]
        endmethod

        static method StoreStr takes player p, string key, string value returns nothing
            call SaveStr(thistype.g_Cache, GetPlayerId(p), StringHash(key), value)
        endmethod

        static method StoreInt takes player p, string key, integer value returns nothing
            call SaveInteger(thistype.g_Cache, GetPlayerId(p), StringHash(key), value)
        endmethod

        static method StoreReal takes player p, string key, real value returns nothing
            call SaveReal(thistype.g_Cache, GetPlayerId(p), StringHash(key), value)
        endmethod

        static method StoreBool takes player p, string key, boolean value returns nothing
            call SaveBoolean(thistype.g_Cache, GetPlayerId(p), StringHash(key), value)
        endmethod

        static method RetrieveStr takes player p, string key returns string
            return LoadStr(thistype.g_Cache, GetPlayerId(p), StringHash(key))
        endmethod

        static method RetrieveInt takes player p, string key returns integer
            return LoadInteger(thistype.g_Cache, GetPlayerId(p), StringHash(key))
        endmethod

        static method RetrieveReal takes player p, string key returns real
            return LoadReal(thistype.g_Cache, GetPlayerId(p), StringHash(key))
        endmethod

        static method RetrieveBool takes player p, string key returns boolean
            return LoadBoolean(thistype.g_Cache, GetPlayerId(p), StringHash(key))
        endmethod

        // field 이름에는 '§' 문자를 사용하지 않는다.
        // 문자열 value는 Base64 처리하여 delimiter 충돌을 막는다.
        static method SyncStr takes string key, string value returns nothing
            if value == null then
                set value = ""
            endif
            call DzSyncData("SVCS", key + "§" + JNStringBase64Encoding(value))
        endmethod

        static method SyncInt takes string key, integer value returns nothing
            call DzSyncData("SVCI", key + "§" + I2S(value))
        endmethod

        static method SyncReal takes string key, real value returns nothing
            call DzSyncData("SVCR", key + "§" + R2S(value))
        endmethod

        static method SyncBool takes string key, boolean value returns nothing
            if value then
                call DzSyncData("SVCB", key + "§1")
            else
                call DzSyncData("SVCB", key + "§0")
            endif
        endmethod

        static method SyncFinish takes nothing returns nothing
            call DzSyncData("SVCF", "")
        endmethod

        private static method StoreStrSync takes nothing returns nothing
            local player p = DzGetTriggerSyncPlayer()
            local string raw = DzGetTriggerSyncData()
            local string key = JNStringSplit(raw, "§", 0)
            local string value = JNStringBase64Decoding(JNStringSplit(raw, "§", 1))
            call thistype.StoreStr(p, key, value)
            set p = null
        endmethod

        private static method StoreIntSync takes nothing returns nothing
            local player p = DzGetTriggerSyncPlayer()
            local string raw = DzGetTriggerSyncData()
            call thistype.StoreInt(p, JNStringSplit(raw, "§", 0), S2I(JNStringSplit(raw, "§", 1)))
            set p = null
        endmethod

        private static method StoreRealSync takes nothing returns nothing
            local player p = DzGetTriggerSyncPlayer()
            local string raw = DzGetTriggerSyncData()
            call thistype.StoreReal(p, JNStringSplit(raw, "§", 0), S2R(JNStringSplit(raw, "§", 1)))
            set p = null
        endmethod

        private static method StoreBoolSync takes nothing returns nothing
            local player p = DzGetTriggerSyncPlayer()
            local string raw = DzGetTriggerSyncData()
            call thistype.StoreBool(p, JNStringSplit(raw, "§", 0), S2I(JNStringSplit(raw, "§", 1)) != 0)
            set p = null
        endmethod

        private static method FinishSync takes nothing returns nothing
            set thistype.g_Finished[GetPlayerId(DzGetTriggerSyncPlayer())] = true
        endmethod

        static method onInit takes nothing returns nothing
            local trigger t
            set thistype.g_Cache = InitHashtable()

            set t = CreateTrigger()
            call DzTriggerRegisterSyncData(t, "SVCS", false)
            call TriggerAddAction(t, function thistype.StoreStrSync)

            set t = CreateTrigger()
            call DzTriggerRegisterSyncData(t, "SVCI", false)
            call TriggerAddAction(t, function thistype.StoreIntSync)

            set t = CreateTrigger()
            call DzTriggerRegisterSyncData(t, "SVCR", false)
            call TriggerAddAction(t, function thistype.StoreRealSync)

            set t = CreateTrigger()
            call DzTriggerRegisterSyncData(t, "SVCB", false)
            call TriggerAddAction(t, function thistype.StoreBoolSync)

            set t = CreateTrigger()
            call DzTriggerRegisterSyncData(t, "SVCF", false)
            call TriggerAddAction(t, function thistype.FinishSync)

            set t = null
        endmethod
    endstruct

    struct SaveLoadManager
        private static ServerPlayerInfo array g_Info[Settings.PLAYER_COUNT]

        static method UpdateServerPlayerInfo takes player p returns nothing
            local integer pid = GetPlayerId(p)
            if thistype.g_Info[pid] == 0 then
                set thistype.g_Info[pid] = ServerPlayerInfo.Create(p)
            endif
            call thistype.g_Info[pid].Update()
        endmethod

        static method GetServerPlayerInfo takes player p returns ServerPlayerInfo
            local integer pid = GetPlayerId(p)
            if thistype.g_Info[pid] == 0 then
                set thistype.g_Info[pid] = ServerPlayerInfo.Create(p)
            endif
            return thistype.g_Info[pid]
        endmethod

        static method GetLastSelectedCharacter takes player p returns string
            return SaveLoadData.GetLastSelectedCharacter(p)
        endmethod

        static method GetCharacterSize takes player p returns integer
            local string userId = SaveLoadData.GetPlayerServerName(p)
            if userId == "" then
                return 0
            endif
            return JNObjectCharacterGetCharacterCount(Settings.API_MAP_CODE, userId, Settings.API_SECRET_KEY)
        endmethod

        static method GetCharacterName takes player p, integer index returns string
            local string userId = SaveLoadData.GetPlayerServerName(p)
            if userId == "" then
                return ""
            endif
            return JNObjectCharacterGetCharacterNameByIndex(userId, index)
        endmethod
    endstruct
endlibrary
