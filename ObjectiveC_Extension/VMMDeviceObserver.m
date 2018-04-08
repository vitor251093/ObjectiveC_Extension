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

BOOL IOHIDDeviceGetLongProperty(IOHIDDeviceRef _Nullable inIOHIDDeviceRef, CFStringRef _Nonnull inKey, long * _Nonnull outValue)
{
    BOOL result = FALSE;
    if (inIOHIDDeviceRef)
    {
        assert(IOHIDDeviceGetTypeID() == CFGetTypeID(inIOHIDDeviceRef));
        
        CFTypeRef tCFTypeRef = IOHIDDeviceGetProperty(inIOHIDDeviceRef, inKey);
        if (tCFTypeRef)
        {
            if (CFNumberGetTypeID() == CFGetTypeID(tCFTypeRef))
            {
                result = CFNumberGetValue((CFNumberRef)tCFTypeRef, kCFNumberSInt32Type, outValue);
            }
        }
    }
    
    return result;
}
long IOHIDDeviceGetUsage(IOHIDDeviceRef _Nullable device)
{
    long result = 0;
    IOHIDDeviceGetLongProperty(device, CFSTR(kIOHIDPrimaryUsageKey), &result);
    return result;
}
long IOHIDDeviceGetVendorID(IOHIDDeviceRef _Nullable device)
{
    long vendorID = 0;
    IOHIDDeviceGetLongProperty(device, CFSTR(kIOHIDVendorIDKey), &vendorID);
    return vendorID;
}

@implementation VMMDeviceObserver

static VMMDeviceObserver *_sharedObserver;

+(nonnull instancetype)sharedObserver
{
    @synchronized([self class])
    {
        if (!_sharedObserver)
        {
            _sharedObserver = [[VMMDeviceObserver alloc] init];
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
-(BOOL)stopObservingForDelegate:(nonnull id<VMMDeviceObserverDelegate>)actionDelegate
{
    if (actionDelegate.hidManager == NULL) return true;
    
    IOReturn IOReturn = IOHIDManagerClose(actionDelegate.hidManager, kIOHIDOptionsTypeNone);
    actionDelegate.hidManager = NULL;
    
    return (IOReturn == kIOReturnSuccess);
}

static void Handle_DeviceMatchingCallback(void *inContext, IOReturn inResult, void *inSender, IOHIDDeviceRef inIOHIDDeviceRef)
{
    if (inIOHIDDeviceRef == NULL) return;
    
    VMMDeviceObserver* sender = VMMDeviceObserver.sharedObserver;
    
    NSObject<VMMDeviceObserverDelegate>* actionDelegate = (__bridge NSObject<VMMDeviceObserverDelegate>*)inContext;
    if (![actionDelegate respondsToSelector:@selector(observedConnectionOfDevice:)]) return;
    
    if ([actionDelegate respondsToSelector:@selector(receivedPacketMaxSize)])
    {
        sender.receivedReport = (uint8_t *)calloc(actionDelegate.receivedPacketMaxSize, sizeof(uint8_t));

        IOHIDDeviceScheduleWithRunLoop(inIOHIDDeviceRef, CFRunLoopGetMain(), kCFRunLoopCommonModes);
        IOHIDDeviceRegisterInputReportCallback(inIOHIDDeviceRef, sender.receivedReport, actionDelegate.receivedPacketMaxSize,
                                               Handle_DeviceReportCallback, inContext);
    }
    
    [actionDelegate observedConnectionOfDevice:inIOHIDDeviceRef];
}
static void Handle_DeviceRemovalCallback (void *inContext, IOReturn inResult, void *inSender, IOHIDDeviceRef inIOHIDDeviceRef)
{
    if (inIOHIDDeviceRef == NULL) return;
    
    NSObject<VMMDeviceObserverDelegate>* actionDelegate = (__bridge NSObject<VMMDeviceObserverDelegate>*)inContext;
    if (![actionDelegate respondsToSelector:@selector(observedRemovalOfDevice:)]) return;
    
    [actionDelegate observedRemovalOfDevice:inIOHIDDeviceRef];
}
static void Handle_DeviceEventCallback   (void *inContext, IOReturn inResult, void *inSender, IOHIDValueRef value)
{
    IOHIDElementRef element = IOHIDValueGetElement(value);      // Pressed key
    if (element == NULL) return;
    
    IOHIDDeviceRef device = IOHIDElementGetDevice(element);     // Device
    if (device == NULL) return;
    
    CFIndex elementValue = -1;
    if (IOHIDValueGetLength(value) <= IOHIDMaxIntegerValueBytes)
    {
        //
        // If the size of the package is bigger than 4 bytes, IOHIDValueGetIntegerValue() will cause
        // a SEGFAULT exception. That should solve the crash caused by that exception, since that
        // kind of exception can't be caught by a try/catch.
        //
        // https://github.com/nagyistoce/macifom/issues/3
        // https://groups.google.com/forum/#!topic/pyglet-users/O3RuDqmYr5Y
        //
        
        elementValue = IOHIDValueGetIntegerValue(value);    // Actual state of the pressed key
    }
    
    IOHIDElementCookie cookie = IOHIDElementGetCookie(element); // Cookie of the pressed key
    uint32_t usage = IOHIDElementGetUsage(element);             // Usage of the pressed key
    CFStringRef name = IOHIDElementGetName(element);
    
    NSObject<VMMDeviceObserverDelegate>* actionDelegate = (__bridge NSObject<VMMDeviceObserverDelegate>*)inContext;
    if (actionDelegate == nil) return;
    if (![actionDelegate respondsToSelector:@selector(observedEventWithName:cookie:usage:value:device:)]) return;
    
    [actionDelegate observedEventWithName:name cookie:cookie usage:usage value:elementValue device:device];
}

static void Handle_DeviceReportCallback   (void* context, IOReturn result, void* sender, IOHIDReportType type, uint32_t reportID, uint8_t*               report, CFIndex reportLength)
{
    IOHIDDeviceRef device = (IOHIDDeviceRef)sender;
    
    NSObject<VMMDeviceObserverDelegate>* actionDelegate = (__bridge NSObject<VMMDeviceObserverDelegate>*)context;
    if (actionDelegate == nil) return;
    if (![actionDelegate respondsToSelector:@selector(observedReportWithID:data:type:length:device:)]) return;
    
    [actionDelegate observedReportWithID:reportID data:report type:type length:reportLength device:device];
}

@end
