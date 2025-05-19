
library ObjectAPI requires ObjectRegister, MaterialAPI, ConsumableAPI, EquipAPI


/*
    from_obj의 count값을 to_obj 로 옮기는 함수
    조합칸 재료 이동시 쓰임
*/
function Split_Object takes Object from_obj, Object to_obj, integer split_count returns nothing
    local integer from_count = from_obj.Get_Object_Property(COUNT)
    local integer to_count = to_obj.Get_Object_Property(COUNT)
    
    if from_count <= split_count then
        set split_count = from_count
    endif
    
    call from_obj.Set_Object_Property(COUNT, from_count - split_count)
    call to_obj.Set_Object_Property(COUNT, to_count + split_count)
endfunction

/*
    오브젝트의 count값 만큼 분리해냄
    조합칸 재료 이동시 쓰임
*/
function Detach_Object takes Object obj, integer split_count returns Object
    local integer original_count = obj.Get_Object_Property(COUNT)
    local Object new_obj
    
    if original_count <= split_count then
        set split_count = original_count
    endif
    
    set new_obj = Object.create()
    call new_obj.Set_Object_Property(ID, obj.Get_Object_Property(ID))
    call new_obj.Set_Object_Property(OBJECT_TYPE, obj.Get_Object_Property(OBJECT_TYPE))
    call new_obj.Set_Object_Property(COUNT, split_count)
    
    call obj.Set_Object_Property(COUNT, original_count - split_count)
    
    return new_obj
endfunction

/*
    범용적인 오브젝트 생성 함수
    오브젝트 ID 값과 count 값을 기입하면 오브젝트를 생성한다
    
    call Create_Object( NORAML_RANDOM_BOX, 20 )
    
    은 일반랜덤상자 20개를 생성한다
    
    장비템의 경우 count 값에 무슨 값을 넣어도 0으로 처리되게 되어있음
    
*/

function Create_Object takes integer object_id, integer count returns Object
    local integer object_type = Get_Object_Data(object_id, OBJECT_TYPE)
    local Object obj
    
    if object_type == EQUIP then
        set obj = Create_Equip(object_id)
    elseif object_type == CONSUMABLE then
        set obj = Create_Consumable(object_id, count)
    elseif object_type == MATERIAL then
        set obj = Create_Material(object_id, count)
    endif
    
    return obj
endfunction


endlibrary