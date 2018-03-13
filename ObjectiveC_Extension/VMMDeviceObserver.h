//
//  VMMDeviceObserver.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 09/08/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IOKit/hid/IOHIDManager.h>
#import <IOKit/hid/IOHIDKeys.h>
#include <IOKit/usb/IOUSBLib.h>

#define VMMDeviceObserverTypesKeyboard  @[@(kHIDUsage_GD_Keyboard), @(kHIDUsage_GD_Keypad)]
#define VMMDeviceObserverTypesJoystick  @[@(kHIDUsage_GD_Joystick), @(kHIDUsage_GD_GamePad), @(kHIDUsage_GD_MultiAxisController)]

@protocol VMMDeviceObserverDelegate
@property (nonatomic, nullable) IOHIDManagerRef hidManager;
@property (nonatomic) CFIndex receivedPacketMaxSize;
@optional
-(void)observedConnectionOfDevice:(nonnull IOHIDDeviceRef)device;
-(void)observedRemovalOfDevice:(nonnull IOHIDDeviceRef)device;
-(void)observedEventWithName:(nullable CFStringRef)name cookie:(IOHIDElementCookie)cookie usage:(uint32_t)usage value:(CFIndex)value device:(nonnull IOHIDDeviceRef)device;
-(void)observedReportWithID:(uint32_t)reportID data:(nonnull uint8_t*)report type:(IOHIDReportType)reportType length:(CFIndex)reportLength device:(nonnull IOHIDDeviceRef)device;
@end

@interface VMMDeviceObserver : NSObject
+(nonnull instancetype)sharedObserver;
-(BOOL)observeDevicesOfTypes:(nonnull NSArray<NSNumber*>*)types forDelegate:(nonnull id<VMMDeviceObserverDelegate>)actionDelegate;
-(void)stopObservingForDelegate:(nonnull id<VMMDeviceObserverDelegate>)actionDelegate;

@property (nonatomic) uint8_t* _Nullable receivedReport;

@end
