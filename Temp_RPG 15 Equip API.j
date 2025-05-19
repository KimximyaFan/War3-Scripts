library EquipAPI requires ObjectRegister, ObjectPreprocess

/*
    장비템을 생성하는 함수이다
    인풋으로 object_id 를 받으며
    
    call Create_Equip( NORMAL_SWORD )
    
    이런 식으로 사용하면 된다
*/

function Create_Equip takes integer object_id returns Object
    local integer property
    local integer star_grade
    local integer grade
    local integer upgrade_count
    local integer value
    local integer min
    local integer max
    local string fixed_option_str
    local string str
    local integer i
    local integer ran
    local integer temp
    local integer array property_arr
    local integer random_option_count
    local integer count = 0
    local Object obj
    
    // 기본설정
    set obj = Object.create()
    call obj.Set_Object_Property(ID, object_id)
    call obj.Set_Object_Property(OBJECT_TYPE, EQUIP)
    call obj.Set_Object_Property(EQUIP_TYPE, Get_Object_Data(object_id, EQUIP_TYPE))
    
    // 성급
    set star_grade = IMaxBJ( Get_Object_Data(object_id, STAR_GRADE), 1 ) 
    call obj.Set_Object_Property(STAR_GRADE, star_grade)
    
    // 등급
    set grade = Get_Object_Data(object_id, GRADE)
    call obj.Set_Object_Property(GRADE, grade)
    
    // 강화횟수
    set upgrade_count = Get_Object_Data(object_id, UPGRADE_COUNT)
    call obj.Set_Object_Property(UPGRADE_COUNT, upgrade_count)
    
    // 고정 옵션 문자열
    set fixed_option_str = Get_Equip_Fixed_Option(object_id)
    
    // 고정 옵션 세팅
    set i = -1
    loop
    set i = i + 1
    set str = JNStringSplit(fixed_option_str, "#", i)
    exitwhen str == ""
        set property = S2I(JNStringSplit(str, ",", 0))
        set value = GetRandomInt( S2I(JNStringSplit(str, ",", 1)), S2I(JNStringSplit(str, ",", 2)) )
        call obj.Set_Object_Property( property, value )
    endloop
    
    // 랜덤 옵션 세팅전 배열 초기화
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= EQUIP_RANDOM_OPTION_SIZE
        set property_arr[i] = EQUIP_RANDOM_OPTION[i]
    endloop
    
    // 전처리한 랜덤옵션 배열에서 배열셔플
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= EQUIP_RANDOM_OPTION_SIZE
        set ran = GetRandomInt(i, EQUIP_RANDOM_OPTION_SIZE-1)
        set temp = property_arr[ran]
        set property_arr[ran] = property_arr[i]
        set property_arr[i] = temp
    endloop
    
    // 전처리한 랜덤옵션 갯수로부터 해당 장비가 몇개의 랜덤옵션을 가지는지
    set random_option_count = Get_Random_Option_Count(star_grade, grade)
    
    // 랜덤옵션 부여
    set i = -1
    loop
    set i = i + 1
    exitwhen count >= random_option_count or i >= EQUIP_RANDOM_OPTION_SIZE
        if obj.Get_Object_Property( property_arr[i] ) == -1 then
            set property = property_arr[i]
            set min = Get_Random_Option_Min(star_grade, grade, property)
            set max = Get_Random_Option_Max(star_grade, grade, property)
            set value = GetRandomInt(min, max)
            call obj.Set_Object_Property( property, value )
            
            set count = count + 1
        endif
    endloop
    
    return obj
endfunction

endlibrary