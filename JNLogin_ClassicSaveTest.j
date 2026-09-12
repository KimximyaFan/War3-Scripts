library ClassicSaveTest initializer RunTests
    private function interface proposition takes nothing returns boolean
    public function Closeto takes real x, real y returns boolean
        return RAbsBJ(x - y) <= 0.001
    endfunction
    private function prop_Closeto takes nothing returns boolean
        return Closeto(1,1) and Closeto(1,1.0005) and not Closeto(0,1)
    endfunction
    public function DebugMsg takes string s returns nothing
        call BJDebugMsg(s)
        call Cheat("DebugMsg: "+s)
    endfunction  
    public function Assert takes string name, proposition t returns nothing
        if t.evaluate() then
            //call BJDebugMsg("|cff00ff00"+"OK  "+"|r"+name)
            //call Cheat("DebugMsg: OK   "+name)
        else
            call DebugMsg("|cffff0000"+"Failed  "+"|r"+name)
            call Cheat("DebugMsg: Failed  "+name)
        endif
    endfunction
    private function RunTests takes nothing returns nothing
        debug local string n = "SelfTest "
        debug call ClassicSaveTest_Assert(n+"Closeto",proposition.prop_Closeto)
    endfunction
endlibrary
