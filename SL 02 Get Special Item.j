library SaveLoadSpecialItem requires SaveLoadForced

globals
    private string ITEM_A_COMMAND = "-안정화"
    private string ITEM_B_COMMAND = "-선택권"
    
    private integer ITEM_A_ID = 'I2JQ'
    private integer ITEM_B_ID = 'I2JR'
    
    private string ITEM_A_NAME = "EX등급 안정화 크리스탈"
    private string ITEM_B_NAME = "증강체 선택권"
endglobals

private function Create_Item takes nothing returns nothing
    local integer pid = GetPlayerId(GetTriggerPlayer())
    local string str = GetEventPlayerChatString()
    local integer item_id
    local integer item_count
    local integer i
    local string item_name
    local real x = GetUnitX(udg_Player_ITEM_MIX[pid+1])
    local real y = GetUnitY(udg_Player_ITEM_MIX[pid+1])
    local item the_item = null
    
    if str == ITEM_A_COMMAND then
        set item_id = ITEM_A_ID
        set item_count = udg_ITEM_A_COUNT[pid+1]
        set item_name = ITEM_A_NAME
        
        set udg_ITEM_A_COUNT[pid+1] = 0
    elseif str == ITEM_B_COMMAND then
        set item_id = ITEM_B_ID
        set item_count = udg_ITEM_B_COUNT[pid+1]
        set item_name = ITEM_B_NAME
        
        set udg_ITEM_B_COUNT[pid+1] = 0
    endif
    
    if item_count <= 0 then
        if GetLocalPlayer() == Player(pid) then
            call BJDebugMsg("횟수가 없습니다.")
        endif
        return
    endif
    
    set i = -1
    loop
    set i = i + 1
    exitwhen i >= item_count
        set the_item = CreateItem(item_id, x, y)
        call SetItemUserData(the_item, pid+1)
    endloop
    
    // 각플, 메세지 출력
    if GetLocalPlayer() == Player(pid) then
        call BJDebugMsg(item_name + "을 " + I2S(item_count) + " 개 습득하였습니다.")
        call God_Int_Forced_Save(pid)
    endif
    
    set the_item = null
endfunction

function Special_Item_Command takes nothing returns nothing
    local integer i = -1
    local trigger trg
    
    set trg = CreateTrigger()
    loop
    set i = i + 1
    exitwhen i > 7
        call TriggerRegisterPlayerChatEvent(trg, Player(i), ITEM_A_COMMAND, false)
        call TriggerRegisterPlayerChatEvent(trg, Player(i), ITEM_B_COMMAND, false)
    endloop

    call TriggerAddAction(trg, function Create_Item)
endfunction

endlibrary