JN Direct Save Refactor
=======================

목표
----
- ClassicSave 완전 제거
- JNObjectCharacterSetInt/Real/String/Boolean 직접 저장
- 서버 운영자가 특정 계정의 Aura/VIP/Ban 같은 값을 직접 설정할 수 있도록 User field 분리
- 기존 LoginDialog.toc/FDF 기반 로그인/캐릭터 슬롯 UI 유지

필요 파일
---------
JNLogin_native.j
JNLogin_Settings.j
JNLogin_TimerTools.j
JNLogin_SaveLoadData.j
JNLogin_SaveLoadLibrary.j
JNLogin_DirectSave.j
JNLogin_GameSaveData.j
JNLogin_SaveLoad.j
JNLogin_SaveSelectDialog.j
JNLogin_LoginDialogUI.j
JNLogin_Init.j

제거한 파일
-----------
JNLogin_ClassicSave.j
JNLogin_ClassicSaveMacros.j
JNLogin_ClassicSaveColorizer.j
JNLogin_ClassicSaveTest.j
기존 JNLogin_SomeExamples.j

UI
--
제공자가 준 UI/LoginDialog.toc 및 그 toc가 참조하는 fdf/blp 파일은 원래 경로 그대로 import.
LoginDialogUI의 DzLoadToc("UI\\LoginDialog.toc")와 모든 frame name은 유지했다.

개발자가 가장 많이 수정할 파일
-----------------------------
JNLogin_GameSaveData.j

1) 필드 등록
   JNDirectSave.RegisterCharacterInt("Gold")
   JNDirectSave.RegisterCharacterBool("QuestClear")
   JNDirectSave.RegisterUserInt("Aura")

2) 저장
   GameSaveData.WriteCharacterFields 안에서
   JNDirectSave.SetCharacterInt(p, "Gold", gold)
   ...
   SaveLoad.RequestSave(p)가 마지막에 JNObjectCharacterSave까지 처리.

3) 로드
   GameSaveData.ApplyLoaded 안에서
   set gold = JNDirectSave.GetCharacterInt(p, "Gold")
   set aura = JNDirectSave.GetUserInt(p, "Aura")

서버 운영값
-----------
Aura/VIP/Ban/Unlock처럼 운영자가 서버에서 직접 바꾸는 값은 User field 권장.
게임에서는 RegisterUserXXX + GetUserXXX만 하고 SetUserXXX/SaveUser를 호출하지 않는다.
그러면 일반 캐릭터 Save와 분리된다.

주의
----
- Settings.API_MAP_CODE / API_SECRET_KEY를 실제 값으로 교체.
- JN/Dz native 실행환경이 필요.
- field 이름에 '§' 문자를 쓰지 말 것.
- 플레이어별 데이터는 전역 단일 integer보다 integer array를 권장.
