library HeroInit requires HeroRevive

/*
    영웅 관련 초기화
*/

function Hero_Init takes nothing returns nothing
    call Revive_Init()
endfunction

endlibrary