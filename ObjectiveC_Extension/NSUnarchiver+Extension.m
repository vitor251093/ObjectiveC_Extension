//
//  NSUnarchiver+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 22/02/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSUnarchiver+Extension.h"

#import "NSData+Extension.h"

@implementation NSUnarchiver (VMMUnarchiver)

+(id)safeUnarchiveObjectWithData:(NSData*)data
{
    @try
    {
        return [self unarchiveObjectWithData:data];
    }
    @catch (NSException *exception)
    {
        return nil;
    }
}
+(id)safeUnarchiveObjectFromFile:(NSString*)wsiPath
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:wsiPath]) return nil;
    
    id contents = nil;
    
    @autoreleasepool
    {
        NSData* wsiData = [NSData safeDataWithContentsOfFile:wsiPath];
        if (!wsiData || wsiData.length == 0) return nil;
        
        NSString* wsiString = [[NSString alloc] initWithData:wsiData encoding:NSUTF8StringEncoding];
        if (wsiString && [wsiString hasPrefix:@"<html>"]) return nil;
        
        contents = [self safeUnarchiveObjectWithData:wsiData];
    }
        
    return contents;
}

@end
