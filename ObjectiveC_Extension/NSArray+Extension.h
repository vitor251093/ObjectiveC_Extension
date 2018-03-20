//
//  NSArray+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 15/05/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSArray (VMMArray)

-(nonnull NSArray*)arrayByRemovingRepetitions;
-(nonnull NSArray*)arrayByRemovingObjectsFromArray:(nonnull NSArray*)otherArray;

-(NSIndexSet* _Nonnull)indexesOfObject:(id _Nonnull)object inRange:(NSRange)range;
-(NSIndexSet* _Nonnull)indexesOfObject:(id _Nonnull)object;

-(NSInteger)lastIndexOfObject:(id _Nonnull)object inRange:(NSRange)range;

-(void)differencesFromArray:(NSArray* _Nonnull)otherArray indexPaths:(void (^_Nonnull)(NSArray<NSIndexSet*>* _Nonnull addedIndexes, NSArray<NSIndexSet*>* _Nonnull removedIndexes))indexPaths;

@end
