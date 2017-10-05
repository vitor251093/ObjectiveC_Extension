//
//  IODeviceSimulator.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 01/10/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//
//  Reference:
//  https://stackoverflow.com/questions/28485257/objective-c-mac-os-x-simulate-a-mouse-click-event-onto-a-specific-applicatio
//

#import "IODeviceSimulator.h"

@implementation IODeviceSimulator

+(void)simulateCursorClickAtScreenPoint:(CGPoint)clickPoint
{
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
