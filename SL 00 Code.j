library SaveLoadCode

function Integer_To_IDstring takes integer value returns string
    local string charMap = "!.#$%&'()*+,-./0123456789:;<=>.@ABCDEFGHIJKLMNOPQRSTUVWXYZ[.]^_`abcdefghijklmnopqrstuvwxyz{|}~."
    local string result = ""
    local integer remainingValue = value
    local integer charValue
    local integer byteno
    
    if value == -1 then
        return "-1"
    endif

    set byteno = 0
    loop
        set charValue = ModuloInteger(remainingValue, 256) - 33
        set remainingValue = remainingValue / 256
        set result = SubString(charMap, charValue, charValue + 1) + result

        set byteno = byteno + 1
        exitwhen byteno == 4
    endloop
    return result
endfunction

function IDstring_To_Integer takes string oid returns integer
    local string chars = "0123456789.......ABCDEFGHIJKLMNOPQRSTUVWXYZ......abcdefghijklmnopqrstuvwxyz"
    local integer This = 0
    local integer i
    local integer j
    local integer ordinal
    local string chr
    local integer pow_256 = 1
    
    if oid == "-1" then
        return -1
    endif

    set i = 3
    loop
    exitwhen i < 0
        set chr = SubString(oid, i, i + 1)
        set j = 0
        loop
        exitwhen j >= 75
            if chr == SubString(chars, j, j + 1) then
                set This = This + (j + 48) * pow_256
                set pow_256 = pow_256 * 256
                exitwhen true
            endif
            set j = j + 1
        endloop
        set i = i - 1
    endloop

    return This
endfunction

endlibrary