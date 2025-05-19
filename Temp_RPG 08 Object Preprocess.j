library ObjectPreprocess requires Base

/*
    오브젝트 관련 전처리
*/

// ==========
// Get
// ==========

// 랜덤 옵션 갯수 가져오기
function Get_Random_Option_Count takes integer star_grade, integer grade returns integer
    return EQUIP_RANDOM_OPTION_COUNT_BY_GRADE[10*star_grade + grade]
endfunction

// 랜덤옵션 최솟값 가져오기
function Get_Random_Option_Min takes integer star_grade, integer grade, integer property returns integer
    return EQUIP_RANDOM_OPTION_MIN_VALUE_BY_GRADE[10*star_grade + grade][property]
endfunction

// 랜덤옵션 최댓값 가져오기
function Get_Random_Option_Max takes integer star_grade, integer grade, integer property returns integer
    return EQUIP_RANDOM_OPTION_MAX_VALUE_BY_GRADE[10*star_grade + grade][property]
endfunction

// 강화 재료 가져오기
function Get_Normal_Upgrade_Material takes integer star_grade, integer grade returns string
    return EQUIP_NORMAL_UPGRADE_MATERIAL[10*star_grade + grade]
endfunction

// 안전 강화 재료 가져오기
function Get_Safe_Upgrade_Material takes integer star_grade, integer grade returns string
    return EQUIP_SAFE_UPGRADE_MATERIAL[10*star_grade + grade]
endfunction

// 강화 확률중 분자 가져오기
function Get_Upgrade_Probability_Weight takes integer star_grade, integer grade, integer equip_type returns integer
    return EQUIP_UPGRADE_PROBABILITY_WEIGHT[10*star_grade + grade][equip_type]
endfunction

// 강화 확률중 분모 가져오기
function Get_Upgrade_Probability_Total takes integer star_grade, integer grade, integer equip_type returns integer
    return EQUIP_UPGRADE_PROBABILITY_TOTAL[10*star_grade + grade][equip_type]
endfunction

// 강화 수치 최솟값 가져오기
function Get_Option_Upgrade_Min takes integer star_grade, integer grade, integer property returns integer
    return EQUIP_UPGRADE_MIN_VALUE[10*star_grade + grade][property]
endfunction

// 강화 수치 최댓값 가져오기
function Get_Option_Upgrade_Max takes integer star_grade, integer grade, integer property returns integer
    return EQUIP_UPGRADE_MAX_VALUE[10*star_grade + grade][property]
endfunction

// 최대 강화 횟수 가져오기
function Get_Max_Upgrade_Count takes integer star_grade, integer grade returns integer
    return EQUIP_MAX_UPGRADE_COUNT_BY_GRADE[10*star_grade + grade]
endfunction

// ==========
// Set
// ==========

// 랜덤 옵션 등록하기
private function Set_Property_Random_Option takes integer property returns nothing
    set EQUIP_RANDOM_OPTION[EQUIP_RANDOM_OPTION_SIZE] = property
    set EQUIP_RANDOM_OPTION_SIZE = EQUIP_RANDOM_OPTION_SIZE + 1
endfunction

// 고정 옵션 등록하기
private function Set_Property_Fixed_Option takes integer property returns nothing
    set EQUIP_FIXED_OPTION[EQUIP_FIXED_OPTION_SIZE] = property
    set EQUIP_FIXED_OPTION_SIZE = EQUIP_FIXED_OPTION_SIZE + 1
endfunction

// 랜덤 옵션 갯수 등록하기
private function Set_Random_Option_Count takes integer star_grade, integer grade, integer count returns nothing
    set EQUIP_RANDOM_OPTION_COUNT_BY_GRADE[10*star_grade + grade] = count
endfunction

// 랜덤 옵션의 최소 최댓값 등록하기
private function Set_Random_Option_Min_Max takes integer star_grade, integer grade, integer property, integer min_value, integer max_value returns nothing
    set EQUIP_RANDOM_OPTION_MIN_VALUE_BY_GRADE[10*star_grade + grade][property] = min_value
    set EQUIP_RANDOM_OPTION_MAX_VALUE_BY_GRADE[10*star_grade + grade][property] = max_value
endfunction

// 강화 수치 최소 최댓값 등록하기
private function Set_Option_Upgrade_Min_Max takes integer star_grade, integer grade, integer property, integer min_value, integer max_value returns nothing
    set EQUIP_UPGRADE_MIN_VALUE[10*star_grade + grade][property] = min_value
    set EQUIP_UPGRADE_MAX_VALUE[10*star_grade + grade][property] = max_value
endfunction

// 최대 강화수치 등록하기
private function Set_Max_Upgrade_Count takes integer star_grade, integer grade, integer count returns nothing
    set EQUIP_MAX_UPGRADE_COUNT_BY_GRADE[10*star_grade + grade] = count
endfunction

// 강화 확률 등록하기
// weight 50, total 1000 이면
// 50 / 1000 확률
private function Set_Upgrade_Probability takes integer star_grade, integer grade, integer equip_type, integer weight, integer total returns nothing
    set EQUIP_UPGRADE_PROBABILITY_WEIGHT[10*star_grade + grade][equip_type] = weight
    set EQUIP_UPGRADE_PROBABILITY_TOTAL[10*star_grade + grade][equip_type] = total
endfunction

// 일반 강화 강화재료 등록하기
private function Set_Normal_Upgrade_Material takes integer star_grade, integer grade, integer object_id, integer count returns nothing
    local string str = EQUIP_NORMAL_UPGRADE_MATERIAL[10*star_grade + grade]
    
    if str == null then
        set str = ""
    endif
    
    set str = str + I2S(object_id) + "," + I2S(count) + "#"
    set EQUIP_NORMAL_UPGRADE_MATERIAL[10*star_grade + grade] = str
endfunction

// 안전 강화 강화재료 등록하기
private function Set_Safe_Upgrade_Material takes integer star_grade, integer grade, integer object_id, integer count returns nothing
    local string str = EQUIP_SAFE_UPGRADE_MATERIAL[10*star_grade + grade]
    
    if str == null then
        set str = ""
    endif
    
    set str = str + I2S(object_id) + "," + I2S(count) + "#"
    set EQUIP_SAFE_UPGRADE_MATERIAL[10*star_grade + grade] = str
endfunction

// 전처리 3
private function Equip_Property_Preprocess_Init3 takes nothing returns nothing
    call DestroyTimer(GetExpiredTimer())
    
    // 일반강화 재료
    call Set_Normal_Upgrade_Material( 1, NORMAL, UPGRADE_SCROLL_NORMAL, 3 )
    call Set_Normal_Upgrade_Material( 1, NORMAL, UPGRADE_SCROLL_ADVANCED, 1 )
    
    call Set_Normal_Upgrade_Material( 1, ADVANCED, UPGRADE_SCROLL_NORMAL, 5 )
    call Set_Normal_Upgrade_Material( 1, ADVANCED, UPGRADE_SCROLL_ADVANCED, 3 )
    call Set_Normal_Upgrade_Material( 1, ADVANCED, UPGRADE_SCROLL_RARE, 1 )
    
    call Set_Normal_Upgrade_Material( 1, RARE, UPGRADE_SCROLL_ADVANCED, 10 )
    call Set_Normal_Upgrade_Material( 1, RARE, UPGRADE_SCROLL_RARE, 5 )
    
    // 안전강화 재료
    call Set_Safe_Upgrade_Material( 1, NORMAL, UPGRADE_SCROLL_NORMAL, 10 )
    call Set_Safe_Upgrade_Material( 1, NORMAL, UPGRADE_SCROLL_ADVANCED, 3 )
    
    call Set_Safe_Upgrade_Material( 1, ADVANCED, UPGRADE_SCROLL_NORMAL, 15 )
    call Set_Safe_Upgrade_Material( 1, ADVANCED, UPGRADE_SCROLL_ADVANCED, 9 )
    call Set_Safe_Upgrade_Material( 1, ADVANCED, UPGRADE_SCROLL_RARE, 3 )
    
    call Set_Safe_Upgrade_Material( 1, RARE, UPGRADE_SCROLL_ADVANCED, 30 )
    call Set_Safe_Upgrade_Material( 1, RARE, UPGRADE_SCROLL_RARE, 15 )
    
    // 각종 텍스트 전처리
    set EQUIP_TYPE_STRING[HELMET] = "투구"
    set EQUIP_TYPE_STRING[NECKLACE] = "목걸이"
    set EQUIP_TYPE_STRING[WEAPON] = "무기"
    set EQUIP_TYPE_STRING[ARMOR] = "갑옷"
    set EQUIP_TYPE_STRING[SHIELD] = "방패"
    set EQUIP_TYPE_STRING[RING] = "반지"
    set EQUIP_TYPE_STRING[BELT] = "벨트"
    set EQUIP_TYPE_STRING[GLOVE] = "장갑"
    set EQUIP_TYPE_STRING[BOOTS] = "부츠"

    set EQUIP_PROPERTY_STRING[DMG] = "데미지"
    set EQUIP_PROPERTY_STRING[DEF] = "방어력"
    set EQUIP_PROPERTY_STRING[CON] = "CON"
    set EQUIP_PROPERTY_STRING[STR] = "STR"
    set EQUIP_PROPERTY_STRING[DEX] = "DEX"
    set EQUIP_PROPERTY_STRING[INT] = "INT"
    set EQUIP_PROPERTY_STRING[CHA] = "CHA"
    set EQUIP_PROPERTY_STRING[HP] = "HP"
    set EQUIP_PROPERTY_STRING[CRIT_DMG] = "치명타데미지"
    set EQUIP_PROPERTY_STRING[MAX_DMG] = "최대치데미지"
    set EQUIP_PROPERTY_STRING[REDUCE_DMG] = "데미지감소"
    set EQUIP_PROPERTY_STRING[AS] = "공격속도"
    set EQUIP_PROPERTY_STRING[POTION_REGEN_POWER] = "물약회복력"
    set EQUIP_PROPERTY_STRING[SHORT_RANGE_DMG] = "근거리데미지"
    set EQUIP_PROPERTY_STRING[LONG_RANGE_DMG] = "원거리데미지"
    set EQUIP_PROPERTY_STRING[MAGIC_DMG] = "마법데미지"
    
    set EQUIP_STAR_GRADE_STRING[1] = "1성"
    set EQUIP_STAR_GRADE_STRING[2] = "2성"
    set EQUIP_STAR_GRADE_STRING[3] = "3성"
    set EQUIP_STAR_GRADE_STRING[4] = "4성"
    set EQUIP_STAR_GRADE_STRING[5] = "5성"
    set EQUIP_STAR_GRADE_STRING[6] = "6성"
    set EQUIP_STAR_GRADE_STRING[7] = "7성"
    
    set EQUIP_GRADE_STRING[NORMAL] = "일반"
    set EQUIP_GRADE_STRING[ADVANCED] = "|cff489CFF고급|r"
    set EQUIP_GRADE_STRING[RARE] = "|cffB95AFF희귀|r"
    set EQUIP_GRADE_STRING[LEGEND] = "|cffFF8224전설|r"
    set EQUIP_GRADE_STRING[HEROIC] = "|cffFF4848영웅|r"
    set EQUIP_GRADE_STRING[EPIC] = "|cffFF4848신화|r"
    set EQUIP_GRADE_STRING[ONLY] = "|cffFF4848유일|r"
    
    call Msg("Object Preprocess 3 end")
endfunction

private function Equip_Property_Preprocess_Init2 takes nothing returns nothing
    call DestroyTimer(GetExpiredTimer())
    
    /*
        강화 수치 최대 최솟값
        
        call Set_Option_Upgrade_Min_Max( 성급, 등급, 옵션, 최솟값, 최댓값 )
    */
    call Set_Option_Upgrade_Min_Max( 1, NORMAL, DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, NORMAL, DEF, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, NORMAL, CON, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, NORMAL, STR, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, NORMAL, DEX, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, NORMAL, INT, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, NORMAL, CHA, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, NORMAL, HP, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, NORMAL, CRIT_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, NORMAL, MAX_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, NORMAL, REDUCE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, NORMAL, AS, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, NORMAL, POTION_REGEN_POWER, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, NORMAL, SHORT_RANGE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, NORMAL, LONG_RANGE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, NORMAL, MAGIC_DMG, 3, 5 )
    
    call Set_Option_Upgrade_Min_Max( 1, ADVANCED, DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ADVANCED, DEF, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ADVANCED, CON, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ADVANCED, STR, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ADVANCED, DEX, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ADVANCED, INT, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ADVANCED, CHA, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ADVANCED, HP, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ADVANCED, CRIT_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ADVANCED, MAX_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ADVANCED, REDUCE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ADVANCED, AS, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ADVANCED, POTION_REGEN_POWER, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ADVANCED, SHORT_RANGE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ADVANCED, LONG_RANGE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ADVANCED, MAGIC_DMG, 3, 5 )
    
    call Set_Option_Upgrade_Min_Max( 1, RARE, DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, RARE, DEF, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, RARE, CON, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, RARE, STR, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, RARE, DEX, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, RARE, INT, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, RARE, CHA, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, RARE, HP, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, RARE, CRIT_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, RARE, MAX_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, RARE, REDUCE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, RARE, AS, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, RARE, POTION_REGEN_POWER, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, RARE, SHORT_RANGE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, RARE, LONG_RANGE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, RARE, MAGIC_DMG, 3, 5 )
    
    call Set_Option_Upgrade_Min_Max( 1, LEGEND, DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, LEGEND, DEF, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, LEGEND, CON, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, LEGEND, STR, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, LEGEND, DEX, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, LEGEND, INT, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, LEGEND, CHA, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, LEGEND, HP, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, LEGEND, CRIT_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, LEGEND, MAX_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, LEGEND, REDUCE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, LEGEND, AS, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, LEGEND, POTION_REGEN_POWER, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, LEGEND, SHORT_RANGE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, LEGEND, LONG_RANGE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, LEGEND, MAGIC_DMG, 3, 5 )
    
    call Set_Option_Upgrade_Min_Max( 1, HEROIC, DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, HEROIC, DEF, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, HEROIC, CON, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, HEROIC, STR, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, HEROIC, DEX, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, HEROIC, INT, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, HEROIC, CHA, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, HEROIC, HP, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, HEROIC, CRIT_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, HEROIC, MAX_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, HEROIC, REDUCE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, HEROIC, AS, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, HEROIC, POTION_REGEN_POWER, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, HEROIC, SHORT_RANGE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, HEROIC, LONG_RANGE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, HEROIC, MAGIC_DMG, 3, 5 )
    
    call Set_Option_Upgrade_Min_Max( 1, EPIC, DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, EPIC, DEF, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, EPIC, CON, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, EPIC, STR, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, EPIC, DEX, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, EPIC, INT, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, EPIC, CHA, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, EPIC, HP, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, EPIC, CRIT_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, EPIC, MAX_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, EPIC, REDUCE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, EPIC, AS, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, EPIC, POTION_REGEN_POWER, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, EPIC, SHORT_RANGE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, EPIC, LONG_RANGE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, EPIC, MAGIC_DMG, 3, 5 )
    
    call Set_Option_Upgrade_Min_Max( 1, ONLY, DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ONLY, DEF, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ONLY, CON, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ONLY, STR, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ONLY, DEX, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ONLY, INT, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ONLY, CHA, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ONLY, HP, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ONLY, CRIT_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ONLY, MAX_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ONLY, REDUCE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ONLY, AS, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ONLY, POTION_REGEN_POWER, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ONLY, SHORT_RANGE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ONLY, LONG_RANGE_DMG, 3, 5 )
    call Set_Option_Upgrade_Min_Max( 1, ONLY, MAGIC_DMG, 3, 5 )
    call Msg("Object Preprocess 2 end")
endfunction


private function Equip_Property_Preprocess_Init1 takes nothing returns nothing
    call DestroyTimer(GetExpiredTimer())
    
    // 아이템 랜덤 옵션
    call Set_Property_Random_Option( SHORT_RANGE_DMG )
    call Set_Property_Random_Option( LONG_RANGE_DMG )
    call Set_Property_Random_Option( MAGIC_DMG )
    call Set_Property_Random_Option( DEF )
    call Set_Property_Random_Option( CON )
    call Set_Property_Random_Option( STR )
    call Set_Property_Random_Option( DEX )
    call Set_Property_Random_Option( INT )
    call Set_Property_Random_Option( CHA )
    call Set_Property_Random_Option( HP )
    call Set_Property_Random_Option( CRIT_DMG )
    call Set_Property_Random_Option( MAX_DMG )
    
    // 아이템 고정 옵션
    call Set_Property_Fixed_Option( DMG )
    call Set_Property_Fixed_Option( DEF )
    call Set_Property_Fixed_Option( CON )
    call Set_Property_Fixed_Option( STR )
    call Set_Property_Fixed_Option( DEX )
    call Set_Property_Fixed_Option( INT )
    call Set_Property_Fixed_Option( CHA )
    call Set_Property_Fixed_Option( HP )
    call Set_Property_Fixed_Option( CRIT_DMG )
    call Set_Property_Fixed_Option( MAX_DMG )
    call Set_Property_Fixed_Option( REDUCE_DMG )
    call Set_Property_Fixed_Option( AS )
    call Set_Property_Fixed_Option( POTION_REGEN_POWER )
    
    /*
        장비 랜덤 옵션 갯수
        
        call Set_Random_Option_Count( 성급, 등급, 랜덤옵션갯수 )
    */
    call Set_Random_Option_Count( 1, NORMAL, 0 )
    call Set_Random_Option_Count( 1, ADVANCED, 1 )
    call Set_Random_Option_Count( 1, RARE, 2 )
    call Set_Random_Option_Count( 1, LEGEND, 3 )
    call Set_Random_Option_Count( 1, HEROIC, 4 )
    call Set_Random_Option_Count( 1, EPIC, 5 )
    call Set_Random_Option_Count( 1, ONLY, 5 )
    call Set_Random_Option_Count( 2, EPIC, 5 )
    call Set_Random_Option_Count( 2, ONLY, 5 )
    call Set_Random_Option_Count( 3, ONLY, 5 )
    call Set_Random_Option_Count( 4, ONLY, 5 )
    call Set_Random_Option_Count( 5, ONLY, 5 )
    call Set_Random_Option_Count( 6, ONLY, 5 )
    call Set_Random_Option_Count( 7, ONLY, 5 )
    
    /*
        장비 랜덤옵션 최대 최소 수치
        
        call Set_Random_Option_Min_Max( 성급, 등급, 옵션, 최솟값, 최댓값 )
    */
    call Set_Random_Option_Min_Max( 1, NORMAL, SHORT_RANGE_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, NORMAL, LONG_RANGE_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, NORMAL, MAGIC_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, NORMAL, DEF, 3, 5 )
    call Set_Random_Option_Min_Max( 1, NORMAL, CON, 3, 5 )
    call Set_Random_Option_Min_Max( 1, NORMAL, STR, 3, 5 )
    call Set_Random_Option_Min_Max( 1, NORMAL, DEX, 3, 5 )
    call Set_Random_Option_Min_Max( 1, NORMAL, INT, 3, 5 )
    call Set_Random_Option_Min_Max( 1, NORMAL, CHA, 3, 5 )
    call Set_Random_Option_Min_Max( 1, NORMAL, HP, 3, 5 )
    call Set_Random_Option_Min_Max( 1, NORMAL, CRIT_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, NORMAL, MAX_DMG, 3, 5 )
    
    call Set_Random_Option_Min_Max( 1, ADVANCED, SHORT_RANGE_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ADVANCED, LONG_RANGE_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ADVANCED, MAGIC_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ADVANCED, DEF, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ADVANCED, CON, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ADVANCED, STR, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ADVANCED, DEX, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ADVANCED, INT, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ADVANCED, CHA, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ADVANCED, HP, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ADVANCED, CRIT_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ADVANCED, MAX_DMG, 3, 5 )
    
    call Set_Random_Option_Min_Max( 1, RARE, SHORT_RANGE_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, RARE, LONG_RANGE_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, RARE, MAGIC_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, RARE, DEF, 3, 5 )
    call Set_Random_Option_Min_Max( 1, RARE, CON, 3, 5 )
    call Set_Random_Option_Min_Max( 1, RARE, STR, 3, 5 )
    call Set_Random_Option_Min_Max( 1, RARE, DEX, 3, 5 )
    call Set_Random_Option_Min_Max( 1, RARE, INT, 3, 5 )
    call Set_Random_Option_Min_Max( 1, RARE, CHA, 3, 5 )
    call Set_Random_Option_Min_Max( 1, RARE, HP, 3, 5 )
    call Set_Random_Option_Min_Max( 1, RARE, CRIT_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, RARE, MAX_DMG, 3, 5 )
    
    call Set_Random_Option_Min_Max( 1, LEGEND, SHORT_RANGE_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, LEGEND, LONG_RANGE_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, LEGEND, MAGIC_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, LEGEND, DEF, 3, 5 )
    call Set_Random_Option_Min_Max( 1, LEGEND, CON, 3, 5 )
    call Set_Random_Option_Min_Max( 1, LEGEND, STR, 3, 5 )
    call Set_Random_Option_Min_Max( 1, LEGEND, DEX, 3, 5 )
    call Set_Random_Option_Min_Max( 1, LEGEND, INT, 3, 5 )
    call Set_Random_Option_Min_Max( 1, LEGEND, CHA, 3, 5 )
    call Set_Random_Option_Min_Max( 1, LEGEND, HP, 3, 5 )
    call Set_Random_Option_Min_Max( 1, LEGEND, CRIT_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, LEGEND, MAX_DMG, 3, 5 )
    
    call Set_Random_Option_Min_Max( 1, HEROIC, SHORT_RANGE_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, HEROIC, LONG_RANGE_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, HEROIC, MAGIC_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, HEROIC, DEF, 3, 5 )
    call Set_Random_Option_Min_Max( 1, HEROIC, CON, 3, 5 )
    call Set_Random_Option_Min_Max( 1, HEROIC, STR, 3, 5 )
    call Set_Random_Option_Min_Max( 1, HEROIC, DEX, 3, 5 )
    call Set_Random_Option_Min_Max( 1, HEROIC, INT, 3, 5 )
    call Set_Random_Option_Min_Max( 1, HEROIC, CHA, 3, 5 )
    call Set_Random_Option_Min_Max( 1, HEROIC, HP, 3, 5 )
    call Set_Random_Option_Min_Max( 1, HEROIC, CRIT_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, HEROIC, MAX_DMG, 3, 5 )
    
    call Set_Random_Option_Min_Max( 1, EPIC, SHORT_RANGE_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, EPIC, LONG_RANGE_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, EPIC, MAGIC_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, EPIC, DEF, 3, 5 )
    call Set_Random_Option_Min_Max( 1, EPIC, CON, 3, 5 )
    call Set_Random_Option_Min_Max( 1, EPIC, STR, 3, 5 )
    call Set_Random_Option_Min_Max( 1, EPIC, DEX, 3, 5 )
    call Set_Random_Option_Min_Max( 1, EPIC, INT, 3, 5 )
    call Set_Random_Option_Min_Max( 1, EPIC, CHA, 3, 5 )
    call Set_Random_Option_Min_Max( 1, EPIC, HP, 3, 5 )
    call Set_Random_Option_Min_Max( 1, EPIC, CRIT_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, EPIC, MAX_DMG, 3, 5 )
    
    call Set_Random_Option_Min_Max( 1, ONLY, SHORT_RANGE_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ONLY, LONG_RANGE_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ONLY, MAGIC_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ONLY, DEF, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ONLY, CON, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ONLY, STR, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ONLY, DEX, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ONLY, INT, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ONLY, CHA, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ONLY, HP, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ONLY, CRIT_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 1, ONLY, MAX_DMG, 3, 5 )
    
    call Set_Random_Option_Min_Max( 2, EPIC, SHORT_RANGE_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 2, EPIC, LONG_RANGE_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 2, EPIC, MAGIC_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 2, EPIC, DEF, 3, 5 )
    call Set_Random_Option_Min_Max( 2, EPIC, CON, 3, 5 )
    call Set_Random_Option_Min_Max( 2, EPIC, STR, 3, 5 )
    call Set_Random_Option_Min_Max( 2, EPIC, DEX, 3, 5 )
    call Set_Random_Option_Min_Max( 2, EPIC, INT, 3, 5 )
    call Set_Random_Option_Min_Max( 2, EPIC, CHA, 3, 5 )
    call Set_Random_Option_Min_Max( 2, EPIC, HP, 3, 5 )
    call Set_Random_Option_Min_Max( 2, EPIC, CRIT_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 2, EPIC, MAX_DMG, 3, 5 )
    
    call Set_Random_Option_Min_Max( 2, ONLY, SHORT_RANGE_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 2, ONLY, LONG_RANGE_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 2, ONLY, MAGIC_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 2, ONLY, DEF, 3, 5 )
    call Set_Random_Option_Min_Max( 2, ONLY, CON, 3, 5 )
    call Set_Random_Option_Min_Max( 2, ONLY, STR, 3, 5 )
    call Set_Random_Option_Min_Max( 2, ONLY, DEX, 3, 5 )
    call Set_Random_Option_Min_Max( 2, ONLY, INT, 3, 5 )
    call Set_Random_Option_Min_Max( 2, ONLY, CHA, 3, 5 )
    call Set_Random_Option_Min_Max( 2, ONLY, HP, 3, 5 )
    call Set_Random_Option_Min_Max( 2, ONLY, CRIT_DMG, 3, 5 )
    call Set_Random_Option_Min_Max( 2, ONLY, MAX_DMG, 3, 5 )

    /*
        강화 최대 횟수
        
        call Set_Max_Upgrade_Count( 성급, 등급, 최대횟수 )
    */
    call Set_Max_Upgrade_Count( 1, NORMAL, 5 )
    call Set_Max_Upgrade_Count( 1, ADVANCED, 10 )
    call Set_Max_Upgrade_Count( 1, RARE, 15 )
    call Set_Max_Upgrade_Count( 1, LEGEND, 20 )
    call Set_Max_Upgrade_Count( 1, HEROIC, 25 )
    call Set_Max_Upgrade_Count( 1, EPIC, 30 )
    call Set_Max_Upgrade_Count( 1, ONLY, 30 )
    call Set_Max_Upgrade_Count( 2, EPIC, 30 )
    call Set_Max_Upgrade_Count( 2, ONLY, 30 )
    call Set_Max_Upgrade_Count( 3, ONLY, 30 )
    call Set_Max_Upgrade_Count( 4, ONLY, 30 )
    call Set_Max_Upgrade_Count( 5, ONLY, 30 )
    call Set_Max_Upgrade_Count( 6, ONLY, 30 )
    call Set_Max_Upgrade_Count( 7, ONLY, 30 )

    /*
        강화 확률
        
        확률은 
        ( 분자 / 분모 ) 로 구현됨
        
        분자 = 50
        분모 = 100 일 경우 
        50/100 으로 50% 확률이 된다
        
        call Set_Upgrade_Probability( 성급, 등급, 장비타입, 분자, 분모 )
    */
    call Set_Upgrade_Probability( 1, NORMAL, HELMET, 50, 100 )
    call Set_Upgrade_Probability( 1, NORMAL, NECKLACE, 50, 100 )
    call Set_Upgrade_Probability( 1, NORMAL, WEAPON, 50, 100 )
    call Set_Upgrade_Probability( 1, NORMAL, ARMOR, 50, 100 )
    call Set_Upgrade_Probability( 1, NORMAL, SHIELD, 50, 100 )
    call Set_Upgrade_Probability( 1, NORMAL, RING, 50, 100 )
    call Set_Upgrade_Probability( 1, NORMAL, BELT, 50, 100 )
    call Set_Upgrade_Probability( 1, NORMAL, GLOVE, 50, 100 )
    call Set_Upgrade_Probability( 1, NORMAL, BOOTS, 50, 100 )
    
    call Set_Upgrade_Probability( 1, ADVANCED, HELMET, 50, 100 )
    call Set_Upgrade_Probability( 1, ADVANCED, NECKLACE, 50, 100 )
    call Set_Upgrade_Probability( 1, ADVANCED, WEAPON, 50, 100 )
    call Set_Upgrade_Probability( 1, ADVANCED, ARMOR, 50, 100 )
    call Set_Upgrade_Probability( 1, ADVANCED, SHIELD, 50, 100 )
    call Set_Upgrade_Probability( 1, ADVANCED, RING, 50, 100 )
    call Set_Upgrade_Probability( 1, ADVANCED, BELT, 50, 100 )
    call Set_Upgrade_Probability( 1, ADVANCED, GLOVE, 50, 100 )
    call Set_Upgrade_Probability( 1, ADVANCED, BOOTS, 50, 100 )
    
    call Set_Upgrade_Probability( 1, RARE, HELMET, 50, 100 )
    call Set_Upgrade_Probability( 1, RARE, NECKLACE, 50, 100 )
    call Set_Upgrade_Probability( 1, RARE, WEAPON, 50, 100 )
    call Set_Upgrade_Probability( 1, RARE, ARMOR, 50, 100 )
    call Set_Upgrade_Probability( 1, RARE, SHIELD, 50, 100 )
    call Set_Upgrade_Probability( 1, RARE, RING, 50, 100 )
    call Set_Upgrade_Probability( 1, RARE, BELT, 50, 100 )
    call Set_Upgrade_Probability( 1, RARE, GLOVE, 50, 100 )
    call Set_Upgrade_Probability( 1, RARE, BOOTS, 50, 100 )
    
    call Set_Upgrade_Probability( 1, LEGEND, HELMET, 50, 100 )
    call Set_Upgrade_Probability( 1, LEGEND, NECKLACE, 50, 100 )
    call Set_Upgrade_Probability( 1, LEGEND, WEAPON, 50, 100 )
    call Set_Upgrade_Probability( 1, LEGEND, ARMOR, 50, 100 )
    call Set_Upgrade_Probability( 1, LEGEND, SHIELD, 50, 100 )
    call Set_Upgrade_Probability( 1, LEGEND, RING, 50, 100 )
    call Set_Upgrade_Probability( 1, LEGEND, BELT, 50, 100 )
    call Set_Upgrade_Probability( 1, LEGEND, GLOVE, 50, 100 )
    call Set_Upgrade_Probability( 1, LEGEND, BOOTS, 50, 100 )
    
    call Set_Upgrade_Probability( 1, HEROIC, HELMET, 50, 100 )
    call Set_Upgrade_Probability( 1, HEROIC, NECKLACE, 50, 100 )
    call Set_Upgrade_Probability( 1, HEROIC, WEAPON, 50, 100 )
    call Set_Upgrade_Probability( 1, HEROIC, ARMOR, 50, 100 )
    call Set_Upgrade_Probability( 1, HEROIC, SHIELD, 50, 100 )
    call Set_Upgrade_Probability( 1, HEROIC, RING, 50, 100 )
    call Set_Upgrade_Probability( 1, HEROIC, BELT, 50, 100 )
    call Set_Upgrade_Probability( 1, HEROIC, GLOVE, 50, 100 )
    call Set_Upgrade_Probability( 1, HEROIC, BOOTS, 50, 100 )
    
    call Set_Upgrade_Probability( 1, EPIC, HELMET, 50, 100 )
    call Set_Upgrade_Probability( 1, EPIC, NECKLACE, 50, 100 )
    call Set_Upgrade_Probability( 1, EPIC, WEAPON, 50, 100 )
    call Set_Upgrade_Probability( 1, EPIC, ARMOR, 50, 100 )
    call Set_Upgrade_Probability( 1, EPIC, SHIELD, 50, 100 )
    call Set_Upgrade_Probability( 1, EPIC, RING, 50, 100 )
    call Set_Upgrade_Probability( 1, EPIC, BELT, 50, 100 )
    call Set_Upgrade_Probability( 1, EPIC, GLOVE, 50, 100 )
    call Set_Upgrade_Probability( 1, EPIC, BOOTS, 50, 100 )
    
    call Set_Upgrade_Probability( 1, ONLY, HELMET, 50, 100 )
    call Set_Upgrade_Probability( 1, ONLY, NECKLACE, 50, 100 )
    call Set_Upgrade_Probability( 1, ONLY, WEAPON, 50, 100 )
    call Set_Upgrade_Probability( 1, ONLY, ARMOR, 50, 100 )
    call Set_Upgrade_Probability( 1, ONLY, SHIELD, 50, 100 )
    call Set_Upgrade_Probability( 1, ONLY, RING, 50, 100 )
    call Set_Upgrade_Probability( 1, ONLY, BELT, 50, 100 )
    call Set_Upgrade_Probability( 1, ONLY, GLOVE, 50, 100 )
    call Set_Upgrade_Probability( 1, ONLY, BOOTS, 50, 100 )
    
    call Set_Upgrade_Probability( 2, EPIC, HELMET, 50, 100 )
    call Set_Upgrade_Probability( 2, EPIC, NECKLACE, 50, 100 )
    call Set_Upgrade_Probability( 2, EPIC, WEAPON, 50, 100 )
    call Set_Upgrade_Probability( 2, EPIC, ARMOR, 50, 100 )
    call Set_Upgrade_Probability( 2, EPIC, SHIELD, 50, 100 )
    call Set_Upgrade_Probability( 2, EPIC, RING, 50, 100 )
    call Set_Upgrade_Probability( 2, EPIC, BELT, 50, 100 )
    call Set_Upgrade_Probability( 2, EPIC, GLOVE, 50, 100 )
    call Set_Upgrade_Probability( 2, EPIC, BOOTS, 50, 100 )
    
    call Set_Upgrade_Probability( 2, ONLY, HELMET, 50, 100 )
    call Set_Upgrade_Probability( 2, ONLY, NECKLACE, 50, 100 )
    call Set_Upgrade_Probability( 2, ONLY, WEAPON, 50, 100 )
    call Set_Upgrade_Probability( 2, ONLY, ARMOR, 50, 100 )
    call Set_Upgrade_Probability( 2, ONLY, SHIELD, 50, 100 )
    call Set_Upgrade_Probability( 2, ONLY, RING, 50, 100 )
    call Set_Upgrade_Probability( 2, ONLY, BELT, 50, 100 )
    call Set_Upgrade_Probability( 2, ONLY, GLOVE, 50, 100 )
    call Set_Upgrade_Probability( 2, ONLY, BOOTS, 50, 100 )
    call Msg("Object Preprocess 1 end")
endfunction

/*
    각종 데이터 및 정보들 전처리
    
    타이머로 나눠서 돌리는 이유 -> oplimit 30만을 넘어가므로 조금씩 나눠서 해야함
*/
function Equip_Property_Preprocess_Init takes nothing returns nothing
    call TimerStart(CreateTimer(), 0.00, false, function Equip_Property_Preprocess_Init1)
    call TimerStart(CreateTimer(), 0.02, false, function Equip_Property_Preprocess_Init2)
    call TimerStart(CreateTimer(), 0.04, false, function Equip_Property_Preprocess_Init3)
endfunction

endlibrary
