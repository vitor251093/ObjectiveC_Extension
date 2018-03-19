//
//  NSArray+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 15/05/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSArray+Extension.h"

@implementation NSArray (VMMArray)

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
