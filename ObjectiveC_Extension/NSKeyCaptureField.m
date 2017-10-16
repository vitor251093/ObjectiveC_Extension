//
//  NSKeyCaptureField.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 18/08/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSKeyCaptureField.h"

#import "IOUsageKeycode.h"

static NSKeyCaptureField* _activeKeyCaptureField;

@implementation NSKeyCaptureField

-(void)awakeFromNib
{
    _keyUsage = -1;
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
    
    [self setKeyUsage:usage];
    
    if (_keyCaptureDelegate)
    {
        [_keyCaptureDelegate keyCaptureField:self didChangedKeyUsage:usage];
    }
}

-(void)setKeyUsage:(uint32_t)keyUsage
{
    if (keyUsage == -1)
    {
        _keyUsage = -1;
        [self setStringValue:@""];
        return;
    }
    
    _keyUsage = keyUsage;
    NSString* keyName = [IOUsageKeycode nameOfUsageKeycode:keyUsage];
    [self setStringValue:keyName ? keyName : [NSString stringWithFormat:@"Unknown Key (%d)",keyUsage]];
}

-(IBAction)clearField:(id)sender
{
    _keyUsage = -1;
    [self setStringValue:@""];
    
    if (_keyCaptureDelegate)
    {
        [_keyCaptureDelegate keyCaptureField:self didChangedKeyUsage:_keyUsage];
    }
}

@end

