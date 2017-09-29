//
//  IODeviceObserver.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 09/08/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IOKit/hid/IOHIDManager.h>
#import <IOKit/hid/IOHIDKeys.h>
#include <IOKit/usb/IOUSBLib.h>

#define IODeviceObserverTypesKeyboard  @[@(kHIDUsage_GD_Keyboard), @(kHIDUsage_GD_Keypad)]

@protocol IODeviceObserverManagementDelegate
@property (nonatomic) IOHIDManagerRef hidManager;
@end

@protocol IODeviceObserverConnectionDelegate
-(void)observedConnectionOfDevice:(IOHIDDeviceRef)device;
-(void)observedRemovalOfDevice:(IOHIDDeviceRef)device;
@end

@protocol IODeviceObserverActionDelegate
-(void)observedEventWithCookie:(IOHIDElementCookie)event andUsage:(uint32_t)usage withValue:(CFIndex)value fromDevice:(IOHIDDeviceRef)device;
@end


@interface IODeviceObserver : NSObject

+(instancetype)sharedObserver;
-(void)observeDevicesOfTypes:(NSArray*)types forDelegate:(id<IODeviceObserverManagementDelegate>)actionDelegate;
-(void)stopObservingForDelegate:(id<IODeviceObserverManagementDelegate>)actionDelegate;

@end
