library ObjectTableEquipment

/*
    장비 오브젝트들을 등록하는 스크립트
*/

globals
    // 일반검
    integer NORMAL_SWORD
    // 일반방패
    integer NORMAL_SHIELD
    // 일반헬멧
    integer NORMAL_HELMET
    // 쎈검
    integer POWER_SWORD
endglobals

function Object_Table_Equip_Init takes nothing returns nothing
    local integer current_object_id
    local string name
    local string img
    
    /*
        사용 법은 다음과 같다
        
        
        1. 변수와 이름 그리고 blp 경로는 Object Table Consumable 에서 다뤘으므로 스킵
        
        
        
        2. Register_Equip( 장비ID, 장비타입, name, img ) 같은 경우
        장비타입 변수는
        constant integer HELMET = 0
        constant integer NECKLACE = 1
        constant integer WEAPON = 2
        constant integer ARMOR = 3
        constant integer SHIELD = 4
        constant integer RING = 5
        constant integer BELT = 6
        constant integer GLOVE = 8
        constant integer BOOTS = 9
        이걸 참고해서 등록하도록 한다
        
        
        
        2. Set_Equip_Fixed_Option( 장비ID, 고정옵션, 최솟값, 최댓값 ) 같은 경우
        고정 옵션은 아래를 참고하도록 한다
        constant integer DMG = 0
        constant integer DEF = 1
        constant integer CON = 2
        constant integer STR = 3
        constant integer DEX = 4
        constant integer INT = 5
        constant integer CHA = 6
        constant integer HP = 7
        constant integer CRIT_DMG = 8
        constant integer MAX_DMG = 9
        constant integer REDUCE_DMG = 10
        constant integer AS = 11
        constant integer POTION_REGEN_POWER = 12
        constant integer SHORT_RANGE_DMG = 13
        constant integer LONG_RANGE_DMG = 14
        constant integer MAGIC_DMG = 15
        그리고 Set_Equip_Fixed_Option() 더 사용해서 고정옵션을 추가로 계속 달 수 있다
        
        
        
        3. Set_Object_Data( 장비ID, GRADE, 등급 )
        장비 등급같은 경우
        constant integer NORMAL = 0 /* 일반 */
        constant integer ADVANCED = 1 /* 고급 */
        constant integer RARE = 2 /* 희귀 */
        constant integer LEGEND = 3 /* 전설 */
        constant integer HEROIC = 4 /* 영웅 */
        constant integer EPIC = 5 /* 신화 */
        constant integer ONLY = 6 /* 유일 */
        이걸 참고해서 등록하도록 한다
        
        
        
        4. 추가로
        Set_Object_Data( 장비ID, STAR_GRADE, 성급 )
        을 통해 해당 장비의 고유 성급을 미리 설정할 수 있다
        만약 이걸 하지않는다면 기본적으로 성급이 1이 된다
        
        
        
        
        결론. 
        최종적으로 아래와 같은 형식을 유지한다
        
        set current_object_id = Get_New_Object_ID()
        set NORMAL_SWORD = current_object_id
        set name = "이름"
        set img = "blp 경로"
        call Register_Equip( current_object_id, WEAPON, name, img )
        ...
        
        call Set_Object_Data( current_object_id, GRADE, NORMAL )
        call Set_Name_To_ID( "NORMAL_SWORD", current_object_id )
        
    */

    set current_object_id = Get_New_Object_ID()
    set NORMAL_SWORD = current_object_id
    set name = "일반 검"
    set img = "ReplaceableTextures\\CommandButtons\\BTNSteelMelee.blp"
    call Register_Equip( current_object_id, WEAPON, name, img )
    call Set_Equip_Fixed_Option( current_object_id, DMG, 4, 6 )
    call Set_Object_Data( current_object_id, GRADE, NORMAL )
    call Set_Name_To_ID( "NORMAL_SWORD", current_object_id )
    
    set current_object_id = Get_New_Object_ID()
    set NORMAL_SHIELD = current_object_id
    set name = "일반 방패"
    set img = "ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpOne.blp"
    call Register_Equip( current_object_id, SHIELD, name, img )
    call Set_Equip_Fixed_Option( current_object_id, DEF, 3, 5 )
    call Set_Object_Data( current_object_id, GRADE, NORMAL )
    call Set_Name_To_ID( "NORMAL_SHIELD", current_object_id )
    
    set current_object_id = Get_New_Object_ID()
    set NORMAL_HELMET = current_object_id
    set name = "일반 투구"
    set img = "ReplaceableTextures\\CommandButtons\\BTNSobiMask.blp"
    call Register_Equip( current_object_id, HELMET, name, img )
    call Set_Equip_Fixed_Option( current_object_id, HP, 5, 10 )
    call Set_Object_Data( current_object_id, GRADE, NORMAL )
    call Set_Name_To_ID( "NORMAL_HELMET", current_object_id )
    
    set current_object_id = Get_New_Object_ID()
    set POWER_SWORD = current_object_id
    set name = "쎈 검"
    set img = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp"
    call Register_Equip( current_object_id, WEAPON, name, img )
    call Set_Equip_Fixed_Option( current_object_id, DMG, 40, 60 )
    call Set_Object_Data( current_object_id, GRADE, ADVANCED )
    call Set_Name_To_ID( "POWER_SWORD", current_object_id )
    
endfunction

endlibrary