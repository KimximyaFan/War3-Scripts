// 마우스 관련 함수 한 곳에 모아 관리
scope MouseInCommon initializer OnInit

// 마우스 좌클릭 ====================================================================================================
private function MouseLeftClick takes nothing returns nothing
    if not Inventory_AreYouPickUp and Inventory_Snap and not Inventory_Drag then
        set Inventory_Drag = true
        call TimeUtility.Update.AddCase("Inventory_FrameMove")
    elseif not EquipSlot_AreYouPickUp and EquipSlot_Snap and not EquipSlot_Drag then
        set EquipSlot_Drag = true
        call TimeUtility.Update.AddCase("EquipSlot_FrameMove")
    endif
endfunction
private function MouseLeftDetach takes nothing returns nothing
    if Inventory_Drag then
        set Inventory_Drag = false
        set Inventory_Snap = false
    endif
    if EquipSlot_Drag then
        set EquipSlot_Drag = false
        set EquipSlot_Snap = false
    endif
endfunction





// 마우스 우클릭 ====================================================================================================
private function MouseRightClick takes nothing returns nothing
    local integer pid = GetPlayerId(DzGetTriggerKeyPlayer())
    local integer i
    local integer itid
    local integer temp
    
    // 우클릭 기능이 동기화중이 아닐 시
    if RightClickEnable then
        // EquipSlot 연동 :: 템을 찝은 상태일 경우 찝기 해제
        if Inventory_AreYouPickUp or EquipSlot_AreYouPickUp then
            // 값 초기화, 프레임 숨기기
            set Inventory_LastSelected = -1
            set Inventory_AreYouPickUp = false
            call DzFrameShow(DzFrameFindByName("InVe_SelectedBack", 0), false)
            call DzFrameShow(DzFrameFindByName("InVe_MouseItem", 0), false)
            // EquipSlot 연동 :: 장착창에 장착 가능 칸 표시 숨김
            if EquipSlot_AreYouPickUp then
                call DzFrameShow(DzFrameFindByName("EqSl_SlotBlackBox", EquipSlot_LastSelected), false)
                set EquipSlot_LastSelected = -1
                set EquipSlot_AreYouPickUp = false
            endif
            call DzFrameShow(DzFrameFindByName("EqSl_Active", 0), false)
        // 템을 안찝은 상태일 경우 우클릭 메뉴 보이기
        else
            set i = 0
            loop
            exitwhen i > 29
                if Inventory_FrameIn[i] then
                    exitwhen true
                endif
                set i = i + 1
            endloop
            if LoadBoolean(Hash, pid, StringHash("bol") + i) then
                // 버리기 모드가 아닐 시
                if not Inventory_ThrowMode then
                    // EquipSlot 연동 :: 텍스쳐 변경
                    set itid = LoadInteger(Hash, pid, StringHash("itid") + i)
                    set temp = S2I(EXExecuteScript2("item", itid, "oldLevel"))
                    // 해당 장착칸이 빈 칸일 경우
                    if not LoadBoolean(Hash, pid, StringHash("Sbol") + temp) then
                        call DzFrameShow(DzFrameFindByName("InVe_DesBack", 0), false)
                        call DzFrameShow(DzFrameFindByName("EqSl_DesBack", 0), false)
                        call DzFrameShow(DzFrameFindByName("EqSl_Active", 0), false)
                        call DzFrameShow(DzFrameFindByName("EqSl_SlotBlackBox", temp), false)
                        call DzFrameSetTexture(DzFrameFindByName("EqSl_SlotA", temp), EXExecuteScript2("item", itid, "Art"), 0)
                        call DzFrameSetTexture(DzFrameFindByName("EqSl_SlotB", temp), EXExecuteScript2("item", itid, "Art"), 0)
                        call DzFrameSetTexture(DzFrameFindByName("InVe_SlotA", i), "UI\\Widgets\\Console\\Human\\human-inventory-slotfiller.blp", 0)
                        call DzFrameSetTexture(DzFrameFindByName("InVe_SlotB", i), "UI\\Widgets\\Console\\Human\\human-inventory-slotfiller.blp", 0)
                    // 해당 장착칸이 빈 칸이 아닐 경우
                    else
                        // EquipSlot 연동 :: 텍스쳐 교체
                        call DzFrameSetTexture(DzFrameFindByName("EqSl_SlotA", temp), EXExecuteScript2("item", itid, "Art"), 0)
                        call DzFrameSetTexture(DzFrameFindByName("EqSl_SlotB", temp), EXExecuteScript2("item", itid, "Art"), 0)
                        set itid = LoadInteger(Hash, pid, StringHash("Sitid") + temp)
                        call DzFrameSetTexture(DzFrameFindByName("InVe_SlotA", i), EXExecuteScript2("item", itid, "Art"), 0)
                        call DzFrameSetTexture(DzFrameFindByName("InVe_SlotB", i), EXExecuteScript2("item", itid, "Art"), 0)
                        call Inventory_RefreshItemDes(pid, itid, DzFrameFindByName("InVe_Slot", i), false)
                    endif
                    // 버튼 잠시 비활성화
                    call DzFrameSetEnable(DzFrameFindByName("InVe_Slot", i), false)
                    set RightClickEnable = false
                    // * Sync Right Click Equip
                    call DzSyncData("RCE", I2S(i))
                    call DzFrameShow(DzFrameFindByName("EqSl_Back", 0), true)
                // 버리기 모드일 시
                else
                    set i = 0
                    loop
                    exitwhen i > 29
                        if Inventory_FrameIn[i] then
                            exitwhen true
                        endif
                        set i = i + 1
                    endloop
                    if LoadBoolean(Hash, pid, StringHash("bol") + i) then
                        //프레임 숨기기
                        call DzFrameShow(DzFrameFindByName("InVe_DesBack", 0), false)
                        call DzFrameShow(DzFrameFindByName("EqSl_DesBack", 0), false) /* EquipSlot 연동 */
                        // 버튼 되돌리기
                        call DzFrameSetTexture(DzFrameFindByName("InVe_SlotA", i), "UI\\Widgets\\Console\\Human\\human-inventory-slotfiller.blp", 0)
                        call DzFrameSetTexture(DzFrameFindByName("InVe_SlotB", i), "UI\\Widgets\\Console\\Human\\human-inventory-slotfiller.blp", 0)
                        // 버튼 잠시 비활성화
                        call DzFrameSetEnable(DzFrameFindByName("InVe_Slot", i), false)
                        set RightClickEnable = false
                        // * Sync Right Click Throw
                        call DzSyncData("RCT", I2S(i))
                    endif
                endif
            // EquipSlot 연동 :: 인벤토리 어느 칸도 작동이 안됐을 경우
            else
                set i = 1
                loop
                exitwhen i > 10
                    if EquipSlot_FrameIn[i] then
                        exitwhen true
                    endif
                    set i = i + 1
                endloop
                // 해당 장착칸에 템이 있을 경우
                if LoadBoolean(Hash, pid, StringHash("Sbol") + i) then
                    set temp = i
                    set itid = LoadInteger(Hash, pid, StringHash("Sitid") + temp)
                    
                    // 빈칸 찾기
                    set i = 0
                    loop
                    exitwhen i > 29
                        if not LoadBoolean(Hash, pid, StringHash("bol") + i) then
                            exitwhen true
                        endif
                        set i = i + 1
                    endloop
                    
                    if i < 30 then
                        call DzFrameShow(DzFrameFindByName("InVe_DesBack", 0), false)
                        call DzFrameShow(DzFrameFindByName("EqSl_DesBack", 0), false)
                        call DzFrameShow(DzFrameFindByName("EqSl_Active", 0), false)
                        call DzFrameShow(DzFrameFindByName("EqSl_SlotBlackBox", temp), false)
                        call DzFrameSetTexture(DzFrameFindByName("EqSl_SlotA", temp), "UI\\Console\\Human\\human-transport-slot.blp", 0)
                        call DzFrameSetTexture(DzFrameFindByName("EqSl_SlotB", temp), "UI\\Console\\Human\\human-transport-slot.blp", 0)
                        call DzFrameSetTexture(DzFrameFindByName("InVe_SlotA", i), EXExecuteScript2("item", itid, "Art"), 0)
                        call DzFrameSetTexture(DzFrameFindByName("InVe_SlotB", i), EXExecuteScript2("item", itid, "Art"), 0)
                        
                        // 버튼 잠시 비활성화
                        call DzFrameSetEnable(DzFrameFindByName("EqSl_Slot", temp), false)
                        set RightClickEnable = false
                        // * Sync Equip Click Right
                        call DzSyncData("ECR", I2S(temp) + "/" + I2S(i) + "/" + I2S(itid))
                    endif
                endif
            endif
        endif
    endif
endfunction

// 초기화 ====================================================================================================
private function OnInit takes nothing returns nothing
    // 좌클릭
    local trigger trg = CreateTrigger()
    call DzTriggerRegisterMouseEventByCode(trg, JN_MOUSE_BUTTON_TYPE_LEFT, 1, false, function MouseLeftClick)
    // 좌클릭 떼기
    set trg = CreateTrigger()
    call DzTriggerRegisterMouseEventByCode(trg, JN_MOUSE_BUTTON_TYPE_LEFT, 0, false, function MouseLeftDetach)
    // 우클릭
    set trg = CreateTrigger()
    call DzTriggerRegisterMouseEventByCode(trg, JN_MOUSE_BUTTON_TYPE_MIDDLE, 0, false, function MouseRightClick)
    set trg = null
endfunction

endscope