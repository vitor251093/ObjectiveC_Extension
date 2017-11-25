//
//  NSBundle+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 25/11/2017.
//  Copyright © 2017 VitorMM. All rights reserved.
//

#import "NSBundle+Extension.h"

#include <stdlib.h>

@implementation NSBundle (VMMBundle)

static NSString* bundleName;

-(NSString*)bundleName
{
    if (bundleName != nil) return bundleName;
    
    bundleName = [self objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    if (!bundleName)
    {
        bundleName = [self objectForInfoDictionaryKey:@"CFBundleName"];
    }
    
    if (!bundleName)
    {
        // Reference:
        // https://stackoverflow.com/a/35322073/4370893
        
        bundleName = [NSString stringWithUTF8String:getprogname()];
    }
    
    if (!bundleName)
    {
        NSString* placeholder = @"App";
        NSString* bundlePath = [self bundlePath];
        bundleName = bundlePath ? bundlePath.stringByDeletingPathExtension.lastPathComponent : placeholder;
    }
    
    return bundleName;
}

@end
