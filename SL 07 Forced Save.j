library SaveLoadForced requires SaveLoadGeneric, SaveLoadSave

function God_Int_Forced_Save takes integer pid returns nothing
    if GetLocalPlayer() == Player(pid) then
        call Save_Load_Save(pid, false)
    endif
endfunction

endlibrary