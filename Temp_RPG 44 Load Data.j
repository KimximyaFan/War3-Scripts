library LoadData initializer Init

globals
    /*
        아래 상수들은 해시테이블 참조용으로 쓰임
    */
    
    // 유닛 레벨
    constant integer UNIT_LEVEL = 0
    // 유닛 타입
    constant integer UNIT_TYPE = 1
    // 경험치
    constant integer UNIT_EXP = 2
    // 골드
    constant integer UNIT_GOLD = 3
    // 나무
    constant integer UNIT_LUMBER = 4
    // 인벤칸
    constant integer INVEN = 50
    // 장착칸
    constant integer WEARING = 100
    // 조합칸
    constant integer COMBINATION = 150
    // 강화칸
    constant integer UPGRADE = 200
    
    // Load Hash Table
    private hashtable LHT = InitHashtable()
endglobals

/*
    로드한 데이터들 가져오는 함수
*/
function Get_Character_Data_Integer takes integer pid, integer field returns integer
    return LoadInteger(LHT, pid, field)
endfunction

/*
    로드한 데이터 중 스트링 가져오는 함수
*/
function Get_Character_Data_String takes integer pid, integer field returns string
    return LoadStr(LHT, pid, field)
endfunction

/*
    동기화된 데이터를 해쉬테이블에 넣는 함수
*/
private function Set_Character_Data_Integer takes integer pid, integer field, integer value returns nothing
    call SaveInteger(LHT, pid, field, value)
endfunction

/*
    동기화된 데이터중 문자열을 해쉬테이블에 넣는 함수
*/
private function Set_Character_Data_String takes integer pid, integer field, string value returns nothing
    call SaveStr(LHT, pid, field, value)
endfunction

/*
    로드 데이터 동기화 후처리
    해쉬테이블에 집어넣음
*/
private function Character_Data_Integer_Synchronize takes nothing returns nothing
    local string sync_str = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_str, "/", 0) )
    local integer field = S2I( JNStringSplit(sync_str, "/", 1) )
    local integer value = S2I( JNStringSplit(sync_str, "/", 2) )

    call Set_Character_Data_Integer( pid, field, value )
endfunction

/*
    로드 문자열데이터 동기화 후처리
    해쉬테이블에 집어넣음
*/
private function Character_Data_String_Synchronize takes nothing returns nothing
    local string sync_str = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_str, "/", 0) )
    local integer field = S2I( JNStringSplit(sync_str, "/", 1) )
    local string value = JNStringSplit(sync_str, "/", 2)

    call Set_Character_Data_String( pid, field, value )
endfunction

/*
    정수 데이터 동기화하기
*/
function Sync_Data_Integer takes integer pid, integer field, integer value returns nothing
    call DzSyncData( "lodint", I2S(pid) + "#" + I2S(field) + "#" + I2S(value) )
endfunction

/*
    문자열 데이터 동기화하기
*/
function Sync_Data_String takes integer pid, integer field, string value returns nothing
    call DzSyncData( "lodstr", I2S(pid) + "#" + I2S(field) + "#" + value )
endfunction

/*
    로드 데이터 관련 초기화 
*/
private function Init takes nothing returns nothing
    local trigger trg
    
    set trg = CreateTrigger()
    call DzTriggerRegisterSyncData(trg, "lodint", false)
    call TriggerAddAction( trg, function Character_Data_Integer_Synchronize )
    
    set trg = CreateTrigger()
    call DzTriggerRegisterSyncData(trg, "lodstr", false)
    call TriggerAddAction( trg, function Character_Data_String_Synchronize )
    
    set trg = null
endfunction

endlibrary