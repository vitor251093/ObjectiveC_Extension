//
//  NSText+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSText+Extension.h"

#import "NSMutableAttributedString+Extension.h"

#import "NSComputerInformation.h"

@implementation NSText (VMMText)
-(void)setSelectedRangeHasTheEndOfTheField
{
    [self setSelectedRange:NSMakeRange(self.string.length,0)];
}
@end

@implementation NSTextView (VMMTextView)
-(void)setAttributedString:(NSAttributedString*)string withColor:(NSColor*)color
{
    NSMutableAttributedString* str = string ? [string mutableCopy] : [[NSMutableAttributedString alloc] init];
    
    [self scrollRangeToVisible:NSMakeRange(0,0)];
    [self setSelectedRange:NSMakeRange(0, 0)];
    
    [str setFontColor:color];
    [str setTextAlignment:IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR ? NSTextAlignmentJustified : kCTJustifiedTextAlignment];
    
    [[self textStorage] setAttributedString:str];
}
@end

@implementation NSTextField (VMMTextField)
-(void)setSelectedRangeHasTheEndOfTheField
{
    [[self currentEditor] setSelectedRangeHasTheEndOfTheField];
}
-(void)setAnyStringValue:(NSString*)stringValue
{
    [self setStringValue:stringValue ? stringValue : @""];
}
@end
