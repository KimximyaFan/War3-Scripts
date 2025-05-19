library LoadAPI requires LoadCharacter, LoadBuild

/*
    이거 실행하면 데이터 불러와짐
*/
function Load takes integer pid returns nothing
    if IS_TEST == true then
        return
    endif
    
    if GetLocalPlayer() == Player(pid) then
        call Load_Object_Character(pid)
    endif
endfunction

/*
    이거 실행하면 불러온 데이터로부터 유닛 생성함
*/
function Build_Unit takes integer pid returns nothing
    call Create_Unit_From_Data(pid)
endfunction

endlibrary