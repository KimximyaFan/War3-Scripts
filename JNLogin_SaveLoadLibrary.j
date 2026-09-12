///////////////////////////////////////////////////////////////////////////
// SaveLoadLibrary - 서버 통신 및 캐시
///////////////////////////////////////////////////////////////////////////
library SaveLoadLibrary requires Settings

    // 서버 플레이어 정보
    struct ServerPlayerInfo
        private string array m_CharacterName[Settings.MAXIMUM_SAVE_CHARACTER_COUNT]
        private integer      m_CharacterCount                   = 0
        private player       m_Player                           = null

        // 인스턴스 생성
        // @param whichPlayer 대상 플레이어
        static method Create takes player whichPlayer returns ServerPlayerInfo
            local ServerPlayerInfo this = ServerPlayerInfo.allocate()
            set this.m_Player = whichPlayer
            return this
        endmethod

        // 캐릭터 리스트 갱신
        // @return none
        method Update takes nothing returns nothing
            local integer i = 0
            set this.m_CharacterCount = SaveLoadManager.GetCharacterSize(this.m_Player)
            loop
                exitwhen i >= this.m_CharacterCount or i >= this.m_CharacterName.size
                set this.m_CharacterName[i] = SaveLoadManager.GetCharacterName(this.m_Player, i)
                set i = i + 1
            endloop
        endmethod

        // 인덱스 캐릭터 이름 반환
        // @param index 캐릭터 인덱스
        // @return string 캐릭터 이름
        method GetCharacterName takes integer index returns string
            return this.m_CharacterName[index]
        endmethod

        // 캐릭터 수 반환
        // @return integer 캐릭터 수
        method GetCharacterCount takes nothing returns integer
            return this.m_CharacterCount
        endmethod
    endstruct

    // 서버 통신 캐시
    struct SaveLoadCache
        private static hashtable  g_SaveLoadCache                  = null
        private static boolean array g_PreloadFinished            [Settings.PLAYER_COUNT]

        // 동기화 시작
        // @param whichPlayer 대상 플레이어
        static method PreloadStart takes player whichPlayer returns nothing
            set thistype.g_PreloadFinished[GetPlayerId(whichPlayer)] = false
        endmethod

        // 캐시 삭제
        // @param whichPlayer 대상 플레이어
        static method ClearPreloadData takes player whichPlayer returns nothing
            call FlushChildHashtable(thistype.g_SaveLoadCache, GetPlayerId(whichPlayer))
            set thistype.g_PreloadFinished[GetPlayerId(whichPlayer)] = false
        endmethod

        // 동기화 완료 여부 반환
        // @param whichPlayer 대상 플레이어
        // @return boolean 완료 여부
        static method IsPreloadFinished takes player whichPlayer returns boolean
            return thistype.g_PreloadFinished[GetPlayerId(whichPlayer)]
        endmethod

        // 캐시 저장 (문자열)
        // @param key 키 이름, value 값
        static method StoreStr takes player whichPlayer, string key, string value returns nothing
            call SaveStr(thistype.g_SaveLoadCache, GetPlayerId(whichPlayer), StringHash(key), value)
        endmethod

        // 캐시 저장 (정수)
        static method StoreInt takes player whichPlayer, string key, integer value returns nothing
            call SaveInteger(thistype.g_SaveLoadCache, GetPlayerId(whichPlayer), StringHash(key), value)
        endmethod

        // 캐시 저장 (실수)
        static method StoreReal takes player whichPlayer, string key, real value returns nothing
            call SaveReal(thistype.g_SaveLoadCache, GetPlayerId(whichPlayer), StringHash(key), value)
        endmethod

        // 캐시 불러오기 (문자열)
        static method RetrieveStr takes player whichPlayer, string key returns string
            return LoadStr(thistype.g_SaveLoadCache, GetPlayerId(whichPlayer), StringHash(key))
        endmethod

        // 캐시 불러오기 (정수)
        static method RetrieveInt takes player whichPlayer, string key returns integer
            return LoadInteger(thistype.g_SaveLoadCache, GetPlayerId(whichPlayer), StringHash(key))
        endmethod

        // 캐시 불러오기 (실수)
        static method RetrieveReal takes player whichPlayer, string key returns real
            return LoadReal(thistype.g_SaveLoadCache, GetPlayerId(whichPlayer), StringHash(key))
        endmethod

        // 동기화 전송 (문자열)
        static method PreloadStr takes player whichPlayer, string data returns nothing
            call DzSyncData("SVCS", data)
        endmethod

        // 동기화 전송 (정수)
        static method PreloadInt takes player whichPlayer, string data returns nothing
            call DzSyncData("SVCI", data)
        endmethod

        // 동기화 전송 (실수)
        static method PreloadReal takes player whichPlayer, string data returns nothing
            call DzSyncData("SVCR", data)
        endmethod

        // 동기화 완료 알림
        static method PreloadFinish takes player whichPlayer returns nothing
            call DzSyncData("SVCF", "")
        endmethod

        // 동기화 콜백: 문자열 저장
        private static method StoreStrSync takes nothing returns nothing
            local player whichPlayer = DzGetTriggerSyncPlayer()
            local string raw    = DzGetTriggerSyncData()
            local string key    = JNStringSplit(raw, "§", 0)
            local string value  = JNStringSplit(raw, "§", 1)
            call thistype.StoreStr(whichPlayer, key, value)
        endmethod

        // 동기화 콜백: 정수 저장
        private static method StoreIntSync takes nothing returns nothing
            local player whichPlayer = DzGetTriggerSyncPlayer()
            local string raw    = DzGetTriggerSyncData()
            local string key    = JNStringSplit(raw, "§", 0)
            local integer val   = S2I(JNStringSplit(raw, "§", 1))
            call thistype.StoreInt(whichPlayer, key, val)
        endmethod

        // 동기화 콜백: 실수 저장
        private static method StoreRealSync takes nothing returns nothing
            local player whichPlayer = DzGetTriggerSyncPlayer()
            local string raw    = DzGetTriggerSyncData()
            local string key    = JNStringSplit(raw, "§", 0)
            local real val      = S2R(JNStringSplit(raw, "§", 1))
            call thistype.StoreReal(whichPlayer, key, val)
        endmethod

        // 동기화 콜백: 완료 표시
        private static method PreloadFinishSync takes nothing returns nothing
            set thistype.g_PreloadFinished[GetPlayerId(DzGetTriggerSyncPlayer())] = true
        endmethod

        // SaveLoadCache 초기화 및 이벤트 바인딩
        static method onInit takes nothing returns nothing
            local trigger trig = CreateTrigger()
            set thistype.g_SaveLoadCache = InitHashtable()
            call TriggerAddAction(trig, function thistype.StoreStrSync)
            call DzTriggerRegisterSyncData(trig, "SVCS", false)
            set trig = CreateTrigger()
            call TriggerAddAction(trig, function thistype.StoreIntSync)
            call DzTriggerRegisterSyncData(trig, "SVCI", false)
            set trig = CreateTrigger()
            call TriggerAddAction(trig, function thistype.StoreRealSync)
            call DzTriggerRegisterSyncData(trig, "SVCR", false)
            set trig = CreateTrigger()
            call TriggerAddAction(trig, function thistype.PreloadFinishSync)
            call DzTriggerRegisterSyncData(trig, "SVCF", false)
            
            set trig = null
        endmethod
    endstruct

    // 세이브/로드 매니저
    struct SaveLoadManager
        private static ServerPlayerInfo array g_ServerPlayerInfoArray[Settings.PLAYER_COUNT]

        // 서버 플레이어 정보 갱신
        // @param whichPlayer 대상 플레이어
        static method UpdateServerPlayerInfo takes player whichPlayer returns nothing
            if thistype.g_ServerPlayerInfoArray[GetPlayerId(whichPlayer)] == null then
                set thistype.g_ServerPlayerInfoArray[GetPlayerId(whichPlayer)] = ServerPlayerInfo.Create(whichPlayer)
            endif
            call thistype.g_ServerPlayerInfoArray[GetPlayerId(whichPlayer)].Update()
        endmethod

        // 서버 플레이어 정보 반환
        // @param whichPlayer 대상 플레이어
        // @return ServerPlayerInfo
        static method GetServerPlayerInfo takes player whichPlayer returns ServerPlayerInfo
            return thistype.g_ServerPlayerInfoArray[GetPlayerId(whichPlayer)]
        endmethod

        // 마지막 선택 캐릭터 이름 반환
        // @param whichPlayer 대상 플레이어
        // @return string 캐릭터 이름
        static method GetLastSelectedCharacter takes player whichPlayer returns string
            return SaveLoadData.GetLastSelectedCharacter(whichPlayer)
        endmethod

        // 서버로부터 캐릭터 수 조회
        // @param whichPlayer 대상 플레이어
        // @return integer 캐릭터 수
        static method GetCharacterSize takes player whichPlayer returns integer
            local string name = SaveLoadData.GetPlayerServerName(whichPlayer)
            return JNObjectCharacterGetCharacterCount(Settings.API_MAP_CODE, name, Settings.API_SECRET_KEY)
        endmethod

        // 서버에서 인덱스 캐릭터 이름 조회
        // @param whichPlayer 대상 플레이어
        // @param index 캐릭터 인덱스
        // @return string 캐릭터 이름
        static method GetCharacterName takes player whichPlayer, integer index returns string
            local string name = SaveLoadData.GetPlayerServerName(whichPlayer)
            return JNObjectCharacterGetCharacterNameByIndex(name, index)
        endmethod
    endstruct
endlibrary