//
//  NSArray+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 15/05/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSArray (VMMArray)

-(nonnull NSArray*)sortedDictionariesArrayWithKey:(nonnull NSString *)key orderingByValuesOrder:(nonnull NSArray*)value;

-(nonnull NSArray*)arrayByRemovingRepetitions;

-(nonnull NSArray*)arrayByRemovingObjectsFromArray:(nonnull NSArray*)otherArray;

@end
