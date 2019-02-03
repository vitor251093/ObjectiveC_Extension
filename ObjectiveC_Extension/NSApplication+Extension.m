//
//  NSApplication+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 23/12/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import "NSApplication+Extension.h"

#import "NSBundle+Extension.h"
#import "NSTask+Extension.h"

@implementation NSApplication (VMMApplication)

+(void)restart
{
    [NSTask runProgram:@"open" withFlags:@[@"-n", [[NSBundle originalMainBundle] bundlePath]]];
    exit(0);
}

+(VMMAppearanceName)appearance
{
    if (VMMAppearanceDarkPreMojaveCompatible == false) {
        return nil;
    }
    
    NSAppearance* nsappearance = [[NSApp mainWindow] appearance];
    if (nsappearance == nil) {
        return nil;
    }
    
    return nsappearance.name;
}
+(BOOL)setAppearance:(VMMAppearanceName)appearance
{
    if (VMMAppearanceDarkPreMojaveCompatible == false) {
        return false;
    }
    
    NSAppearance* nsappearance = appearance != nil ? [NSAppearance appearanceNamed:appearance] : nil;
    
    for (NSWindow* window in [NSApp windows]) {
        [window setAppearance:nsappearance];
    }
    
    return true;
}

@end
