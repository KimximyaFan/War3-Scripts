library ObjectCombinationTable requires ObjectRegister

/*
    조합재료 등록 구현은 다음과 같다
    
    조합 결과물 <- 재료A x개   재료B y개   재료C z개 ...
    
    시간복잡도 O(1) 의 처리를 위해서 우선순위 큐와 스트링해쉬를 사용한다
    
    그리고 ID도 integer, 갯수도 integer 이므로
    서로 구분을 하기 위해서
    ID는 26진법 문자열로 치환한다
    
    0 -> A
    1 -> B
    ...
    26 -> Z
    27 -> AA
    28 -> AB
    ...
    
    예) 쎈 검 조합재료는 다음과 같다
    
    일반검 + 일반방패 + 일반헬멧 + 랜덤박스 3개
    
    일반검의 ID는 2
    일반방패의 ID는 1
    일반헬멧의 ID는 3
    랜덤박스의 ID는 0
    
    이라고 가정한다면
    
    이를 일단 Pair 자료구조와 우선순위 큐를 이용해서 ID 순서로 정렬하고
    (왜 정렬을 하냐면, 어떤순서로 템을 넣고 조합하든 동일한 스트링이 나와야하기 때문이다)
    
    그 후 큐를 Pop 하면서 스트링을 제작한다
    
    위 예시에서는
    랜덤박스 3개라는 정보가 먼저 pop 될것이다 (ID 가 0이기 때문)
    
    그렇다면 스트링은 "A3" 이 된다
    
    그후 큐가 빌때까지 pop을 해서 계속 이어붙혀준다
    
    일반방패 pop 후 이어 붙이면
    
    "A3B0"
    
    일반검 pop 후 이어 붙이면 
    
    "A3B0C0"
    
    일반 헬멧 pop 후 이어 붙이면
    
    "A3B0C0D0"
    
    스트링이 완성되면 이 문자열을 hash 돌려서 정수로 만들고
    
    Object Combination Hash Table에 등록한다

*/

globals
    // Object Combination Hash Table
    private hashtable OCHT
    // 조합 재료 등록시, 결과 오브젝트 ID가 담김
    private integer result_object_id
    // 조합 재료 등록시, 결과 오브젝트 갯수가 담김
    private integer result_object_count
    // 우선순위 큐
    private PriorityQueue pq
    
    // 아래는 해쉬테이블용 변수들임
    // 조합재료 스트링 
    private constant integer COMBINATION_STRING = 0
    // 조합 결과오브젝트 ID
    private constant integer COMBINATION_RESULT_ID = 1
    // 조합 결과오브젝트 갯수
    private constant integer COMBINATION_OBJECT_COUNT = 2
endglobals

/*
    조합 창에서 템올려놓고 조합하기 했을 때, 조합 가능한지 판별하는 함수
    
    결과로 오브젝트 ID를 반환하며, 만약 조합이 불가능하면 -1 반환
*/
function Is_Combination_Possible takes string str returns integer
    local integer combination_key = StringHash(str)
    
    if HaveSavedString(OCHT, combination_key, COMBINATION_STRING) == false then
        return -1
    endif
    
    if str != LoadStr(OCHT, combination_key, COMBINATION_STRING) then
        call BJDebugMsg("해쉬 충돌")
        return -1
    endif
    
    return LoadInteger(OCHT, combination_key, COMBINATION_RESULT_ID)
endfunction

/*
    결과 오브젝트 갯수를 반환하는 함수
*/
function Get_Combination_Object_Count takes string str returns integer
    return LoadInteger(OCHT, StringHash(str), COMBINATION_OBJECT_COUNT)
endfunction

/*
    정수를 26진법 알파벳으로 반환해주는 함수
*/
function Integer_To_Alphabet26 takes integer n returns string
    local string result = ""
    local integer remainder
    local string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    loop
        // 26으로 나누기 전에 1 감소 (0 기반 보정)
        set n = n - 1

        set remainder = ModuloInteger(n, 26)
        set result = SubString(chars, remainder, remainder + 1) + result

        set n = n / 26

        exitwhen n <= 0
    endloop

    return result
endfunction

/*
    조합 등록 시작
*/
private function Register_Start takes integer object_id, integer count returns nothing
    if Get_Object_Data(object_id, OBJECT_TYPE) == EQUIP then
        set count = 0
    endif
    set result_object_id = object_id
    set result_object_count = count
endfunction

/*
    조합 재료 등록
*/
private function Register_Component_Object takes integer object_id, integer count returns nothing
    if Get_Object_Data(object_id, OBJECT_TYPE) == EQUIP then
        set count = 0
    endif
    
    call pq.Push( Pair.create(object_id, count) )
endfunction

/*
    조합 재료 등록 끝
*/
private function Register_End takes nothing returns nothing
    local string str = ""
    local Pair p
    local integer parent_key
    
    loop
    exitwhen pq.Is_Empty() == true
        set p = pq.Pop()
        set str = str + Integer_To_Alphabet26(p.Key) + I2S(p.Value)
        call p.destroy()
    endloop
    
    set parent_key = StringHash(str)
    
    call SaveStr(OCHT, parent_key, COMBINATION_STRING, str)
    call SaveInteger(OCHT, parent_key, COMBINATION_RESULT_ID, result_object_id)
    call SaveInteger(OCHT, parent_key, COMBINATION_OBJECT_COUNT, result_object_count)
endfunction

/*
    조합에 사용될 각종 변수들 초기화
*/
private function Variable_Init takes nothing returns nothing
    set OCHT = InitHashtable()
    set result_object_id = -1
    set pq = PriorityQueue.create(true)
endfunction

function Object_Combination_Table_Init takes nothing returns nothing
    call Variable_Init()
    
    /*
        사용법은 다음과 같다
        
        
        Register_Start( 오브젝트ID, 갯수 ) 로 시작해서 조합 결과 오브젝트를 등록한다
        
        Register_Component_Object( 오브젝트ID, 갯수 ) 를 이용해서 조합 재료들을 등록한다
        
        Register_End() 를 이용해서 조합 등록을 끝낸다
        
        위 순서를 지키는 것은 매우 중요
        
        
        장비 오브젝트 같은 경우 갯수에 아무 숫자를 넣어도 무방하다
        OBJECT_TYPE 이 EQUIP 일 경우 자동으로 count 값을 0으로 처리한다
    */
    call Register_Start(POWER_SWORD, 0)
    call Register_Component_Object(NORMAL_SWORD, 0)
    call Register_Component_Object(NORMAL_SHIELD, 0)
    call Register_Component_Object(NORMAL_HELMET, 0)
    call Register_Component_Object(RANDOM_NORMAL_BOX, 3)
    call Register_End()
endfunction

endlibrary