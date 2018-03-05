//
//  VMMVirtualKeycode.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 09/08/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "VMMVirtualKeycode.h"
#import "VMMLocalizationUtility.h"

@implementation VMMVirtualKeycode

NSDictionary* _virtualKeycodeNames;

+(nonnull NSArray<NSString*>*)allKeyNames
{
    return self.virtualKeycodeNames.allValues;
}

+(nonnull NSDictionary*)virtualKeycodeNames
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
                                @(kVK_ANSI_Equal)         : VMMLocalizedString(@"Equal"),
                                @(kVK_ANSI_9)             : @"9",
                                @(kVK_ANSI_7)             : @"7",
                                @(kVK_ANSI_Minus)         : VMMLocalizedString(@"Minus"),
                                @(kVK_ANSI_8)             : @"8",
                                @(kVK_ANSI_0)             : @"0",
                                @(kVK_ANSI_RightBracket)  : VMMLocalizedString(@"Right Bracket"),
                                @(kVK_ANSI_O)             : @"O",
                                @(kVK_ANSI_U)             : @"U",
                                @(kVK_ANSI_LeftBracket)   : VMMLocalizedString(@"Left Bracket"),
                                @(kVK_ANSI_I)             : @"I",
                                @(kVK_ANSI_P)             : @"P",
                                @(kVK_Enter)              : VMMLocalizedString(@"Return"),
                                @(kVK_ANSI_L)             : @"L",
                                @(kVK_ANSI_J)             : @"J",
                                @(kVK_ANSI_Quote)         : VMMLocalizedString(@"Quote"),
                                @(kVK_ANSI_K)             : @"K",
                                @(kVK_ANSI_Semicolon)     : VMMLocalizedString(@"Semicolon"),
                                @(kVK_ANSI_Backslash)     : VMMLocalizedString(@"Backslash"),
                                @(kVK_ANSI_Comma)         : VMMLocalizedString(@"Comma"),
                                @(kVK_ANSI_Slash)         : VMMLocalizedString(@"Slash"),
                                @(kVK_ANSI_N)             : @"N",
                                @(kVK_ANSI_M)             : @"M",
                                @(kVK_ANSI_Period)        : VMMLocalizedString(@"Period"),
                                @(kVK_Tab)                : VMMLocalizedString(@"Tab"),
                                @(kVK_Space)              : VMMLocalizedString(@"Space"),
                                @(kVK_ANSI_Grave)         : VMMLocalizedString(@"Grave"),
                                @(kVK_Delete)             : VMMLocalizedString(@"Delete"),
                                @(kVK_Play)               : VMMLocalizedString(@"Play"),
                                @(kVK_Escape)             : VMMLocalizedString(@"Escape"),
                                @(kVK_RightCommand)       : VMMLocalizedString(@"Right Command"),
                                @(kVK_LeftCommand)        : VMMLocalizedString(@"Left Command"),
                                @(kVK_LeftShift)          : VMMLocalizedString(@"Left Shift"),
                                @(kVK_CapsLock)           : VMMLocalizedString(@"Caps Lock"),
                                @(kVK_LeftOption)         : VMMLocalizedString(@"Left Option"),
                                @(kVK_LeftControl)        : VMMLocalizedString(@"Left Control"),
                                @(kVK_RightShift)         : VMMLocalizedString(@"Right Shift"),
                                @(kVK_RightOption)        : VMMLocalizedString(@"Right Option"),
                                @(kVK_RightControl)       : VMMLocalizedString(@"Right Control"),
                                @(kVK_Function)           : VMMLocalizedString(@"Function"),
                                @(kVK_F17)                : @"F17",
                                @(kVK_ANSI_KeypadDecimal) : VMMLocalizedString(@"Keypad Decimal"),
                                @(kVK_Next)               : VMMLocalizedString(@"Next"),
                                @(kVK_ANSI_KeypadMultiply): VMMLocalizedString(@"Keypad Multiply"),
                                // @(0x44)                   : @"",
                                @(kVK_ANSI_KeypadPlus)    : VMMLocalizedString(@"Keypad Plus"),
                                // @(0x46)                   : @"",
                                @(kVK_ANSI_KeypadClear)   : VMMLocalizedString(@"Keypad Clear"),
                                @(kVK_VolumeUp)           : VMMLocalizedString(@"Volume Up"),
                                @(kVK_VolumeDown)         : VMMLocalizedString(@"Volume Down"),
                                @(kVK_Mute)               : VMMLocalizedString(@"Mute"),
                                @(kVK_ANSI_KeypadDivide)  : VMMLocalizedString(@"Keypad Divide"),
                                @(kVK_ANSI_KeypadEnter)   : VMMLocalizedString(@"Keypad Enter"),
                                @(kVK_Previous)           : VMMLocalizedString(@"Previous"),
                                @(kVK_ANSI_KeypadMinus)   : VMMLocalizedString(@"Keypad Minus"),
                                @(kVK_F18)                : @"F18",
                                @(kVK_F19)                : @"F19",
                                @(kVK_ANSI_KeypadEquals)  : VMMLocalizedString(@"Keypad Equals"),
                                @(kVK_ANSI_Keypad0)       : VMMLocalizedString(@"Keypad 0"),
                                @(kVK_ANSI_Keypad1)       : VMMLocalizedString(@"Keypad 1"),
                                @(kVK_ANSI_Keypad2)       : VMMLocalizedString(@"Keypad 2"),
                                @(kVK_ANSI_Keypad3)       : VMMLocalizedString(@"Keypad 3"),
                                @(kVK_ANSI_Keypad4)       : VMMLocalizedString(@"Keypad 4"),
                                @(kVK_ANSI_Keypad5)       : VMMLocalizedString(@"Keypad 5"),
                                @(kVK_ANSI_Keypad6)       : VMMLocalizedString(@"Keypad 6"),
                                @(kVK_ANSI_Keypad7)       : VMMLocalizedString(@"Keypad 7"),
                                @(kVK_F20)                : @"F20",
                                @(kVK_ANSI_Keypad8)       : VMMLocalizedString(@"Keypad 8"),
                                @(kVK_ANSI_Keypad9)       : VMMLocalizedString(@"Keypad 9"),
                                @(kVK_JIS_Yen)            : @"Yen",
                                @(kVK_JIS_Underscore)     : VMMLocalizedString(@"Underscore"),
                                @(kVK_JIS_KeypadComma)    : VMMLocalizedString(@"Keypad Comma"),
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
                                @(kVK_ContextMenu)        : VMMLocalizedString(@"Context Menu"),
                                @(kVK_F12)                : @"F12",
                                @(kVK_VidMirror)          : VMMLocalizedString(@"Video Mirror"),
                                @(kVK_F15)                : @"F15",
                                @(kVK_Help)               : VMMLocalizedString(@"Help"),
                                @(kVK_Home)               : VMMLocalizedString(@"Home"),
                                @(kVK_PageUp)             : VMMLocalizedString(@"Page Up"),
                                @(kVK_ForwardDelete)      : VMMLocalizedString(@"Forward Delete"),
                                @(kVK_F4)                 : @"F4",
                                @(kVK_End)                : VMMLocalizedString(@"End"),
                                @(kVK_F2)                 : @"F2",
                                @(kVK_PageDown)           : VMMLocalizedString(@"Page Down"),
                                @(kVK_F1)                 : @"F1",
                                @(kVK_LeftArrow)          : VMMLocalizedString(@"Left Arrow"),
                                @(kVK_RightArrow)         : VMMLocalizedString(@"Right Arrow"),
                                @(kVK_DownArrow)          : VMMLocalizedString(@"Down Arrow"),
                                @(kVK_UpArrow)            : VMMLocalizedString(@"Up Arrow"),
                                @(kVK_Power)              : VMMLocalizedString(@"Power"),
                                // @(0x80)                   : @"",
                                @(kVK_Spotlight)          : VMMLocalizedString(@"Spotlight"),
                                @(kVK_Dashboard)          : VMMLocalizedString(@"Dashboard"),
                                @(kVK_Launchpad)          : VMMLocalizedString(@"Launchpad"),
                                // @(0x84 ~ 0x8F)            : @"",
                                @(kVK_BrightnessUp)       : VMMLocalizedString(@"Brightness Up"),
                                @(kVK_BrightnessDown)     : VMMLocalizedString(@"Brightness Down"),
                                @(kVK_Eject)              : VMMLocalizedString(@"Eject"),
                                // @(0x93 ~ 0x9F)            : @"",
                                @(kVK_ExposesAll)         : VMMLocalizedString(@"Exposes All"),
                                @(kVK_ExposesDesktop)     : VMMLocalizedString(@"Exposes Desktop"),
                                // @(0xA2 ~ 0xFF)            : @"",
                                };
    }
    
    return _virtualKeycodeNames;
}
+(nullable NSString*)nameOfVirtualKeycode:(CGKeyCode)key
{
    return self.virtualKeycodeNames[@(key)];
}

@end
