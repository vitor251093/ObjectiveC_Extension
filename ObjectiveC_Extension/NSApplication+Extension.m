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
#import "NSException+Extension.h"
#import "VMMLogUtility.h"
#import "VMMComputerInformation.h"

@implementation NSApplication (VMMApplication)

+(void)restart
{
    [NSTask runProgram:@"open" withFlags:@[@"-n", [[NSBundle originalMainBundle] bundlePath]]];
    exit(0);
}

+(void)restartInLanguage:(nonnull NSString*)language
{
    if ([VMMComputerInformation isSystemMacOsEqualOrSuperiorTo:@"10.6.2"] == false) {
        // The '--args' parameter in 'open' was only introduced in macOS 10.6.2
        // Reference: https://superuser.com/a/116237
        
        @throw exception(NSIllegalSelectorException, @"NSApplication does not implement restartInLanguage:");
    }
    
    if ([[NSLocale availableLocaleIdentifiers] containsObject:language] == false) {
        NSDebugLog(@"'%@' is not a valid locale identifier", language);
        return;
    }
    
    if ([[[NSBundle originalMainBundle] localizations] containsObject:language] == false) {
        NSDebugLog(@"That application does not support '%@'", language);
        return;
    }
    
    if ([[[NSBundle originalMainBundle] preferredLocalizations] containsObject:language]) {
        return;
    }
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    NSString *cmd = [NSString stringWithFormat:@"/usr/bin/open %@ %@ %@ %@ %@",
                     @"-n", @"-a", [[[NSBundle originalMainBundle] bundlePath] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "],
                     @"--args", [NSString stringWithFormat:@"-AppleLanguages '(%@)'",language]];
    [task setArguments:[NSArray arrayWithObjects:@"-c", cmd, nil]];
    [task launch];
    
    exit(0);
}

+(nullable VMMAppearanceName)appearance
{
    if (VMMAppearanceDarkPreMojaveCompatible == false) {
        return nil;
    }
    
    NSAppearance* nsappearance = [NSApp appearance];
    if (nsappearance == nil) {
        return nil;
    }
    
    return nsappearance.name;
}
+(BOOL)setAppearance:(nullable VMMAppearanceName)appearance
{
    if (VMMAppearanceDarkPreMojaveCompatible == false) {
        return false;
    }
    
    @try {
        NSAppearance* nsappearance = appearance != nil ? [NSAppearance appearanceNamed:appearance] : nil;
        [NSApp setAppearance:nsappearance];
        return true;
    } @catch (NSException *exception) {
        return false;
    }
}

@end
