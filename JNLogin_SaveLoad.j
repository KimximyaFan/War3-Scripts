///////////////////////////////////////////////////////////////////////////
// SaveLoad System - 세이브/로드 모듈
///////////////////////////////////////////////////////////////////////////
scope SaveLoad
    // 간단 메시지 출력
    // @param message 표시할 문자열
    private function Print takes string message returns nothing
        call DisplayTextToPlayer(GetLocalPlayer(), 0.0, 0.0, message)
    endfunction

    struct SaveLoad
        private static boolean array g_IsLockedArray[Settings.PLAYER_COUNT]
        private static unit    array g_SelectedHero   [Settings.PLAYER_COUNT]

        // 세이브/로드 잠금
        // @param whichPlayer 잠금할 플레이어
        static method Lock takes player whichPlayer returns nothing
            set thistype.g_IsLockedArray[GetPlayerId(whichPlayer)] = true
        endmethod

        // 세이브/로드 잠금 해제
        // @param whichPlayer 잠금 해제할 플레이어
        static method Unlock takes player whichPlayer returns nothing
            set thistype.g_IsLockedArray[GetPlayerId(whichPlayer)] = false
        endmethod

        // 잠금 상태 확인
        // @param whichPlayer 확인할 플레이어
        // @return boolean true면 잠금 상태
        static method IsLocked takes player whichPlayer returns boolean
            return thistype.g_IsLockedArray[GetPlayerId(whichPlayer)]
        endmethod

        // 플레이어 선택 가능 여부
        static method IsPlayerSelectable takes nothing returns boolean
            local player triggerPlayer = DzGetTriggerSyncPlayer()
            return not thistype.IsLocked(triggerPlayer)
        endmethod

        // 영웅 선택 처리
        // @trigger 영웅 선택 플레이어
        static method OnHeroSelect takes nothing returns nothing
            local player whichPlayer = DzGetTriggerSyncPlayer()
            set thistype.g_SelectedHero[GetPlayerId(whichPlayer)] = GetTriggerUnit()
            call Print(GetHeroProperName(thistype.g_SelectedHero[GetPlayerId(whichPlayer)]) + " 선택됨")
        endmethod

        // 세이브 요청 처리
        // @param whichPlayer 저장 요청한 플레이어
        static method RequestSave takes player whichPlayer returns nothing
            local string easyCode = ""
            local string heroCode = ""
            if GetUnitTypeId(thistype.g_SelectedHero[GetPlayerId(whichPlayer)]) == 0 then
                call Print("선택한 영웅이 없습니다!")
                return
            endif
            call SaveLoadData.ResetCurrentData()
            call SetEasyCodeGold(whichPlayer, GetPlayerState(whichPlayer, PLAYER_STATE_RESOURCE_GOLD))
            call SetEasyCodeLumber(whichPlayer, GetPlayerState(whichPlayer, PLAYER_STATE_RESOURCE_LUMBER))
            set easyCode = SaveEasyCode(whichPlayer, GetPlayerName(whichPlayer))
            call Print(GetPlayerName(whichPlayer) + "의 세이브코드1:")
            call Print("  " + easyCode)
            call SetHeroCodeLv(whichPlayer, GetHeroLevel(thistype.g_SelectedHero[GetPlayerId(whichPlayer)]))
            call SetHeroCodeXp(whichPlayer, GetHeroXP(thistype.g_SelectedHero[GetPlayerId(whichPlayer)]))
            call SetHeroCodeStr(whichPlayer, GetHeroStr(thistype.g_SelectedHero[GetPlayerId(whichPlayer)], false))
            call SetHeroCodeAgi(whichPlayer, GetHeroAgi(thistype.g_SelectedHero[GetPlayerId(whichPlayer)], false))
            call SetHeroCodeInt(whichPlayer, GetHeroInt(thistype.g_SelectedHero[GetPlayerId(whichPlayer)], false))
            set heroCode = SaveHeroCode(whichPlayer, GetPlayerName(whichPlayer))
            call Print(GetPlayerName(whichPlayer) + "의 세이브코드2:")
            call Print("  " + heroCode)
            call SaveLoadData.RunSaveHelper(whichPlayer)
        endmethod

        // 저장된 데이터로 영웅 생성
        // @param whichPlayer 불러오기 대상 플레이어
        static method MakeHero takes player whichPlayer returns nothing
            local unit hero = CreateUnit(whichPlayer, 'Hpal', 0.0, 0.0, bj_UNIT_FACING)
            call SetHeroLevel(hero, GetHeroCodeLv(whichPlayer), false)
            call SetHeroXP(hero, GetHeroCodeXp(whichPlayer), false)
            call SetHeroStr(hero, GetHeroCodeStr(whichPlayer), true)
            call SetHeroAgi(hero, GetHeroCodeAgi(whichPlayer), true)
            call SetHeroInt(hero, GetHeroCodeInt(whichPlayer), true)
        endmethod

        // 로드 요청 처리
        // @param whichPlayer 로드 요청한 플레이어
        static method RequestLoad takes player whichPlayer returns nothing
            local string easyCode = SaveLoadData.GetMatchedData("EasyCode")
            local string heroCode = SaveLoadData.GetMatchedData("HeroCode")
            if LoadEasyCode(whichPlayer, GetPlayerName(whichPlayer), easyCode) and LoadHeroCode(whichPlayer, GetPlayerName(whichPlayer), heroCode) then
                call Print("로드 성공")
                call SetPlayerState(whichPlayer, PLAYER_STATE_RESOURCE_GOLD, GetEasyCodeGold(whichPlayer))
                call Print("금 " + I2S(GetEasyCodeGold(whichPlayer)))
                call SetPlayerState(whichPlayer, PLAYER_STATE_RESOURCE_LUMBER, GetEasyCodeLumber(whichPlayer))
                call Print("목재 " + I2S(GetEasyCodeLumber(whichPlayer)))
                call thistype.MakeHero(whichPlayer)
            else
                call Print("잘못 입력했습니다!")
                debug call Print("  서버/캐릭: " + SaveLoadData.GetPlayerServerName(whichPlayer) + "," + SaveLoadData.GetLastSelectedCharacter(whichPlayer))
                debug call Print("  코드1/2: " + easyCode + ", " + heroCode)
            endif
            call thistype.Unlock(whichPlayer)
        endmethod

        // 동기화된 데이터 로드 핸들러
        static method SyncDataLoad takes nothing returns nothing
            local player whichPlayer = DzGetTriggerSyncPlayer()
            local string charName     = DzGetTriggerSyncData()
            if charName == null or charName == "" then
                call Print("|CFF98FB98에러: 복구 요청 필요")
                return
            endif
            call Print("|CFF98FB98세이브 데이터를 불러오는 중...")
            call SaveLoadData.RunLoadHelper(whichPlayer, charName)
        endmethod

        // 자동 세이브 타이머 콜백
        static method AutoSaveTimerAction takes nothing returns nothing
            local integer idx = 0
            loop
                exitwhen idx >= Settings.PLAYER_COUNT
                if GetPlayerController(Player(idx)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(idx)) == PLAYER_SLOT_STATE_PLAYING then
                    call thistype.RequestSave(Player(idx))
                endif
                set idx = idx + 1
            endloop
        endmethod

        // 신규 데이터 생성 요청 처리
        static method CreateNewSaveData takes nothing returns nothing
            local player whichPlayer = DzGetTriggerSyncPlayer()
            local string serverName = SaveLoadData.GetPlayerServerName(whichPlayer)
            local string characterName  = DzGetTriggerSyncData()
            
            if not SaveLoadData.IsPlayerLoadedFromServer(whichPlayer) then
                if GetLocalPlayer() == whichPlayer then
                    call JNObjectUserInit(Settings.API_MAP_CODE, serverName, Settings.API_SECRET_KEY, "")
                endif
                call SaveLoadData.SetPlayerLoadedFromServer(whichPlayer, true)
            endif

            if SaveLoadData.GetLastSelectedCharacter(whichPlayer) != characterName then
                if GetLocalPlayer() == whichPlayer then
                    call JNObjectCharacterInit(Settings.API_MAP_CODE, serverName, Settings.API_SECRET_KEY, characterName)
                endif
                call SaveLoadData.SetLastSelectedCharacter(whichPlayer, characterName)
                
            else
                if GetLocalPlayer() == whichPlayer then
                    call JNObjectCharacterClearField(serverName)
                endif
            endif
            
            call DisplayTextToPlayer(whichPlayer, 0.0, 0.0, "|CFF98FB98새로운 슬롯(" + characterName + ")이 생성되었습니다.")
            set whichPlayer = null
        endmethod
        
        // SaveSelectDialog핸들링용
        static method LoadSaveDataEvent takes nothing returns nothing
            local player requestPlayer = DzGetTriggerUIEventPlayer()
            local integer characterIndex = SaveSelectDialog.GetCharacterIndex(DzGetTriggerUIEventFrame())
            local ServerPlayerInfo serverPlayerInfo
            local string characterName = null

            if characterIndex != -1 then
                set serverPlayerInfo = SaveLoadManager.GetServerPlayerInfo(requestPlayer)
                set characterName = serverPlayerInfo.GetCharacterName(characterIndex)
                call SaveSelectDialog.HideSelect()
                if not thistype.IsLocked(requestPlayer) then
                    call thistype.Lock(requestPlayer)
                    call DzSyncData("LoadCh", characterName)
                endif
            endif

            set requestPlayer = null
        endmethod

        // 초기화: 이벤트 등록 및 타이머 설정
        static method onInit takes nothing returns nothing
            local trigger trig       = CreateTrigger()
            local integer idx        = 0
            loop
                exitwhen idx >= Settings.PLAYER_COUNT
                call TriggerRegisterPlayerUnitEvent(trig, Player(idx), EVENT_PLAYER_UNIT_SELECTED, null)
                set idx = idx + 1
            endloop
            call TriggerAddCondition(trig, Condition(function thistype.IsPlayerSelectable))
            call TriggerAddAction   (trig, function thistype.OnHeroSelect)

            set trig = CreateTrigger()
            call DzTriggerRegisterSyncData(trig, "LoadCh", false)
            call TriggerAddAction(trig, function thistype.SyncDataLoad)

            set trig = CreateTrigger()
            call DzTriggerRegisterSyncData(trig, "NewChar", false)
            call TriggerAddAction(trig, function thistype.CreateNewSaveData)
            
            call TimerStart(CreateTimer(), 300.0, true, function thistype.AutoSaveTimerAction)
        endmethod
    endstruct
endscope