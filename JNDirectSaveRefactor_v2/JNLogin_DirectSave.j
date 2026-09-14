
library JNDirectSave requires Settings, TimerTools, SaveLoadData, SaveLoadLibrary
    struct JNDirectSave
        private static constant integer TYPE_INT    = 1
        private static constant integer TYPE_REAL   = 2
        private static constant integer TYPE_STRING = 3
        private static constant integer TYPE_BOOL   = 4

        private static integer g_CharacterFieldCount = 0
        private static string array g_CharacterFieldName
        private static integer array g_CharacterFieldType

        private static integer g_UserFieldCount = 0
        private static string array g_UserFieldName
        private static integer array g_UserFieldType

        private static integer array g_LoadRetry[Settings.PLAYER_COUNT]

        private static method CharacterCacheKey takes string field returns string
            return "C:" + field
        endmethod

        private static method UserCacheKey takes string field returns string
            return "U:" + field
        endmethod

        private static method RegisterCharacterField takes string field, integer fieldType returns nothing
            local integer i = 0
            if field == "" then
                return
            endif
            loop
                exitwhen i >= thistype.g_CharacterFieldCount
                if thistype.g_CharacterFieldName[i] == field then
                    return
                endif
                set i = i + 1
            endloop
            set thistype.g_CharacterFieldName[thistype.g_CharacterFieldCount] = field
            set thistype.g_CharacterFieldType[thistype.g_CharacterFieldCount] = fieldType
            set thistype.g_CharacterFieldCount = thistype.g_CharacterFieldCount + 1
        endmethod

        private static method RegisterUserField takes string field, integer fieldType returns nothing
            local integer i = 0
            if field == "" then
                return
            endif
            loop
                exitwhen i >= thistype.g_UserFieldCount
                if thistype.g_UserFieldName[i] == field then
                    return
                endif
                set i = i + 1
            endloop
            set thistype.g_UserFieldName[thistype.g_UserFieldCount] = field
            set thistype.g_UserFieldType[thistype.g_UserFieldCount] = fieldType
            set thistype.g_UserFieldCount = thistype.g_UserFieldCount + 1
        endmethod

        static method RegisterCharacterInt takes string field returns nothing
            call thistype.RegisterCharacterField(field, TYPE_INT)
        endmethod
        static method RegisterCharacterReal takes string field returns nothing
            call thistype.RegisterCharacterField(field, TYPE_REAL)
        endmethod
        static method RegisterCharacterString takes string field returns nothing
            call thistype.RegisterCharacterField(field, TYPE_STRING)
        endmethod
        static method RegisterCharacterBool takes string field returns nothing
            call thistype.RegisterCharacterField(field, TYPE_BOOL)
        endmethod

        static method RegisterUserInt takes string field returns nothing
            call thistype.RegisterUserField(field, TYPE_INT)
        endmethod
        static method RegisterUserReal takes string field returns nothing
            call thistype.RegisterUserField(field, TYPE_REAL)
        endmethod
        static method RegisterUserString takes string field returns nothing
            call thistype.RegisterUserField(field, TYPE_STRING)
        endmethod
        static method RegisterUserBool takes string field returns nothing
            call thistype.RegisterUserField(field, TYPE_BOOL)
        endmethod

        static method SetCharacterInt takes player p, string field, integer value returns nothing
            local string userId = SaveLoadData.GetPlayerServerName(p)
            if GetLocalPlayer() == p and userId != "" then
                call JNObjectCharacterSetInt(userId, field, value)
            endif
        endmethod

        static method SetCharacterReal takes player p, string field, real value returns nothing
            local string userId = SaveLoadData.GetPlayerServerName(p)
            if GetLocalPlayer() == p and userId != "" then
                call JNObjectCharacterSetReal(userId, field, value)
            endif
        endmethod

        static method SetCharacterString takes player p, string field, string value returns nothing
            local string userId = SaveLoadData.GetPlayerServerName(p)
            if GetLocalPlayer() == p and userId != "" then
                call JNObjectCharacterSetString(userId, field, value)
            endif
        endmethod

        static method SetCharacterBool takes player p, string field, boolean value returns nothing
            local string userId = SaveLoadData.GetPlayerServerName(p)
            if GetLocalPlayer() == p and userId != "" then
                call JNObjectCharacterSetBoolean(userId, field, value)
            endif
        endmethod

        static method SaveCharacter takes player p returns nothing
            local string userId = SaveLoadData.GetPlayerServerName(p)
            local string characterName = SaveLoadData.GetLastSelectedCharacter(p)
            if userId == "" or characterName == "" then
                call DisplayTextToPlayer(p, 0, 0, "|cffff2020[Save] 로그인/캐릭터 선택이 필요합니다.|r")
                return
            endif
            if GetLocalPlayer() == p then
                call JNObjectCharacterSave(Settings.API_MAP_CODE, userId, Settings.API_SECRET_KEY, characterName)
            endif
        endmethod

        static method SetUserInt takes player p, string field, integer value returns nothing
            local string userId = SaveLoadData.GetPlayerServerName(p)
            if GetLocalPlayer() == p and userId != "" then
                call JNObjectUserSetInt(userId, field, value)
            endif
        endmethod

        static method SetUserReal takes player p, string field, real value returns nothing
            local string userId = SaveLoadData.GetPlayerServerName(p)
            if GetLocalPlayer() == p and userId != "" then
                call JNObjectUserSetReal(userId, field, value)
            endif
        endmethod

        static method SetUserString takes player p, string field, string value returns nothing
            local string userId = SaveLoadData.GetPlayerServerName(p)
            if GetLocalPlayer() == p and userId != "" then
                call JNObjectUserSetString(userId, field, value)
            endif
        endmethod

        static method SetUserBool takes player p, string field, boolean value returns nothing
            local string userId = SaveLoadData.GetPlayerServerName(p)
            if GetLocalPlayer() == p and userId != "" then
                call JNObjectUserSetBoolean(userId, field, value)
            endif
        endmethod

        static method SaveUser takes player p returns nothing
            local string userId = SaveLoadData.GetPlayerServerName(p)
            local string characterName = SaveLoadData.GetLastSelectedCharacter(p)
            if userId == "" then
                return
            endif
            if GetLocalPlayer() == p then
                call JNObjectUserSave(Settings.API_MAP_CODE, userId, Settings.API_SECRET_KEY, characterName)
            endif
        endmethod

        static method GetCharacterInt takes player p, string field returns integer
            return SaveLoadCache.RetrieveInt(p, thistype.CharacterCacheKey(field))
        endmethod
        static method GetCharacterReal takes player p, string field returns real
            return SaveLoadCache.RetrieveReal(p, thistype.CharacterCacheKey(field))
        endmethod
        static method GetCharacterString takes player p, string field returns string
            return SaveLoadCache.RetrieveStr(p, thistype.CharacterCacheKey(field))
        endmethod
        static method GetCharacterBool takes player p, string field returns boolean
            return SaveLoadCache.RetrieveBool(p, thistype.CharacterCacheKey(field))
        endmethod

        static method GetUserInt takes player p, string field returns integer
            return SaveLoadCache.RetrieveInt(p, thistype.UserCacheKey(field))
        endmethod
        static method GetUserReal takes player p, string field returns real
            return SaveLoadCache.RetrieveReal(p, thistype.UserCacheKey(field))
        endmethod
        static method GetUserString takes player p, string field returns string
            return SaveLoadCache.RetrieveStr(p, thistype.UserCacheKey(field))
        endmethod
        static method GetUserBool takes player p, string field returns boolean
            return SaveLoadCache.RetrieveBool(p, thistype.UserCacheKey(field))
        endmethod

        static method InitCharacter takes player p, string characterName returns nothing
            local string userId = SaveLoadData.GetPlayerServerName(p)
            if userId == "" or characterName == "" then
                return
            endif
            if GetLocalPlayer() == p then
                call JNObjectUserInit(Settings.API_MAP_CODE, userId, Settings.API_SECRET_KEY, "")
                call JNObjectCharacterInit(Settings.API_MAP_CODE, userId, Settings.API_SECRET_KEY, characterName)
            endif
            call SaveLoadData.SetLastSelectedCharacter(p, characterName)
        endmethod

        static method RequestLoad takes player p, string characterName returns nothing
            local timer t
            local string userId = SaveLoadData.GetPlayerServerName(p)

            if p == null or userId == "" or characterName == "" then
                call SaveLoad.OnLoadFailed(p, "잘못된 로드 요청")
                return
            endif

            call SaveLoadCache.PreloadStart(p)
            set thistype.g_LoadRetry[GetPlayerId(p)] = 0
            call thistype.InitCharacter(p, characterName)

            set t = TimerTools.CreateTimerEx(GetPlayerId(p))
            call TimerStart(t, Settings.SERVER_LOAD_DELAY, false, function thistype.DelayedReadFields)
            set t = null
        endmethod

        private static method DelayedReadFields takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local player p = Player(TimerTools.GetTimerInt(t))
            local string userId = SaveLoadData.GetPlayerServerName(p)
            local integer i = 0
            local integer fieldType
            local string field
            local string key

            if GetLocalPlayer() == p then
                // Character fields
                loop
                    exitwhen i >= thistype.g_CharacterFieldCount
                    set field = thistype.g_CharacterFieldName[i]
                    set fieldType = thistype.g_CharacterFieldType[i]
                    set key = thistype.CharacterCacheKey(field)
                    if fieldType == TYPE_INT then
                        call SaveLoadCache.SyncInt(key, JNObjectCharacterGetInt(userId, field))
                    elseif fieldType == TYPE_REAL then
                        call SaveLoadCache.SyncReal(key, JNObjectCharacterGetReal(userId, field))
                    elseif fieldType == TYPE_STRING then
                        call SaveLoadCache.SyncStr(key, JNObjectCharacterGetString(userId, field))
                    elseif fieldType == TYPE_BOOL then
                        call SaveLoadCache.SyncBool(key, JNObjectCharacterGetBoolean(userId, field))
                    endif
                    set i = i + 1
                endloop

                // User fields: 운영자가 서버에서 바꿀 수 있는 계정값에 적합
                set i = 0
                loop
                    exitwhen i >= thistype.g_UserFieldCount
                    set field = thistype.g_UserFieldName[i]
                    set fieldType = thistype.g_UserFieldType[i]
                    set key = thistype.UserCacheKey(field)
                    if fieldType == TYPE_INT then
                        call SaveLoadCache.SyncInt(key, JNObjectUserGetInt(userId, field))
                    elseif fieldType == TYPE_REAL then
                        call SaveLoadCache.SyncReal(key, JNObjectUserGetReal(userId, field))
                    elseif fieldType == TYPE_STRING then
                        call SaveLoadCache.SyncStr(key, JNObjectUserGetString(userId, field))
                    elseif fieldType == TYPE_BOOL then
                        call SaveLoadCache.SyncBool(key, JNObjectUserGetBoolean(userId, field))
                    endif
                    set i = i + 1
                endloop

                call SaveLoadCache.SyncFinish()
            endif

            call TimerStart(t, Settings.SYNC_RETRY_INTERVAL, false, function thistype.DelayedApplyFields)
            set p = null
            set t = null
        endmethod

        private static method DelayedApplyFields takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local player p = Player(TimerTools.GetTimerInt(t))
            local integer pid = GetPlayerId(p)

            if not SaveLoadCache.IsPreloadFinished(p) then
                set thistype.g_LoadRetry[pid] = thistype.g_LoadRetry[pid] + 1
                if thistype.g_LoadRetry[pid] < Settings.SYNC_MAX_RETRY then
                    call TimerStart(t, Settings.SYNC_RETRY_INTERVAL, false, function thistype.DelayedApplyFields)
                    set p = null
                    set t = null
                    return
                endif

                call SaveLoadCache.ClearPreloadData(p)
                call SaveLoad.OnLoadFailed(p, "동기화 시간 초과")
                call TimerTools.DestroyTimerEx(t)
                set p = null
                set t = null
                return
            endif

            call SaveLoad.OnLoadComplete(p)
            call SaveLoadCache.ClearPreloadData(p)
            call TimerTools.DestroyTimerEx(t)

            set p = null
            set t = null
        endmethod
    endstruct
endlibrary
