//
//  VMMVirtualKeycode.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 09/08/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "VMMVirtualKeycode.h"

@implementation VMMVirtualKeycode

NSDictionary* _virtualKeycodeNames;

+(NSArray*)allKeyNames
{
    return self.virtualKeycodeNames.allValues;
}

+(NSDictionary*)virtualKeycodeNames
{
    if (!_virtualKeycodeNames)
    {
        _virtualKeycodeNames = @{
                                @(kVK_ANSI_A)             : @"A",
                                @(kVK_ANSI_S)             : @"S",
                                @(kVK_ANSI_D)             : @"D",
                                @(kVK_ANSI_F)             : @"F",
                                @(kVK_ANSI_H)             : @"H",
                                @(kVK_ANSI_G)             : @"G",
                                @(kVK_ANSI_Z)             : @"Z",
                                @(kVK_ANSI_X)             : @"X",
                                @(kVK_ANSI_C)             : @"C",
                                @(kVK_ANSI_V)             : @"V",
                                @(kVK_ISO_Section)        : @"ISO Section",
                                @(kVK_ANSI_B)             : @"B",
                                @(kVK_ANSI_Q)             : @"Q",
                                @(kVK_ANSI_W)             : @"W",
                                @(kVK_ANSI_E)             : @"E",
                                @(kVK_ANSI_R)             : @"R",
                                @(kVK_ANSI_Y)             : @"Y",
                                @(kVK_ANSI_T)             : @"T",
                                @(kVK_ANSI_1)             : @"1",
                                @(kVK_ANSI_2)             : @"2",
                                @(kVK_ANSI_3)             : @"3",
                                @(kVK_ANSI_4)             : @"4",
                                @(kVK_ANSI_6)             : @"6",
                                @(kVK_ANSI_5)             : @"5",
                                @(kVK_ANSI_Equal)         : @"Equal",
                                @(kVK_ANSI_9)             : @"9",
                                @(kVK_ANSI_7)             : @"7",
                                @(kVK_ANSI_Minus)         : @"Minus",
                                @(kVK_ANSI_8)             : @"8",
                                @(kVK_ANSI_0)             : @"0",
                                @(kVK_ANSI_RightBracket)  : @"Right Bracket",
                                @(kVK_ANSI_O)             : @"O",
                                @(kVK_ANSI_U)             : @"U",
                                @(kVK_ANSI_LeftBracket)   : @"Left Bracket",
                                @(kVK_ANSI_I)             : @"I",
                                @(kVK_ANSI_P)             : @"P",
                                @(kVK_Enter)              : @"Return",
                                @(kVK_ANSI_L)             : @"L",
                                @(kVK_ANSI_J)             : @"J",
                                @(kVK_ANSI_Quote)         : @"Quote",
                                @(kVK_ANSI_K)             : @"K",
                                @(kVK_ANSI_Semicolon)     : @"Semicolon",
                                @(kVK_ANSI_Backslash)     : @"Backslash",
                                @(kVK_ANSI_Comma)         : @"Comma",
                                @(kVK_ANSI_Slash)         : @"Slash",
                                @(kVK_ANSI_N)             : @"N",
                                @(kVK_ANSI_M)             : @"M",
                                @(kVK_ANSI_Period)        : @"Period",
                                @(kVK_Tab)                : @"Tab",
                                @(kVK_Space)              : @"Space",
                                @(kVK_ANSI_Grave)         : @"Grave",
                                @(kVK_Delete)             : @"Delete",
                                @(kVK_Play)               : @"Play",
                                @(kVK_Escape)             : @"Escape",
                                @(kVK_RightCommand)       : @"Right Command",
                                @(kVK_LeftCommand)        : @"Left Command",
                                @(kVK_LeftShift)          : @"Left Shift",
                                @(kVK_CapsLock)           : @"Caps Lock",
                                @(kVK_LeftOption)         : @"Left Option",
                                @(kVK_LeftControl)        : @"Left Control",
                                @(kVK_RightShift)         : @"Right Shift",
                                @(kVK_RightOption)        : @"Right Option",
                                @(kVK_RightControl)       : @"Right Control",
                                @(kVK_Function)           : @"Function",
                                @(kVK_F17)                : @"F17",
                                @(kVK_ANSI_KeypadDecimal) : @"Keypad Decimal",
                                @(kVK_Next)               : @"Next",
                                @(kVK_ANSI_KeypadMultiply): @"Keypad Multiply",
                                // @(0x44)                   : @"",
                                @(kVK_ANSI_KeypadPlus)    : @"Keypad Plus",
                                // @(0x46)                   : @"",
                                @(kVK_ANSI_KeypadClear)   : @"Keypad Clear",
                                @(kVK_VolumeUp)           : @"Volume Up",
                                @(kVK_VolumeDown)         : @"Volume Down",
                                @(kVK_Mute)               : @"Mute",
                                @(kVK_ANSI_KeypadDivide)  : @"Keypad Divide",
                                @(kVK_ANSI_KeypadEnter)   : @"Keypad Enter",
                                @(kVK_Previous)           : @"Previous",
                                @(kVK_ANSI_KeypadMinus)   : @"Keypad Minus",
                                @(kVK_F18)                : @"F18",
                                @(kVK_F19)                : @"F19",
                                @(kVK_ANSI_KeypadEquals)  : @"Keypad Equals",
                                @(kVK_ANSI_Keypad0)       : @"Keypad 0",
                                @(kVK_ANSI_Keypad1)       : @"Keypad 1",
                                @(kVK_ANSI_Keypad2)       : @"Keypad 2",
                                @(kVK_ANSI_Keypad3)       : @"Keypad 3",
                                @(kVK_ANSI_Keypad4)       : @"Keypad 4",
                                @(kVK_ANSI_Keypad5)       : @"Keypad 5",
                                @(kVK_ANSI_Keypad6)       : @"Keypad 6",
                                @(kVK_ANSI_Keypad7)       : @"Keypad 7",
                                @(kVK_F20)                : @"F20",
                                @(kVK_ANSI_Keypad8)       : @"Keypad 8",
                                @(kVK_ANSI_Keypad9)       : @"Keypad 9",
                                @(kVK_JIS_Yen)            : @"Yen",
                                @(kVK_JIS_Underscore)     : @"Underscore",
                                @(kVK_JIS_KeypadComma)    : @"Keypad Comma",
                                @(kVK_F5)                 : @"F5",
                                @(kVK_F6)                 : @"F6",
                                @(kVK_F7)                 : @"F7",
                                @(kVK_F3)                 : @"F3",
                                @(kVK_F8)                 : @"F8",
                                @(kVK_F9)                 : @"F9",
                                @(kVK_JIS_Eisu)           : @"Eisu",
                                @(kVK_F11)                : @"F11",
                                @(kVK_JIS_Kana)           : @"Kana",
                                @(kVK_F13)                : @"F13",
                                @(kVK_F16)                : @"F16",
                                @(kVK_F14)                : @"F14",
                                // @(0x6C)                   : @"",
                                @(kVK_F10)                : @"F10",
                                @(kVK_ContextMenu)        : @"Context Menu",
                                @(kVK_F12)                : @"F12",
                                @(kVK_VidMirror)          : @"Video Mirror",
                                @(kVK_F15)                : @"F15",
                                @(kVK_Help)               : @"Help",
                                @(kVK_Home)               : @"Home",
                                @(kVK_PageUp)             : @"Page Up",
                                @(kVK_ForwardDelete)      : @"Forward Delete",
                                @(kVK_F4)                 : @"F4",
                                @(kVK_End)                : @"End",
                                @(kVK_F2)                 : @"F2",
                                @(kVK_PageDown)           : @"Page Down",
                                @(kVK_F1)                 : @"F1",
                                @(kVK_LeftArrow)          : @"Left Arrow",
                                @(kVK_RightArrow)         : @"Right Arrow",
                                @(kVK_DownArrow)          : @"Down Arrow",
                                @(kVK_UpArrow)            : @"Up Arrow",
                                @(kVK_Power)              : @"Power",
                                // @(0x80)                   : @"",
                                @(kVK_Spotlight)          : @"Spotlight",
                                @(kVK_Dashboard)          : @"Dashboard",
                                @(kVK_Launchpad)          : @"Launchpad",
                                // @(0x84 ~ 0x8F)            : @"",
                                @(kVK_BrightnessUp)       : @"Brightness Up",
                                @(kVK_BrightnessDown)     : @"Brightness Down",
                                @(kVK_Eject)              : @"Eject",
                                // @(0x93 ~ 0x9F)            : @"",
                                @(kVK_ExposesAll)         : @"Exposes All",
                                @(kVK_ExposesDesktop)     : @"Exposes Desktop",
                                // @(0xA2 ~ 0xFF)            : @"",
                                };
    }
    
    return _virtualKeycodeNames;
}
+(NSString*)nameOfVirtualKeycode:(CGKeyCode)key
{
    return self.virtualKeycodeNames[@(key)];
}

@end
