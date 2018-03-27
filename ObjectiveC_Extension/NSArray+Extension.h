//
//  NSArray+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 15/05/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSArray<ObjectType> (VMMArray)

-(nonnull NSArray<ObjectType>*)arrayByRemovingRepetitions;
-(nonnull NSArray<ObjectType>*)arrayByRemovingObjectsFromArray:(nonnull NSArray<ObjectType>*)otherArray;

-(NSIndexSet* _Nonnull)indexesOfObject:(ObjectType _Nonnull)object inRange:(NSRange)range;
-(NSIndexSet* _Nonnull)indexesOfObject:(ObjectType _Nonnull)object;

-(NSInteger)lastIndexOfObject:(ObjectType _Nonnull)object inRange:(NSRange)range;

-(void)differencesFromArray:(NSArray<ObjectType>* _Nonnull)otherArray indexPaths:(void (^_Nonnull)(NSArray<NSIndexSet*>* _Nonnull addedIndexes, NSArray<NSIndexSet*>* _Nonnull removedIndexes))indexPaths;

@end
