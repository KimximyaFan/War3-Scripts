//==============================================================================
// Legacy (Obsolete)
library ClassicSaveColorizer
    private constant function uppercolor takes nothing returns string
        return "|cffff0000"
    endfunction
    private constant function lowercolor takes nothing returns string
        return "|cff00ff00"
    endfunction
    private constant function numcolor takes nothing returns string
        return "|cff0000ff"
    endfunction

    private function isupper takes string c returns boolean
        return c == StringCase(c,true)
    endfunction

    private function ischar takes string c returns boolean
        return S2I(c) == 0 and c!= "0"
    endfunction

    private function chartype takes string c returns integer
        if(ischar(c)) then
            if isupper(c) then
                return 0
            else
                return 1
            endif
        else
            return 2
        endif
    endfunction

    public function Colorize takes string s returns string
     local string out = ""
     local integer i = 0
     local integer len = StringLength(s)
     local integer ctype
     local string c
     loop
      exitwhen i >= len
      set c = SubString(s,i,i+1)
      set ctype = chartype(c)
      if ctype == 0 then
       set out = out + uppercolor()+c+"|r"
      elseif ctype == 1 then
       set out = out + lowercolor()+c+"|r"
      else
       set out = out + numcolor()+c+"|r"
      endif
      set i = i + 1
     endloop
     return out
    endfunction
    
endlibrary