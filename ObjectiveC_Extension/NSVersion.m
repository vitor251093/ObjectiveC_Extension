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

+(NSVersionCompare)compareVersionString:(NSString*)PK1 withVersionString:(NSString*)PK2
{
    NSArray* PKArray1 = [PK1 componentsSeparatedByString:@"."];
    NSArray* PKArray2 = [PK2 componentsSeparatedByString:@"."];
    
    for (int x = 0; x < PKArray1.count && x < PKArray2.count; x++)
    {
        if ([PKArray1[x] initialIntegerValue].intValue < [PKArray2[x] initialIntegerValue].intValue) return NSVersionCompareSecondIsNewest;
        if ([PKArray1[x] initialIntegerValue].intValue > [PKArray2[x] initialIntegerValue].intValue) return NSVersionCompareFirstIsNewest;
    }
    
    if (PKArray1.count < PKArray2.count) return NSVersionCompareSecondIsNewest;
    if (PKArray1.count > PKArray2.count) return NSVersionCompareFirstIsNewest;
    
    if (PK1.length > PK2.length) return NSVersionCompareFirstIsNewest;
    if (PK1.length < PK2.length) return NSVersionCompareSecondIsNewest;
    
    return NSVersionCompareSame;
}

@end
