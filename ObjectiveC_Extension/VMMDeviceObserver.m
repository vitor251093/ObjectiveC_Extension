//
//  VMMDeviceObserver.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 09/08/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "VMMDeviceObserver.h"

#import "NSMutableArray+Extension.h"

#import "VMMLogUtility.h"

@implementation VMMDeviceObserver

static VMMDeviceObserver *_sharedObserver;

+(nonnull instancetype)sharedObserver
{
    @synchronized([self class])
    {
        if (!_sharedObserver)
        {
            _sharedObserver = [[VMMDeviceObserver alloc] init];
            _sharedObserver.receivedPacketMaxSize = 552;
        }
        return _sharedObserver;
    }
}

-(BOOL)observeDevicesOfTypes:(nonnull NSArray<NSNumber*>*)types forDelegate:(nonnull id<VMMDeviceObserverDelegate>)actionDelegate
{
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
    
    return (IOReturn == kIOReturnSuccess);
}
-(void)stopObservingForDelegate:(nonnull id<VMMDeviceObserverDelegate>)actionDelegate
{
    actionDelegate.hidManager = NULL;
}

static void Handle_DeviceMatchingCallback(void *inContext, IOReturn inResult, void *inSender, IOHIDDeviceRef inIOHIDDeviceRef)
{
    if (inIOHIDDeviceRef == NULL) return;
    
    dispatch_async(dispatch_get_main_queue(),^
    {
        VMMDeviceObserver* sender = VMMDeviceObserver.sharedObserver;
        
        sender.receivedReport = (uint8_t *)calloc(sender.receivedPacketMaxSize, sizeof(uint8_t));

        IOHIDDeviceScheduleWithRunLoop(inIOHIDDeviceRef, CFRunLoopGetMain(), kCFRunLoopCommonModes);
        IOHIDDeviceRegisterInputReportCallback(inIOHIDDeviceRef, sender.receivedReport, sender.receivedPacketMaxSize,
                                               Handle_DeviceReportCallback, inContext);
        
        NSObject<VMMDeviceObserverDelegate>* actionDelegate = (__bridge NSObject<VMMDeviceObserverDelegate>*)inContext;
        if (![actionDelegate respondsToSelector:@selector(observedConnectionOfDevice:)]) return;
        
        [actionDelegate observedConnectionOfDevice:inIOHIDDeviceRef];
    });
}
static void Handle_DeviceRemovalCallback (void *inContext, IOReturn inResult, void *inSender, IOHIDDeviceRef inIOHIDDeviceRef)
{
    if (inIOHIDDeviceRef == NULL) return;
    
    dispatch_async(dispatch_get_main_queue(),^
    {
        NSObject<VMMDeviceObserverDelegate>* actionDelegate = (__bridge NSObject<VMMDeviceObserverDelegate>*)inContext;
        if (![actionDelegate respondsToSelector:@selector(observedRemovalOfDevice:)]) return;
        
        [actionDelegate observedRemovalOfDevice:inIOHIDDeviceRef];
    });
}
static void Handle_DeviceEventCallback   (void *inContext, IOReturn inResult, void *inSender, IOHIDValueRef value)
{
    IOHIDElementRef element = IOHIDValueGetElement(value);      // Pressed key
    if (element == NULL) return;
    
    IOHIDDeviceRef device = IOHIDElementGetDevice(element);     // Device
    if (device == NULL) return;
    
    CFIndex elementValue = IOHIDValueGetIntegerValue(value);    // Actual state of the pressed key
    IOHIDElementCookie cookie = IOHIDElementGetCookie(element); // Cookie of the pressed key
    uint32_t usage = IOHIDElementGetUsage(element);             // Usage of the pressed key
    CFStringRef name = IOHIDElementGetName(element);
    
    //NSDebugLog(@"Device ID = %p; Cookie = %u; Usage = %u; Value = %ld", (void*)device, cookie, usage, elementValue);
    
    NSObject<VMMDeviceObserverDelegate>* actionDelegate = (__bridge NSObject<VMMDeviceObserverDelegate>*)inContext;
    if (actionDelegate == nil) return;
    if (![actionDelegate respondsToSelector:@selector(observedEventWithName:cookie:usage:value:device:)]) return;
    
    dispatch_async(dispatch_get_main_queue(),^
    {
        [actionDelegate observedEventWithName:name cookie:cookie usage:usage value:elementValue device:device];
    });
}

static void Handle_DeviceReportCallback   (void* context, IOReturn result, void* sender, IOHIDReportType type, uint32_t reportID, uint8_t*               report, CFIndex reportLength)
{
    IOHIDDeviceRef device = (IOHIDDeviceRef)sender;
    
    NSObject<VMMDeviceObserverDelegate>* actionDelegate = (__bridge NSObject<VMMDeviceObserverDelegate>*)context;
    if (actionDelegate == nil) return;
    if (![actionDelegate respondsToSelector:@selector(observedReportWithID:data:type:length:device:)]) return;
    
    dispatch_async(dispatch_get_main_queue(),^
    {
        [actionDelegate observedReportWithID:reportID data:report type:type length:reportLength device:device];
    });
}

@end
