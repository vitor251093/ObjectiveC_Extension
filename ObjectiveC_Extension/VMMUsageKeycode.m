//
//  VMMUsageKeycode.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 09/08/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "VMMUsageKeycode.h"
#import "VMMLocalizationUtility.h"

@implementation VMMUsageKeycode

NSDictionary* _usageNamesByKeycode;

+(nonnull NSDictionary*)usageNamesByKeycode
{
    if (!_usageNamesByKeycode)
    {
        _usageNamesByKeycode = @{
                                 // 00 Reserved
                                 @(kKU_ErrorRollOver):             VMMLocalizedString(@"Error Roll Over"),
                                 @(kKU_PostFail):                  VMMLocalizedString(@"Post Fail"),
                                 @(kKU_ErrorUndefined):            VMMLocalizedString(@"Error Undefined"),
                                 @(kKU_ANSI_A):                    @"A",
                                 @(kKU_ANSI_B):                    @"B",
                                 @(kKU_ANSI_C):                    @"C",
                                 @(kKU_ANSI_D):                    @"D",
                                 @(kKU_ANSI_E):                    @"E",
                                 @(kKU_ANSI_F):                    @"F",
                                 @(kKU_ANSI_G):                    @"G",
                                 @(kKU_ANSI_H):                    @"H",
                                 @(kKU_ANSI_I):                    @"I",
                                 @(kKU_ANSI_J):                    @"J",
                                 @(kKU_ANSI_K):                    @"K",
                                 @(kKU_ANSI_L):                    @"L",
                                 @(kKU_ANSI_M):                    @"M",
                                 @(kKU_ANSI_N):                    @"N",
                                 @(kKU_ANSI_O):                    @"O",
                                 @(kKU_ANSI_P):                    @"P",
                                 @(kKU_ANSI_Q):                    @"Q",
                                 @(kKU_ANSI_R):                    @"R",
                                 @(kKU_ANSI_S):                    @"S",
                                 @(kKU_ANSI_T):                    @"T",
                                 @(kKU_ANSI_U):                    @"U",
                                 @(kKU_ANSI_V):                    @"V",
                                 @(kKU_ANSI_W):                    @"W",
                                 @(kKU_ANSI_X):                    @"X",
                                 @(kKU_ANSI_Y):                    @"Y",
                                 @(kKU_ANSI_Z):                    @"Z",
                                
                                 @(kKU_ANSI_1):                    @"1",
                                 @(kKU_ANSI_2):                    @"2",
                                 @(kKU_ANSI_3):                    @"3",
                                 @(kKU_ANSI_4):                    @"4",
                                 @(kKU_ANSI_5):                    @"5",
                                 @(kKU_ANSI_6):                    @"6",
                                 @(kKU_ANSI_7):                    @"7",
                                 @(kKU_ANSI_8):                    @"8",
                                 @(kKU_ANSI_9):                    @"9",
                                 @(kKU_ANSI_0):                    @"0",
                                
                                 @(kKU_Enter):                     VMMLocalizedString(@"Return"),
                                 @(kKU_Escape):                    VMMLocalizedString(@"Escape"),
                                 @(kKU_Delete):                    VMMLocalizedString(@"Delete"),
                                 @(kKU_Tab):                       VMMLocalizedString(@"Tab"),
                                 @(kKU_Space):                     VMMLocalizedString(@"Space"),
                                 @(kKU_ANSI_Minus):                VMMLocalizedString(@"Minus"),
                                 @(kKU_ANSI_Equal):                VMMLocalizedString(@"Equal"),
                                 @(kKU_ANSI_LeftBracket):          VMMLocalizedString(@"Left Bracket"),
                                 @(kKU_ANSI_RightBracket):         VMMLocalizedString(@"Right Bracket"),
                                 @(kKU_ANSI_Backslash):            VMMLocalizedString(@"Backslash"),
                                 @(kKU_NonUSPound):                VMMLocalizedString(@"Pound"),
                                 @(kKU_ANSI_Semicolon):            VMMLocalizedString(@"Semicolon"),
                                 @(kKU_ANSI_Quote):                VMMLocalizedString(@"Quote"),
                                 @(kKU_ANSI_Grave):                VMMLocalizedString(@"Grave"),
                                 @(kKU_ANSI_Comma):                VMMLocalizedString(@"Comma"),
                                 @(kKU_ANSI_Period):               VMMLocalizedString(@"Period"),
                                 @(kKU_ANSI_Slash):                VMMLocalizedString(@"Slash"),
                                 @(kKU_CapsLock):                  VMMLocalizedString(@"Caps Lock"),
                                
                                 @(kKU_F1):                        @"F1",
                                 @(kKU_F2):                        @"F2",
                                 @(kKU_F3):                        @"F3",
                                 @(kKU_F4):                        @"F4",
                                 @(kKU_F5):                        @"F5",
                                 @(kKU_F6):                        @"F6",
                                 @(kKU_F7):                        @"F7",
                                 @(kKU_F8):                        @"F8",
                                 @(kKU_F9):                        @"F9",
                                 @(kKU_F10):                       @"F10",
                                 @(kKU_F11):                       @"F11",
                                 @(kKU_F12):                       @"F12",
                                
                                 @(kKU_PrintScreen):               VMMLocalizedString(@"Print Screen"),
                                 @(kKU_ScrollLock):                VMMLocalizedString(@"Scroll Lock"),
                                 @(kKU_Pause):                     VMMLocalizedString(@"Pause"),
                                 @(kKU_Insert):                    VMMLocalizedString(@"Insert"),
                                 @(kKU_Home):                      VMMLocalizedString(@"Home"),
                                 @(kKU_PageUp):                    VMMLocalizedString(@"Page Up"),
                                 @(kKU_ForwardDelete):             VMMLocalizedString(@"Forward Delete"),
                                 @(kKU_End):                       VMMLocalizedString(@"End"),
                                 @(kKU_PageDown):                  VMMLocalizedString(@"Page Down"),
                                 @(kKU_RightArrow):                VMMLocalizedString(@"Right Arrow"),
                                 @(kKU_LeftArrow):                 VMMLocalizedString(@"Left Arrow"),
                                 @(kKU_DownArrow):                 VMMLocalizedString(@"Down Arrow"),
                                 @(kKU_UpArrow):                   VMMLocalizedString(@"Up Arrow"),
                                
                                 @(kKU_ANSI_KeypadClear):          VMMLocalizedString(@"Keypad Clear"),
                                 @(kKU_ANSI_KeypadDivide):         VMMLocalizedString(@"Keypad Divide"),
                                 @(kKU_ANSI_KeypadMultiply):       VMMLocalizedString(@"Keypad Multiply"),
                                 @(kKU_ANSI_KeypadMinus):          VMMLocalizedString(@"Keypad Minus"),
                                 @(kKU_ANSI_KeypadPlus):           VMMLocalizedString(@"Keypad Plus"),
                                 @(kKU_ANSI_KeypadEnter):          VMMLocalizedString(@"Keypad Enter"),
                                 @(kKU_ANSI_Keypad1):              VMMLocalizedString(@"Keypad 1"),
                                 @(kKU_ANSI_Keypad2):              VMMLocalizedString(@"Keypad 2"),
                                 @(kKU_ANSI_Keypad3):              VMMLocalizedString(@"Keypad 3"),
                                 @(kKU_ANSI_Keypad4):              VMMLocalizedString(@"Keypad 4"),
                                 @(kKU_ANSI_Keypad5):              VMMLocalizedString(@"Keypad 5"),
                                 @(kKU_ANSI_Keypad6):              VMMLocalizedString(@"Keypad 6"),
                                 @(kKU_ANSI_Keypad7):              VMMLocalizedString(@"Keypad 7"),
                                 @(kKU_ANSI_Keypad8):              VMMLocalizedString(@"Keypad 8"),
                                 @(kKU_ANSI_Keypad9):              VMMLocalizedString(@"Keypad 9"),
                                 @(kKU_ANSI_Keypad0):              VMMLocalizedString(@"Keypad 0"),
                                 @(kKU_ANSI_KeypadDecimal):        VMMLocalizedString(@"Keypad Decimal"),
                                 @(kKU_NonUSBackslash):            VMMLocalizedString(@"Backslash"),
                                 @(kKU_Application):               VMMLocalizedString(@"Application"),
                                 @(kKU_Power):                     VMMLocalizedString(@"Power"),
                                 @(kKU_ANSI_KeypadEquals):         VMMLocalizedString(@"Keypad Equals"),
                                
                                 @(kKU_F13):                       @"F13",
                                 @(kKU_F14):                       @"F14",
                                 @(kKU_F15):                       @"F15",
                                 @(kKU_F16):                       @"F16",
                                 @(kKU_F17):                       @"F17",
                                 @(kKU_F18):                       @"F18",
                                 @(kKU_F19):                       @"F19",
                                 @(kKU_F20):                       @"F20",
                                 @(kKU_F21):                       @"F21",
                                 @(kKU_F22):                       @"F22",
                                 @(kKU_F23):                       @"F23",
                                 @(kKU_F24):                       @"F24",
                                
                                 @(kKU_Execute):                   VMMLocalizedString(@"Execute"),
                                 @(kKU_Help):                      VMMLocalizedString(@"Help"),
                                 @(kKU_ContextMenu ):              VMMLocalizedString(@"Context Menu"),
                                 @(kKU_Select):                    VMMLocalizedString(@"Select"),
                                 @(kKU_Stop):                      VMMLocalizedString(@"Stop"),
                                 @(kKU_Again):                     VMMLocalizedString(@"Again"),
                                 @(kKU_Undo):                      VMMLocalizedString(@"Undo"),
                                 @(kKU_Cut):                       VMMLocalizedString(@"Cut"),
                                 @(kKU_Copy):                      VMMLocalizedString(@"Copy"),
                                 @(kKU_Paste):                     VMMLocalizedString(@"Paste"),
                                 @(kKU_Find):                      VMMLocalizedString(@"Find"),
                                 @(kKU_Mute):                      VMMLocalizedString(@"Mute"),
                                 @(kKU_VolumeUp):                  VMMLocalizedString(@"Volume Up"),
                                 @(kKU_VolumeDown):                VMMLocalizedString(@"Volume Down"),
                                 @(kKU_Locking_CapsLock):          VMMLocalizedString(@"Locking Caps Lock"),
                                 @(kKU_Locking_NumLock):           VMMLocalizedString(@"Locking Num Lock"),
                                 @(kKU_Locking_ScrollLock):        VMMLocalizedString(@"Locking Scroll Lock"),
                                 @(kKU_JIS_KeypadComma):           VMMLocalizedString(@"Keypad Comma"),
                                 @(kKU_ANSI_KeypadEqual):          VMMLocalizedString(@"Keypad Equal"),
                                
                                 @(kKU_InternationalKey1):         @"",
                                 @(kKU_InternationalKey2):         @"",
                                 @(kKU_JIS_Yen):                   @"Yen",
                                 @(kKU_InternationalKey4):         @"",
                                 @(kKU_InternationalKey5):         @"",
                                 @(kKU_InternationalKey6):         @"",
                                 @(kKU_InternationalKey7):         @"",
                                 @(kKU_InternationalKey8):         @"",
                                 @(kKU_InternationalKey9):         @"",
                                
                                 @(kKU_Toggle_HangulEnglish):      VMMLocalizedString(@"Hangul/English"),
                                 @(kKU_Conversion_Hanja):          VMMLocalizedString(@"Conversion Hanja"),
                                 @(kKU_Katakana):                  @"Katakana",
                                 @(kKU_Hiragana):                  @"Hiragana",
                                 @(kKU_Zenkaku_Or_Hankaku):        VMMLocalizedString(@"Zankaku or Hankaku"),
                                 @(kKU_LanguageSpecific1):         @"",
                                 @(kKU_LanguageSpecific2):         @"",
                                 @(kKU_LanguageSpecific3):         @"",
                                 @(kKU_LanguageSpecific4):         @"",
                                
                                 @(kKU_AltenateErase):             VMMLocalizedString(@"Alternate Erase"),
                                 @(kKU_SysReq_Or_Attention):       VMMLocalizedString(@"SysReq or Attention"),
                                 @(kKU_Cancel):                    VMMLocalizedString(@"Cancel"),
                                 @(kKU_Clear):                     VMMLocalizedString(@"Clear"),
                                 @(kKU_Prior):                     VMMLocalizedString(@"Prior"),
                                 @(kKU_Return):                    VMMLocalizedString(@"Return"),
                                 @(kKU_Separator):                 VMMLocalizedString(@"Separator"),
                                 @(kKU_Out):                       VMMLocalizedString(@"Out"),
                                 @(kKU_Oper):                      VMMLocalizedString(@"Oper"),
                                 @(kKU_Clear_Or_Again):            VMMLocalizedString(@"Clear or Again"),
                                 @(kKU_CrSel_Or_Props):            VMMLocalizedString(@"CrSel or Props"),
                                 @(kKU_ExSel):                     VMMLocalizedString(@"ExSel"),
                                
                                 // A5 Reserved
                                 // A6 Reserved
                                 // A7 Reserved
                                 // A8 Reserved
                                 // A9 Reserved
                                 // AA Reserved
                                 // AB Reserved
                                 // AC Reserved
                                 // AD Reserved
                                 // AE Reserved
                                 // AF Reserved
                                
                                 @(kKU_Keypad_ZeroZero):           VMMLocalizedString(@"Keypad Zero Zero"),
                                 @(kKU_Keypad_ZeroZeroZero):       VMMLocalizedString(@"Keypad Zero Zero Zero"),
                                 @(kKU_Keypad_ThousandsSeparator): VMMLocalizedString(@"Keypad Thousands Separator"),
                                 @(kKU_Keypad_DecimalSeparator):   VMMLocalizedString(@"Keypad Decimal Separator"),
                                 @(kKU_Keypad_CurrencyUnit):       VMMLocalizedString(@"Keypad Currency Unit"),
                                 @(kKU_Keypad_CurrencySubunit):    VMMLocalizedString(@"Keypad Currency Subunit"),
                                 @(kKU_Keypad_LeftParentheses):    VMMLocalizedString(@"Keypad Left Parentheses"),
                                 @(kKU_Keypad_RightParentheses):   VMMLocalizedString(@"Keypad Right Parentheses"),
                                 @(kKU_Keypad_LeftBraces):         VMMLocalizedString(@"Keypad Left Braces"),
                                 @(kKU_Keypad_RightBraces):        VMMLocalizedString(@"Keypad Right Braces"),
                                 @(kKU_Keypad_Tab):                VMMLocalizedString(@"Keypad Tab"),
                                 @(kKU_Keypad_Backspace):          VMMLocalizedString(@"Keypad Backspace"),
                                 @(kKU_Keypad_A):                  VMMLocalizedString(@"Keypad A"),
                                 @(kKU_Keypad_B):                  VMMLocalizedString(@"Keypad B"),
                                 @(kKU_Keypad_C):                  VMMLocalizedString(@"Keypad C"),
                                 @(kKU_Keypad_D):                  VMMLocalizedString(@"Keypad D"),
                                 @(kKU_Keypad_E):                  VMMLocalizedString(@"Keypad E"),
                                 @(kKU_Keypad_F):                  VMMLocalizedString(@"Keypad F"),
                                 @(kKU_Keypad_XOR):                VMMLocalizedString(@"Keypad XOR"),
                                 @(kKU_Keypad_Circumflex):         VMMLocalizedString(@"Keypad Circumflex"),
                                 @(kKU_Keypad_Percent):            VMMLocalizedString(@"Keypad Percent"),
                                 @(kKU_Keypad_Less_Than):          VMMLocalizedString(@"Keypad Less Than"),
                                 @(kKU_Keypad_More_Than):          VMMLocalizedString(@"Keypad More Than"),
                                 @(kKU_Keypad_Ampersand):          VMMLocalizedString(@"Keypad Ampersand"),
                                 @(kKU_Keypad_AmpersandAmpersand): VMMLocalizedString(@"Keypad Ampersand Ampersand"),
                                 @(kKU_Keypad_VerticalLine):       VMMLocalizedString(@"Keypad Vertical Line"),
                                 @(kKU_Keypad_TwoVerticalLines):   VMMLocalizedString(@"Keypad Two Vertical Lines"),
                                 @(kKU_Keypad_Colon):              VMMLocalizedString(@"Keypad Colon"),
                                 @(kKU_Keypad_NumberSign):         VMMLocalizedString(@"Keypad Number Sign"),
                                 @(kKU_Keypad_Space):              VMMLocalizedString(@"Keypad Space"),
                                 @(kKU_Keypad_CommercialAt):       VMMLocalizedString(@"Keypad Commercial At"),
                                 @(kKU_Keypad_Exclamation):        VMMLocalizedString(@"Keypad Exclamation"),
                                
                                 @(kKU_Keypad_MemoryStore):        VMMLocalizedString(@"Keypad Memory Store"),
                                 @(kKU_Keypad_MemoryRecall):       VMMLocalizedString(@"Keypad Memory Recall"),
                                 @(kKU_Keypad_MemoryClear):        VMMLocalizedString(@"Keypad Memory Clear"),
                                 @(kKU_Keypad_MemoryAdd):          VMMLocalizedString(@"Keypad Memory Add"),
                                 @(kKU_Keypad_MemorySubstract):    VMMLocalizedString(@"Keypad Memory Substract"),
                                 @(kKU_Keypad_MemoryMultiply):     VMMLocalizedString(@"Keypad Memory Multiply"),
                                 @(kKU_Keypad_MemoryDivide):       VMMLocalizedString(@"Keypad Memory Divide"),
                                 @(kKU_Keypad_PlusMinus):          VMMLocalizedString(@"Keypad Plus Minus"),
                                 @(kKU_Keypad_Clear):              VMMLocalizedString(@"Keypad Clear"),
                                 @(kKU_Keypad_ClearEntry):         VMMLocalizedString(@"Keypad Clear Entry"),
                                 @(kKU_Keypad_Binary):             VMMLocalizedString(@"Keypad Binary"),
                                 @(kKU_Keypad_Octal):              VMMLocalizedString(@"Keypad Octal"),
                                 @(kKU_Keypad_Decimal):            VMMLocalizedString(@"Keypad Decimal"),
                                 @(kKU_Keypad_Hexadecimal):        VMMLocalizedString(@"Keypad Hexadecimal"),
                                 // DE ~ DF Reserved
                                
                                 @(kKU_LeftControl):               VMMLocalizedString(@"Left Control"),
                                 @(kKU_LeftShift):                 VMMLocalizedString(@"Left Shift"),
                                 @(kKU_LeftOption):                VMMLocalizedString(@"Left Option"),
                                 @(kKU_LeftCommand):               VMMLocalizedString(@"Left Command"),
                                 @(kKU_RightControl):              VMMLocalizedString(@"Right Control"),
                                 @(kKU_RightShift):                VMMLocalizedString(@"Right Shift"),
                                 @(kKU_RightOption):               VMMLocalizedString(@"Right Option"),
                                 @(kKU_RightCommand):              VMMLocalizedString(@"Right Command"),
                                
                                 // E8 ~ FFFF Reserved
                                };
    }
    
    return _usageNamesByKeycode;
}
+(nullable NSString*)nameOfUsageKeycode:(uint32_t)key
{
    NSString* name = self.usageNamesByKeycode[@(key)];
    return (name && name.length > 0) ? name : nil;
}

@end
