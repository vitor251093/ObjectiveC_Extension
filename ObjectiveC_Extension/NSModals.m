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

static NSWindow* _temporaryAlertsWindow;
static int _temporaryCounter;

+(NSWindow*)modalsWindow
{
    if (_temporaryCounter > 0)
    {
        _temporaryCounter--;
        return _temporaryAlertsWindow;
    }
    
    return _alertsWindow;
}

+(void)nextModalShouldRunOnWindow:(NSWindow*)window
{
    _temporaryCounter = 1;
    _temporaryAlertsWindow = window;
}
+(void)modalsShouldRunOnWindow:(NSWindow*)window whenCalledDuringBlock:(void (^) (void))block
{
    _alertsWindow = window;
    block();
    _alertsWindow = nil;
}

@end
