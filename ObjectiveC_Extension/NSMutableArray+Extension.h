//
//  NSMutableArray+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 24/07/2017.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray<ObjectType> (VMMMutableArray)

-(void)sortAlphabeticallyByKey:(nonnull NSString*)key ascending:(BOOL)ascending;
-(void)sortAlphabeticallyAscending:(BOOL)ascending;
-(void)sortDictionariesWithKey:(nonnull NSString *)key orderingByValuesOrder:(nonnull NSArray*)value;

-(instancetype)map:(_Nullable id (^_Nonnull)(id _Nonnull object))newObjectForObject;
-(instancetype)mapWithIndex:(_Nullable id (^_Nonnull)(id _Nonnull object, NSUInteger index))newObjectForObject;
-(instancetype)filter:(BOOL (^_Nonnull)(id _Nonnull object))newObjectForObject;
-(instancetype)filterWithIndex:(BOOL (^_Nonnull)(id _Nonnull object, NSUInteger index))newObjectForObject;

-(void)sortBySelector:(SEL _Nonnull)selector inOrder:(NSArray* _Nonnull)order;

@end
