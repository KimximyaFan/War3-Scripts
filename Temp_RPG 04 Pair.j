struct Pair
    /*
        자료구조 Pair
        조합 구현에 쓰임
    */

    public integer Key
    public integer Value

    public static method create takes integer k, integer v returns Pair
        local thistype this = thistype.allocate()
        set Key = k
        set Value = v
        return this
    endmethod

    public method destroy takes nothing returns nothing
        set Key = 0
        set Value = 0
        call thistype.deallocate( this )
    endmethod
endstruct