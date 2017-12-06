//
//  NSColor+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 31/08/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define RGBA(r,g,b,a) [NSColor colorWithDeviceRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0]
#define RGB(r,g,b)    RGBA(r,g,b,255.0)

@interface NSColor (VMMColor)

+(nullable NSColor*)colorWithHexColorString:(nonnull NSString*)inColorString;
-(nullable NSString*)hexColorString;

@end
