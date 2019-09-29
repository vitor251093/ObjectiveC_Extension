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
-(void)sortDictionariesWithKey:(nonnull NSString *)key orderingByValuesOrder:(nonnull NSArray*)value
{
    [self sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2)
    {
        NSUInteger obj1ValueIndex = obj1[key] != nil ? [value indexOfObject:obj1[key]] : -1;
        NSUInteger obj2ValueIndex = obj2[key] != nil ? [value indexOfObject:obj2[key]] : -1;
         
        if (obj1ValueIndex == -1 && obj2ValueIndex != -1) return NSOrderedDescending;
        if (obj1ValueIndex != -1 && obj2ValueIndex == -1) return NSOrderedAscending;
        if (obj1ValueIndex == -1 && obj2ValueIndex == -1) return NSOrderedSame;
         
        if (obj1ValueIndex > obj2ValueIndex) return NSOrderedDescending;
        if (obj1ValueIndex < obj2ValueIndex) return NSOrderedAscending;
        return NSOrderedSame;
    }];
}

-(void)sortBySelector:(SEL _Nonnull)selector inOrder:(NSArray* _Nonnull)order
{
    [self sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
    {
         NSUInteger obj1ValueIndex = -1;
         NSUInteger obj2ValueIndex = -1;
         
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
         if ([obj1 respondsToSelector:selector])
         {
             id obj1ReturnedValue = [obj1 performSelector:selector];
             if (obj1ReturnedValue != nil) obj1ValueIndex = [order indexOfObject:obj1ReturnedValue];
         }
         
         if ([obj2 respondsToSelector:selector])
         {
             id obj2ReturnedValue = [obj2 performSelector:selector];
             if (obj2ReturnedValue != nil) obj2ValueIndex = [order indexOfObject:obj2ReturnedValue];
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
