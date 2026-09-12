///////////////////////////////////////////////////////////////////////////
// SaveSelectDialog - 캐릭터 선택창 관리
///////////////////////////////////////////////////////////////////////////
library SaveSelectDialog requires DzAPISync, DzAPIFrameHandle, SaveLoadLibrary
    struct SaveSelectDialog
        // 단일 페이지 슬롯 수
        private static constant integer SLOT_SIZE_PER_PAGE = 8
        
        // 슬롯 프레임 부모 핸들
        public static integer g_SlotParent = 0
        
        // 현재 페이지 인덱스 (0~)
        private static integer g_SlotCurrentPage = 0
        
        // 전체 페이지 수
        private static integer g_SlotPageCount = 1
        
        // 좌우 이동 버튼 핸들
        private static integer g_SlotLeftButton = 0
        private static integer g_SlotRightButton = 0
        
        // 캐릭터 슬롯 버튼 배열
        private static integer array g_SlotButtons[8]
        
        // 새 캐릭터 생성 프레임 요소 핸들
        private static integer g_NewCharParent = 0
        private static integer g_NewCharTitle = 0
        private static integer g_NewCharEditBox = 0
        private static integer g_NewCharLabel = 0
        private static integer g_NewCharTooltip = 0
        private static integer g_NewCharConfirmButton = 0
        private static integer g_NewCharCancelButton = 0
        
        // 새 캐릭터 확인 플래그
        private static boolean m_NewCharConfirm = false

        //---------------------------------------------------------------------------------------
        // 슬롯 클릭 이벤트 바인딩
        // @param eventAction 클릭 시 호출할 함수 코드
        //---------------------------------------------------------------------------------------
        static method BindLoadButtonEvent takes code eventAction returns nothing
            local integer i = 0
            loop
                call DzFrameSetScriptByCode(thistype.g_SlotButtons[i], JN_FRAMEEVENT_CONTROL_CLICK, eventAction, false)
                set i = i + 1
                exitwhen i >= SLOT_SIZE_PER_PAGE
            endloop
        endmethod

        //---------------------------------------------------------------------------------------
        // 이벤트 프레임으로부터 캐릭터 인덱스 계산
        // @param eventFrame 호출된 프레임 핸들
        // @return integer 글로벌 캐릭터 인덱스
        //---------------------------------------------------------------------------------------
        static method GetCharacterIndex takes integer eventFrame returns integer
            local integer i = 0
            loop
                if thistype.g_SlotButtons[i] == eventFrame then
                    return i + thistype.g_SlotCurrentPage * SLOT_SIZE_PER_PAGE
                endif
                set i = i + 1
                exitwhen i >= SLOT_SIZE_PER_PAGE
            endloop
            return -1
        endmethod

        //---------------------------------------------------------------------------------------
        // 슬롯 화면 숨기기
        //---------------------------------------------------------------------------------------
        static method HideSelect takes nothing returns nothing
            call DzFrameShow(thistype.g_SlotParent, false)
        endmethod

        //---------------------------------------------------------------------------------------
        // 슬롯 화면 보이기
        //---------------------------------------------------------------------------------------
        static method ShowSelect takes nothing returns nothing
            call DzFrameShow(thistype.g_SlotParent, true)
        endmethod

        //---------------------------------------------------------------------------------------
        // 슬롯 내용 갱신
        // @param whichPlayer 대상 플레이어
        //---------------------------------------------------------------------------------------
        static method RefreshSlot takes player whichPlayer returns nothing
            local integer i = 0
            local ServerPlayerInfo info = SaveLoadManager.GetServerPlayerInfo(whichPlayer)
            local integer count = 0
            local integer idx = 0
            
            call info.Update()
            set count = info.GetCharacterCount()
            if GetLocalPlayer() == whichPlayer then
                set thistype.g_SlotPageCount = count / SLOT_SIZE_PER_PAGE
                if ModuloInteger(count, SLOT_SIZE_PER_PAGE) > 0 then
                    set thistype.g_SlotPageCount = thistype.g_SlotPageCount + 1
                endif

                call DzFrameSetEnable(thistype.g_SlotLeftButton, false)
                call DzFrameSetEnable(thistype.g_SlotRightButton, thistype.g_SlotPageCount > 1)

                loop
                    set idx = i + thistype.g_SlotCurrentPage * SLOT_SIZE_PER_PAGE
                    if idx < count then
                        call DzFrameSetText(thistype.g_SlotButtons[i], info.GetCharacterName(idx))
                        call DzFrameSetEnable(thistype.g_SlotButtons[i], true)
                    else
                        call DzFrameSetText(thistype.g_SlotButtons[i], "빈 슬롯 " + I2S(idx + 1))
                        call DzFrameSetEnable(thistype.g_SlotButtons[i], false)
                    endif
                    set i = i + 1
                    exitwhen i >= SLOT_SIZE_PER_PAGE
                endloop
            endif
        endmethod

        //---------------------------------------------------------------------------------------
        // 새 캐릭터 입력 화면으로 전환
        //---------------------------------------------------------------------------------------
        private static method CreateNewCharacterEvent takes nothing returns nothing
            call DzFrameShow(thistype.g_SlotParent, false)
            call DzFrameShow(thistype.g_NewCharParent, true)
        endmethod

        //---------------------------------------------------------------------------------------
        // 이전 페이지 버튼 이벤트
        //---------------------------------------------------------------------------------------
        private static method BackwardListEvent takes nothing returns nothing
            local player whichPlayer = DzGetTriggerUIEventPlayer()
            local integer i = 0
            local ServerPlayerInfo info = SaveLoadManager.GetServerPlayerInfo(whichPlayer)
            local integer idx = 0
            local string str = ""
            
            if GetLocalPlayer() == whichPlayer then
                if thistype.g_SlotCurrentPage > 0 then
                    set thistype.g_SlotCurrentPage = thistype.g_SlotCurrentPage - 1
                    call DzFrameSetEnable(thistype.g_SlotLeftButton, thistype.g_SlotCurrentPage != 0)
                    call DzFrameSetEnable(thistype.g_SlotRightButton, thistype.g_SlotCurrentPage != thistype.g_SlotPageCount - 1)

                    loop
                        set idx = i + thistype.g_SlotCurrentPage * SLOT_SIZE_PER_PAGE
                        set str = info.GetCharacterName(idx)
                        if str != null and str != "" then
                            call DzFrameSetText(thistype.g_SlotButtons[i], str)
                            call DzFrameSetEnable(thistype.g_SlotButtons[i], true)
                        endif
                        set i = i + 1
                        exitwhen i >= SLOT_SIZE_PER_PAGE
                    endloop
                endif
            endif
        endmethod

        //---------------------------------------------------------------------------------------
        // 다음 페이지 버튼 이벤트
        //---------------------------------------------------------------------------------------
        private static method ForwardListEvent takes nothing returns nothing
            local player whichPlayer = DzGetTriggerUIEventPlayer()
            local integer i = 0
            local ServerPlayerInfo info = SaveLoadManager.GetServerPlayerInfo(whichPlayer)
            local integer idx = 0
            local string str = ""
            
            if GetLocalPlayer() == whichPlayer then
                if thistype.g_SlotCurrentPage < thistype.g_SlotPageCount - 1 then
                    set thistype.g_SlotCurrentPage = thistype.g_SlotCurrentPage + 1
                    call DzFrameSetEnable(thistype.g_SlotLeftButton, thistype.g_SlotCurrentPage != 0)
                    call DzFrameSetEnable(thistype.g_SlotRightButton, thistype.g_SlotCurrentPage != thistype.g_SlotPageCount - 1)

                    loop
                        set idx = i + thistype.g_SlotCurrentPage * SLOT_SIZE_PER_PAGE
                        set str = info.GetCharacterName(idx)
                        if str == null or str == "" then
                            call DzFrameSetText(thistype.g_SlotButtons[i], "빈 슬롯 " + I2S(idx + 1))
                            call DzFrameSetEnable(thistype.g_SlotButtons[i], false)
                        else
                            call DzFrameSetText(thistype.g_SlotButtons[i], str)
                        endif
                        set i = i + 1
                        exitwhen i >= SLOT_SIZE_PER_PAGE
                    endloop
                endif
            endif
        endmethod

        //---------------------------------------------------------------------------------------
        // 새 캐릭터 이름 확인/생성 이벤트
        //---------------------------------------------------------------------------------------
        private static method ConfirmButtonEvent takes nothing returns nothing
            local player whichPlayer = DzGetTriggerUIEventPlayer()
            local ServerPlayerInfo info = SaveLoadManager.GetServerPlayerInfo(whichPlayer)
            local integer count = info.GetCharacterCount()
            local string name = DzFrameGetText(thistype.g_NewCharEditBox)
            local integer i = 0

            if GetLocalPlayer() == whichPlayer then
                if m_NewCharConfirm then
                    call DzSyncData("NewChar", name)
                    call DzFrameShow(thistype.g_NewCharParent, false)
                else
                    if name != null and name != "" then
                        call DzFrameSetText(thistype.g_NewCharTitle, "정말 이 이름을 사용하시겠어요?")
                        loop
                            exitwhen i >= count
                            if info.GetCharacterName(i) == name then
                                call DzFrameSetText(thistype.g_NewCharTitle, "정말 초기화 하시겠어요?")
                                exitwhen true
                            endif
                            set i = i + 1
                        endloop
                        set m_NewCharConfirm = true
                        call DzFrameSetSize(thistype.g_NewCharParent, 0.3, 0.155)
                        call DzFrameShow(thistype.g_NewCharLabel, true)
                        call DzFrameShow(thistype.g_NewCharEditBox, false)
                        call DzFrameSetText(thistype.g_NewCharLabel, name)
                        call DzFrameSetText(thistype.g_NewCharTooltip, "")
                        call DzFrameSetText(thistype.g_NewCharConfirmButton, "예")
                        call DzFrameSetText(thistype.g_NewCharCancelButton, "아니오")
                    else
                        call DzFrameSetText(thistype.g_NewCharTooltip, "빈 이름은 사용할 수 없어요!")
                    endif
                endif
            endif
        endmethod

        //---------------------------------------------------------------------------------------
        // 새 캐릭터 생성 취소 이벤트
        //---------------------------------------------------------------------------------------
        private static method CancelCreateCharacterEvent takes nothing returns nothing
            local player whichPlayer = DzGetTriggerUIEventPlayer()

            if GetLocalPlayer() == whichPlayer then
                if m_NewCharConfirm then
                    set m_NewCharConfirm = false
                    call DzFrameSetSize(thistype.g_NewCharParent, 0.3, 0.175)
                    call DzFrameSetText(thistype.g_NewCharTitle, "세이브 이름을 입력하세요")
                    call DzFrameShow(thistype.g_NewCharEditBox, true)
                    call DzFrameShow(thistype.g_NewCharLabel, false)
                    call DzFrameSetText(thistype.g_NewCharConfirmButton, "결정")
                    call DzFrameSetText(thistype.g_NewCharCancelButton, "취소")
                elseif SaveLoadManager.GetLastSelectedCharacter(whichPlayer) == null then
                    call DzFrameSetText(thistype.g_NewCharEditBox, "")
                    call DzFrameSetText(thistype.g_NewCharTooltip, "")
                    call DzFrameShow(thistype.g_NewCharParent, false)
                    call DzFrameShow(thistype.g_SlotParent, true)
                endif
            endif
        endmethod

        //---------------------------------------------------------------------------------------
        // 새 캐릭터 생성 프레임 초기화
        //---------------------------------------------------------------------------------------
        private static method InitNewCharFrame takes nothing returns nothing
            local integer ui = DzGetGameUI()

            set thistype.g_NewCharParent = JNCreateFrame("NewCharacter", ui, 0, 0)
            call DzFrameShow(thistype.g_NewCharParent, false)
            call DzFrameSetPoint(thistype.g_NewCharParent, JN_FRAMEPOINT_CENTER, ui, JN_FRAMEPOINT_CENTER, 0, 0)

            set thistype.g_NewCharTitle = DzFrameFindByName("NewCharacterTitle", 0)
            set thistype.g_NewCharEditBox = DzFrameFindByName("NewCharacterEditBox", 0)
            set thistype.g_NewCharLabel = DzFrameFindByName("NewCharacterLabel", 0)
            call DzFrameShow(thistype.g_NewCharLabel, false)
            set thistype.g_NewCharTooltip = DzFrameFindByName("NewCharacterTooltip", 0)
            set thistype.g_NewCharConfirmButton = DzFrameFindByName("NewCharacterConfirmButton", 0)
            call DzFrameSetScriptByCode(thistype.g_NewCharConfirmButton, JN_FRAMEEVENT_CONTROL_CLICK, function thistype.ConfirmButtonEvent, false)
            set thistype.g_NewCharCancelButton = DzFrameFindByName("NewCharacterCancelButton", 0)
            call DzFrameSetScriptByCode(thistype.g_NewCharCancelButton, JN_FRAMEEVENT_CONTROL_CLICK, function thistype.CancelCreateCharacterEvent, false)
        endmethod

        //---------------------------------------------------------------------------------------
        // 슬롯 프레임 초기화 (한 번만 생성)
        //---------------------------------------------------------------------------------------
        private static method InitSlotFrame takes nothing returns nothing
            local integer ui = JNGetGameUI()
            local integer i = 0

            if thistype.g_SlotParent != 0 then
                return
            endif

            set thistype.g_SlotParent = DzCreateFrame("SaveSlot", ui, 0)
            call DzFrameSetPoint(thistype.g_SlotParent, JN_FRAMEPOINT_CENTER, ui, JN_FRAMEPOINT_CENTER, 0, 0.05)

            call DzFrameSetScriptByCode(DzFrameFindByName("NewCharacterButton", 0), JN_FRAMEEVENT_CONTROL_CLICK, function thistype.CreateNewCharacterEvent, false)

            set thistype.g_SlotLeftButton = DzFrameFindByName("LeftButton", 0)
            call DzFrameSetScriptByCode(thistype.g_SlotLeftButton, JN_FRAMEEVENT_CONTROL_CLICK, function thistype.BackwardListEvent, false)
            call DzFrameSetEnable(thistype.g_SlotLeftButton, false)

            set thistype.g_SlotRightButton = DzFrameFindByName("RightButton", 0)
            call DzFrameSetScriptByCode(thistype.g_SlotRightButton, JN_FRAMEEVENT_CONTROL_CLICK, function thistype.ForwardListEvent, false)

            set i = 0
            loop
                set thistype.g_SlotButtons[i] = DzFrameFindByName("SlotButton" + I2S(i + 1), 0)
                set i = i + 1
                exitwhen i >= SLOT_SIZE_PER_PAGE
            endloop
        endmethod

        //---------------------------------------------------------------------------------------
        // 전체 프레임 생성
        //---------------------------------------------------------------------------------------
        static method CreateFrame takes nothing returns nothing
            call thistype.InitSlotFrame()
            call thistype.InitNewCharFrame()
        endmethod
    endstruct
endlibrary