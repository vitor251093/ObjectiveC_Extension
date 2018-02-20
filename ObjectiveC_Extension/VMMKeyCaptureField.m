//
//  VMMKeyCaptureField.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 18/08/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "VMMKeyCaptureField.h"

#import "VMMUsageKeycode.h"
#import "VMMLocalizationUtility.h"

static VMMKeyCaptureField* _activeKeyCaptureField;

@implementation VMMKeyCaptureField

-(void)awakeFromNib
{
    _keyUsageKeycode = -1;
    _activeKeyCaptureField = nil;
}

-(void)startEditing
{
    if (_activeKeyCaptureField)
    {
        if (_activeKeyCaptureField == self) return;
        
        [VMMDeviceObserver.sharedObserver stopObservingForDelegate:_activeKeyCaptureField];
    }
    
    _activeKeyCaptureField = self;
    [VMMDeviceObserver.sharedObserver observeDevicesOfTypes:VMMDeviceObserverTypesKeyboard forDelegate:self];
}
-(void)stopEditing
{
    if (_activeKeyCaptureField == self)
    {
        _activeKeyCaptureField = nil;
    }
    
    [VMMDeviceObserver.sharedObserver stopObservingForDelegate:self];
}

-(BOOL)textShouldBeginEditing:(NSText *)textObject
{
    return false;
}
-(void)textDidEndEditing:(NSNotification *)notification
{
    [self stopEditing];
}

-(BOOL)becomeFirstResponder
{
    BOOL result = [super becomeFirstResponder];
    if (result) [self startEditing];
    return result;
}
-(BOOL)resignFirstResponder
{
    BOOL result = [super resignFirstResponder];
    if (result) [self stopEditing];
    return result;
}

-(void)observedEventWithName:(CFStringRef)name cookie:(IOHIDElementCookie)cookie usage:(uint32_t)usage
                       value:(CFIndex)value device:(IOHIDDeviceRef)device
{
    if (!self.window.isKeyWindow) return;
    if (![[self.window firstResponder] isKindOfClass:NSText.class]) return;
    
    if (_activeKeyCaptureField != self) return;
    if (value != 1) return;
    
    // Exception
    if (usage == 128 && cookie == 242) return; // Logitech G600 Mouse Left-button click
    if (usage == 128 && cookie == 243) return; // Logitech G600 Mouse Middle-button click
    if (usage == 128 && cookie == 244) return; // Logitech G600 Mouse Right-button click
    
    [self setKeyUsageKeycode:usage];
    
    if (_keyCaptureDelegate)
    {
        [_keyCaptureDelegate keyCaptureField:self didChangedKeyUsageKeycode:usage];
    }
}

-(void)setKeyUsageKeycode:(uint32_t)keyUsageKeycode
{
    if (keyUsageKeycode == -1)
    {
        _keyUsageKeycode = -1;
        [self setStringValue:@""];
        return;
    }
    
    _keyUsageKeycode = keyUsageKeycode;
    NSString* keyName = [VMMUsageKeycode nameOfUsageKeycode:keyUsageKeycode];
    [self setStringValue:keyName ? keyName : [NSString stringWithFormat:VMMLocalizedString(@"Unknown Key (%d)"),keyUsageKeycode]];
}

-(IBAction)clearField:(id)sender
{
    _keyUsageKeycode = -1;
    [self setStringValue:@""];
    
    if (_keyCaptureDelegate)
    {
        [_keyCaptureDelegate keyCaptureField:self didChangedKeyUsageKeycode:_keyUsageKeycode];
    }
}

@end

