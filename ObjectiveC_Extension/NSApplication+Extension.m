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

@end
