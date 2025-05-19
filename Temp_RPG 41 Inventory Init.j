library Inventory requires InvenGeneric, InvenButtonAndBox, InvenInven, InvenWearing, InvenDiscard, DiscardAll, DiscardAllCheck, InvenToolTip

// 이 함수 실행하면 인벤토리 생김
function Inventory_Init takes nothing returns nothing
    call Inven_Button_And_Box_Init()
    call Inven_Inven_Init()
    call Inven_Wearing_Init()
    call Inven_Discard_Init()
    call Inven_Discard_All_Init()
    call Inven_Discard_All_Check_Init()
    call Inven_Sort_Init()
    call Inven_Sprite_Init()
    call Inven_Upgrade_Init()
    call Inven_Combination_Init()
    call Inven_Split_Init()
    call Inven_Lock_Init()
    
    // Tool Tip Init 은 항상 마지막 순서로
    call Inven_Tool_Tip_Init()
endfunction

endlibrary