globals
    constant integer JN_OSKEY_TAB = 0x09
endglobals

//! import "DzAPISync.j"
//! import "DzAPIFrameHandle.j"
//! import "JNServer.j"
//! import "JNString.j"
//! import "JNCommon.j"

native JNLogin                takes string userId, string passWord returns boolean
native JNLogout               takes nothing returns boolean
native JNGetSettingLogin      takes nothing returns boolean
native JNLocalLogin           takes string userId returns boolean
native JNStringBase64Encoding takes string str returns string
native JNStringBase64Decoding takes string str returns string
native DzGetTriggerKeyPlayer  takes nothing returns player
native DzTriggerRegisterKeyEventByCode takes trigger trig, integer key, integer status, boolean sync, code funcHandle returns nothing
