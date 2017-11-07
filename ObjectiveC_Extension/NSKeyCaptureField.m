//
//  NSKeyCaptureField.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 18/08/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSKeyCaptureField.h"

#import "VMMUsageKeycode.h"

static NSKeyCaptureField* _activeKeyCaptureField;

@implementation NSKeyCaptureField

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
        
        [IODeviceObserver.sharedObserver stopObservingForDelegate:_activeKeyCaptureField];
    }
    
    _activeKeyCaptureField = self;
    [IODeviceObserver.sharedObserver observeDevicesOfTypes:IODeviceObserverTypesKeyboard forDelegate:self];
}
-(void)stopEditing
{
    if (_activeKeyCaptureField == self)
    {
        _activeKeyCaptureField = nil;
    }
    
    [IODeviceObserver.sharedObserver stopObservingForDelegate:self];
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

-(void)observedEventWithCookie:(IOHIDElementCookie)event andUsage:(uint32_t)usage
                     withValue:(CFIndex)value fromDevice:(IOHIDDeviceRef)device
{
    if (!self.window.isKeyWindow) return;
    if (![[self.window firstResponder] isKindOfClass:NSText.class]) return;
    
    if (_activeKeyCaptureField != self) return;
    if (value != 1) return;
    
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
    [self setStringValue:keyName ? keyName : [NSString stringWithFormat:@"Unknown Key (%d)",keyUsageKeycode]];
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

