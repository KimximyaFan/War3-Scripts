
library SaveLoadData requires Settings
    struct SaveLoadData
        private static string array g_ServerName[Settings.PLAYER_COUNT]
        private static string array g_LastCharacter[Settings.PLAYER_COUNT]

        static method GetPlayerServerName takes player p returns string
            return thistype.g_ServerName[GetPlayerId(p)]
        endmethod

        static method SetPlayerServerName takes player p, string name returns nothing
            set thistype.g_ServerName[GetPlayerId(p)] = name
            set thistype.g_LastCharacter[GetPlayerId(p)] = ""
        endmethod

        static method GetLastSelectedCharacter takes player p returns string
            return thistype.g_LastCharacter[GetPlayerId(p)]
        endmethod

        static method SetLastSelectedCharacter takes player p, string name returns nothing
            set thistype.g_LastCharacter[GetPlayerId(p)] = name
        endmethod

        static method IsLoggedIn takes player p returns boolean
            return thistype.g_ServerName[GetPlayerId(p)] != ""
        endmethod

        static method HasSelectedCharacter takes player p returns boolean
            return thistype.g_LastCharacter[GetPlayerId(p)] != ""
        endmethod
    endstruct
endlibrary
