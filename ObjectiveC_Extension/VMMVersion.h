//
//  VMMVersion.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 18/09/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum VMMVersionCompare
{
    VMMVersionCompareFirstIsNewest,
    VMMVersionCompareSecondIsNewest,
    VMMVersionCompareSame
} VMMVersionCompare;

@interface VMMVersion : NSObject

+(VMMVersionCompare)compareVersionString:(NSString*)PK1 withVersionString:(NSString*)PK2;

@end
