//
//  VMMVersion.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 18/09/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "VMMVersion.h"

#import "NSString+Extension.h"

@implementation VMMVersion

+(VMMVersionCompare)compareVersionString:(nonnull NSString*)PK1 withVersionString:(nonnull NSString*)PK2
{
    @autoreleasepool
    {
        NSArray* PKArray1 = [PK1 componentsSeparatedByString:@"."];
        NSArray* PKArray2 = [PK2 componentsSeparatedByString:@"."];
        
        for (int x = 0; x < PKArray1.count && x < PKArray2.count; x++)
        {
            if ([PKArray1[x] initialIntegerValue].intValue < [PKArray2[x] initialIntegerValue].intValue)
                return VMMVersionCompareSecondIsNewest;
            if ([PKArray1[x] initialIntegerValue].intValue > [PKArray2[x] initialIntegerValue].intValue)
                return VMMVersionCompareFirstIsNewest;
        }
        
        if (PKArray1.count < PKArray2.count) return VMMVersionCompareSecondIsNewest;
        if (PKArray1.count > PKArray2.count) return VMMVersionCompareFirstIsNewest;
        
        if (PK1.length > PK2.length) return VMMVersionCompareFirstIsNewest;
        if (PK1.length < PK2.length) return VMMVersionCompareSecondIsNewest;
        
        return VMMVersionCompareSame;
    }
}

@end
