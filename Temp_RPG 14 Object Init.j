library ObjectInit requires ObjectTableComsumable, ObjectTableEquipment, ObjectTableMaterial, ObjectPreprocess

/*
    이걸 실행하면 각종 초기화들이 실행된다
    가장 먼저 실행하는걸 권장 하며, 
    operation 사용량이 커서 타이머로 분산 초기화가 되므로
    이 초기화를 하고나서 다른 초기화들은 
    타이머로 적당한 딜레이를 주는 것이 권장됨
    Map Init 에 이미 그렇게 구현되어있음
*/
function Object_Init takes nothing returns nothing
    call Equip_Property_Preprocess_Init()
    call Object_Table_Equip_Init()
    call Object_Table_Consumable_Init()
    call Object_Table_Material_Init()
    
    // 마지막에
    call Object_Combination_Table_Init()
endfunction

endlibrary