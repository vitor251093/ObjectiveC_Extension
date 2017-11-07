//
//  NSKeyCaptureField.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 18/08/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VMMDeviceObserver.h"
#import "VMMUsageKeycode.h"

@protocol NSKeyCaptureFieldDelegate <NSObject>
-(void)keyCaptureField:(NSTextField*)field didChangedKeyUsageKeycode:(uint32_t)keyUsage;
@end

@interface NSKeyCaptureField : NSTextField<VMMDeviceObserverManagementDelegate,VMMDeviceObserverActionDelegate>

@property (nonatomic, strong) IBOutlet NSObject<NSKeyCaptureFieldDelegate>* keyCaptureDelegate;
@property (nonatomic) IOHIDManagerRef hidManager;
@property (nonatomic) uint32_t keyUsageKeycode;

@end

