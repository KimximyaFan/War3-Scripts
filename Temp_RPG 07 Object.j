globals
    // Object Hash Table, 오브젝트 관련 정보들이 담김
    hashtable OHT = InitHashtable()
    // NAME to ID HASH TABLE, 오브젝트 이름을 ID로 바뀔 정보들이 담김
    hashtable N2IHT = InitHashtable() 
    
    // 이름을 id로 바꾸는 관련 constant
    constant integer NAME_TO_ID = 0
    
    
    // 랜덤옵션 갯수
    integer EQUIP_RANDOM_OPTION_SIZE = 0
    // 고정옵션 갯수
    integer EQUIP_FIXED_OPTION_SIZE = 0
    // 랜덤옵션 constant 들이 담길 배열
    integer array EQUIP_RANDOM_OPTION[25]
    // 고정옵션 constant 들이 담길 배열
    integer array EQUIP_FIXED_OPTION[25]
    // 최대 강화횟수 정보들이 담길 배열
    integer array EQUIP_RANDOM_OPTION_COUNT_BY_GRADE[100]
    // 랜덤옵션 설정시 최솟값 정보들이 담길 배열
    integer array EQUIP_RANDOM_OPTION_MIN_VALUE_BY_GRADE[100][25]
    // 랜덤옵션 설정시 최댓값 정보들이 담길 배열
    integer array EQUIP_RANDOM_OPTION_MAX_VALUE_BY_GRADE[100][25]
    // 최대 강화횟수 정보 담길 배열
    integer array EQUIP_MAX_UPGRADE_COUNT_BY_GRADE[100]
    // 깅화 확률 배열
    integer array EQUIP_UPGRADE_PROBABILITY_WEIGHT[100][10]
    // 강화 확률 배열
    integer array EQUIP_UPGRADE_PROBABILITY_TOTAL[100][10]
    // 강화 수치 최솟값 배열
    integer array EQUIP_UPGRADE_MIN_VALUE[100][25]
    // 강화 수치 최댓값 배열
    integer array EQUIP_UPGRADE_MAX_VALUE[100][25]
    
    // 장비 종류 문자열 배열
    string array EQUIP_TYPE_STRING[10]
    // 스탯 문자열 배열
    string array EQUIP_PROPERTY_STRING[20]
    // 성급 문자열 배열
    string array EQUIP_STAR_GRADE_STRING[10]
    // 등급 문자열 배열
    string array EQUIP_GRADE_STRING[8]
    // 강화 재료 배열
    string array EQUIP_NORMAL_UPGRADE_MATERIAL[100]
    // 안전 강화 재료 배열
    string array EQUIP_SAFE_UPGRADE_MATERIAL[100]
    
    // 오브젝트 타입
    constant integer CONSUMABLE = 0 /* 소모품 */
    constant integer EQUIP = 1 /* 장비 */
    constant integer MATERIAL = 2 /* 재료 */

    
    // 오브젝트 스트링 프로퍼티
    constant integer IS_ID_REGISTERED = 30 /* 해당 아이디의 오브젝트 등록됐는지? 실수 감지용 */
    constant integer NAME = 31 /* 이름 */
    constant integer IMG = 32 /* 이미지 */
    constant integer EXPLAINATION = 33 /* 설명 */
    constant integer RANDOM_BOX_INNER = 34 /* 랜덤박스 내부 */
    constant integer UPGRADE_MATERIAL = 100 /* 강화재료 */
    constant integer SAFE_UPGRADE_MATERIAL = 200 /* 안전강화재료 */
    constant integer COMBINATION_MATERIAL = 300 /* 조합재료 */
    constant integer EQUIP_FIXED_OPTION = 400 /* 장비 고정 옵션 */
    
    // 소모품 종류
    constant integer RANDOM_BOX = 0 /* 랜덤박스 */
    
    // 장비 등급
    constant integer NORMAL = 0 /* 일반 */
    constant integer ADVANCED = 1 /* 고급 */
    constant integer RARE = 2 /* 희귀 */
    constant integer LEGEND = 3 /* 전설 */
    constant integer HEROIC = 4 /* 영웅 */
    constant integer EPIC = 5 /* 신화 */
    constant integer ONLY = 6 /* 유일 */

    // 장비 종류
    constant integer HELMET = 0
    constant integer NECKLACE = 1
    constant integer WEAPON = 2
    constant integer ARMOR = 3
    constant integer SHIELD = 4
    constant integer RING = 5
    constant integer BELT = 6
    constant integer GLOVE = 8
    constant integer BOOTS = 9
    
    // 장비 옵션 종류
    // 요구 사항대로 구현한 스탯들임, 이름이 곧 설명
    constant integer DMG = 0
    constant integer DEF = 1
    constant integer CON = 2
    constant integer STR = 3
    constant integer DEX = 4
    constant integer INT = 5
    constant integer CHA = 6
    constant integer HP = 7
    constant integer CRIT_DMG = 8
    constant integer MAX_DMG = 9
    constant integer REDUCE_DMG = 10
    constant integer AS = 11
    constant integer POTION_REGEN_POWER = 12
    constant integer SHORT_RANGE_DMG = 13
    constant integer LONG_RANGE_DMG = 14
    constant integer MAGIC_DMG = 15
    
    constant integer EQUIP_PROPERTY_SIZE = 16
    
    // 오브젝트 프로퍼티
    constant integer ID = 16 /* 오브젝트 ID */
    constant integer OBJECT_TYPE = 17 /* 오브젝트 타입 */
    constant integer STAR_GRADE = 18 /* 성급 */
    constant integer GRADE = 19 /* 등급 */
    constant integer UPGRADE_COUNT = 20 /* 강화수치 */
    constant integer COUNT = 21 /* 소모품, 재료등이 몇개 있는지 */
    constant integer EQUIP_TYPE = 22 /* 장비 종류 */
    constant integer CONSUMABLE_TYPE = 23 /* 소모품 종류 */
    constant integer LOCK = 24 /* 아이템 잠금 */
    
    constant integer OBJECT_PROPERTY_SIZE = 25
endglobals


struct Object
    /*
        오브젝트 구조체
        
        오브젝트 타입으로 EQUIP, CONSUMABLE, MATERIAL 이 존재함
        
        EQUIP은 장비
        예) 일반 검
        
        CONSUMABLE은 소모품 
        예) 랜덤박스
        
        MATERIAL은 재료
        예) 강화 주문서
        
        constant 계속 추가해서 마음대로 확장 가능
        
        
        각종 정보들은 전처리된 상수들로 값을 다룬다
        예) object_property[ID] <- 오브젝트 ID
        예) object_property[OBJECT_TYPE] <- 오브젝트 타입
        예) object_property[DMG] <- 장비 DMG 값
    */
    
    // 오브젝트 정보들이 담길 배열
    private integer array object_property[OBJECT_PROPERTY_SIZE]
    
    // 오브젝트 정보 Get
    public method Get_Object_Property takes integer property returns integer
        return object_property[property]
    endmethod
    
    // 오브젝트 정보 Set
    public method Set_Object_Property takes integer property, integer value returns nothing
        set object_property[property] = value
    endmethod
    
    // 생성자
    public static method create takes nothing returns thistype
        local thistype this = thistype.allocate()
        local integer i
        
        set i = -1
        loop
        set i = i + 1
        exitwhen i >= OBJECT_PROPERTY_SIZE
            set object_property[i] = -1
        endloop
        
        return this
    endmethod
    
    // 소멸자
    public method destroy takes nothing returns nothing 
        local integer i
        
        set i = -1
        loop
        set i = i + 1
        exitwhen i >= OBJECT_PROPERTY_SIZE
            set object_property[i] = -1
        endloop
        
        call thistype.deallocate( this )
    endmethod
endstruct