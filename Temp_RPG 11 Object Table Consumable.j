library ObjectTableComsumable requires ObjectRegister

/*
    소모품 오브젝트를 등록하는 스크립트
*/

globals
    // 랜덤 일반 박스
    integer RANDOM_NORMAL_BOX
endglobals

function Object_Table_Consumable_Init takes nothing returns nothing
    local integer current_object_id
    local string name
    local string img
    local string explaination
    
    /*
        사용법은 다음과 같다
        
        
        1. 먼저 오브젝트 이름으로 전역변수를 만든다
        예) integer RANDOM_NORMAL_BOX
        
        
        2. Get_New_Object_ID() 로 ID값을 할당 받는다
        해당 함수는 Object Register and Search 에 있다
        
        
        3. 오브젝트 이름의 변수에 ID 값을 할당 한다
        
        
        4. 이름을 정한다
        
        
        5. blp 경로 스트링을 할당한다
        
        
        6. 설명을 등록한다
        
        
        7. Register_Object( 소모품ID, 오브젝트타입, 이름, 이미지, 설명 ) 
        여긴 계속 복붙해서 형식을 유지한다면 딱히 건들 필요 없다
        
        
        8. Set_Object_Data( 소모품ID, CONSUMABLE, 소모품 타입 )
        현재는 소모품 타입이 RANDOM_BOX 밖에 없으나
        추후 확장을 통해서 다양한 소모품이 등장한다면
        여기서 RANDOM_BOX 부분에 다른 확장한 constant 를 넣으면 된다
        
        
        9. Set_Random_Box_Inner_Object( 소모품ID, 아웃풋오브젝트ID, 가중치 )
        랜덤박스 사용하면 나오는 오브젝트들을 설정한다
        가중치 같은경우, 해당 랜덤박스에 등록된 가중치 값을 다 더해서
        가중치 / 전체 가중치
        값으로 확률이 정해지게 된다
        
        처음 일반랜덤박스 예제를 보면 각각의 장비들이 1의 가중치로 등록되어있는데
        전체 가중치는 1+1+1 = 3 이 되게 되고
        이는 각각 장비들이 1/3, 1/3, 1/3 확률로 각각 뽑힌다는 뜻이다
        
        만약 가중치가 
        일반검은 2
        일반방패는 50
        일반헬멧은 1
        이라고 가정하자
        
        그렇다면 일반검은 2/53 의 확률로 뽑히고
        일반방패는 50/53 의 확률
        일반헬멧은 1/53의 확률로 뽑히게 된다
        
        
        10. Set_Name_To_ID( 오브젝트 영문 스트링, 오브젝트ID )
        이건 굳이 안해도 되긴 하나, 해두면 추후에 디버깅 및 테스트할 때 편할 것이다
        
        
        결론.
        
        set current_object_id = Get_New_Object_ID()
        set RANDOM_NORMAL_BOX = current_object_id
        set name = "이름"
        set img = "blp 경로"
        set explaination = "설명"
        call Register_Object( current_object_id, CONSUMABLE, name, img, explaination )
        call Set_Object_Data( current_object_id, CONSUMABLE_TYPE, RANDOM_BOX )
        call Set_Random_Box_Inner_Object( current_object_id, 등록할 오브젝트 ID, 가중치 )
        
        ... 
        
        call Set_Name_To_ID( "소모품 영문 스트링", current_object_id )
        
        이 형식을 유지해서 복붙해서 쓰면 된다
    */
    
    set current_object_id = Get_New_Object_ID()
    set RANDOM_NORMAL_BOX = current_object_id
    set name = "일반랜덤박스"
    set img = "ReplaceableTextures\\CommandButtons\\BTNBox.blp"
    set explaination = "일반 장비템이 나온다"
    call Register_Object( current_object_id, CONSUMABLE, name, img, explaination )
    call Set_Object_Data( current_object_id, CONSUMABLE_TYPE, RANDOM_BOX )
    call Set_Random_Box_Inner_Object( current_object_id, NORMAL_SWORD, 1 )
    call Set_Random_Box_Inner_Object( current_object_id, NORMAL_SHIELD, 1 )
    call Set_Random_Box_Inner_Object( current_object_id, NORMAL_HELMET, 1 )
    call Set_Name_To_ID( "RANDOM_NORMAL_BOX", current_object_id )
endfunction

endlibrary