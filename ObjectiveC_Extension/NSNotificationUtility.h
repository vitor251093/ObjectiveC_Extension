//
//  NSNotificationUtility.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationUtility : NSObject

+(void)showNotificationMessage:(NSString*)message withTitle:(NSString*)title withUserInfo:(NSString*)info withIcon:(NSImage*)icon withActionButtonText:(NSString*)actionButton;

@end
