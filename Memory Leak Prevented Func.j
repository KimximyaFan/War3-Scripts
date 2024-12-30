library MemoryLeakPrevention

function GetUnitsInRangeOfLocMatchingXXX takes real radius, location whichLocation, boolexpr filter, group g returns group
    set g = CreateGroup()
    call GroupEnumUnitsInRangeOfLoc(g, whichLocation, radius, filter)
    call DestroyBoolExpr(filter)
    call RemoveLocation(whichLocation)
    return g
endfunction

function ReviveHeroLocXXX takes unit whichHero, location loc, boolean doEyecandy returns boolean
    local boolean bool = ReviveHeroLoc(whichHero, loc, doEyecandy)
    call RemoveLocation(loc)
    return bool
endfunction

function SetUnitPositionLocXXX takes unit whichUnit, location whichLocation returns nothing
    call SetUnitPositionLoc(whichUnit, whichLocation)
    call RemoveLocation(whichLocation)
endfunction

function PanCameraToTimedLocForPlayerXXX takes player whichPlayer, location loc, real duration returns nothing
    if (GetLocalPlayer() == whichPlayer) then
        // Use only local code (no net traffic) within this block to avoid desyncs.
        call PanCameraToTimed(GetLocationX(loc), GetLocationY(loc), duration)
    endif
    call RemoveLocation(loc)
endfunction

function GetUnitsInRectAllXXX takes rect r, group temp returns group
    set temp = CreateGroup()
    call GroupEnumUnitsInRect(temp, r, null)
    return temp
endfunction

function CreateItemLocXXX takes integer itemId, location loc returns item
    set bj_lastCreatedItem = CreateItem(itemId, GetLocationX(loc), GetLocationY(loc))
    call RemoveLocation(loc)
    return bj_lastCreatedItem
endfunction


function CreateNUnitsAtLocXXX takes integer count, integer unitId, player whichPlayer, location loc, real face returns group
    call GroupClear(bj_lastCreatedGroup)
    loop
        set count = count - 1
        exitwhen count < 0
        call CreateUnitAtLocSaveLast(whichPlayer, unitId, loc, face)
        call GroupAddUnit(bj_lastCreatedGroup, bj_lastCreatedUnit)
    endloop
    call RemoveLocation(loc)
    return bj_lastCreatedGroup
endfunction

function ForGroupXXX takes group whichGroup, code callback returns nothing
    call ForGroup(whichGroup, callback)
    call GroupClear(whichGroup)
    call DestroyGroup(whichGroup)
endfunction

function IssuePointOrderLocXXX takes unit whichUnit, string order, location whichLocation returns boolean
    return IssuePointOrderLoc( whichUnit, order, whichLocation )
    call RemoveLocation(whichLocation)
endfunction

function Group_Clear takes group g returns nothing
    call GroupClear(g)
    call DestroyGroup(g)
endfunction

// temp should be null
function GetUnitsInRectMatchingXXX takes rect r, boolexpr filter, group temp returns group
    set temp = CreateGroup()
    call GroupEnumUnitsInRect(temp, r, filter)
    call DestroyBoolExpr(filter)
    return temp
endfunction

endlibrary