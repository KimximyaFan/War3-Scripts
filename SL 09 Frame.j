library SaveLoadFrame requires SaveLoadBuild, SaveLoadSave

globals
    private integer load_box
    private integer array load_buttons
    private integer array load_icon_back
    private integer array load_icon_img
    
    private integer save_box
    private integer save_button
    
    private boolean array is_empty
endglobals

private function Save_Button_Clicked takes nothing returns nothing
    local integer clicked_frame = DzGetTriggerUIEventFrame()
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    
    if is_save_possible == false then
        return
    endif
    
    call Save_Load_Save(pid, true)
endfunction

private function New_Chacter_Sync takes nothing returns nothing
    local string sync_str = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_str, "/", 0) )
    
    set udg_Sellect_Value[pid+1] = true
endfunction

private function Load_Chacter_Sync takes nothing returns nothing
    local string sync_str = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_str, "/", 0) )
    local integer current_character_index = S2I( JNStringSplit(sync_str, "/", 1) )
    
    call Save_Load_Build(pid, current_character_index)
endfunction

private function Load_Button_Clicked takes nothing returns nothing
    local integer clicked_frame = DzGetTriggerUIEventFrame()
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    local integer button_index = S2I( JNStringSplit(DzFrameGetName(clicked_frame), "/", 1) )
    local integer state = -1
    
    if Is_Battle_Net() == true then
        set state = JNObjectCharacterInit( Get_Map_Id(), Get_User_Id(), Get_Secret_Key(), Get_Characater_Index(button_index) )
    endif
    
    call Set_Current_Character_Index(button_index)
    
    if is_empty[button_index] == true then
        call DzSyncData("new", I2S(pid) + "/" )
    else
        if state != 0 then
            call BJDebugMsg("연결이 끊겨 있거나 로드되어있습니다.")
            return
        endif

        call DzSyncData("load", I2S(pid) + "/" + I2S(Get_Current_Character_Index()) )
    endif
    
    call DzFrameShow(load_box, false)
    call DzFrameShow(save_button, true)
endfunction

private function Save_Frames takes nothing returns nothing
    // 위치 조절 (중앙 기준)
    local real x_position = -0.335
    local real y_position = 0.250
    // 버튼 크기 조절
    local real width = 0.04
    local real height = 0.04
    
    set save_button = DzCreateFrameByTagName("GLUETEXTBUTTON", "", DzGetGameUI(), "ScriptDialogButton", 0)
    call DzFrameSetPoint(save_button, JN_FRAMEPOINT_CENTER, DzGetGameUI(), JN_FRAMEPOINT_CENTER, x_position, y_position)
    call DzFrameSetSize(save_button, width, height)
    call DzFrameSetText(save_button, "저장")
    call DzFrameSetScriptByCode(save_button, JN_FRAMEEVENT_CONTROL_CLICK, function Save_Button_Clicked, false)
    call DzFrameShow(save_button, false)
endfunction

private function Load_Frames takes nothing returns nothing
    local integer button_count = Get_Character_Count()
    local real button_width = 0.20
    local real button_height = 0.05
    local real button_y_pad = 0.06
    local real icon_back_size = 0.050
    local integer i
    local integer pid
    local integer unit_type
    local string name
    local integer level
    local integer temp
    local real new_pad_x = 0.34
    
    set load_box = DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "EscMenuBackdrop", 0)
    call DzFrameSetPoint(load_box, JN_FRAMEPOINT_CENTER, DzGetGameUI(), JN_FRAMEPOINT_CENTER, 0.0, 0.05)
    call DzFrameSetSize(load_box, 0.34 + 0.34, 0.30)
    call DzFrameShow(load_box, true)
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= button_count  
        // 로드 버튼
        set load_buttons[i] = DzCreateFrameByTagName("GLUETEXTBUTTON", "LoadButton/" + I2S(i), load_box, "ScriptDialogButton", 0)
        call DzFrameSetPoint(load_buttons[i], JN_FRAMEPOINT_TOPLEFT, load_box, JN_FRAMEPOINT_TOPLEFT, 0.1 + new_pad_x * (i/3), -0.07 - button_y_pad * ModuloInteger(i, 3))
        call DzFrameSetSize(load_buttons[i], button_width, button_height)
        call DzFrameSetScriptByCode(load_buttons[i], JN_FRAMEEVENT_CONTROL_CLICK, function Load_Button_Clicked, false)
        call DzFrameShow(load_buttons[i], true)
        
        // 로드 아이콘
        set load_icon_back[i] = DzCreateFrameByTagName("BACKDROP", "", load_box, "QuestButtonBaseTemplate", 0)
        call DzFrameSetPoint(load_icon_back[i], JN_FRAMEPOINT_RIGHT, load_buttons[i], JN_FRAMEPOINT_LEFT, -0.01, 0 )
        call DzFrameSetSize(load_icon_back[i], icon_back_size + 0.002, icon_back_size + 0.002)
        
        set load_icon_img[i] = DzCreateFrameByTagName("BACKDROP", "", load_icon_back[i], "", 0)
        call DzFrameSetPoint(load_icon_img[i], JN_FRAMEPOINT_CENTER, load_icon_back[i], JN_FRAMEPOINT_CENTER, 0, 0 )
        call DzFrameSetSize(load_icon_img[i], icon_back_size, icon_back_size)
        call DzFrameShow(load_icon_img[i], false)
        
        set pid = -1
        loop 
        set pid = pid + 1
        exitwhen pid >= 6
            if GetPlayerController(Player(pid)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(pid)) == PLAYER_SLOT_STATE_PLAYING then
                // 각플
                if GetLocalPlayer() == Player(pid) then
                    set temp = Get_Character_Data(pid, i, CHARACTER_DATA_LEVEL)

                    if temp > 0 then
                        // 캐릭터 이름 과 레벨
                        set unit_type = Get_Character_Data(pid, i, CHARACTER_DATA_UNIT_TYPE)
                        set name = Get_Name_From_Unit_Type( unit_type )
                        set level = Get_Character_Data(pid, i, CHARACTER_DATA_LEVEL)
                        call DzFrameSetText(load_buttons[i], name + " Level : " + I2S(level) )
                        set is_empty[i] = false
                        
                        // 캐릭터 아이콘
                        call DzFrameSetTexture(load_icon_img[i], Get_Img_From_Unit_Type(unit_type), 0)
                        call DzFrameShow(load_icon_img[i], true)
                    else
                        call DzFrameSetText(load_buttons[i], "빈 캐릭터" )
                        set is_empty[i] = true
                    endif
                endif
            endif
        endloop
    endloop
endfunction

private function Sync_Trigger_Init takes nothing returns nothing
    local trigger trg
    
    // 새 캐릭터 동기화
    set trg = CreateTrigger()
    call DzTriggerRegisterSyncData(trg, "new", false)
    call TriggerAddAction( trg, function New_Chacter_Sync )
    
    // 캐릭터 로드 동기화
    set trg = CreateTrigger()
    call DzTriggerRegisterSyncData(trg, "load", false)
    call TriggerAddAction( trg, function Load_Chacter_Sync )
    
    set trg = null
endfunction

function Save_Load_Frame_Init takes nothing returns nothing
    call Sync_Trigger_Init()
    call Load_Frames()
    call Save_Frames()
endfunction

endlibrary
