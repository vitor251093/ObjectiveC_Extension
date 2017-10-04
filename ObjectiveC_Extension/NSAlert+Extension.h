//
//  NSAlert+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#ifndef NSAlert_Extension_Class
#define NSAlert_Extension_Class

#import <Cocoa/Cocoa.h>

typedef enum NSAlertType
{
    NSAlertTypeSuccess,
    NSAlertTypeWarning,
    NSAlertTypeError,
    NSAlertTypeCritical,
    NSAlertTypeCustom
} NSAlertType;

@interface NSAlert (VMMAlert)

+(void)setAlertsWindow:(NSWindow*)alert;

-(void)setIconWithAlertType:(NSAlertType)alertType;

-(NSUInteger)runThreadSafeModal;
+(NSUInteger)runThreadSafeModalWithAlert:(NSAlert* (^)(void))alert;

+(void)showAlertMessageWithException:(NSException*)exception;
+(void)showAlertOfType:(NSAlertType)alertType withMessage:(NSString*)message;
+(void)showAlertMessage:(NSString*)message withTitle:(NSString*)title withSettings:(void (^)(NSAlert* alert))optionsForAlert;

+(void)showAlertAttributedMessage:(NSAttributedString*)message withTitle:(NSString*)title withSubtitle:(NSString*)subtitle;

+(BOOL)showBooleanAlertMessage:(NSString*)message withTitle:(NSString*)title withDefault:(BOOL)yesDefault;
+(BOOL)showBooleanAlertOfType:(NSAlertType)alertType withMessage:(NSString*)message withDefault:(BOOL)yesDefault;
+(BOOL)showBooleanAlertMessage:(NSString*)message withTitle:(NSString*)title withDefault:(BOOL)yesDefault withSettings:(void (^)(NSAlert* alert))setAlertSettings;

+(BOOL)confirmationDialogWithTitle:(NSString*)prompt message:(NSString*)message withSettings:(void (^)(NSAlert* alert))setAlertSettings;

+(NSString*)inputDialogWithTitle:(NSString*)prompt message:(NSString*)message defaultValue:(NSString*)defaultValue;

+(NSString*)showAlertWithButtonOptions:(NSArray*)options withTitle:(NSString*)title withText:(NSString*)text withIconForEachOption:(NSImage* (^)(NSString* option))iconForOption;

@end

#endif
