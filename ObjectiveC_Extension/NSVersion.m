//
//  NSVersion.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 18/09/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSVersion.h"

#import "NSString+Extension.h"

@implementation NSVersion

// NSOrderedSame:       They are the same
// NSOrderedAscending:  The one in the left is bigger
// NSOrderedDescending: The one in the right is bigger
+(NSComparisonResult)compareVersionString:(NSString*)PK1 withVersionString:(NSString*)PK2
{
    NSArray* PKArray1 = [PK1 componentsSeparatedByString:@"."];
    NSArray* PKArray2 = [PK2 componentsSeparatedByString:@"."];
    
    for (int x = 0; x < PKArray1.count && x < PKArray2.count; x++)
    {
        if ([PKArray1[x] initialIntegerValue].intValue < [PKArray2[x] initialIntegerValue].intValue) return NSOrderedDescending;
        if ([PKArray1[x] initialIntegerValue].intValue > [PKArray2[x] initialIntegerValue].intValue) return NSOrderedAscending;
    }
    
    if (PKArray1.count < PKArray2.count) return NSOrderedDescending;
    if (PKArray1.count > PKArray2.count) return NSOrderedAscending;
    
    if (PK1.length > PK2.length) return NSOrderedAscending;
    if (PK1.length < PK2.length) return NSOrderedDescending;
    
    return NSOrderedSame;
}

@end
