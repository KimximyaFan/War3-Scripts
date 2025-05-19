library ConsumableAPI requires ObjectRegister

/*
    소모품 만드는 함수
    
    call Create_Consumable( NORMAL_RANDOM_BOX, 1 )
    
    이런식으로 사용하면 된다
*/

function Create_Consumable takes integer object_id, integer count returns Object
    local Object obj
    
    set obj = Object.create()
    call obj.Set_Object_Property(ID, object_id)
    call obj.Set_Object_Property(OBJECT_TYPE, CONSUMABLE)
    call obj.Set_Object_Property(COUNT, count)
    call obj.Set_Object_Property(CONSUMABLE_TYPE, Get_Object_Data(object_id, CONSUMABLE_TYPE))
    
    return obj
endfunction

endlibrary