//
//  NSNotificationUtility.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//
//  Reference:
//  https://github.com/indragiek/NSUserNotificationPrivate
//

#import "NSNotificationUtility.h"

#import "NSComputerInformation.h"

#import "NSAlert+Extension.h"

@interface NSUserNotification (NSUserNotificationPrivate)

@property(readonly, nonatomic) NSData *_identityImageData;
- (void)_setIdentityImage:(id)arg1 withIdentifier:(id)arg2;

@property(copy) NSImage *_identityImage;
@property BOOL _identityImageHasBorder;

@end

@implementation NSNotificationUtility

+(void)showNotificationMessage:(NSString*)message withTitle:(NSString*)title withUserInfo:(NSString*)info withIcon:(NSImage*)icon withActionButtonText:(NSString*)actionButton
{
    if (!IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR)
    {
        [NSAlert showAlertMessage:message withTitle:title withSettings:^(NSAlert *alert)
        {
            [alert setIcon:icon];
        }];
        return;
    }
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = title;
    notification.informativeText = message;
    notification.soundName = NSUserNotificationDefaultSoundName;
    notification.userInfo = @{@"info":info};
    
    if (icon)
    {
        @try
        {
            [notification setValue:icon   forKey:@"_identityImage"];
            [notification setValue:@FALSE forKey:@"_identityImageHasBorder"];
        }
        @catch (NSException* exception)
        {
            // Avoiding API exception in case something changes (knows to work)
            
            // That feature is only available from macOS 10.9 and beyond
            if (IS_SYSTEM_MAC_OS_10_9_OR_SUPERIOR)
            {
                notification.contentImage = icon;
            }
        }
    }
    
    [notification setHasActionButton:YES];
    [notification setActionButtonTitle:actionButton];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

@end
