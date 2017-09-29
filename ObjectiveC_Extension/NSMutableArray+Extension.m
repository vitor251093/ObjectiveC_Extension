//
//  NSMutableArray+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 24/07/2017.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSMutableArray+Extension.h"

@implementation NSMutableArray (VMMMutableArray)

-(void)sortAlphabeticallyByKey:(NSString*)key ascending:(BOOL)ascending
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending selector:@selector(caseInsensitiveCompare:)];
    [self sortUsingDescriptors:@[sort]];
}
-(void)sortAlphabeticallyAscending:(BOOL)ascending
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:ascending selector:@selector(caseInsensitiveCompare:)];
    [self sortUsingDescriptors:@[sort]];
}

-(void)replaceObjectsWithVariation:(id (^)(id object, NSUInteger index))newObjectForObject
{
    for (NSUInteger index = 0; index < self.count; index++)
    {
        id newObject = newObjectForObject([self objectAtIndex:index], index);
        [self replaceObjectAtIndex:index withObject:newObject ? newObject : [NSNull null]];
    }
}

@end
