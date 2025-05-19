library SaveAPI requires SaveCharacter

/*
    이 함수 실행하면 해당 pid 유저 정보 저장됨
*/
function Save takes integer pid returns nothing
    if IS_TEST == true then
        return
    endif
    
    if GetLocalPlayer() == Player(pid) then
        call Save_Object_Character(pid)
    endif
endfunction

endlibrary