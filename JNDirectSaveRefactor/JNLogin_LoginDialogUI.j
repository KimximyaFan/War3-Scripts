///////////////////////////////////////////////////////////////////////////
// LoginDialogUI - 로그인 프레임 관리
///////////////////////////////////////////////////////////////////////////
library LoginDialogUI requires Settings, TimerTools, SaveLoadData, SaveLoadLibrary, SaveLoad, SaveSelectDialog
    struct LoginDialogEvent
        // [로그인] 버튼 클릭
        static method OnClickLoginButton takes nothing returns nothing
            call LoginDialogUI.ClickCancelButton(DzGetTriggerUIEventPlayer())
            call LoginDialogUI.ToggleFrame(DzGetTriggerUIEventPlayer())
        endmethod

        // [결정]/[확인] 버튼 클릭
        static method OnClickConfirmButton takes nothing returns nothing
            if LoginDialogUI.IsConfirmMode() then
                if LoginDialogUI.RequestLogIn(DzGetTriggerUIEventPlayer()) then
                    call LoginDialogUI.HideMainFrame(DzGetTriggerUIEventPlayer())
                endif
            else
                call LoginDialogUI.ToggleConfirmMode(DzGetTriggerUIEventPlayer())
            endif
        endmethod

        // [취소] 버튼 클릭
        static method OnClickCancelButton takes nothing returns nothing
            if LoginDialogUI.IsConfirmMode() then
                call LoginDialogUI.ClickCancelButton(DzGetTriggerUIEventPlayer())
            else
                call LoginDialogUI.ClickCancelButton(DzGetTriggerUIEventPlayer())
                call LoginDialogUI.HideMainFrame(DzGetTriggerUIEventPlayer())
            endif
        endmethod

        // [눈 모양] 비밀번호 보이기 토글
        static method OnClickShowPasswordButton takes nothing returns nothing
            call LoginDialogUI.ToggleShowPassword(DzGetTriggerUIEventPlayer())
        endmethod

        // ID 입력 텍스트 변경
        static method OnChangeNameEditBoxText takes nothing returns nothing
            call LoginDialogUI.ChangeNameEditBoxText(DzGetTriggerUIEventPlayer(), DzFrameGetText(DzFrameFindByName("LoginDialogIdEditBox", 0)))
        endmethod

        // PW 입력 텍스트 변경
        static method OnChangePasswordEditBoxText takes nothing returns nothing
            call LoginDialogUI.ChangePasswordEditBoxText(DzGetTriggerUIEventPlayer(), DzFrameGetText(DzFrameFindByName("LoginDialogPasswordEditBox", 0)))
        endmethod

        // Tab 키 입력 처리
        static method OnPressTabKey takes nothing returns nothing
            call LoginDialogUI.PressTabKey(DzGetTriggerKeyPlayer())
        endmethod
    endstruct

    struct LoginDialogUI
        ///////////////////////////////////////////////////////////////////////////
        // 설정 상수
        private static constant integer PLAYER_NAME_MAXIMUM_SIZE    = 16      // ID 최대 길이
        private static constant string  CUSTOM_SPLIT_WORD            = ",;|"   // 비허용 특수문자
        private static constant integer PLAYER_PASSWORD_MINIMUM_SIZE = 1       // PW 최소 길이
        private static constant integer PLAYER_PASSWORD_MAXIMUM_SIZE = 20      // PW 최대 길이
        private static constant boolean IS_PASSWORD_ONLY_ENGLISH     = false   // 영문/숫자만 허용

        ///////////////////////////////////////////////////////////////////////////
        // 상태 변수
        private static boolean g_IsFrameVisible    = false              // UI 표시 여부
        private static boolean g_IsShowPassword    = false              // PW 표시 여부
        private static boolean g_IsConfirmMode     = false              // 확인 모드 여부
        private static integer g_MainFrame         = 0                  // 메인 프레임 핸들

        ///////////////////////////////////////////////////////////////////////////
        // 입력값 저장 변수
        private static string  m_WrittenName       = ""                 // 입력된 ID
        private static string  m_DisplayedPassword = ""                 // 화면에 표시될 PW
        private static string  m_RealPassword      = ""                 // 실제 PW

        ///////////////////////////////////////////////////////////////////////////
        // 자동 로그인 처리
        // @param whichPlayer   처리 대상 플레이어
        ///////////////////////////////////////////////////////////////////////////
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

        ///////////////////////////////////////////////////////////////////////////
        // 메인 프레임 표시
        // @param whichPlayer   처리 대상 플레이어
        ///////////////////////////////////////////////////////////////////////////
        static method ShowMainFrame takes player whichPlayer returns nothing
            if GetLocalPlayer() == whichPlayer then
                set g_IsFrameVisible = true
                call DzFrameShow(g_MainFrame, true)
            endif
        endmethod

        ///////////////////////////////////////////////////////////////////////////
        // 메인 프레임 숨김
        // @param whichPlayer   처리 대상 플레이어
        ///////////////////////////////////////////////////////////////////////////
        static method HideMainFrame takes player whichPlayer returns nothing
            if GetLocalPlayer() == whichPlayer then
                set g_IsFrameVisible  = false
                set g_IsConfirmMode   = false
                call DzFrameSetFocus(DzFrameFindByName("LoginDialogIdEditBox", 0), false)
                call DzFrameSetFocus(DzFrameFindByName("LoginDialogPasswordEditBox", 0), false)
                call DzFrameShow(g_MainFrame, false)
            endif
        endmethod

        ///////////////////////////////////////////////////////////////////////////
        // 프레임 토글
        // @param whichPlayer   처리 대상 플레이어
        ///////////////////////////////////////////////////////////////////////////
        static method ToggleFrame takes player whichPlayer returns nothing
            if GetLocalPlayer() == whichPlayer then
                set g_IsFrameVisible = not g_IsFrameVisible
                call DzFrameShow(g_MainFrame, g_IsFrameVisible)
            endif
        endmethod

        ///////////////////////////////////////////////////////////////////////////
        // 확인 모드 여부 반환
        // @return boolean
        ///////////////////////////////////////////////////////////////////////////
        static method IsConfirmMode takes nothing returns boolean
            return g_IsConfirmMode
        endmethod

        ///////////////////////////////////////////////////////////////////////////
        // 별표 문자열 생성
        // @param count  별표 개수
        // @return string
        ///////////////////////////////////////////////////////////////////////////
        private static method GetCountOfStar takes integer count returns string
            local string result = ""
            loop
                exitwhen count <= 0
                set result = result + "*"
                set count  = count - 1
            endloop
            return result
        endmethod

        ///////////////////////////////////////////////////////////////////////////
        // PW 표시 갱신
        // @param pwd  입력된 PW
        ///////////////////////////////////////////////////////////////////////////
        static method UpdatePassword takes string pwd returns nothing
            if g_IsShowPassword then
                set m_DisplayedPassword = pwd
            else
                set m_DisplayedPassword = thistype.GetCountOfStar(StringLength(pwd))
            endif
            call DzFrameSetText(DzFrameFindByName("LoginDialogPasswordEditBox", 0), m_DisplayedPassword)
        endmethod

        ///////////////////////////////////////////////////////////////////////////
        // PW 표시 토글
        // @param whichPlayer   처리 대상 플레이어
        ///////////////////////////////////////////////////////////////////////////
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

        ///////////////////////////////////////////////////////////////////////////
        // ID 입력 검증 및 갱신
        // @param whichPlayer   처리 대상 플레이어
        // @param newText       입력된 텍스트
        ///////////////////////////////////////////////////////////////////////////
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
        
        ///////////////////////////////////////////////////////////////////////////
        // PW 입력 검증 및 갱신
        // @param whichPlayer   처리 대상 플레이어
        // @param originText    입력된 원본 텍스트
        ///////////////////////////////////////////////////////////////////////////
        static method ChangePasswordEditBoxText takes player whichPlayer, string originText returns nothing
            local integer origLen  = StringLength(originText)
            local integer dispLen  = StringLength(m_DisplayedPassword)
            local string  delta    = ""
        
            if GetLocalPlayer() == whichPlayer and origLen != dispLen then
                // 입력된 글자 수가 늘어난 경우
                if origLen > dispLen then
                    // 새로 들어온 문자만 추출
                    set delta = JNStringReplace(originText, "*", "")
        
                    // 한글 및 금지문자 체크
                    if JNStringCount(delta, "[ㄱ-ㅣ가-힣]") > 0 then
                        call DzFrameSetText(DzFrameFindByName("LoginDialogTooltip", 0), "한글 불가")
                        return
                    endif
        
                    if JNStringCount(delta, "[" + CUSTOM_SPLIT_WORD + "]") > 0 then
                        call DzFrameSetText(DzFrameFindByName("LoginDialogTooltip", 0), "특수문자 불가")
                        return
                    endif
        
                    // 영어/숫자만 허용할 경우 필터링
                    if IS_PASSWORD_ONLY_ENGLISH then
                        set delta = JNStringRegex(delta, "[A-Za-z0-9]$", 0)
                    else
                        set delta = JNStringRegex(delta, ".$", 0)
                    endif
        
                    // 실제 비밀번호에 추가
                    if delta != "" then
                        set m_RealPassword = m_RealPassword + delta
        
                        // 길이 제한 체크
                        if StringLength(m_RealPassword) > PLAYER_PASSWORD_MAXIMUM_SIZE then
                            set m_RealPassword = SubString(m_RealPassword, 0, PLAYER_PASSWORD_MAXIMUM_SIZE)
                            call DzFrameSetText(DzFrameFindByName("LoginDialogTooltip", 0), "PW는 최대 " + I2S(PLAYER_PASSWORD_MAXIMUM_SIZE) + "자")
                        elseif StringLength(m_RealPassword) < PLAYER_PASSWORD_MINIMUM_SIZE then
                            call DzFrameSetText(DzFrameFindByName("LoginDialogTooltip", 0), "PW는 최소 " + I2S(PLAYER_PASSWORD_MINIMUM_SIZE) + "자")
                        endif
        
                        call thistype.UpdatePassword(m_RealPassword)
                    endif
        
                // 입력된 글자 수가 줄어든 경우
                else
                    set m_RealPassword = SubString(m_RealPassword, 0, origLen)
                    call thistype.UpdatePassword(m_RealPassword)
                endif
            endif
        endmethod
        
        ///////////////////////////////////////////////////////////////////////////
        // Tab 키 처리: 포커스 이동 및 확인/요청
        // @param whichPlayer   처리 대상 플레이어
        ///////////////////////////////////////////////////////////////////////////
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
        
        ///////////////////////////////////////////////////////////////////////////
        // 로그인 완료 후 UI 전환 대기
        ///////////////////////////////////////////////////////////////////////////
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
        
        ///////////////////////////////////////////////////////////////////////////
        // 동기화된 로그인 처리
        ///////////////////////////////////////////////////////////////////////////
        private static method SyncRequestLogIn takes nothing returns nothing
            local player whichPlayer = DzGetTriggerSyncPlayer()
            local string name = DzGetTriggerSyncData()
    
            call SaveLoadData.SetPlayerServerName(whichPlayer, name)
        
            call TimerStart(TimerTools.CreateTimerEx(GetPlayerId(whichPlayer)), 1.0, false, function LoginDialogUI.DelayedSyncRequestLogIn)
        endmethod
        
        ///////////////////////////////////////////////////////////////////////////
        // 로그인 요청
        // @param whichPlayer   처리 대상 플레이어
        ///////////////////////////////////////////////////////////////////////////
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
        
        ///////////////////////////////////////////////////////////////////////////
        // 확인 모드 토글: UI 크기 및 버튼 텍스트 변경
        // @param whichPlayer   처리 대상 플레이어
        ///////////////////////////////////////////////////////////////////////////
        static method ToggleConfirmMode takes player whichPlayer returns nothing
            local string name = DzFrameGetText(DzFrameFindByName("LoginDialogIdEditBox", 0))
            local string pw   = DzFrameGetText(DzFrameFindByName("LoginDialogPasswordEditBox", 0))
        
            if GetLocalPlayer() == whichPlayer then
                // ID 유효성 체크
                if name == "" or JNStringCount(name, "[" + CUSTOM_SPLIT_WORD + "]") > 0 then
                    call DzFrameSetText(DzFrameFindByName("LoginDialogTooltip", 0), "ID를 올바르게 입력하세요")
                // PW 길이 체크
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
        
        ///////////////////////////////////////////////////////////////////////////
        // 취소 버튼 동작 복원
        // @param whichPlayer   처리 대상 플레이어
        ///////////////////////////////////////////////////////////////////////////
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
        
        ///////////////////////////////////////////////////////////////////////////
        // UI 생성: 버튼 및 이벤트 바인딩
        ///////////////////////////////////////////////////////////////////////////
        static method CreateLoginDialogUI takes nothing returns nothing
            local integer UI = DzGetGameUI()
            // [로그인] 버튼 생성
            local integer btnLogin = 0
            local trigger trig = CreateTrigger()
            
            call DzLoadToc("UI\\LoginDialog.toc")
            set btnLogin = DzCreateFrame("LoginButton", UI, 0)
            call DzFrameSetAbsolutePoint(btnLogin, JN_FRAMEPOINT_CENTER, 0.0229, 0.555)
            call DzFrameSetScriptByCode(btnLogin, JN_FRAMEEVENT_CONTROL_CLICK, function LoginDialogEvent.OnClickLoginButton, false)
        
            // 메인 다이얼로그 생성
            set g_MainFrame = DzCreateFrame("LoginDialog", UI, 0)
            call DzFrameSetAbsolutePoint(g_MainFrame, JN_FRAMEPOINT_CENTER, 0.4, 0.35)
        
            // 스크립트 바인딩
            call DzFrameSetScriptByCode(DzFrameFindByName("LoginDialogShowPasswordButton", 0), JN_FRAMEEVENT_CONTROL_CLICK, function LoginDialogEvent.OnClickShowPasswordButton, false)
            call DzFrameSetScriptByCode(DzFrameFindByName("LoginDialogConfirmButton",      0), JN_FRAMEEVENT_CONTROL_CLICK, function LoginDialogEvent.OnClickConfirmButton,     false)
            call DzFrameSetScriptByCode(DzFrameFindByName("LoginDialogCancelButton",       0), JN_FRAMEEVENT_CONTROL_CLICK, function LoginDialogEvent.OnClickCancelButton,      false)
            call DzFrameSetScriptByCode(DzFrameFindByName("LoginDialogIdEditBox",          0), JN_FRAMEEVENT_EDITBOX_TEXT_CHANGED, function LoginDialogEvent.OnChangeNameEditBoxText,     false)
            call DzFrameSetScriptByCode(DzFrameFindByName("LoginDialogPasswordEditBox",    0), JN_FRAMEEVENT_EDITBOX_TEXT_CHANGED, function LoginDialogEvent.OnChangePasswordEditBoxText, false)
        
            // 동기화 이벤트 등록
            call JNTriggerRegisterSyncData(trig, "LogIn", false)
            call TriggerAddAction(trig, function thistype.SyncRequestLogIn)
        
            // Tab 키 이벤트
            call DzTriggerRegisterKeyEventByCode(trig, JN_OSKEY_TAB, bj_KEYEVENTTYPE_RELEASE, false, function LoginDialogEvent.OnPressTabKey)
        endmethod
    endstruct
endlibrary
