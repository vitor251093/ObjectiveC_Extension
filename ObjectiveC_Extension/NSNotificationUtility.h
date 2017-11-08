//
//  NSNotificationUtility.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NSNotificationUtilityDelegate
-(void)actionButtonPressedForNotificationWithUserInfo:(NSObject*)userInfo;
@end

@interface NSNotificationUtility : NSObject

@property (nonatomic) id<NSNotificationUtilityDelegate> delegate;

+(instancetype)sharedInstance;

-(void)showNotificationMessage:(NSString*)message withTitle:(NSString*)title withUserInfo:(NSObject*)info withIcon:(NSImage*)icon withActionButtonText:(NSString*)actionButton;

@end
