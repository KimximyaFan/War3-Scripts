globals
    /*
        조합 칸 갯수를 나타내는 상수
    */
    constant integer COMBINATION_END = 10
endglobals

struct Hero
    // Property
    private integer level /* 영웅 레벨 */
    private integer pid /* 플레이어번호 */
    private boolean is_auto_remove /* 습득시 자동분해 판별 불린 */
    
    // 영웅 참조용
    private unit hero_unit
    
    // 인벤 25칸
    public Object array inven_object[25]
    // 착용 10칸
    public Object array wearing_object[10]
    // 조합 11칸, 마지막 끝번 10번 인덱스는 조합 결과템용
    public Object array combination_object[11]
    // 업그레이드 10칸, 현재 1칸만 사용함
    public Object array upgrade_object[10]
    
    // 생성자
    public static method create takes integer player_id returns thistype
        local integer i
        local thistype this = thistype.allocate()
        
        set pid = player_id
        
        set i = -1
        loop
        set i = i + 1
        exitwhen i >= 10
            set wearing_object[i] = -1
            set upgrade_object[i] = -1
        endloop
        
        set i = -1
        loop
        set i = i + 1
        exitwhen i >= COMBINATION_END+1
            set combination_object[i] = -1
        endloop
        
        set i = -1
        loop
        set i = i + 1
        exitwhen i >= 25
            set inven_object[i] = -1
        endloop
        
        set level = 1
        return this
    endmethod
    
    // 소멸자
    method destroy takes nothing returns nothing
        call thistype.deallocate( this )
    endmethod
    
    // 영웅 유닛 반환
    public method Get_Hero_Unit takes nothing returns unit
        return hero_unit
    endmethod
    
    // 레벨 반환
    public method Get_Level takes nothing returns integer
        return level
    endmethod
    
    /*
        영웅 유닛 지정
        
        현재 맵 윤곽이 안잡혀 있으므로 다키스트 에서 쓰던 초기화는 일단 주석처리함
    */
    public method Set_Hero_Unit takes unit u returns nothing
        set hero_unit = u
        /*
        call SaveReal( HT, GetHandleId(u), ATTACK_COOLDOWN, JNGetUnitAttackCooldown(u, 1) )
        call Set_Unit_Property( u, AD, 0 )
        call Set_Unit_Property( u, AP, 0 )
        call Set_Unit_Property( u, AS, 0 )
        call Set_Unit_Property( u, MS, R2I(GetUnitMoveSpeed(u) + 0.001) )
        call Set_Unit_Property( u, CRIT, 0 )
        call Set_Unit_Property( u, CRIT_COEF, 0 )
        call Set_Unit_Property( u, ENHANCE_AD, 0 )
        call Set_Unit_Property( u, ENHANCE_AP, 0 )
        call Set_Unit_Property( u, DEF_AD, 0 )
        call Set_Unit_Property( u, DEF_AP, 0 )
        call Set_Unit_Property( u, HP, R2I(JNGetUnitHP(u) + 0.001) )
        call Set_Unit_Property( u, MP, R2I(JNGetUnitMana(u) + 0.001) )
        call Set_Unit_Property( u, HP_REGEN, 1 )
        call Set_Unit_Property( u, MP_REGEN, 1 )
        call Set_Unit_Property( u, REDUCE_AD, 0 )
        call Set_Unit_Property( u, REDUCE_AP, 0 )
        
        set this.unit_base_as = JNGetUnitAttackCooldown(u, 1)
        set this.ms = Get_Unit_Property(u, MS)
        set this.hp = Get_Unit_Property(u, HP)
        set this.mp = Get_Unit_Property(u, MP)
        set this.hp_regen = 1
        set this.mp_regen = 1
        set increase_ad = 0
        set increase_ap = 0
        set increase_as = 0
        set increase_ms = 0
        set increase_hp = 0
        set increase_mp = 0
        set increase_def_ad = 0
        set increase_def_ap = 0
        set increase_hp_regen = 0
        set increase_mp_regen = 0
        */
    endmethod
    
    // 레벨 설정
    public method Set_Level takes integer value returns nothing
        set level = value
    endmethod
    
    // 자동분해 설정
    public method Set_Auto_Remove takes boolean flag returns nothing
        set is_auto_remove = flag
    endmethod
    
    
    /*
        아이템 해제시 
        해당 아이템 스탯만큼 영웅의 스탯을 빼는 함수
    */
    private method Item_Unequiped takes integer wearing_index returns nothing
        local unit u = Get_Hero_Unit()
        local integer property = -1
        local integer value

        loop
        set property = property + 1
        exitwhen property >= EQUIP_PROPERTY_SIZE
            
            set value = wearing_object[wearing_index].Get_Object_Property(property)
            if value != 0 then
                call Set_Unit_Property(u, property, Get_Unit_Property(u, property) - value)
            endif
        endloop

        set u = null
    endmethod
    
    /*
        아이템 착용시
        해당 아이템 스탯만큼 영웅의 스탯을 더하는 함수
    */
    private method Item_Equiped takes integer wearing_index returns nothing
        local unit u = Get_Hero_Unit()
        local integer property = -1
        local integer value

        loop
        set property = property + 1
        exitwhen property >= EQUIP_PROPERTY_SIZE
            
            set value = wearing_object[wearing_index].Get_Object_Property(property)
            if value != 0 then
                call Set_Unit_Property(u, property, Get_Unit_Property(u, property) + value)
            endif
        endloop

        set u = null
    endmethod
    
    /*
        해당 장비 타입을 착용하고있는지 판별하는 함수
        예를 들어 방패를 착용한다 가정한다면
        
        call player_hero[pid].Check_Wearing( Shield )
        
        이런식으로 작동하며,
        
        이미 착용중이면 -1 반환
        
        미착용중이면 제대로된 index를 반환함
    */
    public method Check_Wearing takes integer item_type returns integer
        local integer find_index = -1
        
        if item_type == RING then
            if wearing_object[item_type] == -1 then
                set find_index = item_type
            elseif wearing_object[item_type+2] == -1 then
                set find_index = item_type+2
            endif
        else
            if wearing_object[item_type] == -1 then
                set find_index = item_type
            endif
        endif
        
        return find_index
    endmethod
    
    /*
        인벤 아이템 반환
    */
    public method Get_Inven_Item takes integer i returns Object
        return inven_object[i]
    endmethod
    /*
        착용 아이템 반환
    */
    public method Get_Wearing_Item takes integer i returns Object
        return wearing_object[i]
    endmethod
    /*
        조합칸 아이템 반환
    */
    public method Get_Combination_Item takes integer i returns Object
        return combination_object[i]
    endmethod
    /*
        업그레이드 칸 아이템 반환
    */
    public method Get_Upgrade_Object takes integer i returns Object
        return upgrade_object[i]
    endmethod
    /*
        인벤칸에 아이템 세팅
    */
    public method Set_Inven_Item takes integer i, Object obj returns nothing
        set inven_object[i] = obj
        call Inven_Set_Img(pid, i, obj)
    endmethod
    /*
        착용칸 아이템 세팅
    */
    public method Set_Wearing_Item takes integer i, Object obj returns nothing
        set wearing_object[i] = obj
        call Item_Equiped(i)
        call Wearing_Set_Img( pid, i, obj )
    endmethod
    /*
        조합칸 아이템 세팅
    */
    public method Set_Combination_Item takes integer i, Object obj returns nothing
        set combination_object[i] = obj
        call Combination_Set_Img( pid, i, obj )
    endmethod
    /*
        업그레이드칸 아이템 세팅
    */
    public method Set_Upgrade_Object takes integer i, Object obj returns nothing
        set upgrade_object[i] = obj
        call Upgrade_Set_Img( pid, i, obj )
    endmethod
    /*
        인벤칸 아이템 해제
    */
    public method Remove_Inven_Item takes integer i returns nothing
        set inven_object[i] = -1
        call Inven_Remove_Img( pid, i )
    endmethod
    /*
        착용칸 아이템 해제
    */
    public method Remove_Wearing_Item takes integer i returns nothing
        call Item_Unequiped(i)
        set wearing_object[i] = -1
        call Wearing_Remove_Img( pid, i )
    endmethod
    /*
        조합칸 아이템 해제
    */
    public method Remove_Combination_Item takes integer i returns nothing
        set combination_object[i] = -1
        call Combination_Remove_Img( pid, i )
    endmethod
    /*
        업그레이드칸 아이템 해제
    */
    public method Remove_Upgrade_Object takes integer i returns nothing
        set upgrade_object[i] = -1
        call Upgrade_Remove_Img( pid, i )
    endmethod
    /*
        인벤칸 아이템 삭제
        소멸자를 쓰므로 오브젝트 자체가 날라감
        아이템 버리기에 쓰임
    */
    public method Delete_Inven_Item takes integer i returns nothing
        if inven_object[i].Get_Object_Property(LOCK) == 1 then
            return
        endif
        if inven_object[i] == -1 then
            return
        endif
        call Inven_Remove_Img( pid, i )
        call inven_object[i].destroy()
        set inven_object[i] = -1
    endmethod
    /*
        조합칸 아이템 삭제
        소멸자를 쓰므로 오브젝트 자체가 날라감
        조합 조건 충족시 조합칸 아이템 날릴 때 쓰임
    */
    public method Delete_Combination_Item takes integer i returns nothing
        if combination_object[i] == -1 then
            return
        endif
        call Combination_Remove_Img( pid, i )
        call combination_object[i].destroy()
        set combination_object[i] = -1
    endmethod
    /*
        인벤칸 해당 인덱스에 오브젝트가 존재하는지? 
    */
    public method Check_Inven_Item takes integer i returns boolean
        if inven_object[i] == -1 then
            return false
        else
            return true
        endif
    endmethod
    /*
        착용칸 해당 인덱스에 오브젝트가 존재하는지?
    */
    public method Check_Wearing_Item takes integer i returns boolean
        if wearing_object[i] == -1 then
            return false
        else
            return true
        endif
    endmethod
    /*
        업글칸 해당 인덱스에 오브젝트가 존재하는지?
    */
    public method Check_Upgrade_Object takes integer i returns boolean
        if upgrade_object[i] == -1 then
            return false
        else
            return true
        endif
    endmethod
    
    /*
        인벤칸에 가능한 공간이 있는지 검사
        0부터 24까지 순회하며
        자리가 있으면 해당 인덱스를 반환하고
        없으면 -1 반환
    */
    public method Check_Inven_Possible takes nothing returns integer
        local integer i
        local integer find_index
        local boolean isFind = false
        
        set i = -1
        loop
        set i = i + 1
        exitwhen i > 24 or isFind == true
            if inven_object[i] == -1 then
                set isFind = true
                set find_index = i
            endif
        endloop
        
        if isFind == true then
            return find_index
        else
            return -1
        endif
    endmethod
    
    /*
        같은 ID의 오브젝트가 있는지? 
        CONSUMABLE, MATERIAL 전용, index 반환
        랜덤박스 2개가 인벤에 들어오고 
        만약 이미 20개가 있다면
        기존 랜덤박스를 22개로 만들때 이걸 씀
    */
    public method Check_Same_Id_In_Inven takes Object obj returns integer
        local integer obj_id = obj.Get_Object_Property(ID)
        local integer i
        local integer find_index
        local boolean isFind = false
        
        set i = -1
        loop
        set i = i + 1
        exitwhen i > 24 or isFind == true
            if inven_object[i] != -1 and inven_object[i].Get_Object_Property(ID) == obj_id then
                set isFind = true
                set find_index = i
            endif
        endloop
        
        if isFind == true then
            return find_index
        else
            return -1
        endif
    endmethod
    
    /*
        조합칸에 가능한 공간이 있는지?
        가능한 공간이 없으면 -1을 반환
    */
    public method Check_Combination_Space_Possible takes nothing returns integer
        local integer i
        local integer find_index
        local boolean isFind = false
        
        set i = -1
        loop
        set i = i + 1
        exitwhen i >= COMBINATION_END or isFind == true
            if combination_object[i] == -1 then
                set isFind = true
                set find_index = i
            endif
        endloop
        
        if isFind == true then
            return find_index
        else
            return -1
        endif
    endmethod
    
    /*
        같은 ID의 오브젝트가 있는지? 
        CONSUMABLE, MATERIAL 전용, index 반환
        랜덤박스 2개가 조합칸에 들어오고 
        만약 이미 조합칸에 20개가 있다면
        조합칸 랜덤박스를 22개로 만들때 이걸 씀
    */
    public method Check_Same_Id_In_Combination takes Object obj returns integer
        local integer obj_id = obj.Get_Object_Property(ID)
        local integer i
        local integer find_index
        local boolean isFind = false
        
        if obj.Get_Object_Property(OBJECT_TYPE) == EQUIP then
            return -1
        endif
        
        set i = -1
        loop
        set i = i + 1
        exitwhen i >= COMBINATION_END or isFind == true
            if combination_object[i] != -1 and combination_object[i].Get_Object_Property(ID) == obj_id then
                set isFind = true
                set find_index = i
            endif
        endloop
        
        if isFind == true then
            return find_index
        else
            return -1
        endif
    endmethod
    
    /*
        아이템 자동분해 할 때 쓰는 함수
        유저에게 아이템이 들어왔을 때 해당 아이템이 자동분해 조건에 충족하는지 판별
    */
    public method Check_Object_Should_Be_Removed takes Object obj returns boolean
        local integer grade = obj.Get_Object_Property(GRADE)
        local integer star_grade = obj.Get_Object_Property(STAR_GRADE)
        
        if is_auto_remove == false then
            return false
        endif
        
        if obj.Get_Object_Property(OBJECT_TYPE) == EQUIP and (discard_all_grade_check[pid][grade] == true or discard_all_star_grade_check[pid][star_grade]) then
            return true
        else
            return false
        endif
    endmethod
    
    /*
        유저에게 오브젝트가 들어올 때 쓰는 함수
    */
    public method Add_Object_To_Hero takes Object obj returns integer
        local integer i
        local Object existing_obj
        
        // 자동분해 해야하는지?
        if Check_Object_Should_Be_Removed(obj) == true then
            call obj.destroy()
            return -1
        endif
        
        // 오브젝트가 장비타입이면 그냥 진행
        // 소모품이나 재료면 아이템 중첩 진행
        if obj.Get_Object_Property(OBJECT_TYPE) == EQUIP then
            set i = Check_Inven_Possible()
        else
            set i = Check_Same_Id_In_Inven(obj)
            
            if i == -1 then
                set i = Check_Inven_Possible()
            else
                set existing_obj = Get_Inven_Item(i)
                call existing_obj.Set_Object_Property(COUNT, existing_obj.Get_Object_Property(COUNT) + obj.Get_Object_Property(COUNT))
                call Inven_Item_Count_Refresh(pid, i)
                call obj.destroy()
                return -1
            endif
        endif
        
        // 인벤 꽉찼을 때
        if i == -1 then
            if GetLocalPlayer() == Player(pid) then
                call BJDebugMsg("인벤 꽉참")
            endif
            return obj
        endif

        call Set_Inven_Item( i, obj )
        
        return -1
    endmethod
    
endstruct