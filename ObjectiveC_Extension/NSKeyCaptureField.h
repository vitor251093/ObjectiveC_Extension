//
//  NSKeyCaptureField.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 18/08/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IODeviceObserver.h"
#import "IOUsageKeycode.h"

@protocol NSKeyCaptureFieldDelegate <NSObject>
-(void)keyCaptureField:(NSTextField*)field didChangedKeyUsage:(uint32_t)keyUsage;
@end

@interface NSKeyCaptureField : NSTextField<IODeviceObserverManagementDelegate,IODeviceObserverActionDelegate>

@property (nonatomic, strong) IBOutlet NSObject<NSKeyCaptureFieldDelegate>* keyCaptureDelegate;
@property (nonatomic) IOHIDManagerRef hidManager;
@property (nonatomic,setter=setKeyUsage:) uint32_t keyUsage;

@end

