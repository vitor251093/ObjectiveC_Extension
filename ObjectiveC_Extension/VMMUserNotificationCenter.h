//
//  VMMUserNotificationCenter.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VMMUserNotificationCenterDelegate
-(void)actionButtonPressedForNotificationWithUserInfo:(nullable NSObject*)userInfo;
@end

@interface VMMUserNotificationCenter : NSObject

@property (nonatomic, nullable) id<VMMUserNotificationCenterDelegate> delegate;

+(nonnull instancetype)defaultUserNotificationCenter;

-(void)deliverNotificationWithTitle:(nullable NSString*)title message:(nullable NSString*)message userInfo:(nullable NSObject*)info icon:(nullable NSImage*)icon actionButtonText:(nullable NSString*)actionButton;

@end
