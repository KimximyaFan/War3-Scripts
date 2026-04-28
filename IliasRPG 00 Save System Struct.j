struct SaveSystem
    
    static constant string MAP_ID = "JFT"
    
    static constant string SECRET_KEY = "527366ca-281d-4186-b52c-0938a0d53c4a"
    
    static constant boolean IS_TEST = true
    
    static string array USER_ID[12]
    
    // 유닛 레벨
    static constant integer UNIT_LEVEL = 0
    // 유닛 타입
    static constant integer UNIT_TYPE = 1
    // 경험치
    static constant integer UNIT_EXP = 2
    // 골드
    static constant integer UNIT_GOLD = 3
    // 나무
    static constant integer UNIT_LUMBER = 4
    // 인벤칸
    static constant integer INVEN = 20
    static constant integer INVEN_CHARGE = 30

    // Load Hash Table
    static constant hashtable LHT = InitHashtable()
    
    // ==================
    // Helper Functions
    // ==================
    static method Is_Player_Playing takes integer pid returns boolean
        return GetPlayerController(Player(pid)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(pid)) == PLAYER_SLOT_STATE_PLAYING
    endmethod
    
    static method Get_Item_Type_In_Slot takes unit u, integer index returns integer
        if UnitItemInSlot(u, index) == null then
            return -1
        endif
        return GetItemTypeId( UnitItemInSlot(u, index) )
    endmethod
    
    static method Get_Item_Charge_In_Slot takes unit u, integer index returns integer
        if UnitItemInSlot(u, index) == null then
            return -1
        endif
        return GetItemCharges( UnitItemInSlot(u, index) )
    endmethod
    
endstruct