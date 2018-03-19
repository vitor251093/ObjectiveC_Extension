//
//  NSMutableArray+Extension.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 24/07/2017.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import "NSMutableArray+Extension.h"

@implementation NSMutableArray (VMMMutableArray)

-(void)sortAlphabeticallyByKey:(nonnull NSString*)key ascending:(BOOL)ascending
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending selector:@selector(caseInsensitiveCompare:)];
    [self sortUsingDescriptors:@[sort]];
}
-(void)sortAlphabeticallyAscending:(BOOL)ascending
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:ascending selector:@selector(caseInsensitiveCompare:)];
    [self sortUsingDescriptors:@[sort]];
}

-(void)replaceObjectsWithVariation:(_Nullable id (^_Nonnull)(id _Nonnull object, NSUInteger index))newObjectForObject
{
    for (NSUInteger index = 0; index < self.count; index++)
    {
        id newObject = newObjectForObject([self objectAtIndex:index], index);
        [self replaceObjectAtIndex:index withObject:newObject ? newObject : [NSNull null]];
    }
}

-(void)sortBySelector:(SEL _Nonnull)selector inOrder:(NSArray* _Nonnull)order
{
    [self sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
     {
         NSUInteger obj1ValueIndex;
         NSUInteger obj2ValueIndex;
         
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
         if ([obj1 respondsToSelector:selector])
         {
             obj1ValueIndex = [obj1 performSelector:selector] != nil ? [order indexOfObject:[obj1 performSelector:selector]] : -1;
         }
         else
         {
             obj1ValueIndex = -1;
         }
         
         if ([obj2 respondsToSelector:selector])
         {
             obj2ValueIndex = [obj2 performSelector:selector] != nil ? [order indexOfObject:[obj2 performSelector:selector]] : -1;
         }
         else
         {
             obj2ValueIndex = -1;
         }
#pragma clang diagnostic pop
         
         if (obj1ValueIndex == -1 && obj2ValueIndex != -1) return NSOrderedDescending;
         if (obj1ValueIndex != -1 && obj2ValueIndex == -1) return NSOrderedAscending;
         if (obj1ValueIndex == -1 && obj2ValueIndex == -1) return NSOrderedSame;
         
         if (obj1ValueIndex > obj2ValueIndex) return NSOrderedDescending;
         if (obj1ValueIndex < obj2ValueIndex) return NSOrderedAscending;
         return NSOrderedSame;
     }];
}


@end
