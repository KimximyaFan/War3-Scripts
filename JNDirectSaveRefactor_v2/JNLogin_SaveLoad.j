
library SaveLoad requires Settings, TimerTools, SaveLoadData, SaveLoadLibrary, SaveSelectDialog, JNDirectSave, GameSaveData
    struct SaveLoad
        private static boolean array g_Locked[Settings.PLAYER_COUNT]
        private static string array g_PendingNewCharacterName[Settings.PLAYER_COUNT]

        static method Lock takes player p returns nothing
            set thistype.g_Locked[GetPlayerId(p)] = true
        endmethod

        static method Unlock takes player p returns nothing
            set thistype.g_Locked[GetPlayerId(p)] = false
        endmethod

        static method IsLocked takes player p returns boolean
            return thistype.g_Locked[GetPlayerId(p)]
        endmethod

        static method RequestSave takes player p returns nothing
            if p == null or not SaveLoadData.IsLoggedIn(p) or not SaveLoadData.HasSelectedCharacter(p) then
                call DisplayTextToPlayer(p, 0, 0, "|cffff2020[Save] 로그인 후 캐릭터를 선택하세요.|r")
                return
            endif
            if thistype.IsLocked(p) then
                return
            endif

            call thistype.Lock(p)
            call GameSaveData.WriteCharacterFields(p)
            call JNDirectSave.SaveCharacter(p)
            call thistype.Unlock(p)
            call DisplayTextToPlayer(p, 0, 0, "|cff98fb98[Save] 서버 저장 요청 완료|r")
        endmethod

        static method RequestLoad takes player p, string characterName returns nothing
            if thistype.IsLocked(p) then
                return
            endif
            call thistype.Lock(p)
            call JNDirectSave.RequestLoad(p, characterName)
        endmethod

        static method OnLoadComplete takes player p returns nothing
            call GameSaveData.ApplyLoaded(p)
            call thistype.Unlock(p)
            call DisplayTextToPlayer(p, 0, 0, "|cff98fb98[Load] 서버 로드 완료|r")
        endmethod

        static method OnLoadFailed takes player p, string reason returns nothing
            if p != null then
                call thistype.Unlock(p)
                call DisplayTextToPlayer(p, 0, 0, "|cffff2020[Load] 실패: " + reason + "|r")
            endif
        endmethod

        private static method SyncDataLoad takes nothing returns nothing
            local player p = DzGetTriggerSyncPlayer()
            local string characterName = DzGetTriggerSyncData()
            call thistype.RequestLoad(p, characterName)
            set p = null
        endmethod

        static method LoadSaveDataEvent takes nothing returns nothing
            local player p = DzGetTriggerUIEventPlayer()
            local integer characterIndex = SaveSelectDialog.GetCharacterIndex(DzGetTriggerUIEventFrame())
            local ServerPlayerInfo info
            local string characterName = ""

            if characterIndex >= 0 then
                set info = SaveLoadManager.GetServerPlayerInfo(p)
                set characterName = info.GetCharacterName(characterIndex)
                if characterName != "" then
                    call SaveSelectDialog.HideSelect()
                    if not thistype.IsLocked(p) and GetLocalPlayer() == p then
                        call DzSyncData("LoadCh", characterName)
                    endif
                endif
            endif
            set p = null
        endmethod

        private static method DelayedRefreshSlot takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local player p = Player(TimerTools.GetTimerInt(t))
            call SaveSelectDialog.RefreshSlot(p)
            if GetLocalPlayer() == p then
                call SaveSelectDialog.ShowSelect()
            endif
            call TimerTools.DestroyTimerEx(t)
            set p = null
            set t = null
        endmethod
        
        private static method DelayedSaveNewCharacter takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local integer pid = TimerTools.GetTimerInt(t)
            local player p = Player(pid)
            local string characterName = thistype.g_PendingNewCharacterName[pid]

            call TimerTools.DestroyTimerEx(t)

            if characterName == "" then
                set p = null
                set t = null
                return
            endif

            call SaveLoadData.SetLastSelectedCharacter(p, characterName)
            call JNDirectSave.SaveCharacter(p)

            set thistype.g_PendingNewCharacterName[pid] = ""

            set t = TimerTools.CreateTimerEx(pid)
            call TimerStart(t, Settings.SERVER_LOAD_DELAY, false, function thistype.DelayedRefreshSlot)

            set p = null
            set t = null
        endmethod

        private static method CreateNewSaveData takes nothing returns nothing
            local player p = DzGetTriggerSyncPlayer()
            local string characterName = DzGetTriggerSyncData()
            local integer pid
            local timer t

            if characterName == "" or SaveLoadData.GetPlayerServerName(p) == "" then
                set p = null
                return
            endif

            set pid = GetPlayerId(p)

            call JNDirectSave.InitCharacter(p, characterName)

            set thistype.g_PendingNewCharacterName[pid] = characterName

            call DisplayTextToPlayer(p, 0, 0, "|cff98fb98새로운 슬롯(" + characterName + ") 생성 중...|r")

            set t = TimerTools.CreateTimerEx(pid)
            call TimerStart(t, Settings.SERVER_LOAD_DELAY, false, function thistype.DelayedSaveNewCharacter)

            set p = null
            set t = null
        endmethod

        static method AutoSaveTimerAction takes nothing returns nothing
            local integer i = 0
            loop
                exitwhen i >= Settings.PLAYER_COUNT
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
                    if SaveLoadData.IsLoggedIn(Player(i)) and SaveLoadData.HasSelectedCharacter(Player(i)) then
                        call thistype.RequestSave(Player(i))
                    endif
                endif
                set i = i + 1
            endloop
        endmethod

        static method onInit takes nothing returns nothing
            local trigger t

            set t = CreateTrigger()
            call DzTriggerRegisterSyncData(t, "LoadCh", false)
            call TriggerAddAction(t, function thistype.SyncDataLoad)

            set t = CreateTrigger()
            call DzTriggerRegisterSyncData(t, "NewChar", false)
            call TriggerAddAction(t, function thistype.CreateNewSaveData)

            if Settings.ENABLE_AUTO_SAVE then
                call TimerStart(CreateTimer(), Settings.AUTO_SAVE_INTERVAL, true, function thistype.AutoSaveTimerAction)
            endif

            set t = null
        endmethod
    endstruct
endlibrary
