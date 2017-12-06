//
//  NSArray+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 15/05/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSArray+Extension.h"

@implementation NSArray (VMMArray)

-(nonnull NSArray*)sortedDictionariesArrayWithKey:(nonnull NSString *)key orderingByValuesOrder:(nonnull NSArray*)value
{
    return [self sortedArrayUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2)
    {
        NSUInteger obj1ValueIndex = [value indexOfObject:obj1[key]];
        NSUInteger obj2ValueIndex = [value indexOfObject:obj2[key]];
        
        if (obj1ValueIndex == -1 && obj2ValueIndex != -1) return NSOrderedDescending;
        if (obj1ValueIndex != -1 && obj2ValueIndex == -1) return NSOrderedAscending;
        if (obj1ValueIndex == -1 && obj2ValueIndex == -1) return NSOrderedSame;
        
        if (obj1ValueIndex > obj2ValueIndex) return NSOrderedDescending;
        if (obj1ValueIndex < obj2ValueIndex) return NSOrderedAscending;
        return NSOrderedSame;
    }];
}

-(nonnull NSArray*)arrayByRemovingRepetitions
{
    return [NSSet setWithArray:self].allObjects;
}

-(nonnull NSArray*)arrayByRemovingObjectsFromArray:(nonnull NSArray*)otherArray
{
    NSMutableArray* newArray = [self mutableCopy];
    
    [newArray removeObjectsInArray:otherArray];
    
    return newArray;
}

@end
