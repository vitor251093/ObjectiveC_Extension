//
//  VMMPropertyList.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 08/03/2018.
//  Copyright © 2018 VitorMM. All rights reserved.
//

#import "VMMPropertyList.h"

@implementation VMMPropertyList

+(nullable id)propertyListWithUnarchivedString:(nonnull NSString*)string
{
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self propertyListWithUnarchivedData:data];
    
}
+(nullable id)propertyListWithUnarchivedData:(nonnull NSData*)data
{
    id propertyList;
    
    NSError *error;
    NSPropertyListFormat format;
    propertyList = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable
                                                              format:&format error:&error];
    if (propertyList == nil || error != nil)
    {
        return nil;
    }
    
    return propertyList;
}

+(nullable id)propertyListWithArchivedString:(nonnull NSString *)string
{
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self propertyListWithArchivedData:data];
}
+(nullable id)propertyListWithArchivedData:(nonnull NSData *)data
{
    @try
    {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException* exception)
    {
        return nil;
    }
}

@end
