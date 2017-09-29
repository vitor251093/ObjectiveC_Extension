//
//  NSArray+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 15/05/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSArray (VMMArray)

-(NSArray*)sortedDictionariesArrayWithKey:(NSString *)key orderingByValuesOrder:(NSArray*)value;

-(NSArray*)arrayByRemovingRepetitions;

-(NSArray*)arrayByRemovingObjectsFromArray:(NSArray*)otherArray;

@end
