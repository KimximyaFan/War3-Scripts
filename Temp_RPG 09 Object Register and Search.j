library ObjectRegister

/*
    오브젝트를 등록하는 함수들
*/

globals
    // 오브젝트 ID 할당용 변수
    // 0부터 할당되며, 1씩 자동으로 증가함
    private integer OBJECT_ID = -1
endglobals

// =======================
// Get
// =======================

/*
    가중치 문자열로부터 랜덤으로 1개 를 픽할 때 쓰이는 함수
    랜덤박스에 쓰임
*/
function Get_Index_From_Weight_String takes string weight_str returns integer
    local string str
    local integer array weight_array
    local integer total_weight =0
    local integer choosen_num
    local integer incremental_weight = 0
    local integer i
    
    set i = -1
    loop
    set i = i + 1
    set str = JNStringSplit(weight_str, "#", i)
    exitwhen str == ""
         set weight_array[i] = S2I( JNStringSplit(str, ",", 1) )
         set total_weight = total_weight + weight_array[i]
    endloop
    
    set choosen_num = GetRandomInt(1, total_weight)
    
    set i = -1
    loop
    set i = i + 1
    set incremental_weight = incremental_weight + weight_array[i]
    exitwhen choosen_num <= incremental_weight
    endloop
    
    return i
endfunction

// 새로운 오브젝트 ID를 할당받음
function Get_New_Object_ID takes nothing returns integer
    set OBJECT_ID = OBJECT_ID + 1
    return OBJECT_ID
endfunction

// 랜덤박스 내부 오브젝트 관련 문자열 받아오기
function Get_Random_Box_Inner_Object takes integer object_id returns string
    return LoadStr(OHT, object_id, RANDOM_BOX_INNER)
endfunction

// 오브젝트의 고정 옵션을 받아옴
function Get_Equip_Fixed_Option takes integer object_id returns string
    return LoadStr(OHT, object_id, EQUIP_FIXED_OPTION)
endfunction

// 오브젝트 관련 정보들을 가져옴
function Get_Object_Data takes integer object_id, integer property returns integer
    return LoadInteger(OHT, object_id, property)
endfunction

// 오브젝트 관련 문자열 정보들을 가져옴
function Get_Object_String_Data takes integer object_id, integer property returns string
    return LoadStr(OHT, object_id, property)
endfunction

// 오브젝트 이름으로부터 ID를 받아옴
function Get_Name_To_ID takes string name returns integer
    return LoadInteger(N2IHT, StringHash(name), NAME_TO_ID)
endfunction

// =======================
// Set
// =======================

// 오브젝트 관련 정보 등록
function Set_Object_Data takes integer object_id, integer property, integer value returns nothing
    call SaveInteger(OHT, object_id, property, value)
endfunction

// 오브젝트 관련 문자열 정보 등록
function Set_Object_String_Data takes integer object_id, integer property, string str returns nothing
    call SaveStr(OHT, object_id, property, str)
endfunction

// 오브젝트 이름을 ID로 매핑하는 함수
function Set_Name_To_ID takes string name, integer object_id returns nothing
    call SaveInteger(N2IHT, StringHash(name), NAME_TO_ID, object_id)
endfunction

// 강화 재료 등록, 구현만 되어있고 쓰이진 않음
function Set_Upgrade_Material takes integer object_id, integer star_grade, integer grade, integer material_id, integer count returns nothing
    local string str = ""
    
    if HaveSavedString(OHT, object_id, UPGRADE_MATERIAL + star_grade + grade) == true then
        set str = LoadStr(OHT, object_id, UPGRADE_MATERIAL + grade)
    endif
    
    set str = str + I2S(material_id) + "," + I2S(count) + "#"
    call SaveStr(OHT, object_id, UPGRADE_MATERIAL + grade, str)
endfunction

// 안전 강화 재료 등록, 구현만 되어 있고 쓰이진 않음
function Set_Safe_Upgrade_Material takes integer object_id, integer star_grade, integer grade, integer material_id, integer count returns nothing
    local string str = ""
    
    if HaveSavedString(OHT, object_id, SAFE_UPGRADE_MATERIAL + star_grade + grade) == true then
        set str = LoadStr(OHT, object_id, SAFE_UPGRADE_MATERIAL + grade)
    endif
    
    set str = str + I2S(material_id) + "," + I2S(count) + "#"
    call SaveStr(OHT, object_id, SAFE_UPGRADE_MATERIAL + grade, str)
endfunction

// 조합 재료 등록
function Set_Combination_Material takes integer object_id, integer material_id, integer count returns nothing
    local string str = ""
    
    if HaveSavedString(OHT, object_id, COMBINATION_MATERIAL) == true then
        set str = LoadStr(OHT, object_id, COMBINATION_MATERIAL)
    endif
    
    set str = str + I2S(material_id) + "," + I2S(count) + "#"
    call SaveStr(OHT, object_id, COMBINATION_MATERIAL, str)
endfunction

// 랜덤 박스 내용물 등록
function Set_Random_Box_Inner_Object takes integer object_id, integer inner_object_id, integer weight returns nothing
    local string str = ""
    
    if HaveSavedString(OHT, object_id, RANDOM_BOX_INNER) == true then
        set str = LoadStr(OHT, object_id, RANDOM_BOX_INNER)
    endif
    
    set str = str + I2S(inner_object_id) + "," + I2S(weight) + "#"
    call SaveStr(OHT, object_id, RANDOM_BOX_INNER, str)
endfunction

// 장비 고정옵션 등록
function Set_Equip_Fixed_Option takes integer object_id, integer property, integer min_value, integer max_value returns nothing
    local string str = ""
    
    if HaveSavedString(OHT, object_id, EQUIP_FIXED_OPTION) == true then
        set str = LoadStr(OHT, object_id, EQUIP_FIXED_OPTION)
    endif
    
    set str = str + I2S(property) + "," + I2S(min_value) + "," + I2S(max_value) + "#"
    call SaveStr(OHT, object_id, EQUIP_FIXED_OPTION, str)
endfunction

// 장비 등록
function Register_Equip takes integer object_id, integer equip_type, string object_name, string object_img returns nothing
    if LoadBoolean(OHT, object_id, IS_ID_REGISTERED) == true then
        call BJDebugMsg( "Object ID : " + I2S(object_id) + " 는 이미 등록됨")
        return
    endif
    
    call SaveBoolean(OHT, object_id, IS_ID_REGISTERED, true)
    call SaveInteger(OHT, object_id, OBJECT_TYPE, EQUIP)
    call SaveInteger(OHT, object_id, EQUIP_TYPE, equip_type)
    call SaveStr(OHT, object_id, NAME, object_name)
    call SaveStr(OHT, object_id, IMG, object_img)
endfunction

// 오브젝트 등록
function Register_Object takes integer object_id, integer object_type, string object_name, string object_img, string object_explaination returns nothing
    if LoadBoolean(OHT, object_id, IS_ID_REGISTERED) == true then
        call BJDebugMsg( "Object ID : " + I2S(object_id) + " 는 이미 등록됨")
        return
    endif
    
    call SaveBoolean(OHT, object_id, IS_ID_REGISTERED, true)
    call SaveInteger(OHT, object_id, OBJECT_TYPE, object_type)
    call SaveStr(OHT, object_id, NAME, object_name)
    call SaveStr(OHT, object_id, IMG, object_img)
    call SaveStr(OHT, object_id, EXPLAINATION, object_explaination)
endfunction

endlibrary