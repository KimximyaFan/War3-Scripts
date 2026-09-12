function MainSetup takes nothing returns nothing
    // 서버 상태 확인 및 API 초기화
    call JNUse()
    call JNObjectMapInit(Settings.API_MAP_CODE, Settings.API_SECRET_KEY)
endfunction

function MakeFrameUIs takes nothing returns nothing
    // 로그인 및 슬롯 프레임 UI 생성
    call LoginDialogUI.CreateLoginDialogUI()
    // 숨김
    call LoginDialogUI.HideMainFrame(GetLocalPlayer())
    
    // 선택창
    call SaveSelectDialog.CreateFrame()
    // 숨김
    call SaveSelectDialog.HideSelect()
    
    // 선택창 - 이벤트 등록
    call SaveSelectDialog.BindLoadButtonEvent(function SaveLoad.LoadSaveDataEvent)
endfunction


function TryAutoLogin takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= Settings.PLAYER_COUNT
        // 자동 로그인 시도
        call LoginDialogUI.CheckAutoLogin(Player(i))
        
        set i = i + 1
    endloop
endfunction

function ChatEventActions takes nothing returns nothing
    // 플레이어 채팅 이벤트 처리
    local player whichPlayer = GetTriggerPlayer()
    local string chat = GetEventPlayerChatString()
    local ServerPlayerInfo info = 0
    local integer size = 0

    if chat == "-save" then
        // 저장 명령
        call SaveLoad.RequestSave(whichPlayer)
        call DisplayTextToPlayer(whichPlayer, 0, 0, "|CFFFFCC00[명령어]|r 세이브")

    elseif chat == "-load" then
        // 불러오기 명령
        if GetLocalPlayer() == whichPlayer then
            call DzSyncData("LoadCh", SaveLoadData.GetLastSelectedCharacter(whichPlayer))
        endif
        call DisplayTextToPlayer(whichPlayer, 0, 0, "|CFFFFCC00[명령어]|r 로드 (" + SaveLoadData.GetLastSelectedCharacter(whichPlayer) + ")")

    elseif chat == "-선택창" then
        // 선택창 열기
        if GetLocalPlayer() == whichPlayer then
            call SaveSelectDialog.ShowSelect()
        endif
        call DisplayTextToPlayer(whichPlayer, 0, 0, "|CFFFFCC00[명령어]|r 선택창")

    elseif chat == "-닫기" then
        // 선택창 닫기
        if GetLocalPlayer() == whichPlayer then
            call SaveSelectDialog.HideSelect()
        endif
        call DisplayTextToPlayer(whichPlayer, 0, 0, "|CFFFFCC00[명령어]|r 선택창 닫기")

    elseif chat == "-새로고침" then
        // 캐릭터 리스트 재조회
        call SaveLoadManager.UpdateServerPlayerInfo(whichPlayer)
        set info = SaveLoadManager.GetServerPlayerInfo(whichPlayer)
        set size = info.GetCharacterCount()

        loop
            exitwhen size <= 0
            set size = size - 1
            call DisplayTextToPlayer(whichPlayer, 0, 0, "|CFFFFCC00[명령어]|r 캐릭터 : " + I2S(size) + " : " + info.GetCharacterName(size))
        endloop
    elseif JNStringContains(chat, "-이름변경 ") then
        set chat = JNStringSplit(chat, " ", 1)
        if GetLocalPlayer() == whichPlayer then
            call DzSyncData("NewChar", chat)
        endif
        call DisplayTextToPlayer(whichPlayer, 0, 0, "|CFFFFCC00[명령어]|r 슬롯 이름 변경 : " + chat)
    endif
endfunction

function SetupChatEvent takes nothing returns nothing
    // 채팅 명령 이벤트 등록
    local integer i = 0
    local trigger trig = CreateTrigger()

    loop
        exitwhen i >= Settings.PLAYER_COUNT
        call TriggerRegisterPlayerChatEvent(trig, Player(i), "-save", true)
        call TriggerRegisterPlayerChatEvent(trig, Player(i), "-load", true)
        call TriggerRegisterPlayerChatEvent(trig, Player(i), "-선택창", true)
        call TriggerRegisterPlayerChatEvent(trig, Player(i), "-닫기", true)
        call TriggerRegisterPlayerChatEvent(trig, Player(i), "-새로고침", true)
        call TriggerRegisterPlayerChatEvent(trig, Player(i), "-이름변경 ", false)
        
        set i = i + 1
    endloop

    call TriggerAddAction(trig, function ChatEventActions)
    set trig = null
endfunction

function InitTrig_SomeExamples takes nothing returns nothing
    // 초기 트리거 설정
    local trigger trigInit = null

    // 0초 후 MainSetup
    set trigInit = CreateTrigger()
    call TriggerRegisterTimerEvent(trigInit, 0.00, false)
    call TriggerAddAction(trigInit, function MainSetup)

    // 1초 후 UI 생성
    set trigInit = CreateTrigger()
    call TriggerRegisterTimerEvent(trigInit, 1.00, false)
    call TriggerAddAction(trigInit, function MakeFrameUIs)

    // 2초 후 자동로그인
    set trigInit = CreateTrigger()
    call TriggerRegisterTimerEvent(trigInit, 2.00, false)
    call TriggerAddAction(trigInit, function TryAutoLogin)

    // 3초 후 채팅 이벤트 등록
    set trigInit = CreateTrigger()
    call TriggerRegisterTimerEvent(trigInit, 3.00, false)
    call TriggerAddAction(trigInit, function SetupChatEvent)
endfunction