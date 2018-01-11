//
//  VMMUserNotificationCenter.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//
//  Reference:
//  https://github.com/indragiek/NSUserNotificationPrivate
//
//  Growl support with Applescript:
//  http://growl.info/documentation/applescript-support.php
//  TODO: Check if Growl support is working
//

#import "VMMUserNotificationCenter.h"

#import "VMMComputerInformation.h"

#import "NSAlert+Extension.h"
#import "NSBundle+Extension.h"
#import "NSFileManager+Extension.h"
#import "NSImage+Extension.h"
#import "VMMUUID.h"

#define NOTIFICATION_UTILITY_SHARED_DICTIONARY_KEY @"info"

@interface NSUserNotification (NSUserNotificationPrivate)

@property(readonly, nonatomic) NSData *_identityImageData;
- (void)_setIdentityImage:(id)arg1 withIdentifier:(id)arg2;

@property(copy) NSImage *_identityImage;
@property BOOL _identityImageHasBorder;

@end

@implementation VMMUserNotificationCenter

static VMMUserNotificationCenter *_sharedInstance;

+(nonnull instancetype)defaultUserNotificationCenter
{
    @synchronized([self class])
    {
        if (!_sharedInstance)
        {
            _sharedInstance = [[VMMUserNotificationCenter alloc] init];
        }
        return _sharedInstance;
    }
}

-(BOOL)isGrowlAvailable
{
    NSArray* scriptToCheckIfGrowlExists = @[@"tell application \"System Events\"",
                                            @"\tset isRunning to ¬",
                                            @"\t\t(count of (every process whose bundle identifier is \"com.Growl.GrowlHelperApp\")) > 0",
                                            @"end tell"];
    NSAppleScript* growlExistsScript = [[NSAppleScript alloc] initWithSource:[scriptToCheckIfGrowlExists componentsJoinedByString:@"\n"]];
    NSAppleEventDescriptor* growlExists = [growlExistsScript executeAndReturnError:nil];
    
    return growlExists.booleanValue;
}
-(BOOL)deliverGrowlNotificationWithTitle:(nullable NSString*)title message:(nullable NSString*)message icon:(nullable NSImage*)icon
{
    NSURL* iconFileUrl;
    BOOL doesGrowlSupportImageFromLocation = (IS_SYSTEM_MAC_OS_10_7_OR_SUPERIOR == false);
    BOOL useIcon = doesGrowlSupportImageFromLocation && (icon != nil);
    
    if (useIcon)
    {
        NSString* iconFilePath = [NSString stringWithFormat:@"%@growlTemp%@.png",NSTemporaryDirectory(),VMMUUIDCreate()];
        [icon writeToFile:iconFilePath atomically:YES];
        iconFileUrl = [NSURL fileURLWithPath:iconFilePath];
    }
    
    NSString* appName = [[NSBundle originalMainBundle] bundleName];
    NSArray* growlScript = @[                           @"tell application id \"com.Growl.GrowlHelperApp\"",
                                                        @"\tset the allNotificationsList to {\"Notification\"}",
                                                        @"\tset the enabledNotificationsList to {\"Notification\"}",
                                                        @"\tregister as application ¬",
                             [NSString stringWithFormat:@"\t\t\"%@\" all notifications allNotificationsList ¬",appName],
                                                        @"\t\tdefault notifications enabledNotificationsList ¬",
                             [NSString stringWithFormat:@"\t\ticon of application \"%@\"",appName],
                                                        @"\t",
                                                        @"\tnotify with ¬",
                                                        @"\t\tname \"Notification\"  ¬",
            (title != nil) ? [NSString stringWithFormat:@"\t\ttitle \"%@\"  ¬",title] : @"\t\t¬",
          (message != nil) ? [NSString stringWithFormat:@"\t\tdescription \"%@\"  ¬",message] : @"\t\t¬",
                             [NSString stringWithFormat:@"\t\tapplication name \"%@\" ¬",appName],
                 (useIcon) ? [NSString stringWithFormat:@"\t\timage from location \"%@\"",iconFileUrl.absoluteString] : @"\t\t",
                                                        @"end tell"];
    NSAppleScript* notification = [[NSAppleScript alloc] initWithSource:[growlScript componentsJoinedByString:@"\n"]];
    NSAppleEventDescriptor* notificationSent = [notification executeAndReturnError:nil];
    return (notificationSent != nil);
}

-(void)deliverNotificationWithTitle:(nullable NSString*)title message:(nullable NSString*)message userInfo:(nullable NSObject*)info icon:(nullable NSImage*)icon actionButtonText:(nullable NSString*)actionButton
{
    if (IsClassNSUserNotificationCenterAvailable == false)
    {
        BOOL showAlert = true;
        
        if ([self isGrowlAvailable])
        {
            BOOL success = [self deliverGrowlNotificationWithTitle:title message:message icon:icon];
            if (success) showAlert = false;
        }
        
        if (showAlert)
        {
            if (actionButton != nil)
            {
                BOOL runAction = [NSAlert confirmationDialogWithTitle:title message:message andSettings:^(NSAlert *alert)
                {
                    [alert.buttons.firstObject setTitle:actionButton];
                    [alert setIcon:icon];
                }];
                
                if (runAction && self.delegate != nil)
                {
                    [self.delegate actionButtonPressedForNotificationWithUserInfo:info];
                }
            }
            else
            {
                [NSAlert showAlertWithTitle:title message:message andSettings:^(NSAlert *alert)
                {
                    [alert setIcon:icon];
                }];
            }
        }
        
        return;
    }
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:(id<NSUserNotificationCenterDelegate>)self];
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = title;
    notification.informativeText = message;
    notification.soundName = NSUserNotificationDefaultSoundName;
    notification.userInfo = info ? @{NOTIFICATION_UTILITY_SHARED_DICTIONARY_KEY:info} : @{};
    
    if (icon != nil)
    {
        @try
        {
            [notification setValue:icon   forKey:@"_identityImage"];
            [notification setValue:@FALSE forKey:@"_identityImageHasBorder"];
        }
        @catch (NSException* exception)
        {
            // Avoiding API exception in case something changes in the future
            
            // That feature is only available from macOS 10.9 and beyond
            if ([notification respondsToSelector:@selector(setContentImage:)])
            {
                notification.contentImage = icon;
            }
        }
    }
    
    if (actionButton != nil)
    {
        [notification setHasActionButton:YES];
        [notification setActionButtonTitle:actionButton];
    }
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

-(BOOL)userNotificationCenter:(id)center shouldPresentNotification:(id)notification
{
    return YES;
}
-(void)userNotificationCenter:(id)center didActivateNotification:(id)notification
{
    if (self.delegate != nil)
    {
        NSDictionary* userInfoDict = ((NSUserNotification *)notification).userInfo;
        NSObject* userInfo = userInfoDict[NOTIFICATION_UTILITY_SHARED_DICTIONARY_KEY];
        [self.delegate actionButtonPressedForNotificationWithUserInfo:userInfo];
    }
}

@end
