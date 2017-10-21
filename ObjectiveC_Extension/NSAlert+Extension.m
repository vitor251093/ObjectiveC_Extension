//
//  NSAlert+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//
//  Reference for runModalWithWindow:
//  https://github.com/adobe/brackets-app/blob/master/src/mac/cefclient/NSAlert%2BSynchronousSheet.m

#import "NSAlert+Extension.h"

#import "NSThread+Extension.h"
#import "NSMutableAttributedString+Extension.h"

#import "NSLogUtility.h"
#import "NSModals.h"

#define ALERT_WITH_ATTRIBUTED_MESSAGE_PARAGRAPH_SPACING  2.0f
#define ALERT_WITH_ATTRIBUTED_MESSAGE_WIDTH_MARGIN       50
#define ALERT_WITH_ATTRIBUTED_MESSAGE_WIDTH_LIMIT_MARGIN 200

#define ALERT_WITH_BUTTON_OPTIONS_VIEW_WIDTH_MODIFIER_LIMIT 3
#define ALERT_WITH_BUTTON_OPTIONS_VIEW_WIDTH_MODIFIER_LESS  -20
#define ALERT_WITH_BUTTON_OPTIONS_VIEW_WIDTH_MODIFIER_MORE  30

#define ALERT_WITH_BUTTON_OPTIONS_BUTTONS_LATERAL       0
#define ALERT_WITH_BUTTON_OPTIONS_BUTTONS_SPACE         10
#define ALERT_WITH_BUTTON_OPTIONS_ICON_WIDTH            80
#define ALERT_WITH_BUTTON_OPTIONS_ICON_HEIGHT           80
#define ALERT_WITH_BUTTON_OPTIONS_ICON_BORDER_WITH_TEXT 30
#define ALERT_WITH_BUTTON_OPTIONS_ICON_BORDER           10
#define ALERT_WITH_BUTTON_OPTIONS_ICON_IMAGE_BORDER     10
#define ALERT_WITH_BUTTON_OPTIONS_ICONS_AT_X            3

#define INPUT_DIALOG_MESSAGE_FIELD_FRAME NSMakeRect(0, 0, 260, 24)

#define ALERT_ICON_SIZE 512

@interface NSImage (VMMImageForAlert)
@end

@implementation NSImage (VMMImageForAlert)
-(NSImage*)getTintedImageWithColor:(NSColor*)color
{
    NSImage* tinted;
    
    @autoreleasepool
    {
        tinted = [[NSImage alloc] initWithSize:self.size];
        [tinted lockFocus];
        
        NSRect imageRect = NSMakeRect(0, 0, self.size.width, self.size.height);
        [self drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        
        [color set];
        NSRectFillUsingOperation(imageRect, NSCompositeSourceAtop);
        
        [tinted unlockFocus];
    }
    
    return tinted;
}
+(NSImage*)stopProgressIcon
{
    NSImage* icon = [NSImage imageNamed:NSImageNameStopProgressFreestandingTemplate];
    [icon setSize:NSMakeSize(ALERT_ICON_SIZE, ALERT_ICON_SIZE)];
    return [icon getTintedImageWithColor:[NSColor redColor]];
}
+(NSImage*)cautionIcon
{
    NSImage* icon = [NSImage imageNamed:NSImageNameCaution];
    [icon setSize:NSMakeSize(ALERT_ICON_SIZE, ALERT_ICON_SIZE)];
    return icon;
}
@end

@implementation NSAlert (VMMAlert)

static NSString* bundleName;

+(NSString*)titleForAlertType:(NSAlertType)alertType
{
    switch (alertType)
    {
        case NSAlertTypeSuccess:
            return NSLocalizedString(@"Success",nil);
            
        case NSAlertTypeWarning:
            return NSLocalizedString(@"Warning",nil);
            
        case NSAlertTypeError:
            return NSLocalizedString(@"Error",nil);
            
        case NSAlertTypeCritical:
            return NSLocalizedString(@"Error",nil);
            
        case NSAlertTypeCustom:
        default: break;
    }
    
    if (bundleName) return bundleName;
    
    NSString* placeholder = @"Info";
    NSString* bundleNameKey = @"CFBundleName";
    
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    if (!bundlePath) return placeholder;
    
    NSString* infoPlistPath = [[bundlePath stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Info.plist"];
    NSDictionary* infoPlist = [[NSDictionary alloc] initWithContentsOfFile:infoPlistPath];
    if (!infoPlist || !infoPlist[bundleNameKey]) return bundlePath.stringByDeletingPathExtension.lastPathComponent;
    
    bundleName = infoPlist[bundleNameKey];
    return bundleName;
}
-(void)setIconWithAlertType:(NSAlertType)alertType
{
    switch (alertType)
    {
        case NSAlertTypeWarning:
            [self setAlertStyle:NSCriticalAlertStyle];
            break;
            
        case NSAlertTypeError:
            [self setIcon:[NSImage cautionIcon]];
            break;
            
        case NSAlertTypeCritical:
            [self setIcon:[NSImage stopProgressIcon]];
            break;
            
        default: break;
    }
}

-(IBAction)BE_stopSynchronousSheet:(id)sender
{
    NSUInteger clickedButtonIndex = [[self buttons] indexOfObject:sender];
    NSInteger modalCode = NSAlertFirstButtonReturn + clickedButtonIndex;
    [NSApp stopModalWithCode:modalCode];
}
-(void)BE_beginSheetModalForWindow:(NSWindow *)aWindow
{
    [self beginSheetModalForWindow:aWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
}
-(NSUInteger)runModalWithWindow
{
    NSWindow* window = [NSModals modalsWindow];
    
    if (window)
    {
        for (NSButton *button in self.buttons)
        {
            [button setTarget:self];
            [button setAction:@selector(BE_stopSynchronousSheet:)];
        }
        
        [self performSelectorOnMainThread:@selector(BE_beginSheetModalForWindow:) withObject:window waitUntilDone:YES];
        
        NSInteger modalCode = [NSApp runModalForWindow:[self window]];
        
        [NSApp performSelectorOnMainThread:@selector(endSheet:) withObject:[self window] waitUntilDone:YES];
        [[self window] performSelectorOnMainThread:@selector(orderOut:) withObject:self waitUntilDone:YES];
        
        return modalCode;
    }
    
    return [self runModal];
}

-(NSUInteger)runThreadSafeModal
{
    return [NSAlert runThreadSafeModalWithAlert:^NSAlert*
    {
        return self;
    }];
}
+(NSUInteger)runThreadSafeModalWithAlert:(NSAlert* (^)(void))alert
{
    if ([NSThread isMainThread])
    {
        return [alert() runModalWithWindow];
    }
    
    NSCondition* lock = [[NSCondition alloc] init];
    __block NSUInteger value;
    
    [NSThread dispatchBlockInMainQueue:^
    {
        value = [alert() runModalWithWindow];
        
        [lock signal];
    }];
    
    [lock lock];
    [lock wait];
    [lock unlock];
    
    return value;
}

+(void)showErrorAlertWithException:(NSException*)exception
{
    [self showAlertOfType:NSAlertTypeError withMessage:[NSString stringWithFormat:@"%@: %@", exception.name, exception.reason]];
}
+(void)showAlertOfType:(NSAlertType)alertType withMessage:(NSString*)message
{
    @autoreleasepool
    {
        NSString* alertTitle = [self titleForAlertType:alertType];
        
        [self showAlertWithTitle:alertTitle message:message andSettings:^(NSAlert* alert)
        {
            [alert setIconWithAlertType:alertType];
        }];
    }
}
+(void)showAlertWithTitle:(NSString*)title message:(NSString*)message andSettings:(void (^)(NSAlert* alert))optionsForAlert
{
    [self runThreadSafeModalWithAlert:^NSAlert *
    {
        NSAlert* msgBox = [[NSAlert alloc] init];
        [msgBox setMessageText: title];
        [msgBox addButtonWithTitle:NSLocalizedString(@"OK",nil)];
        [msgBox setInformativeText: message];
        
        optionsForAlert(msgBox);
        
        return msgBox;
    }];
}

+(void)showAlertWithTitle:(NSString*)title subtitle:(NSString*)subtitle andAttributedMessage:(NSAttributedString*)message
{
    __block NSTextView* informativeText = [[NSTextView alloc] init];
    [informativeText setBackgroundColor:[NSColor clearColor]];
    [informativeText.textStorage setAttributedString:message];
    [informativeText setEditable:false];
    
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrapStyle setParagraphSpacing:ALERT_WITH_ATTRIBUTED_MESSAGE_PARAGRAPH_SPACING];
    [informativeText.textStorage addAttribute:NSParagraphStyleAttributeName value:paragrapStyle];
    
    CGFloat width = informativeText.textStorage.size.width + ALERT_WITH_ATTRIBUTED_MESSAGE_WIDTH_MARGIN;
    CGFloat screenLimit = [[NSScreen mainScreen] visibleFrame].size.width - ALERT_WITH_ATTRIBUTED_MESSAGE_WIDTH_LIMIT_MARGIN;
    if (width > screenLimit) width = screenLimit;
    [informativeText setFrame:NSMakeRect(0, 0, width, informativeText.textStorage.size.height)];
    
    [self showAlertWithTitle:title message:subtitle andSettings:^(NSAlert *alert)
    {
        [alert setAccessoryView:informativeText];
    }];
}

+(BOOL)showBooleanAlertWithTitle:(NSString*)title message:(NSString*)message highlighting:(BOOL)highlight
{
    BOOL result;
    
    @autoreleasepool
    {
        result = [self showBooleanAlertWithTitle:title message:message highlighting:highlight withSettings:^(NSAlert* alert) {}];
    }
    
    return result;
}
+(BOOL)showBooleanAlertOfType:(NSAlertType)alertType withMessage:(NSString*)message highlighting:(BOOL)highlight
{
    BOOL result;
    
    @autoreleasepool
    {
        NSString* alertTitle = [self titleForAlertType:alertType];
        
        result = [self showBooleanAlertWithTitle:alertTitle message:message highlighting:highlight withSettings:^(NSAlert* alert)
        {
            [alert setIconWithAlertType:alertType];
        }];
    }
    
    return result;
}
+(BOOL)showBooleanAlertWithTitle:(NSString*)title message:(NSString*)message highlighting:(BOOL)highlight withSettings:(void (^)(NSAlert* alert))optionsForAlert
{
    BOOL value = !highlight;
    NSString* defaultButton;
    NSString* alternateButton;
    
    if (highlight)
    {
        defaultButton = NSLocalizedString(@"Yes",nil);
        alternateButton = NSLocalizedString(@"No",nil);
    }
    else
    {
        defaultButton = NSLocalizedString(@"No",nil);
        alternateButton = NSLocalizedString(@"Yes",nil);
    }
    
    NSUInteger alertResult = [self runThreadSafeModalWithAlert:^NSAlert *
    {
        NSAlert *alert = [NSAlert alertWithMessageText:title != nil ? title : @""
                                         defaultButton:defaultButton
                                       alternateButton:alternateButton
                                           otherButton:nil
                             informativeTextWithFormat:@"%@",message];
        
        optionsForAlert(alert);
        return alert;
    }];
    
    if (alertResult == NSAlertDefaultReturn) value = highlight;
    return value;
}

+(BOOL)confirmationDialogWithTitle:(NSString*)prompt message:(NSString*)message andSettings:(void (^)(NSAlert* alert))optionsForAlert
{
    NSUInteger alertResult;
    
    @autoreleasepool
    {
        alertResult = [self runThreadSafeModalWithAlert:^NSAlert *
        {
            NSAlert *alert = [NSAlert alertWithMessageText:prompt
                                             defaultButton:NSLocalizedString(@"OK",nil)
                                           alternateButton:NSLocalizedString(@"Cancel",nil)
                                               otherButton:nil
                                 informativeTextWithFormat:@"%@",message];
            optionsForAlert(alert);
            return alert;
        }];
    }
    
    return alertResult == NSAlertDefaultReturn;
}

+(NSString*)inputDialogWithTitle:(NSString*)prompt message:(NSString*)message defaultValue:(NSString*)defaultValue
{
    NSString* result;
    
    @autoreleasepool
    {
        if ([NSThread isMainThread])
        {
            NSAlert *alert = [NSAlert alertWithMessageText:prompt
                                             defaultButton:NSLocalizedString(@"OK",nil)
                                           alternateButton:NSLocalizedString(@"Cancel",nil)
                                               otherButton:nil
                                 informativeTextWithFormat:@"%@",message];
            
            NSTextField *input = [[NSTextField alloc] initWithFrame:INPUT_DIALOG_MESSAGE_FIELD_FRAME];
            if (defaultValue) [input setStringValue:defaultValue];
            [alert setAccessoryView:input];
            [[alert window] setInitialFirstResponder:input];
            
            if ([alert runModalWithWindow] == NSAlertDefaultReturn)
            {
                [input validateEditing];
                result = [input stringValue];
            }
        }
        else
        {
            NSCondition* lock = [[NSCondition alloc] init];
            __block NSString* value = nil;
            [NSThread dispatchBlockInMainQueue:^
             {
                 NSAlert *alert = [NSAlert alertWithMessageText:prompt
                                                  defaultButton:NSLocalizedString(@"OK",nil)
                                                alternateButton:NSLocalizedString(@"Cancel",nil)
                                                    otherButton:nil
                                      informativeTextWithFormat:@"%@",message];
                 
                 NSTextField *input = [[NSTextField alloc] initWithFrame:INPUT_DIALOG_MESSAGE_FIELD_FRAME];
                 if (defaultValue) [input setStringValue:defaultValue];
                 [alert setAccessoryView:input];
                 [[alert window] setInitialFirstResponder:input];
                 
                 if ([alert runModalWithWindow] == NSAlertDefaultReturn)
                 {
                     [input validateEditing];
                     value = [input stringValue];
                 }
                 [lock signal];
             }];
            [lock lock];
            [lock wait];
            [lock unlock];
            
            result = value;
        }
    }
    
    return result;
}

static NSAlert* _alertWithButtonOptions;
+(void)selectAlertButton:(NSButton*)sender
{
    sender.tag = true;
    
    [[_alertWithButtonOptions window] setIsVisible:NO]; // will make it invisible instantly
    [NSApp endSheet:[_alertWithButtonOptions window]];  // will close it after the next dialog
}
+(NSString*)showAlertWithTitle:(NSString*)title message:(NSString*)message buttonOptions:(NSArray<NSString*>*)options andIconForEachOption:(NSImage* (^)(NSString* option))iconForOption
{
    NSString* result = nil;
    
    @autoreleasepool
    {
        int totalY = (int) ((options.count-1) / ALERT_WITH_BUTTON_OPTIONS_ICONS_AT_X) + 1;
        int totalX = (int) ALERT_WITH_BUTTON_OPTIONS_ICONS_AT_X;
        BOOL hasSingleLine = totalX == options.count;
        
        CGFloat iconHeight = ALERT_WITH_BUTTON_OPTIONS_ICON_HEIGHT;
        CGFloat iconWidth  = ALERT_WITH_BUTTON_OPTIONS_ICON_WIDTH;
        
        CGFloat viewHeight = iconHeight*totalY + (totalY-1)*ALERT_WITH_BUTTON_OPTIONS_BUTTONS_SPACE;
        CGFloat viewWidth = ALERT_WITH_BUTTON_OPTIONS_BUTTONS_LATERAL*2 +
                            iconWidth*totalX + (totalX-1)*ALERT_WITH_BUTTON_OPTIONS_BUTTONS_SPACE;
        
        // Applying Width modifier
        if (options.count < ALERT_WITH_BUTTON_OPTIONS_VIEW_WIDTH_MODIFIER_LIMIT)
        {
            viewWidth += ALERT_WITH_BUTTON_OPTIONS_VIEW_WIDTH_MODIFIER_LESS;
        }
        else
        {
            viewWidth += ALERT_WITH_BUTTON_OPTIONS_VIEW_WIDTH_MODIFIER_MORE;
        }
        
        __block NSView* sourcesView = [[NSView alloc] init];
        [sourcesView setFrameSize:NSMakeSize(viewWidth,viewHeight)];
        
        for (int i = 0; i < options.count; i++)
        {
            int x = i % ALERT_WITH_BUTTON_OPTIONS_ICONS_AT_X;
            int y = i / ALERT_WITH_BUTTON_OPTIONS_ICONS_AT_X;
            
            BOOL isLastLine = (y + 1 == totalY);
            int totalXLine = (!isLastLine || hasSingleLine) ? (totalX) : (options.count % totalX);
            
            CGFloat axisX = viewWidth/2 - totalXLine*iconWidth/2 + x*iconWidth +
                            ((1-(totalXLine-2*x))/2.0)*ALERT_WITH_BUTTON_OPTIONS_BUTTONS_SPACE;
            CGFloat axisY = (iconHeight + ALERT_WITH_BUTTON_OPTIONS_BUTTONS_SPACE)*(totalY - y - 1);
            
            NSButton* button = [[NSButton alloc] initWithFrame:NSMakeRect(axisX,axisY,iconWidth,iconHeight)];
            
            NSString* sourceName = options[i];
            NSImage* icon = iconForOption(sourceName);
            BOOL doesNotHaveValidIcon = !icon;
            
            button.tag = false;
            
            [button setTitle:sourceName];
            NSMutableAttributedString* title = [[button attributedTitle] mutableCopy];
            [title adjustExpansionToFitWidth:iconWidth - 10];
            [button setAttributedTitle:title];
            
            CGFloat iconBorder;
            if (doesNotHaveValidIcon)
            {
                [button setBordered:YES];
                [button setImagePosition:NSNoImage];
                iconBorder = ALERT_WITH_BUTTON_OPTIONS_ICON_BORDER_WITH_TEXT;
            }
            else
            {
                [button setBordered:NO];
                [button setImagePosition:NSImageOnly];
                iconBorder = ALERT_WITH_BUTTON_OPTIONS_ICON_BORDER;
            }
            
            NSImage* resultImage;
            
            if (icon)
            {
                resultImage = [[NSImage alloc] initWithSize:NSMakeSize(iconWidth, iconHeight)];
                [resultImage lockFocus];
                
                NSRect newRect = NSMakeRect(ALERT_WITH_BUTTON_OPTIONS_ICON_IMAGE_BORDER/2, ALERT_WITH_BUTTON_OPTIONS_ICON_IMAGE_BORDER/2,
                                            iconWidth - ALERT_WITH_BUTTON_OPTIONS_ICON_IMAGE_BORDER,
                                            iconHeight - ALERT_WITH_BUTTON_OPTIONS_ICON_IMAGE_BORDER);
                [icon drawInRect:newRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
                
                [resultImage unlockFocus];
                [resultImage setSize:NSMakeSize(iconWidth - iconBorder, iconHeight - iconBorder)];
                [button setImage:resultImage];
            }
            
            [button setTarget:self];
            [button setAction:@selector(selectAlertButton:)];
            
            [sourcesView addSubview:button];
        }
        
        [self runThreadSafeModalWithAlert:^NSAlert *
        {
            _alertWithButtonOptions = [NSAlert alertWithMessageText:title
                                                      defaultButton:NSLocalizedString(@"Cancel",nil)
                                                    alternateButton:nil
                                                        otherButton:nil
                                          informativeTextWithFormat:@"%@",message];
            
            [_alertWithButtonOptions setAccessoryView:sourcesView];
            return _alertWithButtonOptions;
        }];
        
        for (NSButton* button in sourcesView.subviews)
        {
            if (button.tag == true) result = [button title];
        }
        
        _alertWithButtonOptions = nil;
    }
    
    return result;
}

@end

