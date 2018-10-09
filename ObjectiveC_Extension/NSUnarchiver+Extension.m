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

+(nullable id)safeUnarchiveObjectWithData:(nonnull NSData*)data
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
+(nullable id)safeUnarchiveObjectFromFile:(nonnull NSString*)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return nil;
    
    id contents = nil;
    
    @autoreleasepool
    {
        NSData* data = [NSData safeDataWithContentsOfFile:path];
        if (!data || data.length == 0) return nil;
        
        contents = [self safeUnarchiveObjectWithData:data];
    }
        
    return contents;
}

@end
