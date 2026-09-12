globals
    constant integer JN_OSKEY_TAB = 0x09
endglobals
//------------------------------------------------------------------------
// 네이티브 함수 선언
//------------------------------------------------------------------------
//! import "DzAPISync.j"
//! import "DzAPIFrameHandle.j"
//! import "JNServer.j"
//! import "JNString.j"
//! import "JNCommon.j"
native JNWriteLog takes string str returns nothing
native JNLogin                 takes string userId, string passWord returns boolean       // 로그인 처리
native JNLogout                takes nothing returns boolean                            // 로그아웃 처리
native JNGetSettingLogin       takes nothing returns boolean                            // 자동로그인 설정 확인
native JNLocalLogin            takes string userId returns boolean                    // 로컬 로그인 확인
native JNStringBase64Encoding  takes string str returns string                          // Base64 인코딩
native JNStringBase64Decoding  takes string str returns string                          // Base64 디코딩
native JNGetIp                 takes string MapId, string SecretKey returns string      // 현재 IP 반환
native DzGetTriggerKeyPlayer takes nothing returns player
native DzTriggerRegisterKeyEventByCode takes trigger trig, integer key, integer status, boolean sync, code funcHandle returns nothing