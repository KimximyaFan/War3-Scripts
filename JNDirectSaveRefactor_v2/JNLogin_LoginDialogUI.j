
library LoginDialogUI requires Settings, TimerTools, SaveLoadData, SaveLoadLibrary, SaveLoad, SaveSelectDialog
    struct LoginDialogEvent
        static method OnClickLoginButton takes nothing returns nothing
            call LoginDialogUI.ClickCancelButton(DzGetTriggerUIEventPlayer())
            call LoginDialogUI.ToggleFrame(DzGetTriggerUIEventPlayer())
        endmethod

        static method OnClickConfirmButton takes nothing returns nothing
            if LoginDialogUI.IsConfirmMode() then
                if LoginDialogUI.RequestLogIn(DzGetTriggerUIEventPlayer()) then
                    call LoginDialogUI.HideMainFrame(DzGetTriggerUIEventPlayer())
                endif
            else
                call LoginDialogUI.ToggleConfirmMode(DzGetTriggerUIEventPlayer())
            endif
        endmethod

        static method OnClickCancelButton takes nothing returns nothing
            if LoginDialogUI.IsConfirmMode() then
                call LoginDialogUI.ClickCancelButton(DzGetTriggerUIEventPlayer())
            else
                call LoginDialogUI.ClickCancelButton(DzGetTriggerUIEventPlayer())
                call LoginDialogUI.HideMainFrame(DzGetTriggerUIEventPlayer())
            endif
        endmethod

        static method OnClickShowPasswordButton takes nothing returns nothing
            call LoginDialogUI.ToggleShowPassword(DzGetTriggerUIEventPlayer())
        endmethod

        static method OnChangeNameEditBoxText takes nothing returns nothing
            call LoginDialogUI.ChangeNameEditBoxText(DzGetTriggerUIEventPlayer(), DzFrameGetText(DzFrameFindByName("LoginDialogIdEditBox", 0)))
        endmethod

        static method OnChangePasswordEditBoxText takes nothing returns nothing
            call LoginDialogUI.ChangePasswordEditBoxText(DzGetTriggerUIEventPlayer(), DzFrameGetText(DzFrameFindByName("LoginDialogPasswordEditBox", 0)))
        endmethod

        static method OnPressTabKey takes nothing returns nothing
            call LoginDialogUI.PressTabKey(DzGetTriggerKeyPlayer())
        endmethod
    endstruct

    struct LoginDialogUI
        private static constant integer PLAYER_NAME_MAXIMUM_SIZE    = 16
        private static constant string  CUSTOM_SPLIT_WORD            = ",;|"
        private static constant integer PLAYER_PASSWORD_MINIMUM_SIZE = 1
        private static constant integer PLAYER_PASSWORD_MAXIMUM_SIZE = 20
        private static constant boolean IS_PASSWORD_ONLY_ENGLISH     = false

        private static boolean g_IsFrameVisible    = false
        private static boolean g_IsShowPassword    = false
        private static boolean g_IsConfirmMode     = false
        private static integer g_MainFrame         = 0

        private static string  m_WrittenName       = ""
        private static string  m_DisplayedPassword = ""
        private static string  m_RealPassword      = ""

        static method CheckAutoLogin takes player whichPlayer returns nothing
            if GetLocalPlayer() == whichPlayer then
                if JNGetSettingLogin() then
                    call DisplayTextToPlayer(whichPlayer, 0, 0, "|CFFFFCC00설정된 SupportMainID.txt에 따라 자동 로그인되었습니다.|r")
                    if JNLocalLogin(GetPlayerName(whichPlayer)) then
                        call DzSyncData("LogIn", GetPlayerName(whichPlayer))
                    else
                        call DisplayTextToPlayer(whichPlayer, 0, 0, "|CFFFFCC00자동 로그인에 실패했습니다. 직접 로그인하세요.|r")
                        call thistype.ShowMainFrame(whichPlayer)
                    endif
                else
                    call DisplayTextToPlayer(whichPlayer, 0, 0, "|Cff48ff94[TIP] 툴 설정에서 자동로그인을 등록하세요.|r")
                    call thistype.ShowMainFrame(whichPlayer)
                endif
            endif
        endmethod

        static method ShowMainFrame takes player whichPlayer returns nothing
            if GetLocalPlayer() == whichPlayer then
                set g_IsFrameVisible = true
                call DzFrameShow(g_MainFrame, true)
            endif
        endmethod

        static method HideMainFrame takes player whichPlayer returns nothing
            if GetLocalPlayer() == whichPlayer then
                set g_IsFrameVisible  = false
                set g_IsConfirmMode   = false
                call DzFrameSetFocus(DzFrameFindByName("LoginDialogIdEditBox", 0), false)
                call DzFrameSetFocus(DzFrameFindByName("LoginDialogPasswordEditBox", 0), false)
                call DzFrameShow(g_MainFrame, false)
            endif
        endmethod

        static method ToggleFrame takes player whichPlayer returns nothing
            if GetLocalPlayer() == whichPlayer then
                set g_IsFrameVisible = not g_IsFrameVisible
                call DzFrameShow(g_MainFrame, g_IsFrameVisible)
            endif
        endmethod

        static method IsConfirmMode takes nothing returns boolean
            return g_IsConfirmMode
        endmethod

        private static method GetCountOfStar takes integer count returns string
            local string result = ""
            loop
                exitwhen count <= 0
                set result = result + "*"
                set count  = count - 1
            endloop
            return result
        endmethod

        static method UpdatePassword takes string pwd returns nothing
            if g_IsShowPassword then
                set m_DisplayedPassword = pwd
            else
                set m_DisplayedPassword = thistype.GetCountOfStar(StringLength(pwd))
            endif
            call DzFrameSetText(DzFrameFindByName("LoginDialogPasswordEditBox", 0), m_DisplayedPassword)
        endmethod

        static method ToggleShowPassword takes player whichPlayer returns nothing
            if GetLocalPlayer() == whichPlayer then
                set g_IsShowPassword = not g_IsShowPassword
                if g_IsShowPassword then
                    call DzFrameSetTexture(DzFrameFindByName("LoginDialogShowPasswordButtonA", 0), "UI\\Glues\\BattleNet\\BattlenetWorkingExpansion\\BNetWorkingExp0020.blp", 0)
                else
                    call DzFrameSetTexture(DzFrameFindByName("LoginDialogShowPasswordButtonA", 0), "UI\\Glues\\BattleNet\\BattlenetWorkingExpansion\\BNetWorkingExp0004.blp", 0)
                endif
                call DzFrameShow(DzFrameFindByName("LoginDialogShowPasswordButtonDisabled", 0), not g_IsShowPassword)
                call thistype.UpdatePassword(m_RealPassword)
            endif
        endmethod

        static method ChangeNameEditBoxText takes player whichPlayer, string newText returns nothing
            if GetLocalPlayer() == whichPlayer and m_WrittenName != newText then
                if JNStringCount(newText, "[" + CUSTOM_SPLIT_WORD + "]") > 0 then
                    call DzFrameSetText(DzFrameFindByName("LoginDialogTooltip", 0), "사용할 수 없는 특수문자 포함")
                else
                    set newText = JNStringRegex(newText, "^[^" + CUSTOM_SPLIT_WORD + "]+$", 0)
                    if StringLength(newText) > PLAYER_NAME_MAXIMUM_SIZE then
                        set newText = SubString(newText, 0, PLAYER_NAME_MAXIMUM_SIZE)
                        call DzFrameSetText(DzFrameFindByName("LoginDialogTooltip", 0), "ID는 최대 " + I2S(PLAYER_NAME_MAXIMUM_SIZE) + "자")
                    else
                        call DzFrameSetText(DzFrameFindByName("LoginDialogTooltip", 0), "")
                    endif
                endif
                set m_WrittenName = newText
                call DzFrameSetText(DzFrameFindByName("LoginDialogIdEditBox", 0), m_WrittenName)
            endif
        endmethod

        static method ChangePasswordEditBoxText takes player whichPlayer, string originText returns nothing
            local integer origLen  = StringLength(originText)
            local integer dispLen  = StringLength(m_DisplayedPassword)
            local string  delta    = ""
        
            if GetLocalPlayer() == whichPlayer and origLen != dispLen then
                if origLen > dispLen then
                    set delta = JNStringReplace(originText, "*", "")
        
                    if JNStringCount(delta, "[ㄱ-ㅣ가-힣]") > 0 then
                        call DzFrameSetText(DzFrameFindByName("LoginDialogTooltip", 0), "한글 불가")
                        return
                    endif
        
                    if JNStringCount(delta, "[" + CUSTOM_SPLIT_WORD + "]") > 0 then
                        call DzFrameSetText(DzFrameFindByName("LoginDialogTooltip", 0), "특수문자 불가")
                        return
                    endif
        
                    if IS_PASSWORD_ONLY_ENGLISH then
                        set delta = JNStringRegex(delta, "[A-Za-z0-9]$", 0)
                    else
                        set delta = JNStringRegex(delta, ".$", 0)
                    endif
        
                    if delta != "" then
                        set m_RealPassword = m_RealPassword + delta
        
                        if StringLength(m_RealPassword) > PLAYER_PASSWORD_MAXIMUM_SIZE then
                            set m_RealPassword = SubString(m_RealPassword, 0, PLAYER_PASSWORD_MAXIMUM_SIZE)
                            call DzFrameSetText(DzFrameFindByName("LoginDialogTooltip", 0), "PW는 최대 " + I2S(PLAYER_PASSWORD_MAXIMUM_SIZE) + "자")
                        elseif StringLength(m_RealPassword) < PLAYER_PASSWORD_MINIMUM_SIZE then
                            call DzFrameSetText(DzFrameFindByName("LoginDialogTooltip", 0), "PW는 최소 " + I2S(PLAYER_PASSWORD_MINIMUM_SIZE) + "자")
                        endif
        
                        call thistype.UpdatePassword(m_RealPassword)
                    endif
        
                else
                    set m_RealPassword = SubString(m_RealPassword, 0, origLen)
                    call thistype.UpdatePassword(m_RealPassword)
                endif
            endif
        endmethod
        
        static method PressTabKey takes player whichPlayer returns nothing
            if GetLocalPlayer() == whichPlayer and g_IsFrameVisible then
                if m_WrittenName == "" then
                    call DzFrameSetFocus(DzFrameFindByName("LoginDialogIdEditBox", 0), true)
                elseif m_DisplayedPassword == "" then
                    call DzFrameSetFocus(DzFrameFindByName("LoginDialogPasswordEditBox", 0), true)
                elseif not g_IsConfirmMode then
                    call thistype.ToggleConfirmMode(whichPlayer)
                else
                    if thistype.RequestLogIn(whichPlayer) then
                        call thistype.HideMainFrame(whichPlayer)
                    endif
                endif
            endif
        endmethod
        
        private static method DelayedSyncRequestLogIn takes nothing returns nothing
            local player whichPlayer = Player(TimerTools.GetTimerInt(GetExpiredTimer()))
            call SaveSelectDialog.RefreshSlot(whichPlayer)
            if GetLocalPlayer() == whichPlayer then
                call SaveSelectDialog.ShowSelect()
                call DzFrameShow(DzFrameFindByName("LoginButton", 0), false)
            endif
            call SaveLoad.Unlock(whichPlayer)
            call TimerTools.DestroyTimerEx(GetExpiredTimer())
        endmethod
        
        private static method SyncRequestLogIn takes nothing returns nothing
            local player whichPlayer = DzGetTriggerSyncPlayer()
            local string name = DzGetTriggerSyncData()
    
            call SaveLoadData.SetPlayerServerName(whichPlayer, name)
        
            call TimerStart(TimerTools.CreateTimerEx(GetPlayerId(whichPlayer)), 1.0, false, function LoginDialogUI.DelayedSyncRequestLogIn)
        endmethod

        static method RequestLogIn takes player whichPlayer returns boolean
            if GetLocalPlayer() == whichPlayer then
                if JNLogin(m_WrittenName, m_RealPassword) then
                    call DzSyncData("LogIn", m_WrittenName)
                    set m_RealPassword = ""
                    set m_DisplayedPassword = ""
                    return true
                endif
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|CFFFFCC00[로그인]|r 실패했습니다.")
                set g_IsConfirmMode = false
                call thistype.ShowMainFrame(whichPlayer)
                return false
            endif
            return false
        endmethod

        static method ToggleConfirmMode takes player whichPlayer returns nothing
            local string name = DzFrameGetText(DzFrameFindByName("LoginDialogIdEditBox", 0))
            local string pw   = DzFrameGetText(DzFrameFindByName("LoginDialogPasswordEditBox", 0))
        
            if GetLocalPlayer() == whichPlayer then
                if name == "" or JNStringCount(name, "[" + CUSTOM_SPLIT_WORD + "]") > 0 then
                    call DzFrameSetText(DzFrameFindByName("LoginDialogTooltip", 0), "ID를 올바르게 입력하세요")
                elseif StringLength(pw) < PLAYER_PASSWORD_MINIMUM_SIZE or StringLength(pw) > PLAYER_PASSWORD_MAXIMUM_SIZE then
                    call DzFrameSetText(DzFrameFindByName("LoginDialogTooltip", 0), "PW 길이를 확인하세요")
                else
                    set g_IsConfirmMode = not g_IsConfirmMode
        
                    if g_IsConfirmMode then
                        call DzFrameSetSize(g_MainFrame, 0.3, 0.17)
                        call DzFrameSetText(DzFrameFindByName("LoginDialogIdLabel", 0), name)
                        call DzFrameSetText(DzFrameFindByName("LoginDialogPasswordLabel", 0), pw)
                        call DzFrameSetText(DzFrameFindByName("LoginDialogConfirmButton", 0), "확인")
                    else
                        call DzFrameSetSize(g_MainFrame, 0.3, 0.25)
                        call DzFrameSetText(DzFrameFindByName("LoginDialogIdTitle", 0), "아이디를 입력하세요")
                        call DzFrameSetText(DzFrameFindByName("LoginDialogConfirmButton", 0), "결정")
                    endif
                    call DzFrameShow(DzFrameFindByName("LoginDialogPasswordTitle", 0), not g_IsConfirmMode)
                    call DzFrameShow(DzFrameFindByName("LoginDialogIdEditBox", 0), not g_IsConfirmMode)
                    call DzFrameShow(DzFrameFindByName("LoginDialogPasswordEditBox", 0), not g_IsConfirmMode)
                    call DzFrameShow(DzFrameFindByName("LoginDialogIdLabel", 0), g_IsConfirmMode)
                    call DzFrameShow(DzFrameFindByName("LoginDialogPasswordLabel", 0), g_IsConfirmMode)
                    call DzFrameShow(DzFrameFindByName("LoginDialogTooltip", 0), not g_IsConfirmMode)
                endif
            endif
        endmethod

        static method ClickCancelButton takes player whichPlayer returns nothing
            if GetLocalPlayer() == whichPlayer then
                set g_IsConfirmMode = false
                call DzFrameSetSize(g_MainFrame, 0.3, 0.25)
                call DzFrameShow(DzFrameFindByName("LoginDialogTooltip", 0), true)
                call DzFrameSetText(DzFrameFindByName("LoginDialogConfirmButton", 0), "결정")
                call DzFrameShow(DzFrameFindByName("LoginDialogPasswordTitle", 0), not g_IsConfirmMode)
                call DzFrameShow(DzFrameFindByName("LoginDialogIdEditBox", 0), not g_IsConfirmMode)
                call DzFrameShow(DzFrameFindByName("LoginDialogPasswordEditBox", 0), not g_IsConfirmMode)
                call DzFrameShow(DzFrameFindByName("LoginDialogIdLabel", 0), g_IsConfirmMode)
                call DzFrameShow(DzFrameFindByName("LoginDialogPasswordLabel", 0), g_IsConfirmMode)
                call DzFrameShow(DzFrameFindByName("LoginDialogTooltip", 0), not g_IsConfirmMode)
            endif
        endmethod

        static method CreateLoginDialogUI takes nothing returns nothing
            local integer UI = DzGetGameUI()
            local integer btnLogin = 0
            local trigger trig = CreateTrigger()
            
            call DzLoadToc("UI\\LoginDialog.toc")
            set btnLogin = DzCreateFrame("LoginButton", UI, 0)
            call DzFrameSetAbsolutePoint(btnLogin, JN_FRAMEPOINT_CENTER, 0.0229, 0.555)
            call DzFrameSetScriptByCode(btnLogin, JN_FRAMEEVENT_CONTROL_CLICK, function LoginDialogEvent.OnClickLoginButton, false)
        
            set g_MainFrame = DzCreateFrame("LoginDialog", UI, 0)
            call DzFrameSetAbsolutePoint(g_MainFrame, JN_FRAMEPOINT_CENTER, 0.4, 0.35)
        
            call DzFrameSetScriptByCode(DzFrameFindByName("LoginDialogShowPasswordButton", 0), JN_FRAMEEVENT_CONTROL_CLICK, function LoginDialogEvent.OnClickShowPasswordButton, false)
            call DzFrameSetScriptByCode(DzFrameFindByName("LoginDialogConfirmButton",      0), JN_FRAMEEVENT_CONTROL_CLICK, function LoginDialogEvent.OnClickConfirmButton,     false)
            call DzFrameSetScriptByCode(DzFrameFindByName("LoginDialogCancelButton",       0), JN_FRAMEEVENT_CONTROL_CLICK, function LoginDialogEvent.OnClickCancelButton,      false)
            call DzFrameSetScriptByCode(DzFrameFindByName("LoginDialogIdEditBox",          0), JN_FRAMEEVENT_EDITBOX_TEXT_CHANGED, function LoginDialogEvent.OnChangeNameEditBoxText,     false)
            call DzFrameSetScriptByCode(DzFrameFindByName("LoginDialogPasswordEditBox",    0), JN_FRAMEEVENT_EDITBOX_TEXT_CHANGED, function LoginDialogEvent.OnChangePasswordEditBoxText, false)
        
            call JNTriggerRegisterSyncData(trig, "LogIn", false)
            call TriggerAddAction(trig, function thistype.SyncRequestLogIn)
        
            call DzTriggerRegisterKeyEventByCode(trig, JN_OSKEY_TAB, bj_KEYEVENTTYPE_RELEASE, false, function LoginDialogEvent.OnPressTabKey)
        endmethod
    endstruct
endlibrary
