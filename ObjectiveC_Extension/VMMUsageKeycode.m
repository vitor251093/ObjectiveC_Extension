//
//  VMMUsageKeycode.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 09/08/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "VMMUsageKeycode.h"

@implementation VMMUsageKeycode

NSDictionary* _usageNamesByKeycode;

+(NSArray<NSString*>*)allUsageNames
{
    return self.usageNamesByKeycode.allValues;
}

+(NSDictionary*)usageNamesByKeycode
{
    if (!_usageNamesByKeycode)
    {
        _usageNamesByKeycode = @{
                                 // 00 Reserved
                                 @(kKU_ErrorRollOver):             @"Error Roll Over",
                                 @(kKU_PostFail):                  @"Post Fail",
                                 @(kKU_ErrorUndefined):            @"Error Undefined",
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
                                
                                 @(kKU_Enter):                     @"Return",
                                 @(kKU_Escape):                    @"Escape",
                                 @(kKU_Delete):                    @"Delete",
                                 @(kKU_Tab):                       @"Tab",
                                 @(kKU_Space):                     @"Space",
                                 @(kKU_ANSI_Minus):                @"Minus",
                                 @(kKU_ANSI_Equal):                @"Equal",
                                 @(kKU_ANSI_LeftBracket):          @"Left Bracket",
                                 @(kKU_ANSI_RightBracket):         @"Right Bracket",
                                 @(kKU_ANSI_Backslash):            @"Backslash",
                                 @(kKU_NonUSPound):                @"Pound",
                                 @(kKU_ANSI_Semicolon):            @"Semicolon",
                                 @(kKU_ANSI_Quote):                @"Quote",
                                 @(kKU_ANSI_Grave):                @"Grave",
                                 @(kKU_ANSI_Comma):                @"Comma",
                                 @(kKU_ANSI_Period):               @"Period",
                                 @(kKU_ANSI_Slash):                @"Slash",
                                 @(kKU_CapsLock):                  @"Caps Lock",
                                
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
                                
                                 @(kKU_PrintScreen):               @"Print Screen",
                                 @(kKU_ScrollLock):                @"Scroll Lock",
                                 @(kKU_Pause):                     @"Pause",
                                 @(kKU_Insert):                    @"Insert",
                                 @(kKU_Home):                      @"Home",
                                 @(kKU_PageUp):                    @"Page Up",
                                 @(kKU_ForwardDelete):             @"Forward Delete",
                                 @(kKU_End):                       @"End",
                                 @(kKU_PageDown):                  @"Page Down",
                                 @(kKU_RightArrow):                @"Right Arrow",
                                 @(kKU_LeftArrow):                 @"Left Arrow",
                                 @(kKU_DownArrow):                 @"Down Arrow",
                                 @(kKU_UpArrow):                   @"Up Arrow",
                                
                                 @(kKU_ANSI_KeypadClear):          @"Keypad Clear",
                                 @(kKU_ANSI_KeypadDivide):         @"Keypad Divide",
                                 @(kKU_ANSI_KeypadMultiply):       @"Keypad Multiply",
                                 @(kKU_ANSI_KeypadMinus):          @"Keypad Minus",
                                 @(kKU_ANSI_KeypadPlus):           @"Keypad Plus",
                                 @(kKU_ANSI_KeypadEnter):          @"Keypad Enter",
                                 @(kKU_ANSI_Keypad1):              @"Keypad 1",
                                 @(kKU_ANSI_Keypad2):              @"Keypad 2",
                                 @(kKU_ANSI_Keypad3):              @"Keypad 3",
                                 @(kKU_ANSI_Keypad4):              @"Keypad 4",
                                 @(kKU_ANSI_Keypad5):              @"Keypad 5",
                                 @(kKU_ANSI_Keypad6):              @"Keypad 6",
                                 @(kKU_ANSI_Keypad7):              @"Keypad 7",
                                 @(kKU_ANSI_Keypad8):              @"Keypad 8",
                                 @(kKU_ANSI_Keypad9):              @"Keypad 9",
                                 @(kKU_ANSI_Keypad0):              @"Keypad 0",
                                 @(kKU_ANSI_KeypadDecimal):        @"Keypad Decimal",
                                 @(kKU_NonUSBackslash):            @"Backslash",
                                 @(kKU_Application):               @"Application",
                                 @(kKU_Power):                     @"Power",
                                 @(kKU_ANSI_KeypadEquals):         @"Keypad Equals",
                                
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
                                
                                 @(kKU_Execute):                   @"Execute",
                                 @(kKU_Help):                      @"Help",
                                 @(kKU_ContextMenu ):              @"Context Menu",
                                 @(kKU_Select):                    @"Select",
                                 @(kKU_Stop):                      @"Stop",
                                 @(kKU_Again):                     @"Again",
                                 @(kKU_Undo):                      @"Undo",
                                 @(kKU_Cut):                       @"Cut",
                                 @(kKU_Copy):                      @"Copy",
                                 @(kKU_Paste):                     @"Paste",
                                 @(kKU_Find):                      @"Find",
                                 @(kKU_Mute):                      @"Mute",
                                 @(kKU_VolumeUp):                  @"Volume Up",
                                 @(kKU_VolumeDown):                @"Volume Down",
                                 @(kKU_Locking_CapsLock):          @"Locking Caps Lock",
                                 @(kKU_Locking_NumLock):           @"Locking Num Lock",
                                 @(kKU_Locking_ScrollLock):        @"Locking Scroll Lock",
                                 @(kKU_JIS_KeypadComma):           @"Keypad Comma",
                                 @(kKU_ANSI_KeypadEqual):          @"Keypad Equal",
                                
                                 @(kKU_InternationalKey1):         @"",
                                 @(kKU_InternationalKey2):         @"",
                                 @(kKU_JIS_Yen):                   @"Yen",
                                 @(kKU_InternationalKey4):         @"",
                                 @(kKU_InternationalKey5):         @"",
                                 @(kKU_InternationalKey6):         @"",
                                 @(kKU_InternationalKey7):         @"",
                                 @(kKU_InternationalKey8):         @"",
                                 @(kKU_InternationalKey9):         @"",
                                
                                 @(kKU_Toggle_HangulEnglish):      @"Hangul/English",
                                 @(kKU_Conversion_Hanja):          @"Conversion Hanja",
                                 @(kKU_Katakana):                  @"Katakana",
                                 @(kKU_Hiragana):                  @"Hiragana",
                                 @(kKU_Zenkaku_Or_Hankaku):        @"Zankaku or Hankaku",
                                 @(kKU_LanguageSpecific1):         @"",
                                 @(kKU_LanguageSpecific2):         @"",
                                 @(kKU_LanguageSpecific3):         @"",
                                 @(kKU_LanguageSpecific4):         @"",
                                
                                 @(kKU_AltenateErase):             @"Alternate Erase",
                                 @(kKU_SysReq_Or_Attention):       @"SysReq or Attention",
                                 @(kKU_Cancel):                    @"Cancel",
                                 @(kKU_Clear):                     @"Clear",
                                 @(kKU_Prior):                     @"Prior",
                                 @(kKU_Return):                    @"Return",
                                 @(kKU_Separator):                 @"Separator",
                                 @(kKU_Out):                       @"Out",
                                 @(kKU_Oper):                      @"Oper",
                                 @(kKU_Clear_Or_Again):            @"Clear or Again",
                                 @(kKU_CrSel_Or_Props):            @"CrSel or Props",
                                 @(kKU_ExSel):                     @"ExSel",
                                
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
                                
                                 @(kKU_Keypad_ZeroZero):           @"Keypad Zero Zero",
                                 @(kKU_Keypad_ZeroZeroZero):       @"Keypad Zero Zero Zero",
                                 @(kKU_Keypad_ThousandsSeparator): @"Keypad Thousands Separator",
                                 @(kKU_Keypad_DecimalSeparator):   @"Keypad Decimal Separator",
                                 @(kKU_Keypad_CurrencyUnit):       @"Keypad Currency Unit",
                                 @(kKU_Keypad_CurrencySubunit):    @"Keypad Currency Subunit",
                                 @(kKU_Keypad_LeftParentheses):    @"Keypad Left Parentheses",
                                 @(kKU_Keypad_RightParentheses):   @"Keypad Right Parentheses",
                                 @(kKU_Keypad_LeftBraces):         @"Keypad Left Braces",
                                 @(kKU_Keypad_RightBraces):        @"Keypad Right Braces",
                                 @(kKU_Keypad_Tab):                @"Keypad Tab",
                                 @(kKU_Keypad_Backspace):          @"Keypad Backspace",
                                 @(kKU_Keypad_A):                  @"Keypad A",
                                 @(kKU_Keypad_B):                  @"Keypad B",
                                 @(kKU_Keypad_C):                  @"Keypad C",
                                 @(kKU_Keypad_D):                  @"Keypad D",
                                 @(kKU_Keypad_E):                  @"Keypad E",
                                 @(kKU_Keypad_F):                  @"Keypad F",
                                 @(kKU_Keypad_XOR):                @"Keypad XOR",
                                 @(kKU_Keypad_Circumflex):         @"Keypad Circumflex",
                                 @(kKU_Keypad_Percent):            @"Keypad Percent",
                                 @(kKU_Keypad_Less_Than):          @"Keypad Less Than",
                                 @(kKU_Keypad_More_Than):          @"Keypad More Than",
                                 @(kKU_Keypad_Ampersand):          @"Keypad Ampersand",
                                 @(kKU_Keypad_AmpersandAmpersand): @"Keypad Ampersand Ampersand",
                                 @(kKU_Keypad_VerticalLine):       @"Keypad Vertical Line",
                                 @(kKU_Keypad_TwoVerticalLines):   @"Keypad Two Vertical Lines",
                                 @(kKU_Keypad_Colon):              @"Keypad Colon",
                                 @(kKU_Keypad_NumberSign):         @"Keypad Number Sign",
                                 @(kKU_Keypad_Space):              @"Keypad Space",
                                 @(kKU_Keypad_CommercialAt):       @"Keypad Commercial At",
                                 @(kKU_Keypad_Exclamation):        @"Keypad Exclamation",
                                
                                 @(kKU_Keypad_MemoryStore):        @"Keypad Memory Store",
                                 @(kKU_Keypad_MemoryRecall):       @"Keypad Memory Recall",
                                 @(kKU_Keypad_MemoryClear):        @"Keypad Memory Clear",
                                 @(kKU_Keypad_MemoryAdd):          @"Keypad Memory Add",
                                 @(kKU_Keypad_MemorySubstract):    @"Keypad Memory Substract",
                                 @(kKU_Keypad_MemoryMultiply):     @"Keypad Memory Multiply",
                                 @(kKU_Keypad_MemoryDivide):       @"Keypad Memory Divide",
                                 @(kKU_Keypad_PlusMinus):          @"Keypad Plus Minus",
                                 @(kKU_Keypad_Clear):              @"Keypad Clear",
                                 @(kKU_Keypad_ClearEntry):         @"Keypad Clear Entry",
                                 @(kKU_Keypad_Binary):             @"Keypad Binary",
                                 @(kKU_Keypad_Octal):              @"Keypad Octal",
                                 @(kKU_Keypad_Decimal):            @"Keypad Decimal",
                                 @(kKU_Keypad_Hexadecimal):        @"Keypad Hexadecimal",
                                 // DE ~ DF Reserved
                                
                                 @(kKU_LeftControl):               @"Left Control",
                                 @(kKU_LeftShift):                 @"Left Shift",
                                 @(kKU_LeftOption):                @"Left Option",
                                 @(kKU_LeftCommand):               @"Left Command",
                                 @(kKU_RightControl):              @"Right Control",
                                 @(kKU_RightShift):                @"Right Shift",
                                 @(kKU_RightOption):               @"Right Option",
                                 @(kKU_RightCommand):              @"Right Command",
                                
                                 // E8 ~ FFFF Reserved
                                };
    }
    
    return _usageNamesByKeycode;
}
+(NSString*)nameOfUsageKeycode:(uint32_t)key
{
    NSString* name = self.usageNamesByKeycode[@(key)];
    return (name && name.length > 0) ? name : nil;
}

@end
