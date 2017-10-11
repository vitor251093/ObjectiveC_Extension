//
//  NSModals.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 11/10/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import "NSModals.h"

@implementation NSModals

static NSWindow* _alertsWindow;

+(NSWindow*)modalsWindow
{
    return _alertsWindow;
}

+(void)alertsShouldRunOnWindow:(NSWindow*)window whenCalledDuringBlock:(void (^) (void))block
{
    _alertsWindow = window;
    block();
    _alertsWindow = nil;
}

@end
