library Settings
    struct Settings
        // 반드시 본인 맵의 값으로 교체
        static constant string API_MAP_CODE                  = "MyMapCode"
        static constant string API_SECRET_KEY                = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"

        static constant integer PLAYER_COUNT                 = 6
        static constant integer MAXIMUM_SAVE_CHARACTER_COUNT = 20

        // JNObject Init 직후 서버 데이터를 읽기 전 대기시간.
        // 원본 라이브러리의 1.0초 흐름을 유지.
        static constant real SERVER_LOAD_DELAY               = 1.00
        static constant real SYNC_RETRY_INTERVAL             = 0.10
        static constant integer SYNC_MAX_RETRY               = 30

        // 필요 없으면 false.
        static constant boolean ENABLE_AUTO_SAVE             = true
        static constant real AUTO_SAVE_INTERVAL              = 300.00
    endstruct
endlibrary
