///////////////////////////////////////////////////////////////////////////
// SaveSelectDialog
// 제공자의 FDF/TOC 프레임 이름을 그대로 사용한다.
///////////////////////////////////////////////////////////////////////////
library SaveSelectDialog requires Settings, SaveLoadData, SaveLoadLibrary
    struct SaveSelectDialog
        private static constant integer SLOT_SIZE_PER_PAGE = 8

        public static integer g_SlotParent = 0
        private static integer g_SlotCurrentPage = 0
        private static integer g_SlotPageCount = 1
        private static integer g_SlotLeftButton = 0
        private static integer g_SlotRightButton = 0
        private static integer array g_SlotButtons[8]

        private static integer g_NewCharParent = 0
        private static integer g_NewCharTitle = 0
        private static integer g_NewCharEditBox = 0
        private static integer g_NewCharLabel = 0
        private static integer g_NewCharTooltip = 0
        private static integer g_NewCharConfirmButton = 0
        private static integer g_NewCharCancelButton = 0
        private static boolean m_NewCharConfirm = false

        static method BindLoadButtonEvent takes code eventAction returns nothing
            local integer i = 0
            loop
                exitwhen i >= SLOT_SIZE_PER_PAGE
                call DzFrameSetScriptByCode(thistype.g_SlotButtons[i], JN_FRAMEEVENT_CONTROL_CLICK, eventAction, false)
                set i = i + 1
            endloop
        endmethod

        static method GetCharacterIndex takes integer eventFrame returns integer
            local integer i = 0
            loop
                exitwhen i >= SLOT_SIZE_PER_PAGE
                if thistype.g_SlotButtons[i] == eventFrame then
                    return i + thistype.g_SlotCurrentPage * SLOT_SIZE_PER_PAGE
                endif
                set i = i + 1
            endloop
            return -1
        endmethod

        static method HideSelect takes nothing returns nothing
            call DzFrameShow(thistype.g_SlotParent, false)
        endmethod

        static method ShowSelect takes nothing returns nothing
            call DzFrameShow(thistype.g_SlotParent, true)
        endmethod

        private static method RenderPage takes player p returns nothing
            local ServerPlayerInfo info = SaveLoadManager.GetServerPlayerInfo(p)
            local integer count = info.GetCharacterCount()
            local integer i = 0
            local integer idx
            local string name

            if GetLocalPlayer() != p then
                return
            endif

            call DzFrameSetEnable(thistype.g_SlotLeftButton, thistype.g_SlotCurrentPage > 0)
            call DzFrameSetEnable(thistype.g_SlotRightButton, thistype.g_SlotCurrentPage < thistype.g_SlotPageCount - 1)

            loop
                exitwhen i >= SLOT_SIZE_PER_PAGE
                set idx = i + thistype.g_SlotCurrentPage * SLOT_SIZE_PER_PAGE
                if idx < count then
                    set name = info.GetCharacterName(idx)
                    call DzFrameSetText(thistype.g_SlotButtons[i], name)
                    call DzFrameSetEnable(thistype.g_SlotButtons[i], name != "")
                else
                    call DzFrameSetText(thistype.g_SlotButtons[i], "빈 슬롯 " + I2S(idx + 1))
                    call DzFrameSetEnable(thistype.g_SlotButtons[i], false)
                endif
                set i = i + 1
            endloop
        endmethod

        static method RefreshSlot takes player p returns nothing
            local ServerPlayerInfo info
            local integer count

            call SaveLoadManager.UpdateServerPlayerInfo(p)
            set info = SaveLoadManager.GetServerPlayerInfo(p)
            set count = info.GetCharacterCount()

            set thistype.g_SlotPageCount = count / SLOT_SIZE_PER_PAGE
            if ModuloInteger(count, SLOT_SIZE_PER_PAGE) > 0 then
                set thistype.g_SlotPageCount = thistype.g_SlotPageCount + 1
            endif
            if thistype.g_SlotPageCount < 1 then
                set thistype.g_SlotPageCount = 1
            endif
            if thistype.g_SlotCurrentPage >= thistype.g_SlotPageCount then
                set thistype.g_SlotCurrentPage = thistype.g_SlotPageCount - 1
            endif

            call thistype.RenderPage(p)
        endmethod

        private static method CreateNewCharacterEvent takes nothing returns nothing
            local player p = DzGetTriggerUIEventPlayer()
            if GetLocalPlayer() == p then
                set thistype.m_NewCharConfirm = false
                call DzFrameSetText(thistype.g_NewCharTitle, "세이브 이름을 입력하세요")
                call DzFrameSetText(thistype.g_NewCharEditBox, "")
                call DzFrameSetText(thistype.g_NewCharTooltip, "")
                call DzFrameShow(thistype.g_NewCharLabel, false)
                call DzFrameShow(thistype.g_NewCharEditBox, true)
                call DzFrameSetText(thistype.g_NewCharConfirmButton, "결정")
                call DzFrameSetText(thistype.g_NewCharCancelButton, "취소")
                call DzFrameShow(thistype.g_SlotParent, false)
                call DzFrameShow(thistype.g_NewCharParent, true)
            endif
            set p = null
        endmethod

        private static method BackwardListEvent takes nothing returns nothing
            local player p = DzGetTriggerUIEventPlayer()
            if GetLocalPlayer() == p and thistype.g_SlotCurrentPage > 0 then
                set thistype.g_SlotCurrentPage = thistype.g_SlotCurrentPage - 1
            endif
            call thistype.RenderPage(p)
            set p = null
        endmethod

        private static method ForwardListEvent takes nothing returns nothing
            local player p = DzGetTriggerUIEventPlayer()
            if GetLocalPlayer() == p and thistype.g_SlotCurrentPage < thistype.g_SlotPageCount - 1 then
                set thistype.g_SlotCurrentPage = thistype.g_SlotCurrentPage + 1
            endif
            call thistype.RenderPage(p)
            set p = null
        endmethod

        private static method ConfirmButtonEvent takes nothing returns nothing
            local player p = DzGetTriggerUIEventPlayer()
            local ServerPlayerInfo info = SaveLoadManager.GetServerPlayerInfo(p)
            local integer count = info.GetCharacterCount()
            local string name = DzFrameGetText(thistype.g_NewCharEditBox)
            local integer i = 0

            if GetLocalPlayer() == p then
                if thistype.m_NewCharConfirm then
                    call DzSyncData("NewChar", name)
                    call DzFrameShow(thistype.g_NewCharParent, false)
                    call DzFrameShow(thistype.g_SlotParent, true)
                elseif name == null or name == "" then
                    call DzFrameSetText(thistype.g_NewCharTooltip, "빈 이름은 사용할 수 없어요!")
                else
                    // 중복 이름은 기존 데이터 초기화로 오해하기 쉬워 안전하게 거부한다.
                    loop
                        exitwhen i >= count
                        if info.GetCharacterName(i) == name then
                            call DzFrameSetText(thistype.g_NewCharTooltip, "이미 존재하는 세이브 이름입니다.")
                            set p = null
                            return
                        endif
                        set i = i + 1
                    endloop

                    set thistype.m_NewCharConfirm = true
                    call DzFrameSetSize(thistype.g_NewCharParent, 0.3, 0.155)
                    call DzFrameSetText(thistype.g_NewCharTitle, "정말 이 이름을 사용하시겠어요?")
                    call DzFrameShow(thistype.g_NewCharLabel, true)
                    call DzFrameShow(thistype.g_NewCharEditBox, false)
                    call DzFrameSetText(thistype.g_NewCharLabel, name)
                    call DzFrameSetText(thistype.g_NewCharTooltip, "")
                    call DzFrameSetText(thistype.g_NewCharConfirmButton, "예")
                    call DzFrameSetText(thistype.g_NewCharCancelButton, "아니오")
                endif
            endif
            set p = null
        endmethod

        private static method CancelCreateCharacterEvent takes nothing returns nothing
            local player p = DzGetTriggerUIEventPlayer()
            if GetLocalPlayer() == p then
                if thistype.m_NewCharConfirm then
                    set thistype.m_NewCharConfirm = false
                    call DzFrameSetSize(thistype.g_NewCharParent, 0.3, 0.175)
                    call DzFrameSetText(thistype.g_NewCharTitle, "세이브 이름을 입력하세요")
                    call DzFrameShow(thistype.g_NewCharEditBox, true)
                    call DzFrameShow(thistype.g_NewCharLabel, false)
                    call DzFrameSetText(thistype.g_NewCharConfirmButton, "결정")
                    call DzFrameSetText(thistype.g_NewCharCancelButton, "취소")
                else
                    call DzFrameSetText(thistype.g_NewCharEditBox, "")
                    call DzFrameSetText(thistype.g_NewCharTooltip, "")
                    call DzFrameShow(thistype.g_NewCharParent, false)
                    call DzFrameShow(thistype.g_SlotParent, true)
                endif
            endif
            set p = null
        endmethod

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

            set thistype.g_SlotRightButton = DzFrameFindByName("RightButton", 0)
            call DzFrameSetScriptByCode(thistype.g_SlotRightButton, JN_FRAMEEVENT_CONTROL_CLICK, function thistype.ForwardListEvent, false)

            loop
                exitwhen i >= SLOT_SIZE_PER_PAGE
                set thistype.g_SlotButtons[i] = DzFrameFindByName("SlotButton" + I2S(i + 1), 0)
                set i = i + 1
            endloop
        endmethod

        static method CreateFrame takes nothing returns nothing
            call thistype.InitSlotFrame()
            call thistype.InitNewCharFrame()
        endmethod
    endstruct
endlibrary
