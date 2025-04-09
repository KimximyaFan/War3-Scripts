library SaveLoadLimited requires SaveLoadGeneric

globals
    constant integer CHAR_COUNT = 5
    boolean array is_char_selectable[12][20]
endglobals

function User_Limited_Character_Sync takes nothing returns nothing
    local string sync_str = DzGetTriggerSyncData()
    local integer pid = S2I( JNStringSplit(sync_str, "#", 0) )
    local string str = JNStringSplit(sync_str, "#", 1)
    local integer i = -1
    
    loop
    set i = i + 1
    exitwhen i >= CHAR_COUNT
        if S2I(JNStringSplit(str, "/", i)) == 1 then
            set is_char_selectable[pid+1][i] = true
        else
            set is_char_selectable[pid+1][i] = false
        endif
    endloop

endfunction

function Limited_Characeter_Save takes integer pid returns nothing
    local integer i = -1
    
    loop
    set i = i + 1
    exitwhen i >= CHAR_COUNT
        call JNObjectUserSetBoolean(Get_User_Id(), "CHARACTER" + I2S(i), is_char_selectable[pid+1][i])
    endloop
endfunction

function User_Limited_Character_Register takes integer pid returns nothing
    local string str = ""
    local integer i = -1
    
    loop
    set i = i + 1
    exitwhen i >= CHAR_COUNT
        if JNObjectUserGetBoolean(Get_User_Id(), "CHARACTER" + I2S(i)) == true then
            set str = str + "1/"
        else
            set str = str + "0/"
        endif
    endloop

    call DzSyncData( "lchar", I2S(pid) + "#" + str )
endfunction

// ==========================================================================
// API
// ==========================================================================

function Is_Character_Selectable takes integer pid, integer num returns boolean
    if num < 0 then
        return false
    endif
    return is_char_selectable[pid][num]
endfunction

endlibrary