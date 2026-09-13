///////////////////////////////////////////////////////////////////////////
// GameSaveData - ★ 개발자가 주로 수정하는 파일 ★
//
// 예제: 플레이어별 A/B/C 3개를 Character 필드로 저장한다.
//      Aura는 서버 운영자가 직접 설정하는 User 필드이며 게임에서는 읽기만 한다.
//
// 실제 맵에서는 a/b/c 배열 대신 자신의 인벤토리/퀘스트/스탯 변수를 연결하면 된다.
///////////////////////////////////////////////////////////////////////////
library GameSaveData requires JNDirectSave
    globals
        integer array g_SaveA
        integer array g_SaveB
        integer array g_SaveC

        // 서버에서 운영자가 직접 0/1로 설정한다고 가정.
        integer array g_ServerAura
    endglobals

    struct GameSaveData
        // 로드할 필드 타입/이름을 한 번 등록한다.
        // Character = 일반 게임 세이브 데이터
        // User      = 계정 공용/운영자 제어 데이터
        static method onInit takes nothing returns nothing
            call JNDirectSave.RegisterCharacterInt("A")
            call JNDirectSave.RegisterCharacterInt("B")
            call JNDirectSave.RegisterCharacterInt("C")

            // ★ 서버 운영값: 게임의 RequestSave에서는 절대 SetUserInt("Aura", ...) 하지 않는다.
            call JNDirectSave.RegisterUserInt("Aura")
        endmethod

        // ★ SAVE EDIT POINT ★
        // 저장 버튼/자동저장 시 이 함수가 호출된다.
        // 여기에 저장할 변수들을 SetCharacterXXX로 작성한다.
        static method WriteCharacterFields takes player p returns nothing
            local integer pid = GetPlayerId(p)

            call JNDirectSave.SetCharacterInt(p, "A", g_SaveA[pid])
            call JNDirectSave.SetCharacterInt(p, "B", g_SaveB[pid])
            call JNDirectSave.SetCharacterInt(p, "C", g_SaveC[pid])

            // 예:
            // call JNDirectSave.SetCharacterReal(p, "Crit", MyCrit[pid])
            // call JNDirectSave.SetCharacterString(p, "Title", MyTitle[pid])
            // call JNDirectSave.SetCharacterBool(p, "QuestClear", MyQuestClear[pid])
        endmethod

        // ★ LOAD EDIT POINT ★
        // 서버에서 읽은 값이 DzSyncData까지 끝난 뒤 호출된다.
        static method ApplyLoaded takes player p returns nothing
            local integer pid = GetPlayerId(p)

            set g_SaveA[pid] = JNDirectSave.GetCharacterInt(p, "A")
            set g_SaveB[pid] = JNDirectSave.GetCharacterInt(p, "B")
            set g_SaveC[pid] = JNDirectSave.GetCharacterInt(p, "C")

            // 서버 운영자가 바꾼 계정 필드. 일반 캐릭터 세이브와 분리되어 있다.
            set g_ServerAura[pid] = JNDirectSave.GetUserInt(p, "Aura")

            call DisplayTextToPlayer(p, 0, 0, "A=" + I2S(g_SaveA[pid]) + ", B=" + I2S(g_SaveB[pid]) + ", C=" + I2S(g_SaveC[pid]))
            call DisplayTextToPlayer(p, 0, 0, "Server Aura=" + I2S(g_ServerAura[pid]))
        endmethod
    endstruct
endlibrary
