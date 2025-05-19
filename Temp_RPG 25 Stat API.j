library StatAPI requires UnitProperty

// 스탯창 값 갱신하는 함수임
function Stat_Refresh takes integer pid returns nothing
    local unit u = player_hero[pid].Get_Hero_Unit()

    if GetLocalPlayer() == Player(pid) then
        call DzFrameSetText( stat_values[0], I2S(Get_Unit_Property(u, DMG)) )
        call DzFrameSetText( stat_values[1], I2S(Get_Unit_Property(u, DEF)) )
        call DzFrameSetText( stat_values[2], I2S(Get_Unit_Property(u, CON)))
        call DzFrameSetText( stat_values[3], I2S(Get_Unit_Property(u, STR)) )
        call DzFrameSetText( stat_values[4], I2S(Get_Unit_Property(u, DEX)))
        call DzFrameSetText( stat_values[5], I2S(Get_Unit_Property(u, INT)))
        call DzFrameSetText( stat_values[6], I2S(Get_Unit_Property(u, CHA)))
        call DzFrameSetText( stat_values[7], I2S(Get_Unit_Property(u, HP)))
        call DzFrameSetText( stat_values[8], I2S(Get_Unit_Property(u, CRIT_DMG)) )
        call DzFrameSetText( stat_values[9], I2S(Get_Unit_Property(u, MAX_DMG)) )
        call DzFrameSetText( stat_values[10], I2S(Get_Unit_Property(u, REDUCE_DMG)) )
        call DzFrameSetText( stat_values[11], I2S(Get_Unit_Property(u, AS)) )
        call DzFrameSetText( stat_values[12], I2S(Get_Unit_Property(u, POTION_REGEN_POWER)) )
        call DzFrameSetText( stat_values[13], I2S(Get_Unit_Property(u, SHORT_RANGE_DMG)) )
        call DzFrameSetText( stat_values[14], I2S(Get_Unit_Property(u, LONG_RANGE_DMG)))
        call DzFrameSetText( stat_values[15], I2S(Get_Unit_Property(u, MAGIC_DMG)))
        call DzFrameSetText( level_value, I2S(GetHeroLevel(u)) )
    endif
    
    set u = null
endfunction

endlibrary