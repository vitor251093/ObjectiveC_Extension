//
//  NSArrayTests.m
//  ObjectiveC_Extension
//
//  Created by Vitor Marques de Miranda on 15/05/17.
//  Copyright © 2017 Vitor Marques de Miranda. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSArray+Extension.h"

@interface NSArrayTests : XCTestCase

@end

@implementation NSArrayTests

- (void)testSortedDictionariesArrayWithKeyOrderingByValuesOrder
{
    NSString* key   = @"Bus";
    NSArray* order  = @[@"PCIe", @"PCI", @"Built-In"];
    
    NSMutableArray* input = [@[@{key: @"PCIe"}, @{key: @"Built-In"}, @{key: @"PCI"}] mutableCopy];
    NSArray* output       =  @[@{key: @"PCIe"}, @{key: @"PCI"}, @{key: @"Built-In"}];
    
    [input sortDictionariesWithKey:key orderingByValuesOrder:order];
    XCTAssert([input isEqualToArray:output]);
}

- (void)testArrayByRemovingRepetitions_noChange
{
    NSArray* originalArray = @[@1,@2,@3,@4,@5,@6];
    NSArray* resultArray = [originalArray arrayByRemovingRepetitions];
    
    XCTAssert(resultArray.count == 6);
    XCTAssert([resultArray containsObject:@1]);
    XCTAssert([resultArray containsObject:@2]);
    XCTAssert([resultArray containsObject:@3]);
    XCTAssert([resultArray containsObject:@4]);
    XCTAssert([resultArray containsObject:@5]);
    XCTAssert([resultArray containsObject:@6]);
}
- (void)testArrayByRemovingRepetitions_fromSixToThreeResults
{
    NSArray* originalArray = @[@1,@2,@1,@2,@1,@4];
    NSArray* resultArray = [originalArray arrayByRemovingRepetitions];
    
    XCTAssert(resultArray.count == 3);
    XCTAssert([resultArray containsObject:@1]);
    XCTAssert([resultArray containsObject:@2]);
    XCTAssert([resultArray containsObject:@4]);
}
- (void)testArrayByRemovingRepetitions_oneResultOnly
{
    NSArray* originalArray = @[@1,@1,@1,@1,@1,@1];
    NSArray* resultArray = [originalArray arrayByRemovingRepetitions];
    
    XCTAssert(resultArray.count == 1);
    XCTAssert([resultArray containsObject:@1]);
}

- (void)testArrayByRemovingObjectsFromArray_removeTwoFromFive
{
    NSArray* originalArray = @[@1,@2,@3,@4,@5];
    NSArray* itemsToRemove = @[@2,@5];
    NSArray* result = [originalArray arrayByRemovingObjectsFromArray:itemsToRemove];
    
    XCTAssert(resultArray.count == 3);
    XCTAssert([resultArray containsObject:@1]);
    XCTAssert([resultArray containsObject:@3]);
    XCTAssert([resultArray containsObject:@4]);
}
- (void)testArrayByRemovingObjectsFromArray_removeAll
{
    NSArray* originalArray = @[@1,@2,@3,@4,@5];
    NSArray* itemsToRemove = @[@4,@3,@2,@1,@5];
    NSArray* result = [originalArray arrayByRemovingObjectsFromArray:itemsToRemove];
    
    XCTAssert(resultArray.count == 0);
}
- (void)testArrayByRemovingObjectsFromArray_removeNothing
{
    NSArray* originalArray = @[@1,@2,@3,@4,@5];
    NSArray* itemsToRemove = @[@7,@8];
    NSArray* result = [originalArray arrayByRemovingObjectsFromArray:itemsToRemove];
    
    XCTAssert(resultArray.count == 5);
    XCTAssert([resultArray containsObject:@1]);
    XCTAssert([resultArray containsObject:@2]);
    XCTAssert([resultArray containsObject:@3]);
    XCTAssert([resultArray containsObject:@4]);
    XCTAssert([resultArray containsObject:@5]);
}

@end
