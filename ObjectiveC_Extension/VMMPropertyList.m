//
//  VMMPropertyList.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 08/03/2018.
//  Copyright © 2018 VitorMM. All rights reserved.
//

#import "VMMPropertyList.h"

@implementation VMMPropertyList

+(nullable id)propertyListWithUnarchivedString:(NSString*)string
{
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
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

+(nullable id)propertyListWithArchivedString:(NSString *)string
{
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    id propertyList;
    
    @try
    {
        propertyList = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException* exception)
    {
        return nil;
    }
    
    return propertyList;
}

@end
