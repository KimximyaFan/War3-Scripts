///////////////////////////////////////////////////////////////////////////
// SaveLoad - UI와 JNDirectSave 사이의 컨트롤러
// ClassicSave/영웅 선택 예제는 제거했다.
///////////////////////////////////////////////////////////////////////////
library SaveLoad requires Settings, TimerTools, SaveLoadData, SaveLoadLibrary, SaveSelectDialog, JNDirectSave, GameSaveData
    struct SaveLoad
        private static boolean array g_Locked[Settings.PLAYER_COUNT]

        static method Lock takes player p returns nothing
            set thistype.g_Locked[GetPlayerId(p)] = true
        endmethod

        static method Unlock takes player p returns nothing
            set thistype.g_Locked[GetPlayerId(p)] = false
        endmethod

        static method IsLocked takes player p returns boolean
            return thistype.g_Locked[GetPlayerId(p)]
        endmethod

        // 개발자 호출용: 현재 선택 캐릭터 저장
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

        // 개발자 호출용: 특정 캐릭터 로드
        static method RequestLoad takes player p, string characterName returns nothing
            if thistype.IsLocked(p) then
                return
            endif
            call thistype.Lock(p)
            call JNDirectSave.RequestLoad(p, characterName)
        endmethod

        // JNDirectSave가 동기화까지 끝내면 호출.
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

        // 슬롯 UI의 기존 BindLoadButtonEvent 인터페이스 유지
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

        // NewCharacter UI가 보내는 이벤트
        private static method CreateNewSaveData takes nothing returns nothing
            local player p = DzGetTriggerSyncPlayer()
            local string characterName = DzGetTriggerSyncData()

            if characterName == "" or SaveLoadData.GetPlayerServerName(p) == "" then
                set p = null
                return
            endif

            // Init 자체는 해당 플레이어의 로컬 클라이언트에서만 JN 서버에 접근한다.
            call JNDirectSave.InitCharacter(p, characterName)
            call DisplayTextToPlayer(p, 0, 0, "|cff98fb98캐릭터 슬롯 선택: " + characterName + "|r")

            // JN 서버 반영 시간을 고려해 원본 흐름처럼 잠깐 뒤 슬롯 목록을 다시 읽는다.
            call TimerStart(TimerTools.CreateTimerEx(GetPlayerId(p)), Settings.SERVER_LOAD_DELAY, false, function thistype.DelayedRefreshSlot)
            set p = null
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
