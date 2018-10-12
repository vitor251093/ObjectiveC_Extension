//
//  NSColor+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 31/08/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSColor+Extension.h"
#import "NSException+Extension.h"

NSColor* _Nullable RGBA(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
    return [NSColor colorWithDeviceRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0];
}

NSColor* _Nullable RGB(CGFloat r, CGFloat g, CGFloat b)
{
    return RGBA(r,g,b,255.0);
}

@implementation NSColor (VMMColor)

+(nullable NSColor*)colorWithHexColorString:(nonnull NSString*)inColorString
{
    NSColor* result = nil;
    
    @autoreleasepool
    {
        unsigned colorCode = 0;
        unsigned char redByte, greenByte, blueByte;
        
        if (inColorString.length == 7 && [inColorString hasPrefix:@"#"])
        {
            inColorString = [inColorString substringFromIndex:1];
        }
        
        if (inColorString.length != 6)
        {
            @throw exception(NSInvalidArgumentException,
                             @"colorWithHexColorString: only accepts hexadecimal colors, with 6 or 7 characters (eg. 000000 or #000000)");
        }
        
        NSScanner* scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
        
        redByte = (unsigned char)(colorCode >> 16);
        greenByte = (unsigned char)(colorCode >> 8);
        blueByte = (unsigned char)(colorCode); // masks off high bits
        
        result = RGB((CGFloat)redByte, (CGFloat)greenByte, (CGFloat)blueByte);
    }
    
    return result;
}
-(nullable NSString*)hexColorString
{
    NSString* result = nil;
    
    @autoreleasepool
    {
        // https://developer.apple.com/library/content/qa/qa1576/_index.html
        
        NSString *redHexValue,  *greenHexValue,  *blueHexValue;
        CGFloat   redFloatValue, greenFloatValue, blueFloatValue;
        int        redIntValue,  greenIntValue,   blueIntValue;
        
        NSColor *convertedColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
        
        if (convertedColor != nil)
        {
            [convertedColor getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:NULL];
            
            redIntValue   = redFloatValue   * 255.99999f;
            greenIntValue = greenFloatValue * 255.99999f;
            blueIntValue  = blueFloatValue  * 255.99999f;
            
            redHexValue   = [NSString stringWithFormat:@"%02x", redIntValue];
            greenHexValue = [NSString stringWithFormat:@"%02x", greenIntValue];
            blueHexValue  = [NSString stringWithFormat:@"%02x", blueIntValue];
            
            result = [NSString stringWithFormat:@"%@%@%@", redHexValue, greenHexValue, blueHexValue];
        }
    }
    
    return result;
}

@end
