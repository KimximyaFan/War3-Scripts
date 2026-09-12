///////////////////////////////////////////////////////////////////////////
// SaveLoadData - 저장에 사용하는 데이터 (통신용 이름, 저장용 캐릭터 이름 등)
///////////////////////////////////////////////////////////////////////////
struct SaveLoadData
    // 서버 통신용 플레이어 이름
    private static string array g_OriginalPlayerName[Settings.PLAYER_COUNT]
    // 서버에서 데이터 로드했는지 여부
    private static boolean array g_IsLoadedFromServer[Settings.PLAYER_COUNT]
    // 마지막으로 선택/로드한 캐릭터 이름
    private static string array g_LastSelectedCharacter[Settings.PLAYER_COUNT]
    // 캐릭터 선택 가능 여부
    private static boolean array m_IsEnableSelect[Settings.PLAYER_COUNT]

    // 저장 데이터 개수
    private static integer g_SaveDataSize = 0
    // 저장 슬롯별 제목
    private static string array g_SaveDataTitle[Settings.MAXIMUM_SAVE_CHARACTER_COUNT]
    // 저장 슬롯별 코드
    private static string array g_SaveDataCode[Settings.MAXIMUM_SAVE_CHARACTER_COUNT]

    // 플레이어의 서버 통신용 이름을 반환
    // @param p 플레이어
    // @return 서버용 이름
    static method GetPlayerServerName takes player p returns string
        return g_OriginalPlayerName[GetPlayerId(p)]
    endmethod

    // 플레이어의 서버 통신용 이름을 설정
    // @param p 플레이어
    // @param name 서버용 이름
    static method SetPlayerServerName takes player p, string name returns nothing
        set g_OriginalPlayerName[GetPlayerId(p)] = name
    endmethod

    // 서버에서 데이터 로드했는지 여부를 반환
    // @param p 플레이어
    // @return 로드 여부
    static method IsPlayerLoadedFromServer takes player p returns boolean
        return g_IsLoadedFromServer[GetPlayerId(p)]
    endmethod

    // 서버 로드 여부 설정
    // @param p 플레이어
    // @param enable 설정값
    static method SetPlayerLoadedFromServer takes player p, boolean enable returns nothing
        set g_IsLoadedFromServer[GetPlayerId(p)] = enable
    endmethod

    // 마지막으로 선택한 캐릭터 이름을 반환
    // @param p 플레이어
    // @return 캐릭터 이름
    static method GetLastSelectedCharacter takes player p returns string
        return g_LastSelectedCharacter[GetPlayerId(p)]
    endmethod

    // 마지막으로 선택한 캐릭터 이름을 설정
    // @param p 플레이어
    // @param name 캐릭터 이름
    static method SetLastSelectedCharacter takes player p, string name returns nothing
        set g_LastSelectedCharacter[GetPlayerId(p)] = name
    endmethod

    // 캐릭터 선택 가능 상태 설정
    // @param p 플레이어
    // @param enable 선택 가능 여부
    static method SetCharacterSelectEnable takes player p, boolean enable returns nothing
        set m_IsEnableSelect[GetPlayerId(p)] = enable
    endmethod

    // 현재 저장 데이터를 초기화
    static method ResetCurrentData takes nothing returns nothing
        local integer i = g_SaveDataSize
        loop
            exitwhen i <= 0
            set i = i - 1
            set g_SaveDataCode[i] = null
        endloop
    endmethod

    // 저장 슬롯에 제목을 추가
    // @param title 슬롯 제목
    static method AutoAddSaveTitle takes string title returns nothing
        set g_SaveDataTitle[g_SaveDataSize] = title
        set g_SaveDataSize = g_SaveDataSize + 1
    endmethod

    // 실제 서버에 저장 요청을 지연 실행
    static method DelayedSave takes nothing returns nothing
        local player p = Player(TimerTools.GetTimerInt(GetExpiredTimer()))
        local string serverName = GetPlayerServerName(p)
        local integer i = 0

        if GetLocalPlayer() == p then
            loop
                exitwhen i >= g_SaveDataSize
                call JNObjectCharacterSetString(serverName, g_SaveDataTitle[i], g_SaveDataCode[i])
                set i = i + 1
            endloop
            call JNObjectCharacterSave(Settings.API_MAP_CODE, serverName, Settings.API_SECRET_KEY, thistype.GetLastSelectedCharacter(p))
        endif

        call ResetCurrentData()
        call DestroyTimer(GetExpiredTimer())
    endmethod

    // 저장 작업을 시작
    // @param p 플레이어
    static method RunSaveHelper takes player p returns nothing
        local string serverName = GetPlayerServerName(p)
        local string lastChar = GetLastSelectedCharacter(p)

        if p == null or serverName == "" or lastChar == "" then
            // 입력 검증 실패 시 메시지
            call DisplayTimedTextToPlayer(p, 0.0, 0.0, 10.0, "|CFFFF0202Error) 잘못된 저장 호출입니다.|r")
            return
        endif

        if GetLocalPlayer() == p then
            call JNObjectCharacterClearField(serverName)
        endif
        call TimerStart(TimerTools.CreateTimerEx(GetPlayerId(p)), 1.0, false, function thistype.DelayedSave)
    endmethod

    // 키값에 대응하는 저장 코드를 설정
    // @param keyName 키
    // @param value 코드
    static method SetMatchedData takes string keyName, string value returns nothing
        local integer i = g_SaveDataSize
        loop
            exitwhen i <= 0
            set i = i - 1
            if g_SaveDataTitle[i] == keyName then
                set g_SaveDataCode[i] = value
            endif
        endloop
    endmethod

    // 키값에 대응하는 저장 코드를 반환
    // @param keyName 키
    // @return 코드 또는 null
    static method GetMatchedData takes string keyName returns string
        local integer i = g_SaveDataSize
        loop
            exitwhen i <= 0
            set i = i - 1
            if g_SaveDataTitle[i] == keyName then
                return g_SaveDataCode[i]
            endif
        endloop

        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 10.0, "GetMatchedData: 키를 찾을 수 없습니다.")
        return null
    endmethod

    // 서버에서 불러온 데이터를 순차 적용 후 로드 요청
    static method DelayedLoad2 takes nothing returns nothing
        local player p = Player(TimerTools.GetTimerInt(GetExpiredTimer()))
        local string serverName = GetPlayerServerName(p)
        local integer i = 0

        loop
            exitwhen i >= g_SaveDataSize
            set g_SaveDataCode[i] = SaveLoadCache.RetrieveStr(p, g_SaveDataTitle[i])
            set i = i + 1
        endloop
        
        call SaveLoad.RequestLoad(p)
        call SaveLoadCache.ClearPreloadData(p)
        call DestroyTimer(GetExpiredTimer())
    endmethod

    // 서버에서 데이터 읽기 요청 후 지연 로드2 호출
    static method DelayedLoad takes nothing returns nothing
        local player p = Player(TimerTools.GetTimerInt(GetExpiredTimer()))
        local string serverName = GetPlayerServerName(p)
        local integer i = 0

        if GetLocalPlayer() == p then
            loop
                exitwhen i >= g_SaveDataSize
                call SaveLoadCache.PreloadStr(p, g_SaveDataTitle[i] + "§" + JNObjectCharacterGetString(serverName, g_SaveDataTitle[i]))
                set i = i + 1
            endloop
        endif
        call SaveLoadCache.PreloadFinish(p)
        call TimerStart(GetExpiredTimer(), 0.5, false, function thistype.DelayedLoad2)
    endmethod

    // 로드 작업을 시작
    // @param p 플레이어
    // @param characterName 캐릭터 이름
    static method RunLoadHelper takes player p, string characterName returns nothing
        local string serverName = GetPlayerServerName(p)
        local string lastChar = GetLastSelectedCharacter(p)
        local integer i = 0

        if p == null or serverName == "" or characterName == "" then
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 10.0, "로드 실패 - 잘못된 호출")
            return
        endif

        call SaveLoadCache.PreloadStart(p)
        if not IsPlayerLoadedFromServer(p) then
            if GetLocalPlayer() == p then
                call JNObjectUserInit(Settings.API_MAP_CODE, serverName, Settings.API_SECRET_KEY, "")
            endif
            call SetPlayerLoadedFromServer(p, true)
        endif

        if lastChar != characterName then
            if GetLocalPlayer() == p then
                call JNObjectCharacterInit(Settings.API_MAP_CODE, serverName, Settings.API_SECRET_KEY, characterName)
            endif
            call SetLastSelectedCharacter(p, characterName)
        else
            if GetLocalPlayer() == p then
                call JNObjectCharacterClearField(serverName)
            endif
        endif

        call TimerStart(TimerTools.CreateTimerEx(GetPlayerId(p)), 1.0, false, function thistype.DelayedLoad)
    endmethod

    // 유저 데이터 적용 (추가 로드 단계)
    // @param p 플레이어
    static method ApplyUserLoad takes player p returns nothing
        local integer value = SaveLoadCache.RetrieveInt(p, "DCL")
        // 추가 처리: DonatorInfo.UpdateAllBonus() 등
    endmethod

    // 유저 데이터 로드 지연 처리 2
    static method DelayedUserLoad2 takes nothing returns nothing
        local player p = Player(TimerTools.GetTimerInt(GetExpiredTimer()))
        call ApplyUserLoad(p)
        call SaveLoadCache.ClearPreloadData(p)
        call DestroyTimer(GetExpiredTimer())
    endmethod

    // 유저 데이터 로드 지연 처리 1
    static method DelayedUserLoad takes nothing returns nothing
        local player p = Player(TimerTools.GetTimerInt(GetExpiredTimer()))
        local string serverName = GetPlayerServerName(p)
        
        if GetLocalPlayer() == p then
            call SaveLoadCache.PreloadInt(p, "DCL" +  "§" + I2S(JNObjectUserGetInt(serverName, "DCL")))
            call SaveLoadCache.PreloadFinish(p)
        endif
        call TimerStart(GetExpiredTimer(), 0.5, false, function thistype.DelayedUserLoad2)
    endmethod

    // 유저 데이터 로드 시작
    // @param p 플레이어
    static method LoadUserData takes player p returns nothing
        local string serverName = GetPlayerServerName(p)

        if p == null or serverName == "" then
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 10.0, "유저 로드 실패 - 잘못된 호출")
            return
        endif

        call SaveLoadCache.PreloadStart(p)
        if not IsPlayerLoadedFromServer(p) then
            if GetLocalPlayer() == p then
                call JNObjectUserInit(Settings.API_MAP_CODE, serverName, Settings.API_SECRET_KEY, "")
            endif
            call SetPlayerLoadedFromServer(p, true)
        endif

        call TimerStart(TimerTools.CreateTimerEx(GetPlayerId(p)), 1.0, false, function thistype.DelayedUserLoad)
    endmethod
endstruct