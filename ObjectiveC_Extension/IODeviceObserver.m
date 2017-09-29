//
//  IODeviceObserver.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 09/08/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "IODeviceObserver.h"

#import "NSMutableArray+Extension.h"

#import "NSLogUtility.h"

@implementation IODeviceObserver

static IODeviceObserver *_sharedObserver;

+(instancetype)sharedObserver
{
    @synchronized([self class])
    {
        if (!_sharedObserver)
        {
            _sharedObserver = [[IODeviceObserver alloc] init];
        }
        return _sharedObserver;
    }
    return nil;
}

-(void)observeDevicesOfTypes:(NSArray*)types forDelegate:(id<IODeviceObserverManagementDelegate>)actionDelegate
{
    if (!actionDelegate) return;
    
    actionDelegate.hidManager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
    
    NSMutableArray* deviceTypes = [types mutableCopy];
    [deviceTypes replaceObjectsWithVariation:^id(id object, NSUInteger index)
    {
        return @{@(kIOHIDDeviceUsagePageKey): @(kHIDPage_GenericDesktop), @(kIOHIDDeviceUsageKey): object};
    }];
    
    IOHIDManagerSetDeviceMatchingMultiple(actionDelegate.hidManager, (__bridge CFArrayRef)deviceTypes);
    
    IOHIDManagerRegisterDeviceMatchingCallback(actionDelegate.hidManager, &Handle_DeviceMatchingCallback, (__bridge void*)actionDelegate);
    IOHIDManagerRegisterDeviceRemovalCallback (actionDelegate.hidManager, &Handle_DeviceRemovalCallback,  (__bridge void*)actionDelegate);
    
    IOHIDManagerScheduleWithRunLoop(actionDelegate.hidManager, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
    
    IOReturn IOReturn = IOHIDManagerOpen(actionDelegate.hidManager, kIOHIDOptionsTypeNone);
    
    IOHIDManagerRegisterInputValueCallback(actionDelegate.hidManager, Handle_DeviceEventCallback, (__bridge void*)actionDelegate);
    
    if (IOReturn != kIOReturnSuccess)
    {
        NSDebugLog(@"Couldn't look for devices. IOHIDManagerOpen failed.");
    }
}
-(void)stopObservingForDelegate:(id<IODeviceObserverManagementDelegate>)actionDelegate
{
    if (!actionDelegate) return;
    
    actionDelegate.hidManager = NULL;
}

static void Handle_DeviceMatchingCallback(void *inContext, IOReturn inResult, void *inSender, IOHIDDeviceRef inIOHIDDeviceRef)
{
    if (!inIOHIDDeviceRef) return;
    
    dispatch_async(dispatch_get_main_queue(),^
    {
        NSObject<IODeviceObserverConnectionDelegate>* actionDelegate = (__bridge NSObject<IODeviceObserverConnectionDelegate>*)inContext;
        if (![actionDelegate conformsToProtocol:@protocol(IODeviceObserverConnectionDelegate)]) return;
        
        [actionDelegate observedConnectionOfDevice:inIOHIDDeviceRef];
    });
}
static void Handle_DeviceRemovalCallback (void *inContext, IOReturn inResult, void *inSender, IOHIDDeviceRef inIOHIDDeviceRef)
{
    if (!inIOHIDDeviceRef) return;
    
    dispatch_async(dispatch_get_main_queue(),^
    {
        NSObject<IODeviceObserverConnectionDelegate>* actionDelegate = (__bridge NSObject<IODeviceObserverConnectionDelegate>*)inContext;
        if (![actionDelegate conformsToProtocol:@protocol(IODeviceObserverConnectionDelegate)]) return;
        
        [actionDelegate observedRemovalOfDevice:inIOHIDDeviceRef];
    });
}
static void Handle_DeviceEventCallback   (void *inContext, IOReturn inResult, void *inSender, IOHIDValueRef value)
{
    IOHIDElementRef element = IOHIDValueGetElement(value);      // Key
    IOHIDDeviceRef device = IOHIDElementGetDevice(element);     // Device
    if (!device) return;
    
    IOHIDElementCookie cookie = IOHIDElementGetCookie(element); // Cookie of key
    uint32_t usage = IOHIDElementGetUsage(element);             // Usage of key
    CFIndex elementValue = IOHIDValueGetIntegerValue(value);    // Actual state of key
    
    //NSDebugLog(@"Device ID = %p; Cookie = %u; Usage = %u; Value = %ld", (void*)device, cookie, usage, elementValue);
    
    NSObject<IODeviceObserverActionDelegate>* actionDelegate = (__bridge NSObject<IODeviceObserverActionDelegate>*)inContext;
    if (!actionDelegate) return;
    if (![actionDelegate conformsToProtocol:@protocol(IODeviceObserverActionDelegate)]) return;
    
    dispatch_async(dispatch_get_main_queue(),^
    {
        [actionDelegate observedEventWithCookie:cookie andUsage:usage withValue:elementValue fromDevice:device];
    });
}

@end
