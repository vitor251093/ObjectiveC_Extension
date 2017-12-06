//
//  NSMutableArray+Extension.h
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 24/07/2017.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (VMMMutableArray)

-(void)sortAlphabeticallyByKey:(nonnull NSString*)key ascending:(BOOL)ascending;
-(void)sortAlphabeticallyAscending:(BOOL)ascending;

-(void)replaceObjectsWithVariation:(nullable id (^)(id object, NSUInteger index))newObjectForObject;

@end
