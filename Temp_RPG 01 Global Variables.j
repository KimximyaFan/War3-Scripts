globals

// 테스트 맵인가?
constant boolean IS_TEST = true

// JN 서버저장용 맵아이디
constant string MAP_ID = "AAAA"

// JN 서버저장용 시크릿키
constant string SECRET_KEY = "94668e85-a144-48f4-92fb-a5904a3491d4"

// 전역으로 쓰는 Hero 구조체를 담는 배열
Hero array player_hero

// 유저 아이디
string array USER_ID[7]

// 범용적으로 쓰는 해쉬테이블, 주로 타이머
hashtable HT = InitHashtable()

// 몬스터 플레이어
player p_enemy = Player(12)

/*
    아래 변수들은
    풋붕이, 다키스트 데미지 시스템에서 씀
    
    현재 데미지 시스템을 어떻게 할지 감이 안오므로 해당 변수들은 무시
*/
constant boolean AD_TYPE = false
constant boolean AP_TYPE = true

// 일반
constant integer AD_BASIC_ATTACK = 1
// 관통
constant integer AP_BASIC_ATTACK = 2
// 공성
constant integer AD_NO_CRIT = 3
// 매직
constant integer AP_NO_CRIT = 4
// 카오스
constant integer AD_CRIT = 5
// 영웅
constant integer AP_CRIT = 6

endglobals