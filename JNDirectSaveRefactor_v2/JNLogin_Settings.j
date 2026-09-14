library Settings
    struct Settings
        static constant string API_MAP_CODE                  = "JFT"
        static constant string API_SECRET_KEY                = "527366ca-281d-4186-b52c-0938a0d53c4a"

        static constant integer PLAYER_COUNT                 = 6
        static constant integer MAXIMUM_SAVE_CHARACTER_COUNT = 20

        static constant real SERVER_LOAD_DELAY               = 1.00
        static constant real SYNC_RETRY_INTERVAL             = 0.10
        static constant integer SYNC_MAX_RETRY               = 30

        static constant boolean ENABLE_AUTO_SAVE             = false
        static constant real AUTO_SAVE_INTERVAL              = 300.00
    endstruct
endlibrary
