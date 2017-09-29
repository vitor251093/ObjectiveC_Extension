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
    
    NSArray* input  = @[@{key: @"PCIe"}, @{key: @"Built-In"}, @{key: @"PCI"}];
    NSArray* output = @[@{key: @"PCIe"}, @{key: @"PCI"}, @{key: @"Built-In"}];
    
    XCTAssert([[input sortedDictionariesArrayWithKey:key orderingByValuesOrder:order] isEqualToArray:output]);
}

@end
