
scope JNLoginInit initializer Init

function JNLogin_MainSetup takes nothing returns nothing
    call JNUse()
    call JNObjectMapInit(Settings.API_MAP_CODE, Settings.API_SECRET_KEY)
endfunction

function JNLogin_CreateUI takes nothing returns nothing
    call LoginDialogUI.CreateLoginDialogUI()
    call LoginDialogUI.HideMainFrame(GetLocalPlayer())

    call SaveSelectDialog.CreateFrame()
    call SaveSelectDialog.HideSelect()
    call SaveSelectDialog.BindLoadButtonEvent(function SaveLoad.LoadSaveDataEvent)
endfunction

function JNLogin_TryAutoLogin takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= Settings.PLAYER_COUNT
        if GetPlayerController(Player(i)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
            call LoginDialogUI.CheckAutoLogin(Player(i))
        endif
        set i = i + 1
    endloop
endfunction

function JNLogin_ChatAction takes nothing returns nothing
    local player p = GetTriggerPlayer()
    local string chat = GetEventPlayerChatString()

    if chat == "-save" then
        call SaveLoad.RequestSave(p)
    elseif chat == "-load" then
        if SaveLoadData.HasSelectedCharacter(p) and GetLocalPlayer() == p then
            call DzSyncData("LoadCh", SaveLoadData.GetLastSelectedCharacter(p))
        endif
    elseif chat == "-선택창" then
        if GetLocalPlayer() == p then
            call SaveSelectDialog.RefreshSlot(p)
            call SaveSelectDialog.ShowSelect()
        endif
    elseif chat == "-닫기" then
        if GetLocalPlayer() == p then
            call SaveSelectDialog.HideSelect()
        endif
    endif

    set p = null
endfunction

function JNLogin_SetupChatEvent takes nothing returns nothing
    local trigger t = CreateTrigger()
    local integer i = 0
    loop
        exitwhen i >= Settings.PLAYER_COUNT
        call TriggerRegisterPlayerChatEvent(t, Player(i), "-save", true)
        call TriggerRegisterPlayerChatEvent(t, Player(i), "-load", true)
        call TriggerRegisterPlayerChatEvent(t, Player(i), "-선택창", true)
        call TriggerRegisterPlayerChatEvent(t, Player(i), "-닫기", true)
        set i = i + 1
    endloop
    call TriggerAddAction(t, function JNLogin_ChatAction)
    set t = null
endfunction

function Init takes nothing returns nothing
    local trigger t

    set t = CreateTrigger()
    call TriggerRegisterTimerEvent(t, 0.00, false)
    call TriggerAddAction(t, function JNLogin_MainSetup)

    set t = CreateTrigger()
    call TriggerRegisterTimerEvent(t, 1.00, false)
    call TriggerAddAction(t, function JNLogin_CreateUI)

    set t = CreateTrigger()
    call TriggerRegisterTimerEvent(t, 2.00, false)
    call TriggerAddAction(t, function JNLogin_TryAutoLogin)

    set t = CreateTrigger()
    call TriggerRegisterTimerEvent(t, 3.00, false)
    call TriggerAddAction(t, function JNLogin_SetupChatEvent)

    set t = null
endfunction

endscope