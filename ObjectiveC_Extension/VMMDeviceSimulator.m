//
//  VMMDeviceSimulator.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 01/10/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//
//  Reference:
//  https://stackoverflow.com/questions/28485257/objective-c-mac-os-x-simulate-a-mouse-click-event-onto-a-specific-applicatio
//

#import "VMMDeviceSimulator.h"

@implementation VMMDeviceSimulator

+(void)simulateCursorClickAtScreenPoint:(CGPoint)clickPoint
{
    // TODO: In macOS Mojave, the method below requires accessibility permissions.
    // https://objective-see.com/blog/blog_0x36.html
    // https://forums.developer.apple.com/thread/105667
    //
    // Still couldn't find a suitable workaround for requiring the permission
    // a second time in case the user denied by mistake.

    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, clickPoint, kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, theEvent);
    CGEventSetType(theEvent, kCGEventLeftMouseUp);
    CGEventPost(kCGHIDEventTap, theEvent);
    
    CGEventSetIntegerValueField(theEvent, kCGMouseEventClickState, 2);
    
    CGEventSetType(theEvent, kCGEventLeftMouseDown);
    CGEventPost(kCGHIDEventTap, theEvent);
    
    CGEventSetType(theEvent, kCGEventLeftMouseUp);
    CGEventPost(kCGHIDEventTap, theEvent);
    
    CFRelease(theEvent);
}

+(void)simulateVirtualKeycode:(CGKeyCode)keyCode withKeyDown:(BOOL)keyPressed
{
    CGEventRef cmdd = CGEventCreateKeyboardEvent(NULL, keyCode, keyPressed);
    CGEventPost(kCGHIDEventTap, cmdd);
    CFRelease(cmdd);
}

@end
