library InvenToolTip requires InvenGeneric, ObjectRegister

globals
    // 툴팁 프레임이 어떤 인덱스를 보여주고있는지 담는 변수
    integer current_tool_tip_index = -1
    // 툴팁 프레임 백드롭
    private integer tool_tip_back_drop
    // 툴팁 프레임 오브젝트의 이미지
    private integer tool_tip_img
    // 툴팁 프레임 오브젝트의 이름
    private integer tool_tip_name
    // 툴팁 프레임 오브젝트의 장비 등급
    private integer tool_tip_grade
    // 툴팁 프레임 오브젝트의 장비 타입
    private integer tool_tip_type
    // 툴팁 프레임 오브젝트의 장비 스탯, 배열임
    private integer array tool_tip_stats
endglobals


/*
    마우스가 아이템 칸을 벗어날 때 실행된다
    툴팁 프레임을 감추는 역할을 하며
    그냥 감추기 위해서 함수를 써도 된다
*/
function Inven_Tool_Tip_Leave takes nothing returns nothing
    local integer i
    
    set current_tool_tip_index = -1
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i > 4
        call DzFrameShow(tool_tip_stats[i], false)
    endloop
    
    call DzFrameShow(tool_tip_grade, false)
    call DzFrameShow(tool_tip_type, false)
    
    call DzFrameShow(tool_tip_back_drop, false)
endfunction

/*
    강화 칸에서 필요재료 보여줄 때 쓰이는 함수
*/
private function Required_Process takes integer object_id returns nothing
    local real tool_tip_width = 0.15
    local real tool_tip_height = 0.045
    
    call DzFrameSetTexture(tool_tip_img, Get_Object_String_Data(object_id, IMG), 0)
    
    call DzFrameSetText(tool_tip_name, Get_Object_String_Data(object_id, NAME) )
    
    call DzFrameSetText(tool_tip_stats[0], Get_Object_String_Data( object_id, EXPLAINATION ) )
    call DzFrameShow(tool_tip_stats[0], true)
    
    call DzFrameSetSize(tool_tip_back_drop, tool_tip_width, (inven_item_size + 0.07) + tool_tip_height)
    call DzFrameShow(tool_tip_back_drop, true)
endfunction

/*
    재료 오브젝트 툴팁 보여줄 때 쓰이는 함수
*/
private function Material_Process takes Object obj returns nothing
    local real tool_tip_width = 0.15
    local real tool_tip_height = 0.045
    
    call DzFrameSetText(tool_tip_name, Get_Object_String_Data(obj.Get_Object_Property(ID), NAME) )
    
    call DzFrameSetText(tool_tip_stats[0], Get_Object_String_Data( obj.Get_Object_Property(ID), EXPLAINATION ) )
    call DzFrameShow(tool_tip_stats[0], true)
    
    call DzFrameSetSize(tool_tip_back_drop, tool_tip_width, (inven_item_size + 0.07) + tool_tip_height)
    call DzFrameShow(tool_tip_back_drop, true)
endfunction

/*
    소모품 툴팁 보여줄 때 쓰이는 함수
*/
private function Consumable_Process takes Object obj returns nothing
    local real tool_tip_width = 0.15
    local real tool_tip_height = 0.045
    
    call DzFrameSetText(tool_tip_name, Get_Object_String_Data(obj.Get_Object_Property(ID), NAME) )
    
    call DzFrameSetText(tool_tip_stats[0], Get_Object_String_Data( obj.Get_Object_Property(ID), EXPLAINATION ) )
    call DzFrameShow(tool_tip_stats[0], true)
    
    call DzFrameSetSize(tool_tip_back_drop, tool_tip_width, (inven_item_size + 0.07) + tool_tip_height)
    call DzFrameShow(tool_tip_back_drop, true)
endfunction

/*
    장비 툴팁 보여줄 때 쓰이는 함수
*/
private function Equip_Process takes Object obj returns nothing
    local real tool_tip_width = 0.125
    local real tool_tip_height = 0.015
    local integer count = 0
    local integer property = -1
    local integer value
    
    if obj.Get_Object_Property(UPGRADE_COUNT) > 0 then
        call DzFrameSetText(tool_tip_name, Get_Object_String_Data(obj.Get_Object_Property(ID), NAME) + " +" + I2S(obj.Get_Object_Property(UPGRADE_COUNT)) )
    else
        call DzFrameSetText(tool_tip_name, Get_Object_String_Data(obj.Get_Object_Property(ID), NAME) )
    endif
    
    call DzFrameSetText(tool_tip_grade, EQUIP_GRADE_STRING[ obj.Get_Object_Property(GRADE) ])
    call DzFrameSetText(tool_tip_type, "|cff9E9E9E " + EQUIP_TYPE_STRING[obj.Get_Object_Property(EQUIP_TYPE)] + " |r")
    call DzFrameShow(tool_tip_grade, true)
    call DzFrameShow(tool_tip_type, true)

    loop
    set property = property + 1
    exitwhen property >= EQUIP_PROPERTY_SIZE
        
        set value = obj.Get_Object_Property(property)
        if value > 0 then
            call DzFrameSetText(tool_tip_stats[count], EQUIP_PROPERTY_STRING[property] + " " + I2S(obj.Get_Object_Property(property)) )
            call DzFrameShow(tool_tip_stats[count], true)
            set count = count + 1
        endif
    endloop
    
    call DzFrameSetSize(tool_tip_back_drop, tool_tip_width, (inven_item_size + 0.07) + tool_tip_height * count)
    call DzFrameShow(tool_tip_back_drop, true)
endfunction

/*
    마우스 오브젝트에 갖다 놨을 때 실행되면서 툴팁 보여줌
    
    프레임 하나로 돌려막기
    
    인벤칸, 장착칸, 합성칸, 업글칸, 필요재료 칸 등등 if 로 판별
    
    그 후 오브젝트가 장비템인지 소모품인지 재료인지 또 판별 들어감
    
    그전에 만약 필요재료 칸이라면 return 을 수행한다
    필요재료는 실제 object 인스턴스가 없기 때문
*/
function Inven_Tool_Tip_Enter takes nothing returns nothing
    local integer pid = GetPlayerId( DzGetTriggerUIEventPlayer() )
    local string frame = DzFrameGetName(DzGetTriggerUIEventFrame())
    local integer index = S2I( JNStringSplit(frame, "/", 0) )
    local string the_entered_frame = JNStringSplit(frame, "/", 1)
    local integer object_type
    local Object obj
    
    if is_split_on == true then
        return
    endif
    
    if the_entered_frame == "item" then
        set current_tool_tip_index = index
        set obj = player_hero[pid].Get_Inven_Item(index)
        call DzFrameSetPoint(tool_tip_back_drop, JN_FRAMEPOINT_CENTER, item_buttons[index], JN_FRAMEPOINT_CENTER, -0.09, 0.03)
    elseif the_entered_frame == "wearing" then
        set obj = player_hero[pid].Get_Wearing_Item(index)
        call DzFrameSetPoint(tool_tip_back_drop, JN_FRAMEPOINT_CENTER, wearing_buttons[index], JN_FRAMEPOINT_CENTER, -0.09, 0.03)
    elseif the_entered_frame =="combi" then
        set obj = player_hero[pid].Get_Combination_Item(index)
        call DzFrameSetPoint(tool_tip_back_drop, JN_FRAMEPOINT_CENTER, combi_button[index], JN_FRAMEPOINT_CENTER, 0.09, 0.03)
    elseif the_entered_frame == "upgrade" then
        set obj = player_hero[pid].Get_Upgrade_Object(index)
        call DzFrameSetPoint(tool_tip_back_drop, JN_FRAMEPOINT_CENTER, upgrade_object_button, JN_FRAMEPOINT_CENTER, 0.09, 0.03)
    elseif the_entered_frame == "required" then
        call Required_Process(required_id[pid][index])
        call DzFrameSetPoint(tool_tip_back_drop, JN_FRAMEPOINT_CENTER, required_button[index], JN_FRAMEPOINT_CENTER, 0.09, 0.03)
        return
    endif
    
    call DzFrameSetTexture(tool_tip_img, Get_Object_String_Data(obj.Get_Object_Property(ID), IMG), 0)
    
    set object_type = obj.Get_Object_Property(OBJECT_TYPE)
    
    if object_type == EQUIP then
        call Equip_Process(obj)
    elseif object_type == CONSUMABLE then
        call Consumable_Process(obj)
    elseif object_type == MATERIAL then
        call Material_Process(obj)
    endif
endfunction

// 아이템에 커서 갔다놨을 때의 툴팁나오는거, 백드롭과 이미지 그리고 텍스트들 일단 초기화
private function Inven_Tool_Tip_Frame takes nothing returns nothing
    local integer i
    
    set tool_tip_back_drop = DzCreateFrameByTagName("BACKDROP", "", inven_box, "QuestButtonBaseTemplate", 0)
    
    set tool_tip_img = DzCreateFrameByTagName("BACKDROP", "", tool_tip_back_drop, "QuestButtonBaseTemplate", 0)
    call DzFrameSetPoint(tool_tip_img, JN_FRAMEPOINT_CENTER, tool_tip_back_drop, JN_FRAMEPOINT_TOP, 0, -0.01 - (inven_item_size/2) )
    call DzFrameSetSize(tool_tip_img, inven_item_size, inven_item_size)
    
    set tool_tip_name = DzCreateFrameByTagName("TEXT", "", tool_tip_back_drop, "", 0)
    call DzFrameSetPoint(tool_tip_name, JN_FRAMEPOINT_CENTER, tool_tip_back_drop, JN_FRAMEPOINT_TOP, 0.0, -(inven_item_size + 0.020))
    
    set tool_tip_grade = DzCreateFrameByTagName("TEXT", "", tool_tip_back_drop, "", 0)
    call DzFrameSetPoint(tool_tip_grade, JN_FRAMEPOINT_CENTER, tool_tip_back_drop, JN_FRAMEPOINT_TOP, 0.0, -(inven_item_size + 0.035))
    
    set tool_tip_type = DzCreateFrameByTagName("TEXT", "", tool_tip_back_drop, "", 0)
    call DzFrameSetPoint(tool_tip_type, JN_FRAMEPOINT_CENTER, tool_tip_back_drop, JN_FRAMEPOINT_TOP, 0.0, -(inven_item_size + 0.050))
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i > 4
        set tool_tip_stats[i] = DzCreateFrameByTagName("TEXT", "", tool_tip_back_drop, "", 0)
        call DzFrameSetPoint(tool_tip_stats[i], JN_FRAMEPOINT_CENTER, tool_tip_back_drop, JN_FRAMEPOINT_TOP, 0.0, -(inven_item_size + 0.07) -i * 0.015)
        call DzFrameShow(tool_tip_stats[i], false)
    endloop

    call DzFrameShow(tool_tip_back_drop, false)
endfunction

/*
    이 함수 실행하면 툴팁 프레임 생성함
*/
function Inven_Tool_Tip_Init takes nothing returns nothing
    call Inven_Tool_Tip_Frame()
endfunction

endlibrary