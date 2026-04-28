library LoadData initializer Init

/*
    로드한 데이터들 가져오는 함수
*/
function Get_Character_Data_Integer takes integer pid, integer field returns integer
    return LoadInteger(SaveSystem.LHT, pid, field)
endfunction

/*
    동기화된 데이터를 해쉬테이블에 넣는 함수
*/
private function Set_Character_Data_Integer takes integer pid, integer field, integer value returns nothing
    call SaveInteger(SaveSystem.LHT, pid, field, value)
endfunction

/*
    로드 데이터 동기화 후처리
    해쉬테이블에 집어넣음
*/
private function Character_Data_Integer_Synchronize takes nothing returns nothing
    local string sync_str = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_str, "#", 0) )
    local integer field = S2I( JNStringSplit(sync_str, "#", 1) )
    local integer value = S2I( JNStringSplit(sync_str, "#", 2) )

    call Set_Character_Data_Integer( pid, field, value )
endfunction

/*
    정수 데이터 동기화하기
*/
function Sync_Data_Integer takes integer pid, integer field, integer value returns nothing
    call DzSyncData( "lodint", I2S(pid) + "#" + I2S(field) + "#" + I2S(value) )
endfunction

/*
    로드 데이터 관련 초기화 
*/
private function Init takes nothing returns nothing
    local trigger trg
    
    set trg = CreateTrigger()
    call DzTriggerRegisterSyncData(trg, "lodint", false)
    call TriggerAddAction( trg, function Character_Data_Integer_Synchronize )
    
    set trg = null
endfunction

endlibrary