//
//  VMMUserNotificationCenter.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VMMUserNotificationCenterDelegate
-(void)actionButtonPressedForNotificationWithUserInfo:(NSObject*)userInfo;
@end

@interface VMMUserNotificationCenter : NSObject

@property (nonatomic) id<VMMUserNotificationCenterDelegate> delegate;

+(instancetype)defaultUserNotificationCenter;

-(void)deliverNotificationWithTitle:(NSString*)title message:(NSString*)message userInfo:(NSObject*)info icon:(NSImage*)icon actionButtonText:(NSString*)actionButton;

@end
