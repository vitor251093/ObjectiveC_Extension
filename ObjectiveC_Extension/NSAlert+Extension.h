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

/*!
 * @typedef NSAlertType
 * @brief A list of predefined alert types.
 * @constant NSAlertTypeSuccess  An alert with 'Success' as title and the default alert icon.
 * @constant NSAlertTypeWarning  An alert with 'Warning' as title and the NSCriticalAlertStyle icon.
 * @constant NSAlertTypeError    An alert with 'Error' as title and NSImageNameCaution as icon.
 * @constant NSAlertTypeCritical An alert with 'Error' as title and NSImageNameStopProgressFreestandingTemplate as icon.
 * @constant NSAlertTypeCustom   An alert with the app name as title and the default alert icon.
 */
typedef enum NSAlertType
{
    /// An alert with 'Success' as title and the default alert icon.
    NSAlertTypeSuccess,
    
    /// An alert with 'Warning' as title and the NSCriticalAlertStyle icon.
    NSAlertTypeWarning,
    
    /// An alert with 'Error' as title and NSImageNameCaution as icon.
    NSAlertTypeError,
    
    /// An alert with 'Error' as title and NSImageNameStopProgressFreestandingTemplate as icon.
    NSAlertTypeCritical,
    
    /// An alert with the app name as title and the default alert icon.
    NSAlertTypeCustom
} NSAlertType;

@interface NSAlert (VMMAlert)

/*!
 * @discussion  Changes the icon of a NSAlert based in the NSAlertType.
 * @param alertType The NSAlertType that will be used to configure the alert icon.
 */
-(void)setIconWithAlertType:(NSAlertType)alertType;

/*!
 * @discussion  Same as runModal, but which runs the alert in the main thread and returns the result to the active thread.
 * @discussion  This method is thread safe, so it can be used from any thread or queue.
 * @return      The runModal output.
 */
-(NSUInteger)runThreadSafeModal;

/*!
 * @discussion  Same as runModal, but which creates and runs the alert in the main thread and returns the result to the active thread.
 * @discussion  This method is thread safe, so it can be used from any thread or queue.
 * @param alert A block that will be run in the main thread, and needs as return the NSAlert that will be shown.
 * @return      The runModal output.
 */
+(NSUInteger)runThreadSafeModalWithAlert:(NSAlert* (^)(void))alert;

/*!
 * @discussion  Shows a NSAlert with the contents of a NSException and an Ok button.
 * @discussion  This method is thread safe, so it can be used from any thread or queue.
 * @param exception The exception that will be used to create the alert.
 */
+(void)showErrorAlertWithException:(NSException*)exception;

/*!
 * @discussion  Shows a NSAlert with a predefined NSAlertType, an informative text and an Ok button.
 * @discussion  This method is thread safe, so it can be used from any thread or queue.
 * @param alertType The NSAlertType that will be used to configure the alert.
 * @param message   The message (aka. informative text) that will be shown in the alert.
 */
+(void)showAlertOfType:(NSAlertType)alertType withMessage:(NSString*)message;

/*!
 * @discussion  Shows a NSAlert with a title, an informative text, any other configurations specified in the block and an Ok button.
 * @discussion  This method is thread safe, so it can be used from any thread or queue.
 * @param title           The title that will be shown in the alert.
 * @param message         The message (aka. informative text) that will be shown in the alert.
 * @param optionsForAlert The block to make any extra adjustments in the alert before showing it.
 */
+(void)showAlertWithTitle:(NSString*)title message:(NSString*)message andSettings:(void (^)(NSAlert* alert))optionsForAlert;

/*!
 * @discussion  Shows a NSAlert with a title, a subtitle, an attributed informative text and an Ok button.
 * @discussion  This method is thread safe, so it can be used from any thread or queue.
 * @param message         The message (aka. attributed informative text) that will be shown in the alert.
 * @param title           The title that will be shown in the alert.
 * @param subtitle        The subtitle (aka. informative text) that will be shown in the alert.
 */
+(void)showAlertAttributedMessage:(NSAttributedString*)message withTitle:(NSString*)title withSubtitle:(NSString*)subtitle;

/*!
 * @discussion  Shows a NSAlert with a title, an informative text and Yes/No buttons.
 * @discussion  This method is thread safe, so it can be used from any thread or queue.
 * @param message         The message (aka. informative text) that will be shown in the alert.
 * @param title           The title that will be shown in the alert.
 * @param yesDefault      The button that will be highlighted by default in the alert (Yes/No).
 * @return                true if Yes was pressed, false if No was pressed.
 */
+(BOOL)showBooleanAlertMessage:(NSString*)message withTitle:(NSString*)title withDefault:(BOOL)yesDefault;

/*!
 * @discussion  Shows a NSAlert with a predefined NSAlertType, an informative text and Yes/No buttons.
 * @discussion  This method is thread safe, so it can be used from any thread or queue.
 * @param alertType The NSAlertType that will be used to configure the alert.
 * @param message         The message (aka. informative text) that will be shown in the alert.
 * @param yesDefault      The button that will be highlighted by default in the alert (Yes/No).
 * @return                true if Yes was pressed, false if No was pressed.
 */
+(BOOL)showBooleanAlertOfType:(NSAlertType)alertType withMessage:(NSString*)message withDefault:(BOOL)yesDefault;

/*!
 * @discussion  Shows a NSAlert with a title, an informative text, any other configurations specified in the block and Yes/No buttons.
 * @discussion  This method is thread safe, so it can be used from any thread or queue.
 * @param message          The message (aka. informative text) that will be shown in the alert.
 * @param title            The title that will be shown in the alert.
 * @param yesDefault       The button that will be highlighted by default in the alert (Yes/No).
 * @param setAlertSettings The block to make any extra adjustments in the alert before showing it.
 * @return                 true if Yes was pressed, false if No was pressed.
 */
+(BOOL)showBooleanAlertMessage:(NSString*)message withTitle:(NSString*)title withDefault:(BOOL)yesDefault withSettings:(void (^)(NSAlert* alert))setAlertSettings;

/*!
 * @discussion  Shows a NSAlert with a title, an informative text, any other configurations specified in the block and Ok/Cancel buttons.
 * @discussion  This method is thread safe, so it can be used from any thread or queue.
 * @param message          The message (aka. informative text) that will be shown in the alert.
 * @param prompt           The title that will be shown in the alert.
 * @param setAlertSettings The block to make any extra adjustments in the alert before showing it.
 * @return                 true if Ok was pressed, false if Cancel was pressed.
 */
+(BOOL)confirmationDialogWithTitle:(NSString*)prompt message:(NSString*)message withSettings:(void (^)(NSAlert* alert))setAlertSettings;

/*!
 * @discussion  Shows a NSAlert with a title, an informative text, a text field and Ok/Cancel buttons.
 * @discussion  This method is thread safe, so it can be used from any thread or queue.
 * @param prompt       The title that will be shown in the alert.
 * @param message      The message (aka. informative text) that will be shown in the alert.
 * @param defaultValue The initial string value of the text field.
 * @return             The string value of the text field if Ok was pressed, nil if Cancel was pressed.
 */
+(NSString*)inputDialogWithTitle:(NSString*)prompt message:(NSString*)message defaultValue:(NSString*)defaultValue;

/*!
 * @discussion  Shows a NSAlert with a title, an informative text, big squared buttons and a Cancel button.
 * @discussion  This method is thread safe, so it can be used from any thread or queue.
 * @param options       The list of the buttons that should appear in the dialog.
 * @param title         The title that will be shown in the alert.
 * @param text          The message (aka. informative text) that will be shown in the alert.
 * @param iconForOption A block that needs as return the image that will be the icon for each button title.
 * @return              The title of the pressed big button if any was pressed, nil if Cancel was pressed.
 */
+(NSString*)showAlertWithButtonOptions:(NSArray*)options withTitle:(NSString*)title withText:(NSString*)text withIconForEachOption:(NSImage* (^)(NSString* option))iconForOption;

@end

#endif
