//==============================================================================
/*
[2020.12.25 21:44] 업데이트 : STA (Seperate Thread Action) 기능 추가
[2020.12.25 21:44] 업데이트 : 텍스트파일 작성 기능 추가 (ClassicTextFile~)
[2020.12.23 02:18] 핫픽스 : 디버그 모드에서 오류가 발생하지 않도록 수정
*/
//==============================================================================
//! textmacro CustomSaveCode takes ID, CHARSET
    static constant string CHARSET = "$CHARSET$"
    static constant integer MAX_PARITY = 5
    static constant integer ID = $ID$
    private static player STA_P = null
    private static integer STA_PID = 0
    private static string STA_PN = null
    private static string STA_S = null
    private static boolean STA_R = false
    private static boolean STA_OP = false
    private static ClassicSaveCode STA_CD = 0
    private static method STABeforeSave takes nothing returns nothing
        static if thistype.OnBeforeSave.exists then
            call thistype.OnBeforeSave(STA_P,STA_PID,STA_PN)
        endif
    endmethod
    private static method STASave takes nothing returns nothing
        static if thistype.OnSave.exists then
            set STA_OP = false
            call thistype.OnSave(STA_P,STA_PID,STA_PN,STA_CD)
            set STA_OP = true
        else
            set STA_OP = true
        endif
    endmethod
    private static method STAAfterSave takes nothing returns nothing
        static if thistype.OnAfterSave.exists then
            call thistype.OnAfterSave(STA_P,STA_PID,STA_PN,STA_S)
        endif
    endmethod
    private static method STABeforeLoad takes nothing returns nothing
        static if thistype.OnBeforeLoad.exists then
            call thistype.OnBeforeLoad(STA_P,STA_PID,STA_PN,STA_S)
        endif
    endmethod
    private static method STALoad takes nothing returns nothing
        static if thistype.OnLoad.exists then
            set STA_R = false
            set STA_OP = false
            set STA_R = thistype.OnLoad(STA_P,STA_PID,STA_PN,STA_CD)
            set STA_OP = true
        else
            set STA_R = true
            set STA_OP = true
        endif
    endmethod
    private static method STAAfterLoad takes nothing returns nothing
        static if thistype.OnAfterLoad.exists then
            call thistype.OnAfterLoad(STA_P,STA_PID,STA_PN)
        endif
    endmethod
    static method Save takes player p, string pn returns string
        local integer pid = GetPlayerId(p)
        local ClassicSaveCode cd = ClassicSaveCode.create(CHARSET)
        local integer parity = GetRandomInt(1,MAX_PARITY)
        local string s
        call cd.Encode(parity,MAX_PARITY)
        static if thistype.OnBeforeSave.exists then
            //call thistype.OnBeforeSave(p,pid,pn)
            set STA_P = p
            set STA_PID = pid
            set STA_PN = pn
            call ForForce(bj_FORCE_PLAYER[0], function thistype.STABeforeSave)
        endif
        static if thistype.OnSave.exists then
            //call thistype.OnSave(p,pid,pn,cd)
            set STA_P = p
            set STA_PID = pid
            set STA_PN = pn
            set STA_CD = cd
            call ForForce(bj_FORCE_PLAYER[0], function thistype.STASave)
        endif
        call cd.Encode(parity,MAX_PARITY)
        set s = cd.Save(pn,ID)
        call cd.destroy()
        static if thistype.OnAfterSave.exists then
            //call thistype.OnAfterSave(p,pid,pn,s)
            set STA_P = p
            set STA_PID = pid
            set STA_PN = pn
            set STA_S = s
            call ForForce(bj_FORCE_PLAYER[0], function thistype.STAAfterSave)
        endif
        return s
    endmethod
    static method Load takes player p, string pn, string s returns boolean
        local integer pid = GetPlayerId(p)
        local ClassicSaveCode cd = ClassicSaveCode.create(CHARSET)
        local boolean b = cd.Load(pn,s,ID)
        local integer parity
        static if thistype.OnBeforeLoad.exists then
            //call thistype.OnBeforeLoad(p,pid,pn,s)
            set STA_P = p
            set STA_PID = pid
            set STA_PN = pn
            set STA_S = s
            call ForForce(bj_FORCE_PLAYER[0], function thistype.STABeforeLoad)
        endif
        if b then
            set b = false
            set parity = cd.Decode(MAX_PARITY)
            if parity > 0 then
                static if thistype.OnLoad.exists then
                    //call thistype.OnLoad(p,pid,pn,cd)
                    set STA_P = p
                    set STA_PID = pid
                    set STA_PN = pn
                    set STA_CD = cd
                    call ForForce(bj_FORCE_PLAYER[0], function thistype.STALoad)
                endif
                if STA_OP and STA_R and cd.Decode(MAX_PARITY) == parity then
                    set b = true
                endif
            endif
        endif
        call cd.destroy()
        if b then
            static if thistype.OnAfterLoad.exists then
                //call thistype.OnAfterLoad(p,pid,pn)
                set STA_P = p
                set STA_PID = pid
                set STA_PN = pn
                call ForForce(bj_FORCE_PLAYER[0], function thistype.STAAfterLoad)
            endif
        endif
        return b
    endmethod
//! endtextmacro
//==============================================================================
//! textmacro SaveCode takes NAME,ID,CHARSET
private struct $NAME$ extends array
    static constant string CHARSET = "$CHARSET$"
    static integer ARGS = 0
    static integer array ARGMAX
    static integer array ARG
    static constant integer MAX_PARITY = 5
    
    // AutoAdd
    static method onInit takes nothing returns nothing
        call SaveLoadData.AutoAddSaveTitle("$NAME$")
    endmethod
endstruct

function Save$NAME$ takes player p, string pn returns string
    local integer pid = GetPlayerId(p)
    local ClassicSaveCode cd = ClassicSaveCode.create($NAME$.CHARSET)
    local string s
    local integer value
    local integer i = 0
    local integer parity = GetRandomInt(1,$NAME$.MAX_PARITY)
    call cd.Encode(parity,$NAME$.MAX_PARITY)
    loop
        exitwhen i == $NAME$.ARGS
        set value = $NAME$.ARG[pid*$NAME$.ARGS+i]
        if value > $NAME$.ARGMAX[i] then
            set value = $NAME$.ARGMAX[i]
        endif
        if value < 0 then
            set value = 0
        endif
        call cd.Encode(value,$NAME$.ARGMAX[i])
        set i = i + 1
    endloop
    call cd.Encode(parity,$NAME$.MAX_PARITY)
    set s = cd.Save(pn,$ID$)
    call cd.destroy()
    // Auto Add
    call SaveLoadData.SetMatchedData("$NAME$", s)
    return s
endfunction

function Load$NAME$ takes player p, string pn, string s returns boolean
    local integer pid = GetPlayerId(p)
    local ClassicSaveCode cd = ClassicSaveCode.create($NAME$.CHARSET)
    local boolean b = cd.Load(pn,s,$ID$)
    local integer i = $NAME$.ARGS - 1
    local integer parity
    if b then
        set parity = cd.Decode($NAME$.MAX_PARITY)
        if parity < 1 then
            set b = false
        else
            loop
                exitwhen i < 0
                set $NAME$.ARG[pid*$NAME$.ARGS+i] = cd.Decode($NAME$.ARGMAX[i])
                set i = i - 1
            endloop
            if cd.Decode($NAME$.MAX_PARITY) != parity then
                set b = false
            endif
        endif
    endif
    call cd.destroy()
    return b
endfunction

function Clear$NAME$ takes player p returns nothing
    local integer pid = GetPlayerId(p)
    local integer i = 0
    loop
        exitwhen i == $NAME$.ARGS
        set $NAME$.ARG[pid*$NAME$.ARGS+i] = 0
        set i = i + 1
    endloop
endfunction
//! endtextmacro
//! textmacro SaveCodeData takes NAME,ARG,MAXIMUM
private struct $NAME$$ARG$ extends array
    static integer ARGIDX
    private static method onInit takes nothing returns nothing
        local integer i = 0
        set ARGIDX = $NAME$.ARGS
        set $NAME$.ARGMAX[ARGIDX] = $MAXIMUM$
        set $NAME$.ARGS = $NAME$.ARGS + 1
        debug call DisplayTextToPlayer(GetLocalPlayer(),0,0,"[$NAME$:$ARG$] record "+I2S(ARGIDX)+" max "+I2S($MAXIMUM$))
    endmethod
endstruct
function Set$NAME$$ARG$ takes player p, integer v returns nothing
    set $NAME$.ARG[GetPlayerId(p)*$NAME$.ARGS+$NAME$$ARG$.ARGIDX] = v
endfunction
function Get$NAME$$ARG$ takes player p returns integer
    return $NAME$.ARG[GetPlayerId(p)*$NAME$.ARGS+$NAME$$ARG$.ARGIDX]
endfunction
//! endtextmacro