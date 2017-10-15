//
//  NSImage+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 12/03/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#ifndef NSImage_Extension_Class
#define NSImage_Extension_Class

#import <Cocoa/Cocoa.h>

@interface NSImage (VMMImage)

+(NSImage*)imageWithData:(NSData*)data;

+(NSImage*)quickLookImageFromFileAtPath:(NSString*)arquivo;
+(NSImage*)imageFromFileAtPath:(NSString*)arquivo;

+(NSImage*)transparentImageWithSize:(NSSize)size;

-(BOOL)saveAsIcnsAtPath:(NSString*)icnsPath;

-(BOOL)writeToFile:(NSString*)file atomically:(BOOL)useAuxiliaryFile;

@end

#endif
