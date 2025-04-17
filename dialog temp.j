function Trig_temp_Func001C takes nothing returns boolean
    if ( not ( GetClickedButtonBJ() == udg_Ch1_Otaku_Guild_Dialog_Button1[0] ) ) then
        return false
    endif
    if ( not ( udg_isConversation == false ) ) then
        return false
    endif
    return true
endfunction

function Trig_temp_Func002C takes nothing returns boolean
    if ( not ( GetClickedButtonBJ() == udg_Ch1_Otaku_Guild_Dialog_Button1[1] ) ) then
        return false
    endif
    if ( not ( udg_isConversation == false ) ) then
        return false
    endif
    return true
endfunction

function Trig_temp_Func003C takes nothing returns boolean
    if ( not ( GetClickedButtonBJ() == udg_Ch1_Otaku_Guild_Dialog_Button1[2] ) ) then
        return false
    endif
    if ( not ( udg_isConversation == false ) ) then
        return false
    endif
    return true
endfunction

function Trig_temp_Func004C takes nothing returns boolean
    if ( not ( GetClickedButtonBJ() == udg_Ch1_Otaku_Guild_Dialog_Button1[3] ) ) then
        return false
    endif
    if ( not ( udg_isConversation == false ) ) then
        return false
    endif
    return true
endfunction

function Trig_temp_Func005C takes nothing returns boolean
    if ( not ( GetClickedButtonBJ() == udg_Ch1_Otaku_Guild_Dialog_Button1[4] ) ) then
        return false
    endif
    if ( not ( udg_isConversation == false ) ) then
        return false
    endif
    return true
endfunction

function Trig_temp_Func027Func010C takes nothing returns boolean
    if ( not ( udg_Ch1_Otaku_Quest_Array[0] == 1 ) ) then
        return false
    endif
    return true
endfunction

function Trig_temp_Func027Func013C takes nothing returns boolean
    if ( not ( udg_Ch1_Otaku_Quest_Array[0] == 1 ) ) then
        return false
    endif
    return true
endfunction

function Trig_temp_Func027C takes nothing returns boolean
    if ( not ( CountUnitsInGroup(udg_Ch1_Otaku_Monster_Group[0]) == 0 ) ) then
        return false
    endif
    return true
endfunction

function Trig_temp_Func031C takes nothing returns boolean
    if ( not ( CountUnitsInGroup(udg_Ch1_Otaku_Monster_Group[1]) == 0 ) ) then
        return false
    endif
    return true
endfunction

function Trig_temp_Func035Func003C takes nothing returns boolean
    if ( not ( udg_Ch1_Otaku_Quest_Array[2] == 1 ) ) then
        return false
    endif
    return true
endfunction

function Trig_temp_Func035Func006C takes nothing returns boolean
    if ( not ( udg_Ch1_Otaku_Quest_Array[2] == 1 ) ) then
        return false
    endif
    return true
endfunction

function Trig_temp_Func035C takes nothing returns boolean
    if ( not ( CountUnitsInGroup(udg_Ch1_Otaku_Monster_Group[2]) == 0 ) ) then
        return false
    endif
    return true
endfunction

function Trig_temp_Func039C takes nothing returns boolean
    if ( not ( CountUnitsInGroup(udg_Ch1_Otaku_Monster_Group[3]) == 0 ) ) then
        return false
    endif
    return true
endfunction

function Trig_temp_Func043C takes nothing returns boolean
    if ( not ( IsUnitAliveBJ(udg_Ch1_Otaku_ForestBear) == false ) ) then
        return false
    endif
    return true
endfunction

function Trig_temp_Actions takes nothing returns nothing
    if ( Trig_temp_Func001C() ) then
        call GlobalTV.Setinteger( 1, 0 )
    else
    endif
    if ( Trig_temp_Func002C() ) then
        call GlobalTV.Setinteger( 1, 1 )
    else
    endif
    if ( Trig_temp_Func003C() ) then
        call GlobalTV.Setinteger( 1, 2 )
    else
    endif
    if ( Trig_temp_Func004C() ) then
        call GlobalTV.Setinteger( 1, 3 )
    else
    endif
    if ( Trig_temp_Func005C() ) then
        call GlobalTV.Setinteger( 1, 4 )
    else
    endif
    // ---------------------------------------------
    if GlobalTV.integerB == 5 then
    call GlobalTV.SleepForStage( 0.10, 2 )
    else
    call GlobalTV.SleepForStageNext( 0.10 )
    endif
    // ---------------------------------------------
    endif
    // ---------------------------------------------
    if GlobalTV.Stage == 2 then
    // ---------------------------------------------
    call DialogDisplayBJ( false, udg_Ch1_Otaku_Guild_Dialog1, GlobalTV.playerA )
    call DialogClearBJ( udg_Ch1_Otaku_Guild_Dialog1 )
    call GlobalTV.Flush(  )
    endif
    // ---------------------------------------------
    if GlobalTV.Stage == 1 then
    // ---------------------------------------------
    // 유닛그룹수 0인지 판별 -> 0 이면 isCleared를 true 한다.
    // 유닛그룹수 0 이 아니면, 퀘스트 클릭을 처음 했는지 판별한다.
    if GlobalTV.integerB == 0 then
    if ( Trig_temp_Func027C() ) then
        set udg_Ch1_Otaku_Guild_isCleared[0] = true
        call DisplayTimedTextToForce( GetPlayersAll(), 4.00, "TRIGSTR_5243" )
        call PlaySoundBJ( gg_snd_AlchemistTransmuteDeath1 )
        set udg_Gold_AllplayerGet_Integer = 50
        call TriggerExecute( gg_trg_Gold_All_Player_Get )
        call PlaySoundBJ( gg_snd_QuestCompleted )
        call DestroyQuest( udg_Quest_Ch1_Sub[0] )
    else
        if udg_Ch1_Otaku_Guild_isInitial[0] == false then
        call PlaySoundBJ( gg_snd_QuestNew )
        if ( Trig_temp_Func027Func010C() ) then
            call DisplayTimedTextToForce( GetPlayersAll(), 10.00, "TRIGSTR_5248" )
            call TriggerExecute( gg_trg_Ch1_Otaku_Guild_Forest1_Talk )
            call CreateQuestBJ( bj_QUESTTYPE_OPT_DISCOVERED, "TRIGSTR_5249", "TRIGSTR_5250", "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp" )
            set udg_Quest_Ch1_Sub[0] = GetLastCreatedQuestBJ()
            call QuestMessageBJ( GetPlayersAll(), bj_QUESTMESSAGE_DISCOVERED, "TRIGSTR_5251" )
        else
            call DisplayTimedTextToForce( GetPlayersAll(), 6.00, "TRIGSTR_5244" )
            call TriggerExecute( gg_trg_Ch1_Otaku_Guild_Forest1_Talk2 )
            call CreateQuestBJ( bj_QUESTTYPE_OPT_DISCOVERED, "TRIGSTR_5245", "TRIGSTR_5246", "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp" )
            set udg_Quest_Ch1_Sub[0] = GetLastCreatedQuestBJ()
            call QuestMessageBJ( GetPlayersAll(), bj_QUESTMESSAGE_DISCOVERED, "TRIGSTR_5247" )
        endif
        set udg_Ch1_Otaku_Guild_isInitial[0] = true
        else
        if ( Trig_temp_Func027Func013C() ) then
            call DisplayTimedTextToForce( GlobalTV.Getforce(0), 3.00, "TRIGSTR_5253" )
        else
            call DisplayTimedTextToForce( GlobalTV.Getforce(0), 3.00, "TRIGSTR_5252" )
        endif
        endif
    endif
    endif
    // ---------------------------------------------
    if GlobalTV.integerB == 1 then
    if ( Trig_temp_Func031C() ) then
        set udg_Ch1_Otaku_Guild_isCleared[1] = true
        call DisplayTimedTextToForce( GetPlayersAll(), 4.00, "TRIGSTR_5254" )
        call PlaySoundBJ( gg_snd_AlchemistTransmuteDeath1 )
        set udg_Gold_AllplayerGet_Integer = 75
        call TriggerExecute( gg_trg_Gold_All_Player_Get )
        call PlaySoundBJ( gg_snd_QuestCompleted )
        call DestroyQuest( udg_Quest_Ch1_Sub[1] )
    else
        if udg_Ch1_Otaku_Guild_isInitial[1] == false then
        call PlaySoundBJ( gg_snd_ArrangedTeamInvitation )
        call DisplayTimedTextToForce( GetPlayersAll(), 10.00, "TRIGSTR_5255" )
        set udg_Ch1_Otaku_Guild_isInitial[1] = true
        call TriggerExecute( gg_trg_Ch1_Otaku_Guild_Forest2_Talk )
        call CreateQuestBJ( bj_QUESTTYPE_OPT_DISCOVERED, "TRIGSTR_5256", "TRIGSTR_5257", "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp" )
        set udg_Quest_Ch1_Sub[1] = GetLastCreatedQuestBJ()
        call QuestMessageBJ( GetPlayersAll(), bj_QUESTMESSAGE_DISCOVERED, "TRIGSTR_5258" )
        else
        call DisplayTimedTextToForce( GlobalTV.Getforce(0), 3.00, "TRIGSTR_5259" )
        endif
    endif
    endif
    // ---------------------------------------------
    if GlobalTV.integerB == 2 then
    if ( Trig_temp_Func035C() ) then
        set udg_Ch1_Otaku_Guild_isCleared[2] = true
        call DisplayTimedTextToForce( GetPlayersAll(), 4.00, "TRIGSTR_5270" )
        call PlaySoundBJ( gg_snd_AlchemistTransmuteDeath1 )
        set udg_Gold_AllplayerGet_Integer = 100
        call TriggerExecute( gg_trg_Gold_All_Player_Get )
        call PlaySoundBJ( gg_snd_QuestCompleted )
        call DestroyQuest( udg_Quest_Ch1_Sub[2] )
    else
        if udg_Ch1_Otaku_Guild_isInitial[2] == false then
        call PlaySoundBJ( gg_snd_QuestNew )
        if ( Trig_temp_Func035Func003C() ) then
            call DisplayTimedTextToForce( GetPlayersAll(), 10.00, "TRIGSTR_5264" )
            call TriggerExecute( gg_trg_Ch1_Otaku_Guild_Desert_Talk1 )
            call CreateQuestBJ( bj_QUESTTYPE_OPT_DISCOVERED, "TRIGSTR_5265", "TRIGSTR_5266", "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp" )
            set udg_Quest_Ch1_Sub[2] = GetLastCreatedQuestBJ()
            call QuestMessageBJ( GetPlayersAll(), bj_QUESTMESSAGE_DISCOVERED, "TRIGSTR_5267" )
        else
            call DisplayTimedTextToForce( GetPlayersAll(), 10.00, "TRIGSTR_5260" )
            call TriggerExecute( gg_trg_Ch1_Otaku_Guild_Desert_Talk2 )
            call CreateQuestBJ( bj_QUESTTYPE_OPT_DISCOVERED, "TRIGSTR_5261", "TRIGSTR_5262", "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp" )
            set udg_Quest_Ch1_Sub[2] = GetLastCreatedQuestBJ()
            call QuestMessageBJ( GetPlayersAll(), bj_QUESTMESSAGE_DISCOVERED, "TRIGSTR_5263" )
        endif
        set udg_Ch1_Otaku_Guild_isInitial[2] = true
        else
        if ( Trig_temp_Func035Func006C() ) then
            call DisplayTimedTextToForce( GlobalTV.Getforce(0), 3.00, "TRIGSTR_5269" )
        else
            call DisplayTimedTextToForce( GlobalTV.Getforce(0), 3.00, "TRIGSTR_5268" )
        endif
        endif
    endif
    endif
    // ---------------------------------------------
    if GlobalTV.integerB == 3 then
    if ( Trig_temp_Func039C() ) then
        set udg_Ch1_Otaku_Guild_isCleared[3] = true
        call DisplayTimedTextToForce( GetPlayersAll(), 4.00, "TRIGSTR_5271" )
        call PlaySoundBJ( gg_snd_AlchemistTransmuteDeath1 )
        set udg_Gold_AllplayerGet_Integer = 75
        call TriggerExecute( gg_trg_Gold_All_Player_Get )
        call PlaySoundBJ( gg_snd_QuestCompleted )
        call DestroyQuest( udg_Quest_Ch1_Sub[3] )
    else
        if udg_Ch1_Otaku_Guild_isInitial[3] == false then
        call PlaySoundBJ( gg_snd_ArrangedTeamInvitation )
        call DisplayTimedTextToForce( GetPlayersAll(), 10.00, "TRIGSTR_5272" )
        set udg_Ch1_Otaku_Guild_isInitial[3] = true
        call TriggerExecute( gg_trg_Ch1_Otaku_Guild_Troll_Talk )
        call CreateQuestBJ( bj_QUESTTYPE_OPT_DISCOVERED, "TRIGSTR_5273", "TRIGSTR_5274", "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp" )
        set udg_Quest_Ch1_Sub[3] = GetLastCreatedQuestBJ()
        call QuestMessageBJ( GetPlayersAll(), bj_QUESTMESSAGE_DISCOVERED, "TRIGSTR_5275" )
        else
        call DisplayTimedTextToForce( GlobalTV.Getforce(0), 3.00, "TRIGSTR_5276" )
        endif
    endif
    endif
    // ---------------------------------------------
    if GlobalTV.integerB == 4 then
    if ( Trig_temp_Func043C() ) then
        set udg_Ch1_Otaku_Guild_isCleared[4] = true
        call DisplayTimedTextToForce( GetPlayersAll(), 4.00, "TRIGSTR_5277" )
        call PlaySoundBJ( gg_snd_AlchemistTransmuteDeath1 )
        set udg_Gold_AllplayerGet_Integer = 200
        call TriggerExecute( gg_trg_Gold_All_Player_Get )
        call PlaySoundBJ( gg_snd_QuestCompleted )
        call DestroyQuest( udg_Quest_Ch1_Sub[4] )
    else
        if udg_Ch1_Otaku_Guild_isInitial[4] == false then
        call PlaySoundBJ( gg_snd_ArrangedTeamInvitation )
        call DisplayTimedTextToForce( GetPlayersAll(), 10.00, "TRIGSTR_5278" )
        set udg_Ch1_Otaku_Guild_isInitial[4] = true
        call TriggerExecute( gg_trg_Ch1_Otaku_Guild_Bear_Talk )
        call CreateQuestBJ( bj_QUESTTYPE_OPT_DISCOVERED, "TRIGSTR_5279", "TRIGSTR_5280", "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp" )
        set udg_Quest_Ch1_Sub[4] = GetLastCreatedQuestBJ()
        call QuestMessageBJ( GetPlayersAll(), bj_QUESTMESSAGE_DISCOVERED, "TRIGSTR_5281" )
        else
        call DisplayTimedTextToForce( GlobalTV.Getforce(0), 3.00, "TRIGSTR_5282" )
        endif
    endif
    endif
    // ---------------------------------------------
    call GlobalTV.SleepForStageNext( 0.10 )
    endif
    // ---------------------------------------------
endfunction

//===========================================================================
function InitTrig_temp takes nothing returns nothing
    set gg_trg_temp = CreateTrigger(  )
    call TriggerRegisterDialogEventBJ( gg_trg_temp, udg_Ch1_Otaku_Guild_Dialog1 )
    call TriggerAddAction( gg_trg_temp, function Trig_temp_Actions )
endfunction
