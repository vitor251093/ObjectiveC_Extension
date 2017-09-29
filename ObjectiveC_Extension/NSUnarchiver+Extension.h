//
//  NSUnarchiver+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#ifndef NSUnarchiver_Extension_Class
#define NSUnarchiver_Extension_Class

#import <Foundation/Foundation.h>

@interface NSUnarchiver (VMMUnarchiver)

+(id)safeUnarchiveObjectWithData:(NSData*)data;
+(id)safeUnarchiveObjectFromFile:(NSString*)wsiPath;

@end

#endif