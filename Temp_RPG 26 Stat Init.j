library Stat requires StatButtonAndBox, StatText, UnitProperty, StatAPI

// 이 함수 실행하면 스탯창 생김
function Stat_Init takes nothing returns nothing
    call Stat_Button_And_Box_Init()
    call Stat_Text_Init()
endfunction

endlibrary