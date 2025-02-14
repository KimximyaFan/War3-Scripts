function Saori_Unset_Gold takes unit u returns nothing
    call AddUnitAnimationPropertiesBJ( false, "gold", u )
    call AddUnitAnimationPropertiesBJ( true, "alternate", u )
endfunction

function Saori_Set_Gold takes unit u returns nothing
    call AddUnitAnimationPropertiesBJ( false, "alternate", u )
    call AddUnitAnimationPropertiesBJ( true, "gold", u )
endfunction