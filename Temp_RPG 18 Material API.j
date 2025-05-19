library MaterialAPI

/*
    재료 오브젝트 생성하는 함수
    
    call Create_Material( UPGRADE_SCROLL_NORAML, 2 )
    
    이런식으로 사용하면 된다
*/

function Create_Material takes integer object_id, integer count returns Object
    local Object obj
    
    set obj = Object.create()
    call obj.Set_Object_Property(ID, object_id)
    call obj.Set_Object_Property(OBJECT_TYPE, MATERIAL)
    call obj.Set_Object_Property(COUNT, count)
    
    return obj
endfunction

endlibrary