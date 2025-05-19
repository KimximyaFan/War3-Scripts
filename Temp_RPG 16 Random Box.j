library RandomBox requires EquipAPI

/*
    랜덤박스를 더블클릭했을 때 처리하는 함수
    Inventory Inven 쪽에서 이 함수를 호출하며
    더블클릭한 오브젝트가 소모품이고 그 소모품이 랜덤박스일 때 이게 실행됨
    해당 랜덤박스 ID에 등록된 Inner Object 문자열을 이용해서 오브젝트를 생성함
*/

function Random_Box_Process_In_Inventory takes integer pid, integer inven_index, Object obj returns nothing
    local integer index
    local integer choosen_inner_object_index
    local integer current_count = obj.Get_Object_Property(COUNT)
    local integer use_count = 1
    local string inner_object_str = Get_Random_Box_Inner_Object( obj.Get_Object_Property(ID) )
    local Object inner_obj

    
    // 생성가능한 공간 있는지 파악하고, 만약 된다면
    set index = player_hero[pid].Check_Inven_Possible()
    if index == -1 then
        return
    endif
    
    // ID 이용해서 Random Box Inner Object 가져온다음, 가중치 기반으로 하나 선택해서 오브젝트 생성 후 영웅에 기입
    set choosen_inner_object_index = Get_Index_From_Weight_String(inner_object_str)
    set inner_obj = Create_Equip( S2I( JNStringSplit( JNStringSplit(inner_object_str, "#", choosen_inner_object_index), ",", 0 ) ) )
    call player_hero[pid].Add_Object_To_Hero(inner_obj)

    // Count 깎고, 만약 0되면 object 날리고
    if current_count - use_count <= 0 then
        call player_hero[pid].Delete_Inven_Item(inven_index)
    else
        call obj.Set_Object_Property( COUNT, current_count - use_count )
    endif
endfunction

endlibrary